#import "MSOCIAdaptorKit.h"

@implementation MSOCIStatement

- (id)initWithRequest:(NSString *)request withDatabaseConnection:(MSOCIConnection *)connection withStmt:(OCIStmt *)stmt
{
    if((self= [super initWithRequest:request withDatabaseConnection:connection])) {
        _stmt= stmt;
        _ctx= [connection context];
        if (!_check(self, OCIAttrGet(stmt, OCI_HTYPE_STMT, &_count, NULL, OCI_ATTR_BIND_COUNT, _ctx->herror))) {
          _count= 0;
        }
        else
          _bind= MSCalloc(_count, sizeof(MSOCIBindParamInfo), "MSOCIStatement");
    }
    return self;
}

- (void)terminateOperation
{
  if (_bind) {
    unsigned int i;
    for(i= 0; i < _count; ++i) {
      if (_bind[i].b)
        [_bind[i].b release];
    }
    MSFree(_bind, "MSOCIStatement");
    _bind= NULL;}
  if (_stmt) {
    OCIHandleFree((dvoid *)_stmt, (ub4)OCI_HTYPE_STMT);
    _stmt= NULL; }
  [super terminateOperation];
}

static inline BOOL _check(MSOCIStatement *self, sword ociReturnValue) {
  NSString *error= nil; BOOL ret;
  if (!(ret= _check_err(ociReturnValue, self->_ctx->herror, &error)))
    [self error:error];
  return ret;
}

static inline BOOL _check_idx(MSOCIStatement *self, MSUInt idx) {
  BOOL ret;
  if (!(ret = idx < self->_count))
    [self error:FMT(@"index %u is out of bounds [0, %u[", idx, self->_count)];
  return ret;
}

#define OCI_BIND(VALUE, IDX, UNION_ACCESS, CTYPE, OCITYPE) ({ \
  OCIBind *hbnd; \
  _bind[parameterIndex].u.UNION_ACCESS= VALUE; \
  _check(self, OCIBindByPos(_stmt, &hbnd, _ctx->herror, \
    (ub4)parameterIndex + 1, &_bind[parameterIndex].u.UNION_ACCESS, (sb8)sizeof(CTYPE), OCITYPE, \
    0, 0, 0, 0, 0, OCI_DEFAULT)); \
})

#define CHECKIDX(SELF, IDX) _check_idx(self, IDX)

- (BOOL)bindChar:           (MSChar)value at:(MSUInt)parameterIndex
{
  return [self bindInt:(MSInt)value at:parameterIndex];
}
- (BOOL)bindByte:           (MSByte)value at:(MSUInt)parameterIndex
{
  return [self bindUnsignedInt:(MSUInt)value at:parameterIndex];
}
- (BOOL)bindShort:         (MSShort)value at:(MSUInt)parameterIndex
{
  return [self bindInt:(MSInt)value at:parameterIndex];
}
- (BOOL)bindUnsignedShort:(MSUShort)value at:(MSUInt)parameterIndex
{
  return [self bindUnsignedInt:(MSUInt)value at:parameterIndex];
}
- (BOOL)bindInt:             (MSInt)value at:(MSUInt)parameterIndex
{
  return CHECKIDX(self, parameterIndex) && OCI_BIND(value, parameterIndex, i4, MSInt, SQLT_INT);
}
- (BOOL)bindUnsignedInt:    (MSUInt)value at:(MSUInt)parameterIndex
{
  return CHECKIDX(self, parameterIndex) && OCI_BIND(value, parameterIndex, u4, MSUInt, SQLT_UIN);
}
- (BOOL)bindLong:           (MSLong)value at:(MSUInt)parameterIndex
{
  if (!CHECKIDX(self, parameterIndex)) return NO;
  else {
    OCIBind *hbnd;
    DESTROY(_bind[parameterIndex].b);
    CBuffer *b= CCreateBuffer(sizeof(OCINumber));
    OCINumberFromInt(_ctx->herror, &value, sizeof(MSLong), OCI_NUMBER_SIGNED, (OCINumber*)CBufferBytes(b));
    b->length= sizeof(OCINumber);
    _bind[parameterIndex].b= (id)b;
    return _check(self, OCIBindByPos(_stmt, &hbnd, _ctx->herror,
      (ub4)parameterIndex + 1, (void *)CBufferBytes(b), (sb8)CBufferLength(b), SQLT_VNU,
      0, 0, 0, 0, 0, OCI_DEFAULT));
  }

}
- (BOOL)bindUnsignedLong:  (MSULong)value at:(MSUInt)parameterIndex
{
  if (!CHECKIDX(self, parameterIndex)) return NO;
  else {
    OCIBind *hbnd;
    DESTROY(_bind[parameterIndex].b);
    CBuffer *b= CCreateBuffer(sizeof(OCINumber));
    OCINumberFromInt(_ctx->herror, &value, sizeof(MSULong), OCI_NUMBER_UNSIGNED, (OCINumber*)CBufferBytes(b));
    b->length= sizeof(OCINumber);
    _bind[parameterIndex].b= (id)b;
    return _check(self, OCIBindByPos(_stmt, &hbnd, _ctx->herror,
      (ub4)parameterIndex + 1, (void *)CBufferBytes(b), (sb8)CBufferLength(b), SQLT_VNU,
      0, 0, 0, 0, 0, OCI_DEFAULT));
  }
}
- (BOOL)bindFloat:           (float)value at:(MSUInt)parameterIndex
{
  return CHECKIDX(self, parameterIndex) && OCI_BIND(value, parameterIndex, d, double, SQLT_FLT);
}
- (BOOL)bindDouble:         (double)value at:(MSUInt)parameterIndex
{
  return CHECKIDX(self, parameterIndex) && OCI_BIND(value, parameterIndex, d, double, SQLT_FLT);
}
- (BOOL)bindDate:          (MSDate *)date at:(MSUInt)parameterIndex
{
  if (!CHECKIDX(self, parameterIndex)) return NO;
  else {
    OCIBind *hbnd;
    DESTROY(_bind[parameterIndex].b);
    CBuffer *b= CCreateBuffer(7);
    unsigned year= [date yearOfCommonEra];
    CBufferAppendByte(b, (year / 100) + 100);
    CBufferAppendByte(b, (year % 100) + 100);
    CBufferAppendByte(b, [date monthOfYear]);
    CBufferAppendByte(b, [date dayOfMonth]);
    CBufferAppendByte(b, [date hourOfDay] + 1);
    CBufferAppendByte(b, [date minuteOfHour] + 1);
    CBufferAppendByte(b, [date secondOfMinute] + 1);
    _bind[parameterIndex].b= (id)b;
    return _check(self, OCIBindByPos(_stmt, &hbnd, _ctx->herror,
      (ub4)parameterIndex + 1, (void *)CBufferBytes(b), (sb8)CBufferLength(b), SQLT_DAT,
      0, 0, 0, 0, 0, OCI_DEFAULT));
  }
}

