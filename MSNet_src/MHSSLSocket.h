//
//  MHSSLSocket.h
//  MSFoundation
//
//  Created by Geoffrey Guilbon on 28/06/13.
//
//

int MHCheckSocketState(int sock_fd, int writing) ;

@interface MHSSLSocket : NSObject
{
    void *_secureSocket ;
    void *_ssl_ctx ;
    SOCKET _socket ;
    MSInt _localPort ;
    BOOL _isBlockingIO ;
}

- (SOCKET)socket ;
- (BOOL)isBlocking ;

- (MSUInt)readIn:(void *)buf length:(MSUInt)length ;
- (BOOL)writeBytes:(const void *)bytes length:(MSUInt)length ;

@end

@interface MHSSLClientSocket : MHSSLSocket

+ (id)sslSocketWithCertificateFile:(NSString *)certPath keyFile:(NSString *)keyPath CAFile:(NSString *)CAPath sslOptions:(MSLong)sslOptions isBlockingIO:(BOOL)isBlockingIO ;
- (id)initWithCertificateFile:(NSString *)certPath keyFile:(NSString *)keyPath CAFile:(NSString *)CAPath sslOptions:(MSLong)sslOptions isBlockingIO:(BOOL)isBlockingIO ;

- (BOOL)connectOnServer:(NSString *)server port:(MSUInt)port ;

@end
