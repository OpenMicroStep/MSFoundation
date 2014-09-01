/* _odbcWin32.m created by Logitud on Thu 28-Nov-2013 */

#import "_odbcWin32.h"

#ifdef WIN32

static HINSTANCE __odbc32_DLL = (HINSTANCE)NULL;

//***************************************************************
typedef	SQLRETURN (__stdcall *DLL_ODBC32_SQLGetDiagRec) (SQLSMALLINT HandleType, SQLHANDLE Handle, SQLSMALLINT RecNumber, SQLCHAR *Sqlstate, SQLINTEGER *NativeError, SQLCHAR* MessageText, SQLSMALLINT BufferLength, SQLSMALLINT *TextLength);
typedef SQLRETURN (__stdcall *DLL_ODBC32_SQLAllocHandle) (SQLSMALLINT HandleType, SQLHANDLE InputHandle, SQLHANDLE *OutputHandle);
typedef SQLRETURN (__stdcall *DLL_ODBC32_SQLDriverConnect) (SQLHDBC hdbc, SQLHWND hwnd, SQLCHAR *szConnStrIn, SQLSMALLINT cchConnStrIn, SQLCHAR *szConnStrOut, SQLSMALLINT cchConnStrOutMax, SQLSMALLINT *pcchConnStrOut, SQLUSMALLINT fDriverCompletion);
typedef SQLRETURN (__stdcall *DLL_ODBC32_SQLSetConnectAttr) (SQLHDBC ConnectionHandle, SQLINTEGER Attribute, SQLPOINTER Value, SQLINTEGER StringLength);
typedef SQLRETURN (__stdcall *DLL_ODBC32_SQLDisconnect) (SQLHDBC ConnectionHandle);
typedef SQLRETURN (__stdcall *DLL_ODBC32_SQLFreeHandle) (SQLSMALLINT HandleType, SQLHANDLE Handle);
typedef SQLRETURN (__stdcall *DLL_ODBC32_SQLExecDirect) (SQLHSTMT StatementHandle, SQLCHAR* StatementText, SQLINTEGER TextLength);
typedef SQLRETURN (__stdcall *DLL_ODBC32_SQLTables) (SQLHSTMT StatementHandle, SQLCHAR *CatalogName, SQLSMALLINT NameLength1, SQLCHAR *SchemaName, SQLSMALLINT NameLength2, SQLCHAR *TableName, SQLSMALLINT NameLength3, SQLCHAR *TableType, SQLSMALLINT NameLength4);
typedef SQLRETURN (__stdcall *DLL_ODBC32_SQLSetEnvAttr) (SQLHENV EnvironmentHandle, SQLINTEGER Attribute, SQLPOINTER Value, SQLINTEGER StringLength);
typedef SQLRETURN (__stdcall *DLL_ODBC32_SQLGetData) (SQLHSTMT StatementHandle, SQLUSMALLINT ColumnNumber, SQLSMALLINT TargetType, SQLPOINTER TargetValue, SQLLEN BufferLength, SQLLEN *StrLen_or_IndPtr);
typedef SQLRETURN (__stdcall *DLL_ODBC32_SQLNumResultCols) (SQLHSTMT StatementHandle, SQLSMALLINT *ColumnCount);
typedef SQLRETURN (__stdcall *DLL_ODBC32_SQLDescribeCol) (SQLHSTMT StatementHandle, SQLUSMALLINT ColumnNumber, SQLCHAR *ColumnName, SQLSMALLINT BufferLength, SQLSMALLINT *NameLength, SQLSMALLINT *DataType, SQLULEN *ColumnSize, SQLSMALLINT *DecimalDigits, SQLSMALLINT *Nullable);
typedef SQLRETURN (__stdcall *DLL_ODBC32_SQLFetch) (SQLHSTMT StatementHandle);
typedef SQLRETURN (__stdcall *DLL_ODBC32_SQLEndTran) (SQLSMALLINT HandleType, SQLHANDLE Handle, SQLSMALLINT CompletionType);

//***************************************************************
static DLL_ODBC32_SQLGetDiagRec		__odbc32_SQLGetDiagRec;
static DLL_ODBC32_SQLAllocHandle		__odbc32_SQLAllocHandle;
static DLL_ODBC32_SQLDriverConnect     	__odbc32_SQLDriverConnect;
static DLL_ODBC32_SQLSetConnectAttr     	__odbc32_SQLSetConnectAttr;
static DLL_ODBC32_SQLDisconnect     	__odbc32_SQLDisconnect;
static DLL_ODBC32_SQLFreeHandle     	__odbc32_SQLFreeHandle;
static DLL_ODBC32_SQLExecDirect     	__odbc32_SQLExecDirect;
static DLL_ODBC32_SQLTables     		__odbc32_SQLTables;
static DLL_ODBC32_SQLSetEnvAttr     	__odbc32_SQLSetEnvAttr;
static DLL_ODBC32_SQLGetData     	__odbc32_SQLGetData;
static DLL_ODBC32_SQLNumResultCols     	__odbc32_SQLNumResultCols;
static DLL_ODBC32_SQLDescribeCol     	__odbc32_SQLDescribeCol;
static DLL_ODBC32_SQLFetch     		__odbc32_SQLFetch;
static DLL_ODBC32_SQLEndTran     	__odbc32_SQLEndTran;

