/*
 
 MSDBConnectionPool.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Vincent Rouillé : v-rouille@logitud.fr
 
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
 include <MSDatabase/MSDatabase.h>
 */

#import "MSDatabase_Private.h"

@implementation MSDBConnectionPool

+ (id)connectionPoolWithDictionnary:(MSDictionary *)dictionary
{
    return [[[MSDBConnectionPool alloc] initWithDictionnary:dictionary] autorelease];
}

- (id)initWithDictionnary:(MSDictionary *)dictionary
{
    if((self= [super init])) {
        _connectionDictionary= [dictionary retain];
        _idleConnections= [MSArray new];
        mtx_init(&_connectionLock, mtx_plain);
    }
    return self;
}

- (void)dealloc
{
    mtx_destroy(&_connectionLock);
    [_connectionDictionary release];
    [_idleConnections release];
    [super dealloc];
}

// Thread safe
- (MSDBConnection *)requireConnection
{
    MSDBConnection *ret;
    NSUInteger p;
    
    mtx_lock(&_connectionLock);
    if((p= [_idleConnections count])) {
        --p;
        ret= [[[_idleConnections objectAtIndex:p] retain] autorelease];
        [_idleConnections removeObjectAtIndex:p];
    } else {
        ret= [MSDBConnection connectionWithDictionary:_connectionDictionary];
    }
    mtx_unlock(&_connectionLock);
    return ret;
}

// Thread safe
- (void)releaseConnection:(MSDBConnection *)connection
{
    mtx_lock(&_connectionLock);
    [connection terminateAllOperations];
    [_idleConnections addObject:connection];
    mtx_unlock(&_connectionLock);
}

@end
