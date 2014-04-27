/*
 
 MSOCIConnection.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011

 Jean-Michel BERTHEAS : jean-michel.bertheas@club-internet.fr
 Frederic Olivi : fred.olivi@free.fr

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
#import "MSOCIConnection.h"
#import "_MSOCIConnectionPrivate.h"
#import "MSOCIResultSet.h"
#import "MSOCITransaction.h"
#import "oci.h"

#ifdef WIN32
#import <windows.h>
#endif

#define DEFAULT_TRANSACTION_TIMEOUT 60


@implementation MSOCIConnection

#ifdef WIN32
+ (void)initialize
{
    initializeOCILibraryForWin32() ;
}
#endif

-(OCICtx *)context {return _ctx;}

-(void) cleanup
{
    BOOL res = TRUE;

    OCI_CALL(res, _ctx, OCISessionEnd(_ctx->hservice, _ctx->herror, _ctx->hsesssion, (ub4)OCI_DEFAULT));
    OCI_CALL(res, _ctx, OCIServerDetach(_ctx->hserver,_ctx->herror, (ub4) OCI_DEFAULT));
    OCI_CALL(res, _ctx, OCIHandleFree((dvoid *) _ctx->hserver, (ub4) OCI_HTYPE_SERVER));
    OCI_CALL(res, _ctx, OCIHandleFree((dvoid *) _ctx->hservice, (ub4) OCI_HTYPE_SVCCTX));
    OCI_CALL(res, _ctx,OCIHandleFree((dvoid *) _ctx->herror, (ub4) OCI_HTYPE_ERROR));
    OCIHandleFree((dvoid *) _ctx->henv, (ub4) OCI_HTYPE_ENV);
}

- (id)initWithConnectionDictionary:(NSDictionary *)dictionary
{
    if ((self = [super initWithConnectionDictionary:dictionary])) {
        NSMutableDictionary *tDict ;
        _MSOCIThreadContext *context ;

        NSString *database = [dictionary objectForLazyKey:@"database"] ;
        NSString *user = [dictionary objectForLazyKey:@"user"] ;
        NSString *password = [dictionary objectForLazyKey:@"password"] ;

        setenv("NLS_LANG", "AMERICAN_AMERICA.UTF8", 1);
        
        if (!database) { database = [dictionary objectForLazyKey:@"database-name"] ;}
        if (!database) { database = [dictionary objectForLazyKey:@"db"] ;}
        if (!database) { database = [dictionary objectForLazyKey:@"db-name"] ;}
        if (![database length]) {
            RELEASE(self) ;
            return nil ;
        }

        if (!user) { user = [dictionary objectForLazyKey:@"user-name"] ;}
        if (!user) { user = [dictionary objectForLazyKey:@"login"] ;}
        if (![user length]) {
            RELEASE(self) ;
            return nil ;
        }

        if (!password) { password = [dictionary objectForLazyKey:@"pwd"] ;}
        if (![password length]) {
            RELEASE(self) ;
            return nil ;
        }

        tDict = [[NSThread currentThread] threadDictionary] ;
        context = [tDict objectForKey:@"_$ociContext"] ;

        if (!context) {
            // creation de context
            context = [ALLOC(_MSOCIThreadContext) init] ;
            if (context) {
                [tDict setObject:context forKey:@"_$ociContext"];
                RELEASE(context) ;
            }
            else {
                RELEASE(self) ;
                return nil ;
            }
        }
        _ctx = [context context] ;
        //_writeEncoding = _readEncoding = NSUTF8StringEncoding ;
        // MSGetEncodingFrom is declared in MSUnichar.h. WARNING : you can get NSNEXTSTEPStringEncoding and NSUTF16StringEncoding

        //		if (MSGetEncodingFrom([dictionary objectForKey:@"encoding"], &_writeEncoding)) { _readEncoding = _writeEncoding ; }
        //		(void)MSGetEncodingFrom([dictionary objectForKey:@"write-encoding"], &_writeEncoding) ;
        //		(void)MSGetEncodingFrom([dictionary objectForKey:@"read-encoding"], &_readEncoding) ;

        [_currentDictionary setObject:database forKey:@"$_database"] ;
        [_currentDictionary setObject:user forKey:@"$_user"] ;
        [_currentDictionary setObject:password forKey:@"$_password"] ;
        _cFlags.readOnly = [[dictionary objectForLazyKey:@"read-only"] isTrue] || [[dictionary objectForLazyKey:@"readonly"] isTrue] ;

    }

    return self ;
}

-(BOOL) _connectWithDataBase:(NSString *)database User:(NSString *)user Password:(NSString *)password
{
    text *db =(text *)[database UTF8String] ;
    text *username =(text *)[user UTF8String] ;
    text *pwd =(text *)[password UTF8String] ;
    BOOL res = TRUE;

    if ((OCI_SUCCESS != OCIEnvCreate((OCIEnv **) &(_ctx->henv), OCI_DEFAULT,
                                     (dvoid *) NULL, NULL, NULL, NULL,
                                     (size_t) 0, (dvoid **) NULL)))
    {
        NSLog(@"ERROR - OCIEnvCreate");
        return NO;
    };

    if ((OCI_SUCCESS != OCIHandleAlloc((dvoid *)_ctx->henv,
                                       (dvoid **) (void *) &_ctx->herror,
                                       OCI_HTYPE_ERROR,
                                       (size_t) 0, (dvoid **) NULL)))
    {
        NSLog(@"ERROR - OCIHandleAlloc OCI_HTYPE_ERROR");
        return NO;
    };

    if ((OCI_SUCCESS != OCIHandleAlloc( (dvoid *)_ctx->henv, (dvoid **) &(_ctx->hserver), OCI_HTYPE_SERVER,(size_t) 0, (dvoid **) 0)))
    {
        NSLog(@"ERROR - OCIHandleAlloc OCI_HTYPE_SERVER");
        return NO;
    };

    if ((OCI_SUCCESS != OCIHandleAlloc( (dvoid *)_ctx->henv, (dvoid **) &_ctx->hservice, OCI_HTYPE_SVCCTX,(size_t) 0, (dvoid **) 0)))
    {
        NSLog(@"ERROR - OCIHandleAlloc OCI_HTYPE_SVCCTX");
        return NO;
    };

    if ((OCI_SUCCESS != OCIServerAttach(_ctx->hserver, _ctx->herror, db, strlen((char *)db), 0)))
    {
        NSLog(@"ERROR - OCIServerAttach");
        return NO;
    };

    if ((OCI_SUCCESS != OCIAttrSet( (dvoid *) _ctx->hservice, OCI_HTYPE_SVCCTX, (dvoid *)_ctx->hserver,(ub4) 0, OCI_ATTR_SERVER, (OCIError *) _ctx->herror)))
    {
        NSLog(@"ERROR - OCIAttrSet OCI_HTYPE_SVCCTX");
        return NO;
    };

    if ((OCI_SUCCESS != OCIHandleAlloc((dvoid *)_ctx->henv, (dvoid **)&_ctx->hsesssion,(ub4) OCI_HTYPE_SESSION, (size_t) 0, (dvoid **) 0)))
    {
        NSLog(@"ERROR - OCIHandleAlloc OCI_HTYPE_SESSION");
        return NO;
    };

    if ((OCI_SUCCESS != OCIAttrSet((dvoid *) _ctx->hsesssion, (ub4) OCI_HTYPE_SESSION, (dvoid *) username, (ub4) strlen((char *)username), (ub4) OCI_ATTR_USERNAME, _ctx->herror)))
    {
        NSLog(@"ERROR - OCIAttrSet OCI_HTYPE_SESSION OCI_ATTR_USERNAME");
        return NO;
    };

    if ((OCI_SUCCESS != OCIAttrSet((dvoid *) _ctx->hsesssion, (ub4) OCI_HTYPE_SESSION, (dvoid *) pwd, (ub4) strlen((char *)pwd), (ub4) OCI_ATTR_PASSWORD, _ctx->herror)))
    {
        NSLog(@"ERROR - OCIAttrSet OCI_HTYPE_SESSION OCI_ATTR_PASSWORD");
        return NO;
    };

    OCI_CALL(res,_ctx,OCISessionBegin (_ctx->hservice, _ctx->herror, _ctx->hsesssion, OCI_CRED_RDBMS, (ub4) OCI_DEFAULT));

    if (!res) {return NO;} ;

    if ((OCI_SUCCESS != OCIAttrSet((dvoid *) _ctx->hservice, (ub4) OCI_HTYPE_SVCCTX,(dvoid *) _ctx->hsesssion, (ub4) 0,(ub4) OCI_ATTR_SESSION, _ctx->herror)))
    {
        NSLog(@"ERROR - OCIAttrSet OCI_HTYPE_SVCCTX OCI_ATTR_SESSION");
        return NO;
    };

    if (_cFlags.readOnly) {
    }

    return YES;
}

-(BOOL) _disconnect
{
    [self cleanup];   
    return YES;
}

- (BOOL)connect
{
    if (![self isConnected]) {

        NSString *database = [_currentDictionary objectForLazyKey:@"$_database"] ;
        NSString *user = [_currentDictionary objectForLazyKey:@"$_user"] ;
        NSString *password = [_currentDictionary objectForLazyKey:@"$_password"] ;

        if (![self _connectWithDataBase:database User:user Password:password]) {
            _lastError = FailAtOpen;
            // 	_hdbc = NULL ;
            return NO ;
        }
        _cFlags.connected = YES ;
        [[NSNotificationCenter defaultCenter] postNotificationName:MSConnectionDidConnectNotification object:self] ;
    }
    return YES ;
}

- (BOOL)disconnect
{
    if ([self isConnected]) {
        RETAIN(self) ; // since the terminateAllOperations can release us, we must keep that object alive until we decide to release it
        [self terminateAllOperations] ;

        if (![self _disconnect]){
            _lastError = FailAtClose ;
            return NO ;
        }
        //		_hdbc = NULL ;
        _cFlags.connected = NO ;
        [[NSNotificationCenter defaultCenter] postNotificationName:MSConnectionDidDisconnectNotification object:self] ;
        RELEASE(self) ;
    }
    return YES ;
}

- (MSDBResultSet *)fetchWithRequest:(NSString *)query
{
    if ([query length] && [self connect]) {

        text *sql =(text *)[query UTF8String] ;
        OCIStmt *stmt;
        MSOCIResultSet *resultSet ;
        BOOL res = TRUE;

        OCI_CALL(res,_ctx,OCIHandleAlloc((dvoid *) _ctx->henv, (dvoid **) &stmt, OCI_HTYPE_STMT, (size_t) 0, (dvoid **) 0));
        OCI_CALL(res,_ctx,OCIStmtPrepare(stmt, _ctx->herror, sql,(ub4) strlen((char *) sql),(ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT));
        OCI_CALL(res,_ctx,OCIStmtExecute(_ctx->hservice, stmt,_ctx->herror, (ub4) 0, (ub4) 0,(CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT));

        if (res) {
            resultSet = [ALLOC(MSOCIResultSet) initWithStatement:stmt connection:self] ;
            if (resultSet) {
                // === WARNING === the connection does not retain its operations...
                CArrayAddObjectWithoutRetain(&_operations, resultSet) ;
                return AUTORELEASE(resultSet) ;
            }
        }

    }
    return nil ;
}

- (MSArray *)tableNames
{
    MSArray *array = MSCreateArray(8) ;

    NEW_POOL ;

    if ([self isConnected]) {
        MSDBResultSet *resultSet = [self fetchWithRequest:@"SELECT TABLE_NAME FROM TABS"] ;

        while ([resultSet nextRow])
        {
            MSRow *row = nil ;
            NSString *tableName = nil ;

            row = [resultSet rowDictionary] ;
            tableName = [[row objectForKey:@"TABLE_NAME"] toString] ;
            
            if ([tableName length]) { MSAAdd(array, tableName) ; }
        }
    }

    KILL_POOL ;

    return AUTORELEASE(array) ;
}

- (MSDBTransaction *)openTransaction
{
    if (!_cFlags.readOnly && [self connect] && [self openedTransactionsCount] == 0) {
        // only one transaction at a time
        MSOCITransaction *transaction = [ALLOC(MSOCITransaction) initWithDatabaseConnection:self] ;
        if (transaction) {
            CArrayAddObjectWithoutRetain(&_operations, transaction) ;
            return transaction;
        }
    }
    return nil ;
}

@end


@implementation _MSOCIThreadContext

-(OCICtx *)context
{
//    NSLog(@"ctx %p",&_ctx);
    return &_ctx;
}

@end