//***************************************************************
SQLRETURN SQLGetDiagRec(SQLSMALLINT HandleType, SQLHANDLE Handle, SQLSMALLINT RecNumber, SQLCHAR *Sqlstate, SQLINTEGER *NativeError, SQLCHAR* MessageText, SQLSMALLINT BufferLength, SQLSMALLINT *TextLength)
{
    return __odbc32_SQLGetDiagRec(HandleType, Handle, RecNumber, Sqlstate, NativeError, MessageText, BufferLength, TextLength) ;
}

SQLRETURN SQLAllocHandle(SQLSMALLINT HandleType, SQLHANDLE InputHandle, SQLHANDLE *OutputHandle)
{
    return __odbc32_SQLAllocHandle(HandleType, InputHandle, OutputHandle) ; 
}

SQLRETURN SQLDriverConnect(SQLHDBC hdbc, SQLHWND hwnd, SQLCHAR *szConnStrIn, SQLSMALLINT cchConnStrIn, SQLCHAR *szConnStrOut, SQLSMALLINT cchConnStrOutMax, SQLSMALLINT *pcchConnStrOut, SQLUSMALLINT fDriverCompletion)
{
    return __odbc32_SQLDriverConnect(hdbc, hwnd, szConnStrIn, cchConnStrIn, szConnStrOut, cchConnStrOutMax, pcchConnStrOut, fDriverCompletion) ;
}

SQLRETURN SQLSetConnectAttr(SQLHDBC ConnectionHandle, SQLINTEGER Attribute, SQLPOINTER Value, SQLINTEGER StringLength)
{
    return __odbc32_SQLSetConnectAttr(ConnectionHandle, Attribute, Value, StringLength) ; 
}

SQLRETURN SQLDisconnect(SQLHDBC ConnectionHandle)
{
    return __odbc32_SQLDisconnect(ConnectionHandle) ;
}

SQLRETURN SQLFreeHandle(SQLSMALLINT HandleType, SQLHANDLE Handle)
{
    return __odbc32_SQLFreeHandle(HandleType, Handle) ;
}

SQLRETURN SQLExecDirect(SQLHSTMT StatementHandle, SQLCHAR* StatementText, SQLINTEGER TextLength)
{
    return __odbc32_SQLExecDirect(StatementHandle, StatementText, TextLength) ;
}

SQLRETURN SQLTables(SQLHSTMT StatementHandle, SQLCHAR *CatalogName, SQLSMALLINT NameLength1, SQLCHAR *SchemaName, SQLSMALLINT NameLength2, SQLCHAR *TableName, SQLSMALLINT NameLength3, SQLCHAR *TableType, SQLSMALLINT NameLength4)
{
    return __odbc32_SQLTables(StatementHandle, CatalogName, NameLength1, SchemaName, NameLength2, TableName, NameLength3, TableType, NameLength4) ;
}

SQLRETURN SQLSetEnvAttr(SQLHENV EnvironmentHandle, SQLINTEGER Attribute, SQLPOINTER Value, SQLINTEGER StringLength)
{
    return __odbc32_SQLSetEnvAttr(EnvironmentHandle, Attribute, Value, StringLength) ;
}

SQLRETURN SQLGetData(SQLHSTMT StatementHandle, SQLUSMALLINT ColumnNumber, SQLSMALLINT TargetType, SQLPOINTER TargetValue, SQLLEN BufferLength, SQLLEN *StrLen_or_IndPtr)
{
    return __odbc32_SQLGetData(StatementHandle, ColumnNumber, TargetType, TargetValue, BufferLength, StrLen_or_IndPtr) ;
}

SQLRETURN SQLNumResultCols(SQLHSTMT StatementHandle, SQLSMALLINT *ColumnCount)
{
    return __odbc32_SQLNumResultCols(StatementHandle, ColumnCount) ;
}

SQLRETURN SQLDescribeCol(SQLHSTMT StatementHandle, SQLUSMALLINT ColumnNumber, SQLCHAR *ColumnName, SQLSMALLINT BufferLength, SQLSMALLINT *NameLength, SQLSMALLINT *DataType, SQLULEN *ColumnSize, SQLSMALLINT *DecimalDigits, SQLSMALLINT *Nullable)
{
    return __odbc32_SQLDescribeCol(StatementHandle, ColumnNumber, ColumnName, BufferLength, NameLength, DataType, ColumnSize, DecimalDigits, Nullable) ;
}

SQLRETURN SQLFetch(SQLHSTMT StatementHandle)
{
    return __odbc32_SQLFetch(StatementHandle) ;
}

SQLRETURN SQLEndTran(SQLSMALLINT HandleType, SQLHANDLE Handle, SQLSMALLINT CompletionType)
{
    return __odbc32_SQLEndTran(HandleType, Handle, CompletionType) ;
}

