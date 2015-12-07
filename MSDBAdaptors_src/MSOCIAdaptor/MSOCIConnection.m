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

#import "MSOCIAdaptorKit.h"

#define DEFAULT_TRANSACTION_TIMEOUT 60


@implementation MSOCIConnection

- (id)initWithConnectionDictionary:(MSDictionary *)dictionary
{
  if ((self = [super initWithConnectionDictionary:dictionary])) {
    id db, hostname, port;
    db= [dictionary objectForLazyKey:@"database"];
    hostname= [dictionary objectForLazyKey:@"hostname"];
    if (hostname) {
      port= [dictionary objectForLazyKey:@"port"];
      if (!port) port= @"1521";
      db= FMT(@"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=%@)(Port=%@))(CONNECT_DATA=(SID=%@)))", hostname, port, db);
    }
    _database= [db copy];
    _user= [[dictionary objectForLazyKey:@"user"] copy];
    _password= [[dictionary objectForLazyKey:@"password"] copy];
    if (![_database length] || ![_user length] || ![_password length])
      DESTROY(self) ;
    setenv("NLS_LANG", "AMERICAN_AMERICA.UTF8", 1);
  }
  return self ;
}

- (void)dealloc
{
  RELEASE(_database);
  RELEASE(_user);
  RELEASE(_password);
  [super dealloc];
}

-(OCICtx *)context
{
  return &_ctx;
}

BOOL _check_err(sword ociReturnValue, void *herror, NSString **error) {
  switch (ociReturnValue) {
    case OCI_SUCCESS: return YES;
    case OCI_SUCCESS_WITH_INFO: *error= @"OCI_SUCCESS_WITH_INFO"; return NO;
    case OCI_NEED_DATA:         *error= @"OCI_NEED_DATA"; return NO;
    case OCI_ERROR: {
      sb4 errcode= 0; unichar errbuf[1024]; ub4 recordno= 1; CString *str= CCreateString(0);
      errbuf[0]= 0;
      while (OCIErrorGet(herror, recordno, 0, &errcode, (text*)errbuf, sizeof(errbuf), OCI_HTYPE_ERROR) == OCI_SUCCESS) {
        CStringAppendBytes(str, NSUTF16StringEncoding, errbuf, _utf16len(errbuf, sizeof(errbuf) / 2));
        recordno++;
      }
      if (CStringLength(str) > 0 && CStringCharacterAtIndex(str, CStringLength(str) - 1) == '\n')
        str->length--;
      *error= AUTORELEASE(str);
      return NO;
    }
    case OCI_INVALID_HANDLE:    *error= @"OCI_INVALID_HANDLE"; return NO;
    case OCI_STILL_EXECUTING:   *error= @"OCI_STILL_EXECUTING"; return NO;
    case OCI_CONTINUE:          *error= @"OCI_CONTINUE"; return NO;
    default:                    *error= @"unknown error"; return NO;
  }
}

static BOOL _check_noerr(MSOCIConnection *self, sword ociReturnValue, NSString *err) {
  if (ociReturnValue == OCI_SUCCESS) return YES;
  [self error:err];
  return NO;
}

static inline BOOL _check(MSOCIConnection *self, sword ociReturnValue) {
  NSString *error= nil; BOOL ret;
  if (!(ret= _check_err(ociReturnValue, self->_ctx.herror, &error)))
    [self error:error];
  return ret;
}

