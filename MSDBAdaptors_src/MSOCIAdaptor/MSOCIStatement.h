
@class MSOCIConnection;

typedef struct  {
    union {
      MSChar i1;
      MSByte u1;
      MSShort i2;
      MSUShort u2;
      MSInt i4;
      MSUInt u4;
      MSLong i8;
      MSULong u8;
      double d;
      sb2 ind;
  } u;
  NSData *b;
} MSOCIBindParamInfo;

@interface MSOCIStatement : MSDBStatement {
  OCIStmt *_stmt;
  OCICtx *_ctx;
  MSOCIBindParamInfo *_bind;
  unsigned int _count;
}
- (id)initWithRequest:(NSString *)request withDatabaseConnection:(MSOCIConnection *)connection withStmt:(OCIStmt *)stmt;
@end
