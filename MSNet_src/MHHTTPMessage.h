/*
 
 MHHTTPMessage.h
 
 This file is is a part of the MicroStep Application Server over Http Framework.
 
 Initial copyright LOGITUD Solutions (logitud@logitud.fr) since 2012
 
 Herve Malaingre : herve@malaingre.com
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 
 
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
 
 */

#define HTTP_200_RESPONSE "HTTP/1.1 200 OK\r\n"\
"Connection: close\r\n"\
"Content-Length: %li\r\n"\
"Content-Type: %s\r\n"\
"Date: %s\r\n"\
"Last-Modified: %s\r\n"\
"\r\n"

/*#define HTTP_200_OPTIONS_RESPONSE "HTTP/1.1 200 OK\r\n"\
"Connection: close\r\n"\
"Allow: HEAD,GET,POST,OPTIONS\r\n"\
"Content-length: 0\r\n"\
"\r\n"*/

#define HTTP_400_RESPONSE "HTTP/1.1 400 Malformed\r\n"\
"Connection: close\r\n"\
"Content-Type: text/html\r\n"\
"Content-Length: 137\r\n"\
"\r\n"\
"<html><head><title>Malformed request</title></head>"\
"<body><p>You sent a malformed request that the server did not understand"\
"</body></html>" 

#define HTTP_403_RESPONSE "HTTP/1.1 403 Forbidden\r\n"\
"Connection: close\r\n"\
"Content-Type: text/html\r\n"\
"Content-Length: 100\r\n"\
"\r\n"\
"<html><head><title>Forbidden</title></head>"\
"<body><p>Access to this object is forbidden"\
"</body></html>" 

#define HTTP_404_RESPONSE "HTTP/1.1 404 Not found\r\n"\
"Connection: close\r\n"\
"Content-Type: text/html\r\n"\
"Content-Tength: 111\r\n"\
"\r\n"\
"<html><head><title>Not Found</title></head>"\
"<body><p>Sorry, the object you requested was not found"\
"</body></html>" 

#define HTTP_408_RESPONSE "HTTP/1.1 408 Request Time-out\r\n"\
"Connection: close\r\n"\
"Content-Type: text/html\r\n"\
"Content-Length: 95\r\n"\
"\r\n"\
"<html><head><title>Request Time-out</title></head>"\
"<body><p>The request timed-out."\
"</body></html>" 

#define HTTP_418_RESPONSE "HTTP/1.1 418 I'm a teapot\r\n"\
"Connection: close\r\n"\
"Content-Type: text/html\r\n"\
"Content-Length: 85\r\n"\
"\r\n"\
"<html><head><title>I'm a teapot</title></head>"\
"<body><p>I'm a teapot</p>"\
"</body></html>" 

#define HTTP_500_RESPONSE "HTTP/1.1 500 Internal Server Error\r\n"\
"Connection: close\r\n"\
"Content-Type: text/html\r\n"\
"Content-Length: 178\r\n"\
"\r\n"\
"<html><head><title>Internal Server Error</title></head>"\
"<body><p>The server encountered an internal error or misconfiguration "\
"and was unable to complete your request</body></html>" 

#define HTTP_501_RESPONSE "HTTP/1.1 501 Not Implemented\r\n"\
"Connection: close\r\n"\
"Content-Type: text/html\r\n"\
"Content-Length: 116\r\n"\
"\r\n"\
"<html><head><title>Not Implemented</title></head>"\
"<body><p>This method is not implemented by the server"\
"</body></html>" 

#define HTTP_503_RESPONSE "HTTP/1.1 503 Service Unavailable\r\n"\
"Connection: close\r\n"\
"Content-Type: text/html\r\n"\
"Content-Length: 96\r\n"\
"\r\n"\
"<html><head><title>Service Unavailable</title></head>"\
"<body><p>Server is overloaded"\
"</body></html>" 


