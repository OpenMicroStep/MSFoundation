//
//  MHSSLSocket.m
//  MSFoundation
//
//  Created by Geoffrey Guilbon on 28/06/13.
//
//

#import "_MASHPrivate.h"

// writing: 0 = read; 1 = write, 2 = connect
int MHCheckSocketState(int sock_fd, int writing)
{
	fd_set rset, wset;
	struct timeval tv = {5, 0};
	int rc = 0;
    
	if (sock_fd < 0) return SOCKET_HAS_BEEN_CLOSED;
    
	FD_ZERO(&rset);
	FD_SET(sock_fd, &rset);
	wset = rset;
    
	switch (writing)
	{
		case 0:
            rc = select(sock_fd+1, &rset, NULL, NULL, &tv);
            break;
		case 1:
            rc = select(sock_fd+1, NULL, &wset, NULL, &tv);
            break;
		case 2:
            rc = select(sock_fd+1, &rset, &wset, NULL, &tv);
            break;
	}
    
    // Return SOCKET_TIMED_OUT on timeout, SOCKET_OPERATION_OK otherwise
    if(rc < 0)
    {
        MSRaise(NSGenericException, @"select  returns -1") ;
    }
 	return rc == 0 ? SOCKET_HAS_TIMED_OUT : SOCKET_OPERATION_OK;
}

@implementation MHSSLSocket

- (SOCKET)socket { return _socket ; }

- (BOOL)isBlocking { return _isBlockingIO ; }

- (BOOL)writeBytes:(const void *)bytes length:(MSUInt)length
{
#warning TODO WRITE SPLIT
    int write = 0 ;
    int err = 0;
    int sockstate;
    
    if (!_secureSocket) { return NO; }
    
    if(_isBlockingIO)
    {
        write = OPENSSL_SSL_write(_secureSocket, bytes, length) ;
        err = OPENSSL_SSL_get_error(_secureSocket, write);
    } else
    {
        do {
            write = OPENSSL_SSL_write(_secureSocket, bytes, length) ;
            err = OPENSSL_SSL_get_error(_secureSocket, write);
            
            switch (err) {
                case SSL_ERROR_WANT_READ:
//                    sockstate = MHCheckSocketState(_socket, 0);
                    break;
                case SSL_ERROR_WANT_WRITE:
//                    sockstate = MHCheckSocketState(_socket, 1);
                    break;
                case SSL_ERROR_SYSCALL:
                    // NSLog(@"writeBytes:length: SSL_ERROR_SYSCALL : %@", MSGetOpenSSLErrStr());
                case SSL_ERROR_SSL:
                    // A SSL protocol error occured, we don't want to deal with the data.
                case SSL_ERROR_ZERO_RETURN:
                    // Client closed the SSL connection
                    [self close];
                    return NO;
                default:
                    sockstate = SOCKET_OPERATION_OK;
                    break;
            }
            if (sockstate == SOCKET_HAS_TIMED_OUT ||
                sockstate == SOCKET_IS_NONBLOCKING ||
                sockstate == SOCKET_HAS_BEEN_CLOSED) {
                // Connection timed out
                [self close];
                return NO ;
            }
        } while (write < 0 && (err == SSL_ERROR_WANT_READ || err == SSL_ERROR_WANT_WRITE));
    }
    
    if (write <= 0) {
        MHServerLogWithLevel(MHLogWarning, @"MHSSLSocket writeBytes:length: failed (%@)", MSGetOpenSSL_SSLErrStr(_secureSocket, err)) ;
        [self close] ;
        return NO;
    }
    
    return (write == length) ;
}