- (BOOL)bindString:     (NSString*)string at:(MSUInt)parameterIndex
{
  BOOL ret= NO;
  if (CHECKIDX(self, parameterIndex)) {
    CBuffer *b; OCIBind *hbnd; SES ses;
    ses= SESFromString(string);
    b= CCreateBuffer(0);
    CBufferAppendSES(b, ses, NSUTF16StringEncoding);
    CBufferAppendBytes(b, "\0\0", 2);
    DESTROY(_bind[parameterIndex].b);
    _bind[parameterIndex].b= (id)b;
    ret= _check(self, OCIBindByPos(_stmt, &hbnd, _ctx->herror,
      (ub4)parameterIndex + 1, (void *)CBufferBytes(b), (sb8)CBufferLength(b), SQLT_STR,
      0, 0, 0, 0, 0, OCI_DEFAULT));
    if (ret) {
      ub1 charsetForm= SQLCS_NCHAR;
      ub2 charset= OCI_UTF16ID;
      OCIAttrSet(hbnd, OCI_HTYPE_BIND, &charsetForm, 0, OCI_ATTR_CHARSET_FORM, 0);
      OCIAttrSet(hbnd, OCI_HTYPE_BIND, &charset, 0, OCI_ATTR_CHARSET_ID, 0);
    }
  }
  return ret;
}
- (BOOL)bindBuffer:     (MSBuffer*)buffer at:(MSUInt)parameterIndex
{
  if (!CHECKIDX(self, parameterIndex)) return NO;
  else {
    OCIBind *hbnd;
    ASSIGNCOPY(_bind[parameterIndex].b, buffer);
    return _check(self, OCIBindByPos(_stmt, &hbnd, _ctx->herror,
      (ub4)parameterIndex+ 1, (void *)[_bind[parameterIndex].b bytes], (sb8)[_bind[parameterIndex].b length], SQLT_BIN,
      0, 0, 0, 0, 0, OCI_DEFAULT));
  }
}
- (BOOL)bindNullAt:(MSUInt)parameterIndex
{
  if (!CHECKIDX(self, parameterIndex)) return NO;
  else {
    OCIBind *hbnd;
    _bind[parameterIndex].u.ind= OCI_IND_NULL;
    return _check(self, OCIBindByPos(_stmt, &hbnd, _ctx->herror,
      (ub4)parameterIndex + 1, 0, 0, 0,
      &_bind[parameterIndex].u.ind, 0, 0, 0, 0, OCI_DEFAULT));
  }
}

- (MSDBResultSet *)fetch
{
  if (_check(self, OCIStmtExecute(_ctx->hservice, _stmt, _ctx->herror, 0, 0, NULL, NULL, OCI_DEFAULT))) {
      return AUTORELEASE([ALLOC(MSOCIResultSet) initWithConnection:(MSOCIConnection*)_connection ocistmt:_stmt stmt:self]);}
  return nil;
}

- (MSInt)execute
{
  ub4 row_count; BOOL ok;
  ok= _check(self, OCIStmtExecute(_ctx->hservice, _stmt, _ctx->herror, 1, 0, NULL, NULL, OCI_DEFAULT));
  ok= ok && _check(self, OCIAttrGet(_stmt, OCI_HTYPE_STMT, &row_count, 0, OCI_ATTR_ROW_COUNT, _ctx->herror));
  return ok ? (MSInt)row_count : MSSQL_ERROR;
}

@end