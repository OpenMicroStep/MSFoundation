/*
 
 _MHSSLSocket.m
 
 This file is is a part of the MicroStep Application Server over Http Framework.
 
 Initial copyright LOGITUD Solutions (logitud@logitud.fr) since 2012
 
 Herve Malaingre : herve@malaingre.com
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 Geoffrey Guilbon : gguilbon@gmail.com
 
 
 This software is a computer program whose purpose is to [describe
 functionalities and technical features of your software].
 
 This software is governed by the CeCILL-C license under French law and
 abiding by the rules of distribution of free software.  You can  use,
 modify and/ or redistribute the software under the terms of the CeCILL-C
 license as circulated by CEA, CNRS and INRIA at the following URL
 "http://www.cecill.info".
 
 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability.
 
 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or
 data to be ensured and,  more generally, to use and operate it in the
 same conditions as regards security.
 
 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL-C license and that you accept its terms.
 
 A Special homage to Steve Jobs who permits the Objective-C technology
 to meet the world. Without him, this years-long work should not have
 been existing at all. Thank you Steve and rest in peace.
 
 */

#import "_MASHPrivate.h"

@implementation MHSSLSocket (Private)

- (void)dealloc
{
    [self close] ;
    [super dealloc] ;
}

- (SSL *)SSLSocket { return _secureSocket ; }
- (MSInt)localPort { return _localPort ; }


// On error, close the socket and return -1
- (MSInt)readHeadersIn:(void *)buf length:(MSUInt)length
{
    MSInt read_bytes = 0 ;
    MSInt len ;
    int err = 0;
    int sockstate;

    if (_secureSocket == NULL) { return -1; }

    do {
        len = OPENSSL_SSL_read(_secureSocket, buf, length);
        err = OPENSSL_SSL_get_error(_secureSocket, len);
        
        switch (err) {
            case SSL_ERROR_WANT_READ:
                sockstate = MHCheckSocketState(_socket, 0);
                break;
            case SSL_ERROR_WANT_WRITE:
                sockstate = MHCheckSocketState(_socket, 1);
                break;
            case SSL_ERROR_SYSCALL:
                // NSLog(@"writeBytes:length: SSL_ERROR_SYSCALL : %@", MSGetOpenSSLErrStr());
            case SSL_ERROR_SSL:
                // A SSL protocol error occured, we don't want to deal with the data.
            case SSL_ERROR_ZERO_RETURN:
                // Client closed the SSL connection
                [self close];
                return -1;
            default:
                sockstate = SOCKET_OPERATION_OK;
                break;
        }
        
        if (sockstate == SOCKET_HAS_TIMED_OUT ||
            sockstate == SOCKET_IS_NONBLOCKING ||
            sockstate == SOCKET_HAS_BEEN_CLOSED) {
            // Connection timed out
            [self close];
            return -1 ;
        }
    } while (err == SSL_ERROR_WANT_READ || err == SSL_ERROR_WANT_WRITE);

    if(len < 0) {
        MHServerLogWithLevel(MHLogWarning, @"MHSSLSocket readHeadersIn:length: failed") ;
        [self close];
        return -1 ;
    }
    
    read_bytes += len ;
    if (len == 1 && len < length) // Some browsers like Google Chrome sends a single byte first
    {
        do {
            len = OPENSSL_SSL_read(_secureSocket, buf + read_bytes, length - read_bytes);
            err = OPENSSL_SSL_get_error(_secureSocket, len);
            
            switch (err) {
                case SSL_ERROR_WANT_READ:
                    sockstate = MHCheckSocketState(_socket, 0);
                    break;
                case SSL_ERROR_WANT_WRITE:
                    sockstate = MHCheckSocketState(_socket, 1);
                    break;
                case SSL_ERROR_SYSCALL:
                    // NSLog(@"writeBytes:length: SSL_ERROR_SYSCALL : %@", MSGetOpenSSLErrStr());
                case SSL_ERROR_SSL:
                    // A SSL protocol error occured, we don't want to deal with the data.
                case SSL_ERROR_ZERO_RETURN:
                    // Client closed the SSL connection
                    [self close];
                    return -1;
                default:
                    sockstate = SOCKET_OPERATION_OK;
                    break;
            }

            if (sockstate == SOCKET_HAS_TIMED_OUT ||
                sockstate == SOCKET_IS_NONBLOCKING ||
                sockstate == SOCKET_HAS_BEEN_CLOSED) {
                // Connection timed out
                [self close];
                return -1 ;
            }
        } while (err == SSL_ERROR_WANT_READ || err == SSL_ERROR_WANT_WRITE);
        read_bytes += len ;
    }
    return read_bytes ;
}

