#import "msdb_validate.h"

#define UTF8(OBJ) [[OBJ description] UTF8String]
#define TASSERT_EXECSQL(W, C, SQL, MSG...) TASSERT(W, [C executeRawSQL:SQL] != MSSQL_ERROR, "%s: %s", UTF8(FMT(MSG)), UTF8([C lastError]))

static MSDictionary* tst_connectionDictionary(test_t *test) {
  MSDBTestsContext *ctx= (MSDBTestsContext *)TSHAREDCONTEXT_GET(test);
  return [ctx->adaptors objectAtIndex:ctx->idx];
}
static MSDBConnection *tst_assertGetConnection(test_t *test) {
  MSDBConnection *connection; MSDictionary *params;

  params= tst_connectionDictionary(test);
  TASSERT(test, params != nil, "unable to load parameters", params);
  connection= [MSDBConnection connectionWithDictionary:params];
  TASSERT(test, connection != nil, "unable to find adaptor for database %s", UTF8(params));
  TASSERT(test, [connection connect], "unable to connect to database %s: %s", UTF8(params), UTF8([connection lastError]));
  return [connection isConnected] ? connection : nil;
}
static MSDBConnection *tst_getConnection(test_t *test) {
  MSDBConnection *connection; MSDictionary *params;

  params= tst_connectionDictionary(test);
  connection= [MSDBConnection connectionWithDictionary:params];
  return [connection connect] ? connection : nil;
}

static void tst_prepare(test_t *test) {
  MSDBConnection *connection; MSDictionary *adaptor; NSString *type;
  adaptor= tst_connectionDictionary(test);
  connection= tst_assertGetConnection(test);
  type= [adaptor objectForKey:@"adaptor"];
  if ([@"MSSQLCipherAdaptor" isEqual:type]) {
    TASSERT_EXECSQL(test, connection, @"DROP TABLE IF EXISTS TEST1", @"unable to remove table TEST1");
    TASSERT_EXECSQL(test, connection, @"DROP TABLE IF EXISTS TEST2", @"unable to remove table TEST2");
    TASSERT_EXECSQL(test, connection, @"CREATE TABLE TEST1(c1 TEXT DEFAULT NULL, c2 INTEGER DEFAULT NULL, c3 TEXT, c4 DATETIME DEFAULT NULL)", @"unable to create table TEST1");
    TASSERT_EXECSQL(test, connection, @"CREATE TABLE TEST2("
                                        @"tstr TEXT DEFAULT NULL, "
                                        @"tdat INTEGER DEFAULT NULL, "
                                        @"tint INTEGER DEFAULT NULL, "
                                        @"tdec NUMERIC DEFAULT NULL, "
                                        @"tbin BLOB DEFAULT NULL,"
                                        @"ttxt TEXT DEFAULT NULL"
                                      @")", @"unable to create table TEST2");
  }
  else if ([@"MSOCIAdaptor" isEqual:type]) { // VARCHAR, DATE, INTEGER, DECIMAL, BLOB, CLOB
    id tables= [connection tableNames];
    if ([tables containsObject:@"TEST1"]) TASSERT_EXECSQL(test, connection, @"DROP TABLE TEST1", @"unable to remove table TEST1");
    if ([tables containsObject:@"TEST2"]) TASSERT_EXECSQL(test, connection, @"DROP TABLE TEST2", @"unable to remove table TEST2");
    TASSERT_EXECSQL(test, connection, @"CREATE TABLE TEST1(c1 VARCHAR(255) DEFAULT NULL, c2 INTEGER DEFAULT NULL, c3 VARCHAR(255), c4 DATE DEFAULT NULL)", @"unable to create table TEST1");
    TASSERT_EXECSQL(test, connection, @"CREATE TABLE TEST2("
                                        @"tstr VARCHAR(255) DEFAULT NULL, "
                                        @"tdat DATE DEFAULT NULL, "
                                        @"tint INTEGER DEFAULT NULL, "
                                        @"tdec DECIMAL(31, 10) DEFAULT NULL, "
                                        @"tbin BLOB DEFAULT NULL,"
                                        @"ttxt CLOB DEFAULT NULL"
                                      @")", @"unable to create table TEST2");
  }
  else if ([@"MSMySQLAdaptor" isEqual:type]) {
    TASSERT_EXECSQL(test, connection, @"CREATE TABLE TEST1(c1 VARCHAR(255) DEFAULT NULL, c2 INTEGER DEFAULT NULL, c3 TEXT, c4 DATETIME DEFAULT NULL)", @"unable to create table TEST1");
  }
  else if ([@"MSODBCAdaptor" isEqual:type]) {
    TASSERT_EXECSQL(test, connection, @"CREATE TABLE TEST1(c1 VARCHAR(255) DEFAULT NULL, c2 INTEGER DEFAULT NULL, c3 TEXT, c4 DATETIME DEFAULT NULL)", @"unable to create table TEST1");
  }
  else {
    TASSERT(test, NO, "unsupported adaptor type: %s", UTF8(type));
  }

}
static void tst_next(test_t *test) {
  MSDBTestsContext *ctx= (MSDBTestsContext *)TSHAREDCONTEXT_GET(test);
  ++ctx->idx;
}

