//
//  msdb_adaptor_validate.m
//  _MicroStep
//
//  Created by Vincent Rouillé on 01/12/2014.
//
//

#import "msdb_validate.h"
#include <pthread.h>

enum AdaptorType {
    SQLiteAdaptor,
    MySQLAdaptor,
    ODBCAdaptorAccess,
};

static int tst_connection(NSDictionary *params, MSDBConnection **outDB)
{
    int err= 0;
    MSDBConnection *connection;
    
    connection= *outDB= [MSDBConnection connectionWithDictionary:params];
    if(!connection) {
        NSLog(@"A1: adaptor not found %@",[params objectForKey:@"adaptor"]); err++; }
    if(![connection connect]) {
        NSLog(@"A2: unable to connect"); err++; }
    if(![connection isConnected]) {
        NSLog(@"A3: not connected"); err++; }
    [connection disconnect];
    if([connection isConnected]) {
        NSLog(@"A4: connected"); err++; }
    if(![connection connect]) {
        NSLog(@"A5: unable to reconnect"); err++; }
    return err;
}

static int tst_scheme(MSDBConnection *connection, enum AdaptorType adaptorType)
{
    int err= 0;
    id tables;
    
    tables= [connection tableNames];
    if(![tables isKindOfClass:[NSArray class]]) {
        NSLog(@"B1: unable to get table names"); err++; }
    if([tables containsObject:@"test1"] && [connection executeRawSQL:@"DROP TABLE test1"] == MSSQL_ERROR) {
        NSLog(@"B2: unable to drop table test1: %@", [connection lastError]); err++; }
    if([connection executeRawSQL:@"DROP TABLE test1"] != MSSQL_ERROR) {
        NSLog(@"B3: drop test1 didn't failed"); err++; }
    if([tables containsObject:@"test2"] && [connection executeRawSQL:@"DROP TABLE test2"] == MSSQL_ERROR) {
        NSLog(@"B4: unable to drop table test2"); err++; }
    if([connection executeRawSQL:@"DROP TABLE test2"] != MSSQL_ERROR) {
        NSLog(@"B5: drop test2 didn't failed"); err++; }
    switch (adaptorType) {
        case SQLiteAdaptor:
            if([connection executeRawSQL:@"CREATE TABLE test1(c1 TEXT DEFAULT NULL, c2 INTEGER DEFAULT NULL, c3 TEXT, c4 DATETIME DEFAULT NULL)"] == MSSQL_ERROR) {
                NSLog(@"B6:SQLite: unable to create table test1 :%@", [connection lastError]); err++; }
            break;
        case MySQLAdaptor:
            if([connection executeRawSQL:@"CREATE TABLE test1(c1 VARCHAR(255) DEFAULT NULL, c2 INTEGER DEFAULT NULL, c3 TEXT, c4 DATETIME DEFAULT NULL)"] == MSSQL_ERROR) {
                NSLog(@"B6:MySQL: unable to create table test1 :%@", [connection lastError]); err++; }
            break;
        case ODBCAdaptorAccess:
            // See Microsoft Access SQL Reference
            if([connection executeRawSQL:@"CREATE TABLE test1(c1 VARCHAR(255), c2 INTEGER, c3 TEXT, c4 DATETIME)"] == MSSQL_ERROR) {
                NSLog(@"B6:ODBC:Access: unable to create table test1 :%@", [connection lastError]); err++; }
            break;
    }
    tables= [connection tableNames];
    if(![tables containsObject:@"test1"]) {
        NSLog(@"B7: table test1 not found in tables :%@", tables); err++; }
    
    return err;
}


struct tst_transaction_struct {
    pthread_mutex_t mutex;
    pthread_cond_t cond;
    int count, size;
    int err1, err2;
    id params;
};

static void tst_transactions_wait(struct tst_transaction_struct* barrier)
{
    pthread_mutex_lock(&barrier->mutex);
    if(++barrier->count >= barrier->size) {
        barrier->count = 0;
        pthread_cond_broadcast(&barrier->cond);
    } else {
        pthread_cond_wait(&barrier->cond, &(barrier->mutex));
    }
    pthread_mutex_unlock(&barrier->mutex);
}