//***************************************************************
void initializeOdbcLibraryForWin32()
{
    if(!__odbc32_DLL)
    {
        __odbc32_DLL = MSLoadDLL(@"odbc32.dll") ;

        if (__odbc32_DLL != NULL) {
            __odbc32_SQLGetDiagRec		= (DLL_ODBC32_SQLGetDiagRec)		GetProcAddress(__odbc32_DLL, "SQLGetDiagRec") ;
            __odbc32_SQLAllocHandle		= (DLL_ODBC32_SQLAllocHandle)		GetProcAddress(__odbc32_DLL, "SQLAllocHandle") ;
            __odbc32_SQLDriverConnect		= (DLL_ODBC32_SQLDriverConnect)		GetProcAddress(__odbc32_DLL, "SQLDriverConnect") ;
            __odbc32_SQLSetConnectAttr		= (DLL_ODBC32_SQLSetConnectAttr)	GetProcAddress(__odbc32_DLL, "SQLSetConnectAttr") ;
            __odbc32_SQLDisconnect		= (DLL_ODBC32_SQLDisconnect)		GetProcAddress(__odbc32_DLL, "SQLDisconnect") ;
            __odbc32_SQLFreeHandle		= (DLL_ODBC32_SQLFreeHandle)		GetProcAddress(__odbc32_DLL, "SQLFreeHandle") ;
            __odbc32_SQLExecDirect		= (DLL_ODBC32_SQLExecDirect)		GetProcAddress(__odbc32_DLL, "SQLExecDirect") ;
            __odbc32_SQLTables			= (DLL_ODBC32_SQLTables)		GetProcAddress(__odbc32_DLL, "SQLTables") ;
            __odbc32_SQLSetEnvAttr		= (DLL_ODBC32_SQLSetEnvAttr)		GetProcAddress(__odbc32_DLL, "SQLSetEnvAttr") ;
            __odbc32_SQLGetData			= (DLL_ODBC32_SQLGetData)		GetProcAddress(__odbc32_DLL, "SQLGetData") ;
            __odbc32_SQLNumResultCols  		= (DLL_ODBC32_SQLNumResultCols)		GetProcAddress(__odbc32_DLL, "SQLNumResultCols") ;
            __odbc32_SQLDescribeCol  		= (DLL_ODBC32_SQLDescribeCol)		GetProcAddress(__odbc32_DLL, "SQLDescribeCol") ;
            __odbc32_SQLFetch	  		= (DLL_ODBC32_SQLFetch)			GetProcAddress(__odbc32_DLL, "SQLFetch") ;
            __odbc32_SQLEndTran	  		= (DLL_ODBC32_SQLEndTran)		GetProcAddress(__odbc32_DLL, "SQLEndTran") ;

            if (!(__odbc32_SQLGetDiagRec
                  &&__odbc32_SQLAllocHandle
                  &&__odbc32_SQLDriverConnect
                  &&__odbc32_SQLSetConnectAttr
                  &&__odbc32_SQLDisconnect
                  &&__odbc32_SQLFreeHandle
                  &&__odbc32_SQLExecDirect
                  &&__odbc32_SQLTables
                  &&__odbc32_SQLSetEnvAttr
                  &&__odbc32_SQLGetData
                  &&__odbc32_SQLNumResultCols
                  &&__odbc32_SQLDescribeCol
                  &&__odbc32_SQLFetch
                  &&__odbc32_SQLEndTran
                  ))
            {
                if(!__odbc32_SQLGetDiagRec)             NSLog(@"__odbc32_SQLGetDiagRec NULL");
                if(!__odbc32_SQLAllocHandle)           	NSLog(@"__odbc32_SQLAllocHandle NULL");
                if(!__odbc32_SQLDriverConnect)          NSLog(@"__odbc32_SQLDriverConnect NULL");
                if(!__odbc32_SQLSetConnectAttr)		NSLog(@"__odbc32_SQLSetConnectAttr NULL");
                if(!__odbc32_SQLDisconnect)		NSLog(@"__odbc32_SQLDisconnect NULL");
                if(!__odbc32_SQLFreeHandle)		NSLog(@"__odbc32_SQLFreeHandle NULL");
                if(!__odbc32_SQLExecDirect)		NSLog(@"__odbc32_SQLExecDirect NULL");
                if(!__odbc32_SQLTables)			NSLog(@"__odbc32_SQLTables NULL");
                if(!__odbc32_SQLSetEnvAttr)		NSLog(@"__odbc32_SQLSetEnvAttr NULL");
                if(!__odbc32_SQLGetData)			NSLog(@"__odbc32_SQLGetData NULL");
                if(!__odbc32_SQLNumResultCols)		NSLog(@"__odbc32_SQLNumResultCols NULL");
                if(!__odbc32_SQLDescribeCol)		NSLog(@"__odbc32_SQLDescribeCol NULL");
                if(!__odbc32_SQLFetch)			NSLog(@"__odbc32_SQLFetch NULL");
                if(!__odbc32_SQLEndTran)			NSLog(@"__odbc32_SQLEndTran NULL");

                MSRaise(NSGenericException, @"Error while loading odbc32.dll") ;
            }
        }
        else {
            MSRaise(NSGenericException, @"Error while loading odbc32.dll") ;
        }
    }
}

#endif //WIN32