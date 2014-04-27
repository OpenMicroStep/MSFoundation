/*
 
 MSOCITransaction.m
 
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

#import "MSOCITransaction.h"
#import "MSOCIConnection.h"

@implementation MSOCITransaction

- (BOOL)appendSQLCommand:(NSString *)sql error:(MSInt *)errorPtr
{
    BOOL res = YES ;
    OCICtx *_ctx =  [(MSOCIConnection *)_connection context];
    text *sqlText =(text *)[sql UTF8String] ;

    OCIStmt *stmt=NULL;


    OCI_CALL(res,_ctx,OCIHandleAlloc((dvoid *) _ctx->henv, (dvoid **) &stmt, OCI_HTYPE_STMT, (size_t) 0, (dvoid **) 0));
    OCI_CALL(res,_ctx,OCIStmtPrepare(stmt, _ctx->herror, sqlText,(ub4) strlen((char *) sqlText),(ub4) OCI_NTV_SYNTAX, (ub4) OCI_DEFAULT));
    OCI_CALL(res,_ctx,OCIStmtExecute(_ctx->hservice, stmt,_ctx->herror, (ub4) 1, (ub4) 0,(CONST OCISnapshot *) NULL, (OCISnapshot *) NULL, OCI_DEFAULT));

    if (stmt) { OCIHandleFree(stmt, OCI_HTYPE_STMT); }

    return res ;
}

- (void)terminateOperation
{
    if ([self isOpened]) {
        BOOL res = YES ;
        OCICtx *_ctx =  [(MSOCIConnection *)_connection context];
        OCI_CALL(res, _ctx, OCITransRollback(_ctx->hservice, _ctx->herror, (ub4) 0));

        if (!res) {
            MSRaiseFrom(NSGenericException, self, _cmd, @"impossible to rollback current transaction") ;
        }

        [(_MSDBGenericConnection *)_connection unregisterOperation:self] ;
        [super terminateOperation] ;
    }
}


- (BOOL)saveWithError:(MSInt *)errorPtr
{
    if ([self isOpened]) {

        BOOL res = YES ;
        OCICtx *_ctx =  [(MSOCIConnection *)_connection context];
        OCI_CALL(res, _ctx, OCITransCommit(_ctx->hservice, _ctx->herror, (ub4) 0));

        if (!res) {
            [self terminateOperation] ;
            if (errorPtr) { *errorPtr = 0 ; }
            return NO ;
        }
        [(_MSDBGenericConnection *)_connection unregisterOperation:self] ;
        [super terminateOperation] ;
        return YES ;
    }
    return NO ;
}

@end