static void *tst_transactions_thread1(void *arg) {
    struct tst_transaction_struct *s= (struct tst_transaction_struct*)arg;
    int err= 0;
    NEW_POOL;
    MSDBConnection *connection= (MSDBConnection *)[MSDBConnection connectionWithDictionary:s->params];
    
    if(![connection connect]) {
        NSLog(@"T1:1: unable to connect: %@", [connection lastError]); err++; }
    
    // Condition 1: Wait for 0,1,2 connected
    tst_transactions_wait(s);
    // Condition 2: Wait for 0 inserts inside a transaction
    tst_transactions_wait(s);
    
    if([[connection fetchWithRequest:@"SELECT c2 FROM test1 WHERE c2=10"] nextRow]) {
        NSLog(@"T5:1: found raw inserted by another transaction"); err++; }
    if(![connection beginTransaction]) {
        NSLog(@"T6:1: unable to begin transaction: %@", [connection lastError]); err++; }
    if([[connection fetchWithRequest:@"SELECT c2 FROM test1 WHERE c2=10"] nextRow]) {
        NSLog(@"T7:1: found raw inserted by another transaction"); err++; }
    if([connection executeRawSQL:@"INSERT INTO test1 (c2) VALUES (11)"] == MSSQL_ERROR) {
        NSLog(@"T8:1: unable insert raw: %@", [connection lastError]); err++; }
    if(![[connection fetchWithRequest:@"SELECT c2 FROM test1 WHERE c2=11"] nextRow]) {
        NSLog(@"T9:1: unable find inserted raw"); err++; }
        
    // Condition 3: Wait for 1 inserts inside a transaction
    tst_transactions_wait(s);
    // Condition 4: Wait for 0 commit
    tst_transactions_wait(s);
    
    if(![connection rollback]) {
        NSLog(@"T14:1: unable to rollback: %@", [connection lastError]); err++; }
    
    // Condition 5: Wait for 1 rollback
    tst_transactions_wait(s);
    
    if([[connection fetchWithRequest:@"SELECT c2 FROM test1 WHERE c2=11"] nextRow]) {
        NSLog(@"T15:1: found raw inserted by another transaction"); err++; }
    [connection disconnect];
    KILL_POOL;
    s->err1= err;
    return NULL;
}

static void *tst_transactions_thread2(void *arg) {
    struct tst_transaction_struct *s= (struct tst_transaction_struct*)arg;
    int err= 0;
    NEW_POOL;
    MSDBConnection *connection= (MSDBConnection *)[MSDBConnection connectionWithDictionary:s->params];
    
    if(![connection connect]) {
        NSLog(@"T1:2: unable to connect: %@", [connection lastError]); err++; }
    
    // Condition 1: Wait for 0,1,2 connected
    tst_transactions_wait(s);
    // Condition 2: Wait for 0 inserts inside a transaction
    tst_transactions_wait(s);
    
    if([[connection fetchWithRequest:@"SELECT c2 FROM test1 WHERE c2=10"] nextRow]) {
        NSLog(@"T11:2: find raw inserted in another transaction "); err++; }
        
    // Condition 3: Wait for 1 inserts inside a transaction
    tst_transactions_wait(s);
    // Condition 4: Wait for 0 commit
    tst_transactions_wait(s);
    [connection rollback]; // If we are in autocommit mode, force getting out
    if(![[connection fetchWithRequest:@"SELECT c2 FROM test1 WHERE c2=10"] nextRow]) {
        NSLog(@"T12:2: unable find inserted raw"); err++; }
    if([[connection fetchWithRequest:@"SELECT c2 FROM test1 WHERE c2=11"] nextRow]) {
        NSLog(@"T13:2: found raw inserted by another transaction"); err++; }
   
    // Condition 5: Wait for 1 rollback
    tst_transactions_wait(s);
    
    if([[connection fetchWithRequest:@"SELECT c2 FROM test1 WHERE c2=11"] nextRow]) {
        NSLog(@"T15:2: found raw inserted by another transaction"); err++; }
    [connection disconnect];
    KILL_POOL;
    s->err2= err;
    return NULL;
}

