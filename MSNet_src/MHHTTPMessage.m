/*
 
 MHHTTPMessage.m
 
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

#import "_MASHPrivate.h"

@implementation MHHTTPMessage

- (void)dealloc 
{
    if (_isHead) DESTROY(_secureSocket) ;
    DESTROY(_messageContinuation) ;
    DESTROY(_completeBody) ;
    DESTROY(_parameters) ;
    [super dealloc] ;
}

+ (id)retainedMessageFromSocket:(id)secureSocket withBytes:(const void *)bytes length:(MSUInt)length lastMessage:(MHHTTPMessage **)aLastMessage
{
    return (id)CHTTPMessageCreate(secureSocket, bytes, length, (CHTTPMessage **)aLastMessage) ;
}

- (void)appendBytes:(const void *)bytes length:(MSUInt)length lastMessage:(MHHTTPMessage **)aLastMessage
{
    CHTTPMessageAppendBytes((CHTTPMessage *)self, bytes, length, (CHTTPMessage **)aLastMessage) ;
}

- (MHHTTPMessage *)messageContinuation
{
    return _messageContinuation ;
}

- (void *)bodyBytes
{
    return _headers[MHHTTPBody] ;
}

- (MSUInt)bodySize
{
    return _bodySize ;
}

- (void)parseMessage
{
    char *token;
    char *savedPtr;
    char *headEnd;
    char *ptr;
    long bodySize = 0;
    MHHTTPMessage *nextMessage = NULL ;
    
    if(_isHead)
    {
        if (!_isParsed) {
            _isParsed = 1 ;
            
            // First we set every header offset to NULL
            memset(_headers, 0, sizeof(char*) * MH_HTTP_MAX_MANAGED_HEADERS);
            
            headEnd = strstr(_buf, "\r\n\r\n");
            
            // no HTTP headers in the received data
            if(headEnd)
            {
                // The first line should be the "METHOD /path HTTP/1.1"
                *headEnd = 0 ;
                token = strtok_r(_buf, "\r\n", &savedPtr);
                ptr = strchr(token, 32);
                
                _headers[MHHTTPMethod] = _buf;
                
                if(ptr)
                {
                    *ptr = 0;
                    // remove the leading '/'
                    if(ptr[1] == '/') _headers[MHHTTPUrl] = ptr + 2;
                    ptr = strchr(ptr + 1, 32);
                    if(ptr) *ptr = 0;
                }
                
                token = strtok_r(NULL, "\r\n", &savedPtr);
                while (token != NULL)
                {
                    if(!strncasecmp(token, "Host: ", 6))
                    {
                        // Only process the first occurence of a header
                        if(!_headers[MHHTTPHost])
                            _headers[MHHTTPHost] = token + 6;
                    }
                    else if(!strncasecmp(token, "Referer: ", 9))
                    {
                        if(!_headers[MHHTTPReferer])
                            _headers[MHHTTPReferer] = token + 9;
                    }
                    else if(!strncasecmp(token, "User-Agent: ", 12))
                    {
                        if(!_headers[MHHTTPUserAgent])
                            _headers[MHHTTPUserAgent] = token + 12;
                    }
                    else if(!strncasecmp(token, "Cookie: ", 8))
                    {
                        if(!_headers[MHHTTPCookie])
                        {
                            _headers[MHHTTPCookie] = token + 8;
                        }
                    }
                    else if(!strncasecmp(token, "X-Forwarded-For: ", 17))
                    {
                        if(!_headers[MHHTTPForwardedFor])
                            _headers[MHHTTPForwardedFor] = token + 17;
                    }
                    else if(!strncasecmp(token, "Accept: ", 8))
                    {
                        if(!_headers[MHHTTPClientTypes])
                            _headers[MHHTTPClientTypes] = token + 8;
                    }
                    else if(!strncasecmp(token, "Accept-Charset: ", 16))
                    {
                        if(!_headers[MHHTTPClientCharset])
                            _headers[MHHTTPClientCharset] = token + 16;
                    }
                    else if(!strncasecmp(token, "Accept-Encoding: ", 17))
                    {
                        if(!_headers[MHHTTPClientEncoding])
                            _headers[MHHTTPClientEncoding] = token + 17;
                    }
                    else if(!strncasecmp(token, "Accept-Language: ", 17))
                    {
                        if(!_headers[MHHTTPClientLanguage])
                            _headers[MHHTTPClientLanguage] = token + 17;
                    }
                    else if(!strncasecmp(token, "MASH_SESSION_ID: ", 17))
                    {
                        if(!_headers[MHHTTPSessionId])
                            _headers[MHHTTPSessionId] = token + 17;
                    }
                    else if(!strncasecmp(token, "TransactID: ", 12))
                    {
                        if(!_headers[MHHTTPTransactId])
                            _headers[MHHTTPTransactId] = token + 12;
                    }
                    else if(!strncasecmp(token, "Content-Type: ", 14))
                    {
                        if(!_headers[MHHTTPBodyType])
                            _headers[MHHTTPBodyType] = token + 14;
                    }
                    else if(!strncasecmp(token, "Content-Length: ", 16))
                    {
                        if(!_headers[MHHTTPBodyLength])
                        {
                            if(!strncmp(_headers[MHHTTPMethod], "UPLD", 4)) bodySize = 0;
                            else {
                                _headers[MHHTTPBodyLength] = token + 16;
                                bodySize = atol(token + 16);
                                _headers[MHHTTPBody] = headEnd + 4;
                            }
                        }
                    }
                    else if(!strncasecmp(token, "MASH_APP_ID: ", 13))
                    {
                        if(!_headers[MHHTTPAppId])
                            _headers[MHHTTPAppId] = token + 13;
                    }
                    else if(!strncasecmp(token, "MASH_CONTEXT_ID: ", 17))
                    {
                        if(!_headers[MHHTTPContextId])
                            _headers[MHHTTPContextId] = token + 17;
                    }
                    else if(!strncasecmp(token, "MASH_AUTH_RESPONSE: ", 20))
                    {
                        if(!_headers[MHHTTPAuthResponse])
                            _headers[MHHTTPAuthResponse] = token + 20;
                    }
                    else if(!strncasecmp(token, "MASH_AUTH_GET_SESSION: ", 23))
                    {
                        if(!_headers[MHHTTPAuthGetSession])
                            _headers[MHHTTPAuthGetSession] = token + 23;
                    }
                    else if(!strncasecmp(token, "If-Modified-Since: ", 19))
                    {
                        if(!_headers[MHHTTPIfModifiedSince])
                            _headers[MHHTTPIfModifiedSince] = token + 19;
                    }
                    else if(!strncasecmp(token, "MASH_UPLD_FILE_NAME: ", 21))
                    {
                        if(!_headers[MHHTTPUploadFileName])
                            _headers[MHHTTPUploadFileName] = token + 21;
                    }
                    else if(!strncasecmp(token, "MASH_UPLD_RSRC_URL: ", 20))
                    {
                        if(!_headers[MHHTTPUploadResourceURL])
                            _headers[MHHTTPUploadResourceURL] = token + 20;
                    }
                    else if(!strncasecmp(token, "MASH_VOLATILE_UPLOADED_RSRC: ", 20))
                    {
                        if(!_headers[MHHTTPContainsVolatileUploadedResource])
                            _headers[MHHTTPContainsVolatileUploadedResource] = token + 20;
                    }
                    else if(!strncasecmp(token, "one-way-transaction: ", 21))
                    {
                        if(!_headers[MHHTTPOneWayTransaction])
                            _headers[MHHTTPOneWayTransaction] = token + 21;
                    }
                    else if(!strncasecmp(token, "Envelope-Type: ", 15))
                    {
                        if(!_headers[MHHTTPEnvelopeType])
                            _headers[MHHTTPEnvelopeType] = token + 15;
                    }
                    else if(!strncasecmp(token, "Envelope-Length: ", 17))
                    {
                        if(!_headers[MHHTTPEnvelopeLength])
                            _headers[MHHTTPEnvelopeLength] = token + 17;
                    }
                    else if(!strncasecmp(token, "Response-Format: ", 17))
                    {
                        if(!_headers[MHHTTPResponseFormat])
                            _headers[MHHTTPResponseFormat] = token + 17;
                    }
                    token = strtok_r(NULL, "\r\n", &savedPtr);
                }
                _fullBodySize = (MSUInt)bodySize;
                
                // if pointer to body is null, body size is null too.
                _bodySize = _headers[MHHTTPBody] ? (MSUInt)(_bufferLength-(_headers[MHHTTPBody]-_buf)) : 0 ;

            }
            else
            {
                // No headers found, malformed HTTP request
                // Consider the message as raw data, just a body
                _bodySize = _bufferLength;
                _headers[MHHTTPBody] = _buf;
            }
            
            nextMessage = _messageContinuation ;
            while (nextMessage)
            {
                [nextMessage parseMessage];
                nextMessage = [nextMessage messageContinuation] ;
            }
        }
    }
    else
    {
        // Non-head message
        _bodySize = _bufferLength;
        _headers[MHHTTPBody] = _buf;
    }
}

- (MSBuffer *)getCompleteBody
{
    if (!_completeBody) {
        if(_isHead) {
            MHHTTPMessage *nextMessage = _messageContinuation ;
            void *currentBodyBytes ;
            [self parseMessage] ;
            currentBodyBytes = [self bodyBytes] ;
            if (nextMessage && currentBodyBytes) {
                _completeBody = MSCreateBufferWithBytes(currentBodyBytes, _bodySize) ;
                while (nextMessage) {
                    void *nextBodyBytes = [nextMessage bodyBytes] ;
                    if (nextBodyBytes) {
                        CBufferAppendBytes((CBuffer *)_completeBody, nextBodyBytes, [nextMessage bodySize]) ;
                        nextMessage = [nextMessage messageContinuation] ;
                    }
                    else {
                        MSRaise(NSGenericException, @"MHHTTPMessage getCompleteBody : chained message has no body!") ;
                    }
                }
            }
            else {
                if (_bodySize) _completeBody = MSCreateBufferWithBytesNoCopyNoFree(_headers[MHHTTPBody], _bodySize) ;
            }
        }
        else {
            MSRaise(NSGenericException, @"MHHTTPMessage getCompleteBody : Trying to get complete body on a non head message!") ;
        }
    }
    return _completeBody ;
}

- (NSString *)description
{
    [self parseMessage] ;
    return [NSString stringWithFormat:@"%@\nMHHTTPMethod : %s\nMHHTTPUrl : %s\nMHHTTPHost : %s\nMHHTTPReferer : %s\nMHHTTPUserAgent : %s\nMHHTTPCookie: %s\nMHHTTPOS : %s\nMHHTTPPlatform : %s\nMHHTTPBrowser : %s\nMHHTTPBrowserVersion : %s\nMHHTTPForwardedFor : %s\nMHHTTPClientTypes : %s\nMHHTTPClientCharset : %s\nMHHTTPClientEncoding : %s\nMHHTTPClientLanguage : %s\nMHHTTPSessionId : %s\nMHHTTPTransactId : %s\nMHHTTPBodyType : %s\nMHHTTPBodyLength : %s\nMHHTTPBody : %s\nMHHTTPIfModifiedSince : %s\nMHHTTPAppId : %s\nMHHTTPContextId : %s\nMHHTTPAuthResponse : %s\nMHHTTPAuthGetSession : %s\nMHHTTPOrigFile : %s\nMHHTTPDestFile : %s\n",
            [super description], 
            _headers[MHHTTPMethod],
            _headers[MHHTTPUrl],
            _headers[MHHTTPHost],
            _headers[MHHTTPReferer],
            _headers[MHHTTPUserAgent],
            _headers[MHHTTPCookie],
            _headers[MHHTTPOS],
            _headers[MHHTTPPlatform],
            _headers[MHHTTPBrowser],
            _headers[MHHTTPBrowserVersion],
            _headers[MHHTTPForwardedFor],
            _headers[MHHTTPClientTypes],
            _headers[MHHTTPClientCharset],
            _headers[MHHTTPClientEncoding],
            _headers[MHHTTPClientLanguage],
            _headers[MHHTTPSessionId],
            _headers[MHHTTPTransactId],
            _headers[MHHTTPBodyType],
            _headers[MHHTTPBodyLength],
            _headers[MHHTTPBody],
            _headers[MHHTTPIfModifiedSince],
            _headers[MHHTTPAppId],
            _headers[MHHTTPContextId],
            _headers[MHHTTPAuthResponse],
            _headers[MHHTTPAuthGetSession],
            _headers[MHHTTPUploadFileName],
            _headers[MHHTTPUploadResourceURL]
            ] ;
}

- (NSString *)getHeader:(MHHTTPRegister)headerRegister
{
    char *header ;
    [self parseMessage] ;

    header = _headers[headerRegister] ;

    return (header) ? [NSString stringWithUTF8String:header] : nil ;
}

- (NSString *)contentType
{
    NSString * ext = [[self getHeader:MHHTTPUrl] pathExtension] ;

    if([ext caseInsensitiveCompare:@"json"] == NSOrderedSame)
        return @"application/json";
    else if([ext caseInsensitiveCompare:@"jpg"] == NSOrderedSame)
        return @"image/jpeg";
    else if([ext caseInsensitiveCompare:@"jpeg"] == NSOrderedSame)
        return @"image/jpeg";
    else if([ext caseInsensitiveCompare:@"png"] == NSOrderedSame)
        return @"image/png";
    else if([ext caseInsensitiveCompare:@"zip"] == NSOrderedSame)
        return @"application/zip";
    else if([ext caseInsensitiveCompare:@"exe"] == NSOrderedSame)
        return @"application/octet-stream";
    else if([ext caseInsensitiveCompare:@"xml"] == NSOrderedSame)
        return @"text/xml";
    else if([ext caseInsensitiveCompare:@"txt"] == NSOrderedSame)
        return @"text/plain";
    else if([ext caseInsensitiveCompare:@"js"] == NSOrderedSame)
        return @"text/javascript";
    else if([ext caseInsensitiveCompare:@"gif"] == NSOrderedSame)
        return @"image/gif";
    else if([ext caseInsensitiveCompare:@"css"] == NSOrderedSame)
        return @"text/css";
    else if([ext caseInsensitiveCompare:@"rtf"] == NSOrderedSame)
        return @"application/rtf";
    else return @"text/html; charset=utf-8"; // defaults to text/html... later to application/json ?
}

// Extract parameters from the query string as a NSDictionary
// Return an empty dictionary if no parameters are given or if an error occured
// TODO: urldecode the strings (%2F -> '/')
- (void)_parameters
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary] ;
    NSString * method = [self getHeader:MHHTTPMethod] ;
    NSMutableString * queryString = [NSMutableString string] ;
    NSRange questionMark ;
    
    
    // GET method => extract parameters from the url
    NSString * url = [self getHeader:MHHTTPUrl] ;
    
    questionMark = [url rangeOfString:@"?"] ;
    if((questionMark.location != NSNotFound) && (questionMark.location < [url length] - 1))
    {
        [queryString appendString:[url substringFromIndex:(questionMark.location + 1)]] ;
    }
    
    if([method isEqualToString:MHTTPMethodPOST])
    {
        // POST method => check the content-type then extract parameters from the body
        if([[self getHeader:MHHTTPBodyType] isEqualToString:@"application/x-www-form-urlencoded"])
        {
            if(_fullBodySize < 4096)
            {
                if([queryString length]) [queryString appendString:@"&"] ;
                [queryString appendString:[MSASCIIString stringWithBuffer:[self getCompleteBody]]] ;
            }
        }
    }
    if(queryString)
    {
        NSEnumerator * kve ;
        NSString * kv ;
        
        kve = [[queryString componentsSeparatedByString:@"&"] objectEnumerator] ;
        while((kv = [kve nextObject]))
        {
            NSRange equalMark = [kv rangeOfString:@"="] ;
            if((equalMark.location != NSNotFound) && (equalMark.location < [kv length] - 1))
            {
                NSString * k = [kv substringToIndex:equalMark.location] ;
                NSString * v = [kv substringFromIndex:(equalMark.location + 1)] ;
                if([k length] && [v length])
                {
                    [dict setObject:[v decodedURLString] forKey:[k decodedURLString]] ;
                }
            }
        }
    }
    ASSIGN(_parameters, dict) ;
}

- (NSDictionary *)parameters
{
    if(!_parameters)
    {
        [self _parameters] ;
    }
    
    return _parameters ;
}

- (NSString *)parameterNamed:(NSString *)name
{
    return [[self parameters] objectForKey:name] ;
}

- (NSString *)httpMethod
{
    return [self getHeader:MHHTTPMethod] ;
}

- (BOOL)isGetRequest
{
    return [[self httpMethod] isEqualToString:MHTTPMethodGET] ;
}

- (BOOL)isPostRequest
{
    return [[self httpMethod] isEqualToString:MHTTPMethodPOST] ;
}

- (BOOL)clientBrowserSupportsDeflateCompression
{
    BOOL canCompress = YES ;
    NSString *userAgent = nil ;
    BOOL isIE = NO ;
    
    if (![[self getHeader:MHHTTPClientEncoding] containsString:@"deflate"]) {
        canCompress = NO ; //client browser does not support deflate compression
    }
    
    userAgent = [self getHeader:MHHTTPUserAgent];
    isIE = ([userAgent containsString:@"(compatible; MSIE"] || [userAgent containsString:@"Trident/"]);
    
    if (canCompress && isIE) {
        canCompress = NO ; //Internet Explorer does not support deflate compression with SSL
    }
    
    return canCompress ;
}

@end