- (BOOL)_connect
{
  BOOL ret = YES;
  NSData *dbname= [_database dataUsingEncoding:NSUTF16StringEncoding];
  NSData *username= [_user dataUsingEncoding:NSUTF16StringEncoding];
  NSData *pwd= [_password dataUsingEncoding:NSUTF16StringEncoding];
  ret= ret && _check_noerr(self, OCIEnvCreate(&_ctx.henv, OCI_UTF16 | OCI_OBJECT | OCI_THREADED, NULL, NULL, NULL, NULL, 0, NULL), @"Unable to create environment");
  ret= ret && _check_noerr(self, OCIHandleAlloc((dvoid *)_ctx.henv, (dvoid **)&_ctx.herror,   OCI_HTYPE_ERROR, 0, 0), @"Unable to create error handle");
  ret= ret && _check_noerr(self, OCIHandleAlloc((dvoid *)_ctx.henv, (dvoid **)&_ctx.hserver,  OCI_HTYPE_SERVER,0, 0), @"Unable to create server handle");
  ret= ret && _check(self, OCIServerAttach(_ctx.hserver, _ctx.herror, (text*)[dbname bytes], (sb4)[dbname length], OCI_DEFAULT));
  ret= ret && _check_noerr(self, OCIHandleAlloc((dvoid *)_ctx.henv, (dvoid **)&_ctx.hservice, OCI_HTYPE_SVCCTX,0, 0), @"Unable to create service handle");
  ret= ret && _check(self, OCIAttrSet((dvoid *)_ctx.hservice, OCI_HTYPE_SVCCTX, (dvoid *)_ctx.hserver, (ub4)0, OCI_ATTR_SERVER, (OCIError *)_ctx.herror));
  ret= ret && _check(self, OCIHandleAlloc((dvoid *)_ctx.henv, (dvoid **)&_ctx.hsession, (ub4)OCI_HTYPE_SESSION, 0, 0));
  ret= ret && _check(self, OCIAttrSet((dvoid *)_ctx.hsession, (ub4) OCI_HTYPE_SESSION, (text*)[username bytes], (sb4)[username length], (ub4)OCI_ATTR_USERNAME, _ctx.herror));
  ret= ret && _check(self, OCIAttrSet((dvoid *)_ctx.hsession, (ub4) OCI_HTYPE_SESSION, (text*)[pwd bytes], (sb4)[pwd length], (ub4)OCI_ATTR_PASSWORD, _ctx.herror));
  ret= ret && _check(self, OCISessionBegin(_ctx.hservice, _ctx.herror, _ctx.hsession, OCI_CRED_RDBMS, (ub4) OCI_DEFAULT));
  ret= ret && _check(self, OCIAttrSet((dvoid *)_ctx.hservice, (ub4) OCI_HTYPE_SVCCTX,(dvoid *) _ctx.hsession, (ub4) 0,(ub4) OCI_ATTR_SESSION, _ctx.herror));
  return ret;
}

-(BOOL)_disconnect
{
  BOOL ret = YES;
  ret= ret && _check(self, OCISessionEnd(_ctx.hservice, _ctx.herror, _ctx.hsession, (ub4)OCI_DEFAULT));
  ret= ret && _check(self, OCIHandleFree((dvoid *)_ctx.hsession,  (ub4)OCI_HTYPE_SESSION));
  ret= ret && _check(self, OCIServerDetach(_ctx.hserver,_ctx.herror, (ub4)OCI_DEFAULT));
  ret= ret && _check(self, OCIHandleFree((dvoid *)_ctx.hserver,  (ub4)OCI_HTYPE_SERVER));
  ret= ret && _check(self, OCIHandleFree((dvoid *)_ctx.hservice, (ub4)OCI_HTYPE_SVCCTX));
  ret= ret && _check(self, OCIHandleFree((dvoid *)_ctx.herror,   (ub4)OCI_HTYPE_ERROR));
  ret= ret && _check(self, OCIHandleFree((dvoid *)_ctx.henv,     (ub4)OCI_HTYPE_ENV));
  return YES;
}

#pragma mark Scheme

- (MSArray *)tableNames
{
  NEW_POOL ;
  CArray *array = CCreateArray(8) ;
  MSDBResultSet *set ;
  set = [self fetchWithRequest:@"SELECT TABLE_NAME FROM TABS"] ;
  while ([set nextRow]) {
    NSString *s = [[set objectAtColumn:0] toString] ;
    if ([s length]) { CArrayAddObject(array, s) ; }
  }
  KILL_POOL;
  return AUTORELEASE((MSArray*)array) ;
}

#pragma mark Transaction

- (BOOL)isInTransaction
{
  // OCI is always in transaction mode
  return YES;
}