static int tst_transactions(MSDBConnection *connection, enum AdaptorType adaptorType)
{
    int err= 0;
    struct tst_transaction_struct s;
    NEW_POOL;
    pthread_t thread1, thread2;
    // TODO: SQLite doesn't seems to like concurrent transactions
    (void)adaptorType;
    s.size= 3;
    s.params= [connection connectionDictionary];
    s.err1= 0;
    s.err2= 0;
    {
        // Init conditions
        s.count= 0;
        pthread_mutex_init(&s.mutex, NULL);
        pthread_cond_init(&s.cond, NULL);
        
        // Spawn the two threads.
        pthread_create(&thread1, NULL, &tst_transactions_thread1, &s);
        pthread_create(&thread2, NULL, &tst_transactions_thread2, &s);
    }
    
    if(![connection connect]) {
        NSLog(@"T1:0: unable to connect: %@", [connection lastError]); err++; }
    
    // Condition 1: Wait for 0,1,2 connected
    tst_transactions_wait(&s);
    
    if(![connection beginTransaction]) {
        NSLog(@"T2:0: unable to begin transaction: %@", [connection lastError]); err++; }
    if([connection executeRawSQL:@"INSERT INTO test1 (c2) VALUES (10)"] == MSSQL_ERROR) {
        NSLog(@"T3:0: unable insert raw: %@", [connection lastError]); err++; }
    if(![[connection fetchWithRequest:@"SELECT c2 FROM test1 WHERE c2=10"] nextRow]) {
        NSLog(@"T4:0: unable find inserted raw"); err++; }
    
    // Condition 2: Wait for 0 inserts inside a transaction
    tst_transactions_wait(&s);
    // Condition 3: Wait for 1 inserts inside a transaction
    tst_transactions_wait(&s);

    if(![connection commit]) {
        NSLog(@"T10:0: unable to commit: %@", [connection lastError]); err++; }
    
    // Condition 4: Wait for 0 commit
    tst_transactions_wait(&s);
    
    if(![[connection fetchWithRequest:@"SELECT c2 FROM test1 WHERE c2=10"] nextRow]) {
        NSLog(@"T11:0: unable find inserted raw"); err++; }
    if([[connection fetchWithRequest:@"SELECT c2 FROM test1 WHERE c2=11"] nextRow]) {
        NSLog(@"T12:0: found raw inserted by another transaction"); err++; }

    // Condition 5: Wait for 1 rollback
    tst_transactions_wait(&s);
    
    if([[connection fetchWithRequest:@"SELECT c2 FROM test1 WHERE c2=11"] nextRow]) {
        NSLog(@"T15:0: found raw inserted by another transaction"); err++; }
    
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
    
    pthread_mutex_destroy(&s.mutex);
    pthread_cond_destroy(&s.cond);
    
    KILL_POOL;
    return err + s.err1 + s.err2;
}

