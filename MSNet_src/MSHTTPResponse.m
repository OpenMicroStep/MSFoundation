//
//  MSHTTPResponse.m
//
//
//  Created by Geoffrey Guilbon on 20/08/13.
//  Copyright (c) 2013 Geoffrey Guilbon. All rights reserved.
//

#import "MSNet_Private.h"
//#import "MSUnicodeString.h"
//#import "MSHTTPResponse.h"

@implementation MSHTTPResponse


+ (id)httpResponseFromBytes:(void *)bytes length:(MSUInt)length
{
    return [[[self alloc] initFromBytes:bytes length:length] autorelease] ;
}

- (id)initFromBytes:(void *)bytes length:(MSUInt)length
{
    BOOL ok = YES ;
    
    ASSIGN(_headers, [NSMutableDictionary dictionary]) ;
    ASSIGN(_content, AUTORELEASE(MSCreateBuffer(0))) ;

    if(length)
    {
        char *headerStart = bytes ;
        char *headerEnd = NULL ;
        MSLong headerLineLength ;
        MSULong remainingBytes = length ;
        BOOL first = YES ;        
                
        while ((headerEnd = strnstr(headerStart, "\r\n", remainingBytes)))
        {
            MSString *headerLine = nil ;
            headerLineLength = headerEnd - headerStart ;

            if (!headerLineLength) break ;
          
            headerLine = AUTORELEASE((MSString*)CCreateString(32)) ;
            CStringAppendBytes((CString*)headerLine,
              NSUTF8StringEncoding, headerStart, headerLineLength) ;
            
            if(first) //status line
            {
                NSMutableArray *statusLine = [[[headerLine componentsSeparatedByString:@" "] mutableCopy] autorelease] ;
              
                if([statusLine count] < 3)
                {
                    ok = NO ;
                    break ;
                } else {
                    [self setHTTPVersion:[statusLine objectAtIndex:0]] ;
                    [self setHTTPStatus:[[statusLine objectAtIndex:1] intValue]] ;
                    [statusLine removeObjectAtIndex:0] ;
                    [statusLine removeObjectAtIndex:0] ; //delete version and status
                    
                    [self setHTTPStatusString:[statusLine componentsJoinedByString:@" "]] ;
                }
                first = NO ;
            } else //headers
            {
                NSArray *split = [headerLine componentsSeparatedByString:@": "] ;
                if([split count] != 2)
                {
                    ok = NO ;
                    break ;
                } else {
                    [self setHeader:[split objectAtIndex:1] forKey:[split objectAtIndex:0]] ;
                }
            }

            headerStart = headerEnd + 2 ;
            remainingBytes -= (headerLineLength + 2) ;
        }

        if(ok)
        {
            char *bodyStart = headerEnd + 2 ;
            remainingBytes -= 2 ;
            
            if(remainingBytes && [_headers objectForKey:@"Content-Length"]) //get content
            {
                ASSIGN(_content, AUTORELEASE(MSCreateBufferWithBytes((void *)bodyStart, remainingBytes))) ;
            }
            return self ;
        }
    }
    return nil ;
}

- (void)dealloc
{
    DESTROY(_headers) ;
    DESTROY(_content) ;
    DESTROY(_HTTPVersion) ;
    DESTROY(_HTTPStatusString) ;
    DESTROY(_contentType) ;
    DESTROY(_content) ;
    
    [super dealloc] ;
}

- (NSString *)HTTPVersion { return _HTTPVersion ; }
- (void)setHTTPVersion:(NSString *)HTTPVersion { ASSIGN(_HTTPVersion, HTTPVersion) ; }

- (MSUInt)HTTPStatus { return _HTTPStatus ; }
- (void)setHTTPStatus:(MSUInt)status { _HTTPStatus = status ; }

- (NSString *)HTTPStatusString { return _HTTPStatusString ; }
- (void)setHTTPStatusString:(NSString *)HTTPStatusString { ASSIGN(_HTTPStatusString, HTTPStatusString) ; }

- (NSString *)headerValueForKey:(NSString *)header { return [_headers objectForKey:header] ; }
- (void)setHeader:(NSString *)value forKey:(NSString *)header { [_headers setObject:value forKey:header] ; }
- (NSDictionary *)headers { return _headers ; }

- (NSString *)contentType { return _contentType ; }
- (void)setContentType:(NSString *)contentType {  ASSIGN(_contentType, contentType) ; }

- (MSBuffer *)content {return _content ; }
- (void)addBytes:(void *)bytes length:(MSUInt)length { if(bytes && length) CBufferAppendBytes((CBuffer *)_content, bytes, length) ; }


@end


@implementation MSHTTPResponse (MASHAdditions)

- (NSString *)mashSessionID
{
  NSString *sessionID = nil ;
  NSString *cookieLine = [self headerValueForKey:@"Set-Cookie"] ;
  
  if([cookieLine length] && ![cookieLine containsString:@"deleted"])
  {
    NSArray * components = [cookieLine componentsSeparatedByString:@";"] ;
    sessionID = ([components count]) ? [components objectAtIndex:0] : nil ;
  }
  return sessionID ;
}

@end