static void tst_connection(test_t *test)
{
  MSDBConnection *connection;

  connection= tst_getConnection(test);
  TASSERT(test, [connection isConnected], "connection should be connected");
  [connection disconnect];
  TASSERT(test, ![connection isConnected], "connection should be disconnected");
  TASSERT(test, [connection connect], "unable to reconnect to database");
  TASSERT(test, [connection isConnected], "connection should be connected");
  [connection disconnect];
  TASSERT(test, ![connection isConnected], "connection should be disconnected again");
}

static void tst_tables(test_t *test)
{
  MSDBConnection *connection= tst_getConnection(test);
  if (connection) {
    id tables;

    tables= [connection tableNames];
    TASSERT(test, [tables containsObject:@"TEST1"], "the table TEST1 must exists");
    TASSERT(test, [tables containsObject:@"TEST2"], "the table TEST2 must exists");

    [connection disconnect];}
}


struct tst_transaction_struct {
  mtx_t mutex;
  cnd_t cond;
  test_t *test;
  int count, size;
};

static void tst_transactions_wait(struct tst_transaction_struct* barrier)
{
  mtx_lock(&barrier->mutex);
  if(++barrier->count >= barrier->size) {
    barrier->count = 0;
    cnd_broadcast(&barrier->cond);
  } else {
    cnd_wait(&barrier->cond, &(barrier->mutex));
  }
  mtx_unlock(&barrier->mutex);
}

static int tst_transactions_thread1(void *arg) {
  NEW_POOL;
  struct tst_transaction_struct *s= (struct tst_transaction_struct*)arg;
  test_t *test= s->test;
  MSDBConnection *connection= tst_getConnection(test);
  if (connection) {
    // Condition 1: Wait for 0,1,2 connected
    tst_transactions_wait(s);
    // Condition 2: Wait for 0 inserts inside a transaction
    tst_transactions_wait(s);

    TASSERT(test, ![[connection select:@[@"c2"] from:@"TEST1" where:@"c2=10"] nextRow], "found row inserted by another transaction");
    TASSERT(test, [connection beginTransaction], "unable to begin transaction: %s", UTF8([connection lastError]));
    TASSERT(test, ![[connection fetchWithRequest:@"SELECT c2 FROM TEST1 WHERE c2=10"] nextRow], "found row inserted by another transaction");
    TASSERT(test, [connection executeRawSQL:@"INSERT INTO TEST1 (c2) VALUES (11)"] != MSSQL_ERROR, "unable insert row: %s", UTF8([connection lastError]));

    // Condition 3: Wait for 1 inserts inside a transaction
    tst_transactions_wait(s);
    // Condition 4: Wait for 0 commit
    tst_transactions_wait(s);

    TASSERT(test, [connection rollback], "unable to rollback: %s", UTF8([connection lastError]));

    // Condition 5: Wait for 1 rollback
    tst_transactions_wait(s);

    TASSERT(test, ![[connection fetchWithRequest:@"SELECT c2 FROM TEST1 WHERE c2=11"] nextRow], "found row inserted by another transaction");

    [connection disconnect];
  }
  KILL_POOL;
  return 0;
}