static int tst_statements(MSDBConnection *connection, enum AdaptorType adaptorType)
{
    int err= 0;
    id obj; MSLong msLongValue;
    MSDBStatement *s;
    MSDBResultSet *r;
    (void)adaptorType;
    
    if([connection insert:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"c1", nil] into:@"test1"] != 1) {
        NSLog(@"S1: unable to insert row: %@", [connection lastError]); err++; }
    if([connection countRowsFrom:@"test1" where:@"c1 = ?" withBindings:[NSArray arrayWithObjects:@"1", nil]] != 1) {
        NSLog(@"S2: unable to find inserted row"); err++; }
    if([connection update:@"test1" set:[NSDictionary dictionaryWithObjectsAndKeys:@"2", @"c1", nil] where:@"c1 = ?" withBindings:[NSArray arrayWithObjects:@"1", nil]] != 1) {
        NSLog(@"S3: unable to update row: %@", [connection lastError]); err++; }
    if([connection update:@"test1" set:[NSDictionary dictionaryWithObjectsAndKeys:@"3", @"c1", nil] where:@"c1 = ?" withBindings:[NSArray arrayWithObjects:@"1", nil]] != 0) {
        NSLog(@"S4: unable to update row: %@", [connection lastError]); err++; }
    if([connection insert:[NSDictionary dictionaryWithObjectsAndKeys:@"5", @"c1", nil] into:@"test1"] != 1) {
        NSLog(@"S1: unable to insert row: %@", [connection lastError]); err++; }
    r= [connection select:[NSArray arrayWithObjects:@"c1", nil] from:@"test1" where:@"c1 = ?" withBindings:[NSArray arrayWithObjects:@"2", nil]];
    if(![r nextRow]) {
        NSLog(@"S5: unable to find inserted row"); err++; }
    if(![[r objectForKey:@"c1"] isEqual:@"2"]) {
        NSLog(@"S6: found row doesn't match : '%@' != '2'", [r objectForKey:@"c1"]); err++; }
    [r terminateOperation];
    if([connection deleteFrom:@"test1" where:@"c1 = ?" withBindings:[NSArray arrayWithObjects:@"2", nil]] != 1) {
        NSLog(@"S7: unable to delete row"); err++; }
    if([connection countRowsFrom:@"test1" where:@"c1 = ?" withBindings:[NSArray arrayWithObjects:@"2", nil]] != 0) {
        NSLog(@"S8: deleted row is still found"); err++; }
    
    if([connection insert:[NSDictionary dictionaryWithObjectsAndKeys:@"100", @"c2", @"firstrow", @"c1", nil] into:@"test1"] != 1) {
        NSLog(@"S10: unable to insert row: %@", [connection lastError]); err++; }
    if([connection insert:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:101], @"c2", nil] into:@"test1"] != 1) {
        NSLog(@"S11: unable to insert row: %@", [connection lastError]); err++; }
    if([connection insert:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:102.0], @"c2", nil] into:@"test1"] != 1) {
        NSLog(@"S13: unable to insert row: %@", [connection lastError]); err++; }

    s= [connection statementForSelect:[NSArray arrayWithObjects:@"c1", @"c2", nil] from:@"test1" where:@"c2 > ?" groupBy:nil having:nil orderBy:@"c2 ASC" limit:nil];
    if(!s) {
        NSLog(@"S14: unable to create statement: %@", [connection lastError]); err++; }
    if(![s bindObjects:[NSArray arrayWithObjects:@"99", nil]]) {
        NSLog(@"S15: unable to bind objects: %@", [s lastError]); err++; }
    r= [s fetch];
    
    // First row c1= 'firstrow', c2= 100
    if(![r nextRow]) {
        NSLog(@"S16: unable to fetch first row"); err++; }
    obj= [r allValues];
    if([obj count] != 2) {
        NSLog(@"S17: rows should contains 2 values"); err++; }
    else if(![[obj objectAtIndex:0] isEqual:@"firstrow"]) {
        NSLog(@"S18: first value of raw should be 'firstrow': %@", [obj objectAtIndex:0]); err++; }
    else if(![[obj objectAtIndex:1] isEqual:[NSNumber numberWithInt:100]]) {
        NSLog(@"S19: first value of raw should be '100': %@", [obj objectAtIndex:1]); err++; }
    
    // 2nd row c1= NULL, c2= 101
    if(![r nextRow]) {
        NSLog(@"S20: unable to fetch 2nd row"); err++; }
    obj= [r allValues];
    if([obj count] != 2) {
        NSLog(@"S21: rows should contains 2 values"); err++; }
    else if(![[obj objectAtIndex:0] isEqual:MSNull]) {
        NSLog(@"S22: first value of raw should be NSNull: %@", [obj objectAtIndex:0]); err++; }
    else if(![[obj objectAtIndex:1] isEqual:[NSNumber numberWithInt:101]]) {
        NSLog(@"S23: first value of raw should be '101': %@", [obj objectAtIndex:1]); err++; }
    
    // 3rd row c1= NULL, c2= 102
    if(![r nextRow]) {
        NSLog(@"S24: unable to fetch 3rd row"); err++; }
    obj= [r allValues];
    if([obj count] != 2) {
        NSLog(@"S25: rows should contains 2 values"); err++; }
    else if(![[obj objectAtIndex:0] isEqual:MSNull]) {
        NSLog(@"S26: first value of raw should be NSNull: %@", [obj objectAtIndex:0]); err++; }
    else if(![[obj objectAtIndex:1] isEqual:[NSNumber numberWithInt:102]]) {
        NSLog(@"S27: first value of raw should be '102': %@", [obj objectAtIndex:1]); err++; }
    
    if([r nextRow]) {
        NSLog(@"S28: too much rows"); err++; }
    [r terminateOperation];
    
    if([connection deleteFrom:@"test1" where:@"c2 = ? OR c1 = ?" withBindings:[NSArray arrayWithObjects:@"101", @"firstrow", nil]] != 2) {
        NSLog(@"S29: unable to delete 2 rows"); err++; }
    
    if(![s bindObjects:[NSArray arrayWithObjects:@"101", nil]]) {
        NSLog(@"S30: unable to bind objects to already used statement: %@", [s lastError]); err++; }
    if(!(r= [s fetch])) {
        NSLog(@"S31: unable to fetch %@", [s lastError]); err++; }
    if(![r nextRow]) {
        NSLog(@"S32: unable to fetch 1st row"); err++; }
    if(![r getLongAt:&msLongValue column:1]) {
        NSLog(@"S33: unable to get long at column 1"); err++; }
    if(msLongValue != 102) {
        NSLog(@"S34: long value at column 1 should be 102, not %lld", msLongValue); err++; }
    if([r nextRow]) {
        NSLog(@"S35: too much rows"); err++; }
    [r terminateOperation];
    [s terminateOperation];
    
    return err;
}