- (MSUInt)readIn:(void *)buf length:(MSUInt)length
{
#warning TODO READ SPLIT
    MSInt len = 0 ;
    int err, sockstate;
    
    if (!_secureSocket) return 0;
    
    
    if(_isBlockingIO)
    {
        len = OPENSSL_SSL_read(_secureSocket, buf, length);
        err = OPENSSL_SSL_get_error(_secureSocket, len);
    } else
    {
        do {
            len = OPENSSL_SSL_read(_secureSocket, buf, length);
            err = OPENSSL_SSL_get_error(_secureSocket, len);
            
            switch (err) {
                case SSL_ERROR_WANT_READ:
//                    sockstate = MHCheckSocketState(_socket, 0);
                    break;
                case SSL_ERROR_WANT_WRITE:
//                    sockstate = MHCheckSocketState(_socket, 1);
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
        } while (err == SSL_ERROR_WANT_READ || err == SSL_ERROR_WANT_WRITE) ;
        
    }
    
    if(len < 0) {
        MHServerLogWithLevel(MHLogWarning, @"MHSSLSocket readIn:length: failed (%@)", MSGetOpenSSL_SSLErrStr(_secureSocket, err)) ;
        [self close];
        return 0 ;
    }
    
    return len ;
}

@end

@implementation MHSSLClientSocket

- (void)dealloc
{
    [self close] ;
    [super dealloc] ;
}

+ (id)sslSocketWithCertificateFile:(NSString *)certPath keyFile:(NSString *)keyPath CAFile:(NSString *)CAPath sslOptions:(MSLong)sslOptions isBlockingIO:(BOOL)isBlockingIO
{
    return [[[self alloc] initWithCertificateFile:certPath keyFile:keyPath CAFile:CAPath sslOptions:sslOptions isBlockingIO:isBlockingIO] autorelease] ;
}

- (id)initWithCertificateFile:(NSString *)certPath keyFile:(NSString *)keyPath CAFile:(NSString *)CAPath sslOptions:(MSLong)sslOptions isBlockingIO:(BOOL)isBlockingIO
{
    BOOL isDir = NO ;
    _isBlockingIO = isBlockingIO ;
    //create ssl ctx
    if((_ssl_ctx = MHCreateClientSSLContext(sslOptions)) == NULL) return NULL ;
    OPENSSL_SSL_CTX_set_mode(_ssl_ctx, SSL_MODE_AUTO_RETRY) ;
    
    //load cert and key is provided
    if(certPath && keyPath)
    {
        char *certFilePathCStr = NULL ;
        char *keyFilePathCStr = NULL ;
        
        if((! MSFileExistsAtPath(certPath, &isDir)) || (MSFileExistsAtPath(certPath, &isDir) && isDir)) MSRaise(NSInternalInconsistencyException, @"MHSSLSocket : Unable to find client certificate file at path '%@'", certPath) ;
        if((! MSFileExistsAtPath(keyPath, &isDir)) || (MSFileExistsAtPath(keyPath, &isDir) && isDir))  MSRaise(NSInternalInconsistencyException, @"MHSSLSocket : Unable to find client key file at path '%@'", keyPath) ;
        
        certFilePathCStr = (char *)[certPath fileSystemRepresentation] ;
        keyFilePathCStr = (char *)[keyPath fileSystemRepresentation] ;

        if(MHLoadCertificate(_ssl_ctx, certFilePathCStr, keyFilePathCStr) != EXIT_SUCCESS) return NULL ;
    }
    
    //load ca file if provided
    if(CAPath)
    {
        char *CAFilePathCStr = NULL ;
        
        if((! MSFileExistsAtPath(CAPath, &isDir)) || (MSFileExistsAtPath(CAPath, &isDir) && isDir)) MSRaise(NSInternalInconsistencyException, @"MHSSLSocket : Unable to find client CA file at path '%@'", CAPath) ;
        
        CAFilePathCStr = (char *)[CAPath fileSystemRepresentation] ;
        
        if(!OPENSSL_SSL_CTX_load_verify_locations(_ssl_ctx, CAFilePathCStr, NULL))
        {
            MHServerLogWithLevel(MHLogCritical, @"Client certificate verification failed : '%@'", MSGetOpenSSLErrStr()) ;
            return nil ;
        }
    }
    
    return self ;
}

- (BOOL)connectOnServer:(NSString *)server port:(MSUInt)port
{
    SOCKET sd ;
    NSString *error ;
    int connect = 0 ;
    int err ;
    
    //connect socket
    if((sd = MHNewSocketOnServerPort(server, port, _isBlockingIO, &error)) == -1) return NO ;
    
    _secureSocket = OPENSSL_SSL_new(_ssl_ctx) ;
    OPENSSL_SSL_set_fd(_secureSocket, sd) ;
    _socket = sd ;
    
    do {
        connect = OPENSSL_SSL_connect(_secureSocket) ;
        err = OPENSSL_SSL_get_error(_secureSocket, connect);
        
    } while (!_isBlockingIO && connect < 0 && (err == SSL_ERROR_WANT_READ || err == SSL_ERROR_WANT_WRITE)) ;
    
    if (connect != 1)
    {
        MHServerLogWithLevel(MHLogError,@"MHSSLSocket SSL_connect() on server %@:%d (%@)", server, port, MSGetOpenSSL_SSLErrStr(_secureSocket, connect)) ;
        return NO ;
    }
    
    return YES ;
}

@end