static int tst_transactions_thread2(void *arg) {
  NEW_POOL;
  struct tst_transaction_struct *s= (struct tst_transaction_struct*)arg;
  test_t *test= s->test;
  MSDBConnection *connection= tst_getConnection(test);
  if (connection) {
    // Condition 1: Wait for 0,1,2 connected
    tst_transactions_wait(s);
    // Condition 2: Wait for 0 inserts inside a transaction
    tst_transactions_wait(s);

    TASSERT(test, ![[connection select:@[@"c2"] from:@"TEST1" where:@"c2=10"] nextRow], "found row inserted by another transaction");

    // Condition 3: Wait for 1 inserts inside a transaction
    tst_transactions_wait(s);
    // Condition 4: Wait for 0 commit
    tst_transactions_wait(s);

    [connection rollback]; // If we are in autocommit mode, force getting out
    TASSERT(test, [[connection fetchWithRequest:@"SELECT c2 FROM TEST1 WHERE c2=10"] nextRow], "unable find inserted row");
    TASSERT(test, ![[connection fetchWithRequest:@"SELECT c2 FROM TEST1 WHERE c2=11"] nextRow], "found row inserted by another transaction");

    // Condition 5: Wait for 1 rollback
    tst_transactions_wait(s);

    TASSERT(test, ![[connection fetchWithRequest:@"SELECT c2 FROM TEST1 WHERE c2=11"] nextRow], "found row inserted by another transaction");
    [connection disconnect];
  }
  KILL_POOL;
  return 0;
}

static void tst_transactions(test_t *test)
{
  if ([@"MSSQLCipherAdaptor" isEqual:[tst_connectionDictionary(test) objectForKey:@"adaptor"]]) return;
  struct tst_transaction_struct s;
  MSDBConnection *connection= tst_getConnection(test);
  if (connection) {
    thrd_t thread1, thread2;
    s.size= 3;
    s.test= test;

    // Setup
    {
      // Init conditions
      s.count= 0;
      mtx_init(&s.mutex, mtx_plain);
      cnd_init(&s.cond);

      // Spawn the two threads.
      thrd_create(&thread1, &tst_transactions_thread1, &s);
      thrd_create(&thread2, &tst_transactions_thread2, &s);
    }

    // Condition 1: Wait for 0,1,2 connected
    tst_transactions_wait(&s);

    TASSERT(test, [connection beginTransaction], "unable to begin transaction: %s", UTF8([connection lastError]));
    TASSERT(test, [connection executeRawSQL:@"INSERT INTO TEST1 (c2) VALUES (10)"] != MSSQL_ERROR, "unable insert row: %s", UTF8([connection lastError]));
    TASSERT(test, [[connection fetchWithRequest:@"SELECT c2 FROM TEST1 WHERE c2=10"] nextRow], "unable find inserted raw");

    // Condition 2: Wait for 0 inserts inside a transaction
    tst_transactions_wait(&s);
    // Condition 3: Wait for 1 inserts inside a transaction
    tst_transactions_wait(&s);

    TASSERT(test, [connection commit], "unable to commit: %s", UTF8([connection lastError]));

    // Condition 4: Wait for 0 commit
    tst_transactions_wait(&s);

    {
      NEW_POOL;
      TASSERT(test, [[connection fetchWithRequest:@"SELECT c2 FROM TEST1 WHERE c2=10"] nextRow], "unable find inserted raw");
      TASSERT(test, ![[connection fetchWithRequest:@"SELECT c2 FROM TEST1 WHERE c2=11"] nextRow], "found raw inserted by another transaction");
      KILL_POOL;
    }

    // Condition 5: Wait for 1 rollback
    tst_transactions_wait(&s);

    {
      NEW_POOL;
      TASSERT(test, ![[connection fetchWithRequest:@"SELECT c2 FROM TEST1 WHERE c2=11"] nextRow], "found raw inserted by another transaction");
      KILL_POOL;
    }

    thrd_join(thread1, NULL);
    thrd_join(thread2, NULL);

    mtx_destroy(&s.mutex);
    cnd_destroy(&s.cond);
    [connection disconnect];
  }
}