static int _msdb_adaptor_validate(id dbParams, enum AdaptorType type, const char * adaptorName)
{
    int err= 0; clock_t t0= clock(), t1; double seconds;
    MSDBConnection *connection;
    
    err+= tst_connection(dbParams, &connection);
    if([connection isConnected]) {
        err+= tst_scheme(connection, type);
        //err+= tst_transactions(connection, type);
        err+= tst_statements(connection, type);
        [connection disconnect];
    }
    
    t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
    fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n",adaptorName,(err?"FAIL":"PASS"),seconds);
    return err;
}

int msdb_adaptor_validate(void)
{
    int err= 0;
    id dbParams;
    
    /*dbParams= [MSDictionary dictionaryWithKeysAndObjects:
                  @"host",     @"localhost",
                  @"port",     [NSNumber numberWithInt:3306],
                  @"user",     @"root",
                  @"pwd",      @"",
                  @"adaptor",  @"MSMySqlAdaptor",
                  @"database", @"msdb_test_mysql",
                  nil];
    err+= _msdb_adaptor_validate(dbParams, MySQLAdaptor, "MySQLAdaptor");*/
    
    dbParams= [MSDictionary dictionaryWithKeysAndObjects:
                  @"path",     @"msdb_test_sqlite.db",
                  @"adaptor",  @"MSSQLCipherAdaptor",
                  nil];
    err+= _msdb_adaptor_validate(dbParams, SQLiteAdaptor, "SQLiteAdaptor");
    
    dbParams= [MSDictionary dictionaryWithKeysAndObjects:
                  @"connectionString", @"DSN=msdb_test_access;Uid=;Pwd=;",
                  @"adaptor",  @"MSODBCAdaptor",
                  nil];
    err+= _msdb_adaptor_validate(dbParams, ODBCAdaptorAccess, "ODBCAdaptor:Access");
    
    return err;
}
