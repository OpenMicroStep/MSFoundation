/*
 
 MSCurlHandler.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
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
 
 WARNING : this header file cannot be included alone, please direclty
 include <MSFoundation/MSFoundation.h>
 
 A call to the MSFoundation initialize function must be done before using
 these functions.
 */

#import "MSNet_Private.h"
//#import "MSBuffer.h"


@implementation MSCurlHandler


+ (id)curlHandlerWithServer:(NSString *)server
{
    CURL_initialize() ;
    return [[[self alloc] initWithServer:server port:0 useSSL:NO] autorelease] ;
}

+ (id)curlHandlerWithServer:(NSString *)server port:(MSUShort)port useSSL:(BOOL)useSSL
{
    CURL_initialize() ;
    return [[[self alloc] initWithServer:server port:port useSSL:useSSL] autorelease] ;
}

- (void) _clean
{
    if(_curl) MS_curl_easy_cleanup(_curl) ;
}

- (id)initWithServer:(NSString *)server port:(MSUShort)port useSSL:(BOOL)useSSL
{
    //Test values
    if(!server) MSRaise(NSGenericException, @"No Server specified") ;
    
    //Initialize curl
    MS_curl_global_init(CURL_GLOBAL_ALL) ;
    
    //Initialize curl context
    _curl = (void *)MS_curl_easy_init() ;
    
    //Create lock to prevent multiple silmultaneous curl actions
    _lock = [[NSLock alloc] init] ; //retain
    
    if(! _curl)
    {
        //clean and raise exception //TODO
        [self _clean] ;
        MSRaise(NSGenericException, @"Curl not created") ;
    }
    
    [self setServer:server] ;
    [self setPort:port] ;
    [self setUseSSL:useSSL] ;
    
    MS_curl_easy_setopt_long(_curl, CURLOPT_NOPROGRESS, TRUE) ;
    
    return self ;
}

- (void)setVerbose:(BOOL)mode
{
    MS_curl_easy_setopt_long(_curl, CURLOPT_VERBOSE, mode) ;
}
- (void)setServer:(NSString *)server { ASSIGN(_server, server) ; }
- (void)setPort:(MSUShort)port { _port = port ; }
- (void)setUseSSL:(BOOL)useSSL { _useSSL = useSSL ; }
- (NSString*)server { return _server; }
- (MSUShort)port { return _port; }
- (BOOL)useSSL { return _useSSL; }
- (void*)curl { return _curl; }
- (NSLock*)lock { return _lock; }

- (void)dealloc
{
    [self _clean] ;
    
    RELEASE(_lock) ;
    RELEASE(_server) ;
    [super dealloc];
}


@end