- (void)close
{
    if (_secureSocket) {
        SOCKET socket = [self socket] ;

        if (!OPENSSL_SSL_get_shutdown(_secureSocket)) {
            MSInt err, shutdown ;
            do {
                shutdown = OPENSSL_SSL_shutdown(_secureSocket) ;
                err = OPENSSL_SSL_get_error(_secureSocket, shutdown);
                
            } while (!_isBlockingIO && shutdown != 1 && (err == SSL_ERROR_WANT_READ || err == SSL_ERROR_WANT_WRITE)) ;
        }
        OPENSSL_SSL_free(_secureSocket) ;
        _secureSocket = NULL ;
        _ssl_ctx = NULL ;
        
        MHCloseSocket(socket) ;
    }
}

- (MSUInt)singleNonBlockingReadIn:(void *)buf length:(MSUInt)length
{
    MSInt len ;
    int err ;
    
    if(_isBlockingIO) { MSRaise(NSInternalInconsistencyException, @"singleNonBlockingReadIn:length: MHSSLSocket must be non-blocking") ; }
    
    len = OPENSSL_SSL_read(_secureSocket, buf, length);
    err = OPENSSL_SSL_get_error(_secureSocket, len);
    
    return err ? 0 : len ;
}

- (MSCertificate *)getPeerCertificate {
    X509 *peerCert = OPENSSL_SSL_get_peer_certificate(_secureSocket) ;
    if(peerCert) {
        return [MSCertificate certificateWithX509:peerCert] ;
    }
    return nil ;
}

@end


//ssl authentication modes
static int __mh_ssl_oneWay_auth_id_ctx = 1 ;
static int __mh_ssl_twoWay_auth_id_ctx = 2 ;

@implementation MHSSLServerSocket

- (void)dealloc
{
    [self close] ;
    [super dealloc] ;
}

+ (id)sslSocketWithContext:(SSL_CTX *)ctx andSocket:(SOCKET)sd isBlockingIO:(BOOL)isBlockingIO
{
    return [[[self alloc] initWithContext:ctx andSocket:sd isBlockingIO:isBlockingIO] autorelease] ;
}

- (id)initWithContext:(SSL_CTX *)ctx andSocket:(SOCKET)sd isBlockingIO:(BOOL)isBlockingIO {
    struct sockaddr_in sin ;
#ifdef WO451
    int addrlen = sizeof(sin) ;
#else
    socklen_t addrlen = sizeof(sin) ;
#endif
    _ssl_ctx = ctx ;
    _secureSocket = OPENSSL_SSL_new(_ssl_ctx);
    OPENSSL_SSL_set_fd(_secureSocket, sd);
    _socket = sd ;
    _isBlockingIO = isBlockingIO ;
    
    if(getsockname(_socket, (struct sockaddr *)&sin, &addrlen) == 0 && sin.sin_family == AF_INET && addrlen == sizeof(sin))
    {
        _localPort = ntohs(sin.sin_port) ;
    }
    
    return self ;
}

+ (int)oneWayAuthCtxID { return __mh_ssl_oneWay_auth_id_ctx ; }
+ (int)twoWayAuthCtxID { return __mh_ssl_twoWay_auth_id_ctx ; }

- (BOOL)accept
{
    int err ;
    int accept ;
    
    do {
        accept = OPENSSL_SSL_accept(_secureSocket) ;
        err = OPENSSL_SSL_get_error(_secureSocket, accept);
        
    } while (!_isBlockingIO && accept < 0 && (err == SSL_ERROR_WANT_READ || err == SSL_ERROR_WANT_WRITE)) ;
    
    if (accept != 1) {
        MHServerLogWithLevel(MHLogInfo, @"MHSSLSocket accept : SSL_accept() : %@", MSGetOpenSSL_SSLErrStr(_secureSocket, err)) ;
        [self close] ;
    }
    
    return accept == 1 ;
}

@end