static void tst_types(test_t *test)
{
  MSDBConnection *connection= tst_getConnection(test);
  if (connection) {
    MSDBResultSet *r;
    NSString  *tstr=  @"abcdefghijklmnopqrstuvwxyz";
    MSDate    *tdat= [MSDate date];
    NSNumber  *tint=  [NSNumber numberWithInt:987654];
    MSDecimal *tdec=  [MSDecimal decimalWithUTF8String:"12345678987654321.123456789"];
    MSBuffer  *tbin=  [MSBuffer bufferWithCString:"abcdefghijklmnopqrstuvwxyz"];
    MSString  *ttxt=  [MSString mutableString];
    for(int i = 0; i < 20; ++i)
      [ttxt appendString:@"abcdefghijklmnopqrstuvwxyz\n"];

    TASSERT_EQUALS_LLD_S(test, ([connection insert:@{
      @"tstr": tstr,
      @"tdat": tdat,
      @"tint": tint,
      @"tdec": tdec,
      @"tbin": tbin,
      @"ttxt": ttxt,
    } into:@"TEST2"]), 1, "unable to insert row: %s", UTF8([connection lastError]));

    r= [connection select:@[@"tstr", @"tdat", @"tint", @"tdec", @"tbin", @"ttxt"] from:@"TEST2" where:nil];
    TASSERT(test, [r nextRow], "unable to find inserted row");
    TASSERT_EQUALS_OBJ(test, [r objectForKey:@"tstr"], tstr);
    TASSERT_EQUALS_OBJ(test, [r objectForKey:@"tdat"], tdat);
    TASSERT_EQUALS_OBJ(test, [r objectForKey:@"tint"], tint);
    TASSERT_EQUALS_OBJ(test, [r objectForKey:@"tdec"], tdec);
    TASSERT_EQUALS_OBJ(test, [r objectForKey:@"tbin"], tbin);
    TASSERT_EQUALS_OBJ(test, [r objectForKey:@"ttxt"], ttxt);
    [r terminateOperation];
  }
}