#ifndef MH_HTTP_MAX_MANAGED_HEADERS
#define MH_HTTP_MAX_MANAGED_HEADERS 48
#define MH_HTTP_MAX_HEADERS_SIZE 2048
#endif

#define HTTPOK                            200
#define HTTPCreated                       201
#define HTTPAccepted                      202
#define HTTPPartialInformation            203
#define HTTPNoResponse                    204
#define HTTPResetContent                  205
#define HTTPPartialContent                206
#define HTTPMovedPermanently              301
#define HTTPFound                         302
#define HTTPMethod                        303
#define HTTPNotModified                   304
#define HTTPTemporaryRedirect             307
#define HTTPBadRequest                    400
#define HTTPUnauthorized                  401
#define HTTPPaymentRequired               402
#define HTTPForbidden                     403
#define HTTPNotFound                      404
#define HTTPProxyAuthenticationRequired   407
#define HTTPInternalError                 500
#define HTTPNotImplemented                501
#define HTTPBadGateway                    502
#define HTTPServiceUnavailable            503
#define HTTPGatewayTimeout                504

#define MHHTTPMethodGET      @"GET"
#define MHHTTPMethodPOST     @"POST"

typedef enum {
    MHHTTPMethod = 0,
    MHHTTPUrl,
    MHHTTPHost,
    MHHTTPReferer,
    MHHTTPUserAgent,
    MHHTTPCookie,
    MHHTTPOS,
    MHHTTPPlatform,
    MHHTTPBrowser,
    MHHTTPBrowserVersion,
    MHHTTPForwardedFor,
    MHHTTPClientTypes,
    MHHTTPClientCharset,
    MHHTTPClientEncoding,
    MHHTTPClientLanguage,
    MHHTTPSessionId,
    MHHTTPTransactId,
    MHHTTPBodyType,
    MHHTTPBodyLength,
    MHHTTPBody,
    MHHTTPIfModifiedSince,
    MHHTTPAppId,
    MHHTTPContextId,
    MHHTTPAuthResponse,
    MHHTTPAuthGetSession,
    MHHTTPAuthLogin,
    MHHTTPAuthPassword,
    MHHTTPAuthTarget,
    MHHTTPAuthChallenge,
    MHHTTPAuthURN,
    MHHTTPUploadFileName,
    MHHTTPUploadResourceURL,
    MHHTTPContainsVolatileUploadedResource,
    MHHTTPOneWayTransaction,
    MHHTTPEnvelopeType,
    MHHTTPEnvelopeLength,
    MHHTTPResponseFormat
} MHHTTPRegister ;

#define MIMETYPE_OCTET_STREAM   @"application/octet-stream"
#define MIMETYPE_JSON           @"application/json"


@interface MHHTTPMessage : MHBunchableObject
{
@private
    id _secureSocket ;
    MSShort _isHead ;
    MSShort _isParsed ;
    char *_headers[MH_HTTP_MAX_MANAGED_HEADERS] ;
    char _buf[MH_HTTP_MAX_HEADERS_SIZE] ;
    MSUInt _bufferLength ;
    MSUInt _bodySize ;
    MSUInt _fullBodySize ;
    MHHTTPMessage *_messageContinuation ;
    MSBuffer *_completeBody ;
    NSDictionary *_parameters ;
}

+ (id)retainedMessageFromSocket:(id)secureSocket withBytes:(const void *)bytes length:(MSUInt)length lastMessage:(MHHTTPMessage **)aLastMessage ;
- (void)appendBytes:(const void *)bytes length:(MSUInt)length lastMessage:(MHHTTPMessage **)aLastMessage;

- (MSBuffer *)getCompleteBody ;
- (NSString *)getHeader:(MHHTTPRegister)headerRegister ;
- (NSString *)contentType ;
- (NSDictionary *)parameters ;
- (NSString *)parameterNamed:(NSString *)name ;
- (NSString *)httpMethod ;
- (BOOL)isGetRequest ;
- (BOOL)isPostRequest ;

- (BOOL)clientBrowserSupportsDeflateCompression ;
@end