- (BOOL)beginTransaction
{
  BOOL ret= YES;
  if (_transactionLevel > 0)
    ret= _check(self, OCITransStart(_ctx.hservice, _ctx.herror, DEFAULT_TRANSACTION_TIMEOUT, OCI_TRANS_NEW));
  if (ret) ++_transactionLevel;
  return ret;
}

- (BOOL)commit
{
  BOOL ret= _check(self, OCITransCommit(_ctx.hservice, _ctx.herror, OCI_DEFAULT));
  if (ret && _transactionLevel > 0) --_transactionLevel;
  return ret;
}

- (BOOL)rollback
{
  BOOL ret= _check(self, OCITransRollback(_ctx.hservice, _ctx.herror, OCI_DEFAULT));
  if (ret && _transactionLevel > 0) --_transactionLevel;
  return ret;
}


#pragma mark Request

//  _check(self, OCIAttrGet(stmt, OCI_HTYPE_STMT, &stmtType, NULL, OCI_ATTR_STMT_TYPE, _ctx.herror))

static NSString *_replaceQuestionMarkBinds(NSString *request) {
  NSUInteger i, e; unichar u, limit= 0; unsigned p= 0;
  SES ses= SESFromString(request);
  CString *ret= CCreateString(SESLength(ses));
  for(i= SESStart(ses), e= SESEnd(ses); i < e && (u= SESIndexN(ses, &i));) {
    if(u == '\'' || u == '\"') {
      if (limit == u)
        limit= 0;
      else if(!limit)
        limit= u;
    }
    if(!limit && u == '?')
      CStringAppendFormat(ret, ":%u", p++);
    else
      CStringAppendCharacter(ret, u);
  }
  return AUTORELEASE(ret);
}

static inline OCIStmt* OCI_Prepare(MSOCIConnection *self, NSString *request) {
  OCIStmt *stmt; NSData *req;
  if ([request length]
   && _check(self, OCIHandleAlloc((dvoid *)self->_ctx.henv, (dvoid **)&stmt, OCI_HTYPE_STMT, 0, 0))) {
    req= [request dataUsingEncoding:NSUTF16StringEncoding];
    if (_check(self, OCIStmtPrepare(stmt, self->_ctx.herror, (text*)[req bytes], (ub4)[req length], (ub4)OCI_NTV_SYNTAX, (ub4)OCI_DEFAULT)))
      return stmt;
    else { OCIHandleFree(stmt, OCI_HTYPE_STMT); }}
  return NULL;
}
- (MSDBStatement *)statementWithRequest:(NSString *)request
{
  OCIStmt *stmt= OCI_Prepare(self, request= _replaceQuestionMarkBinds(request));
  if (stmt)
    return AUTORELEASE([ALLOC(MSOCIStatement) initWithRequest:request withDatabaseConnection:self withStmt:stmt]);
  return nil ;
}

- (MSDBResultSet *)fetchWithRequest:(NSString *)request
{
  OCIStmt *stmt= OCI_Prepare(self, request);
  if (stmt) {
    if (_check(self, OCIStmtExecute(_ctx.hservice, stmt, _ctx.herror, 0, 0, NULL, NULL, OCI_DEFAULT))) {
      return AUTORELEASE([ALLOC(MSOCIResultSet) initWithConnection:self ocistmt:stmt stmt:nil]);}
    else {
      OCIHandleFree(stmt, OCI_HTYPE_STMT);}}
  return nil;
}

- (MSInt)executeRawSQL:(NSString *)request
{
  BOOL ok; OCIStmt *stmt;
  ok= (stmt= OCI_Prepare(self, request)) != NULL;
  ok= ok && _check(self, OCIStmtExecute(_ctx.hservice, stmt, _ctx.herror, 1, 0, NULL, NULL, OCI_DEFAULT));
  ok= ok && _check(self, OCIHandleFree(stmt, OCI_HTYPE_STMT));
  return ok ? 0 : -1;
}

- (NSString *)escapeString:(NSString *)aString withQuotes:(BOOL)withQuotes ;
{
  return [self notImplemented:_cmd];
}

@end