static void tst_statements(test_t *test)
{
  MSDBConnection *connection= tst_getConnection(test);
  if (connection) {
    id obj; MSLong msLongValue; BOOL ok= YES;
    MSDBStatement *s;
    MSDBResultSet *r;

    TASSERT_EQUALS_LLD_S(test, [connection insert:@{@"c1":@"1"} into:@"TEST1"], 1, "unable to insert row: %s", UTF8([connection lastError]));
    TASSERT_EQUALS_LLD_S(test, [connection countRowsFrom:@"TEST1" where:@"c1 = ?" withBindings:@[@"1"]], 1, "unable to find inserted row");
    TASSERT_EQUALS_LLD_S(test, [connection update:@"TEST1" set:@{@"c1": @"2"} where:@"c1 = ?" withBindings:@[@"1"]], 1, "unable to update row: %s", UTF8([connection lastError]));
    TASSERT_EQUALS_LLD_S(test, [connection update:@"TEST1" set:@{@"c1": @"3"} where:@"c1 = ?" withBindings:@[@"1"]], 0, "unable to update row: %s", UTF8([connection lastError]));
    TASSERT_EQUALS_LLD_S(test, [connection insert:@{@"c1": @"5"} into:@"TEST1"], 1, "unable to insert row: %s", UTF8([connection lastError]));

    r= [connection select:@[@"c1"] from:@"TEST1" where:@"c1 = ?" withBindings:@[@"2"]];
    TASSERT(test, [r nextRow], "unable to find inserted row");
    TASSERT_EQUALS_OBJ(test, [r objectForKey:@"c1"], @"2");
    [r terminateOperation];

    TASSERT_EQUALS_LLD_S(test, [connection deleteFrom:@"TEST1" where:@"c1 = ?" withBindings:@[@"2"]], 1, "unable to delete row");
    TASSERT_EQUALS_LLD_S(test, [connection countRowsFrom:@"TEST1" where:@"c1 = ?" withBindings:@[@"2"]], 0, "deleted row is still found");

    TASSERT_EQUALS_LLD_S(test, ([connection insert:@{@"c2": @"100", @"c1": @"firstrow"} into:@"TEST1"]), 1, "unable to insert row: %s", UTF8([connection lastError]));
    TASSERT_EQUALS_LLD_S(test, [connection insert:@{@"c2": @101} into:@"TEST1"], 1, "unable to insert row: %s", UTF8([connection lastError]));
    TASSERT_EQUALS_LLD_S(test, [connection insert:@{@"c2": @102.0} into:@"TEST1"], 1, "unable to insert row: %s", UTF8([connection lastError]));

    s= [connection statementForSelect:@[@"c1", @"c2"] from:@"TEST1" where:@"c2 > ?" groupBy:nil having:nil orderBy:@"c2 ASC" limit:nil];
    TASSERT(test, s, "unable to create statement: %s", UTF8([connection lastError]));
    TASSERT(test, [s bindObjects:@[@"99"]], "unable to bind objects: %s", UTF8([s lastError]));
    r= [s fetch];

    // First row c1= 'firstrow', c2= 100
    TASSERT(test, ok= [r nextRow], "unable to fetch first row");
    if (ok) {
      obj= [r allValues];
      TASSERT_EQUALS_LLD(test, [obj count], 2);
      TASSERT_EQUALS_OBJ(test, [obj objectAtIndex:0], @"firstrow");
      TASSERT_EQUALS_OBJ(test, [obj objectAtIndex:1], [NSNumber numberWithInt:100]);}

    // 2nd row c1= NULL, c2= 101
    TASSERT(test, ok= [r nextRow], "unable to fetch 2nd row");
    if (ok) {
      obj= [r allValues];
      TASSERT_EQUALS_LLD(test, [obj count], 2);
      TASSERT_EQUALS_OBJ(test, [obj objectAtIndex:0], MSNull);
      TASSERT_EQUALS_OBJ(test, [obj objectAtIndex:1], [NSNumber numberWithInt:101]);}

    // 3rd row c1= NULL, c2= 102
    TASSERT(test, ok= [r nextRow], "unable to fetch 3rd row");
    if (ok) {
      obj= [r allValues];
      TASSERT_EQUALS_LLD(test, [obj count], 2);
      TASSERT_EQUALS_OBJ(test, [obj objectAtIndex:0], MSNull);
      TASSERT_EQUALS_OBJ(test, [obj objectAtIndex:1], [NSNumber numberWithInt:102]);}

    TASSERT(test, ![r nextRow], "too much rows");
    [r terminateOperation];

    TASSERT_EQUALS_LLD_S(test, ([connection deleteFrom:@"TEST1" where:@"c2 = ? OR c1 = ?" withBindings:@[@"101", @"firstrow"]]), 2, "unable to delete 2 rows");

    TASSERT(test, [s bindObjects:@[@"101"]], "unable to bind objects to already used statement: %s", UTF8([s lastError]));
    TASSERT(test, r= [s fetch], "unable to fetch %s", UTF8([s lastError]));
    TASSERT(test, [r nextRow], "unable to fetch 1st row");
    TASSERT(test, [r getLongAt:&msLongValue column:1], "unable to get long at column 1");
    TASSERT_EQUALS_LLD_S(test, msLongValue, 102, "long value at column 1 should be 102");
    TASSERT(test, ![r nextRow], "too much rows");
    [r terminateOperation];
    [s terminateOperation];
  }
}

testdef_t msdb_adaptor[]= {
  {"prepare"     , NULL,tst_prepare     },
  {"connection"  , NULL,tst_connection  },
  {"tables"      , NULL,tst_tables      },
  {"types"       , NULL,tst_types       },
  {"statements"  , NULL,tst_statements  },
  {"transactions", NULL,tst_transactions},
  {"next"        , NULL,tst_next        },
  {NULL}
};

