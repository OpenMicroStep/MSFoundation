/*

 _odbcWin32.h

 This file is is a part of the MicroStep Framework.

 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011

 Jean-Michel Berthéas : jean-michel.bertheas@club-internet.fr

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

#ifdef WIN32

#import <windows.h>
#import <MSFoundation/MSFoundation.h>

typedef void*	    		SQLHANDLE;
typedef HWND                    SQLHWND;
typedef SQLHANDLE               SQLHENV;
typedef SQLHANDLE               SQLHDBC;
typedef SQLHANDLE               SQLHSTMT;

typedef void*              	HDBC;

typedef void*              	HSTMT;
typedef unsigned char   		SQLCHAR;
typedef signed char     		SQLSCHAR;
typedef SQLCHAR         		SQLTCHAR;

typedef long            		SQLINTEGER;
typedef unsigned long   		SQLUINTEGER;
typedef short           		SQLSMALLINT;
typedef unsigned short  		SQLUSMALLINT;
typedef SQLSMALLINT     		SQLRETURN;
typedef void *          		SQLPOINTER;

#define SQLLEN          SQLINTEGER
#define SQLULEN         SQLUINTEGER
#define SQLSETPOSIROW   SQLUSMALLINT

#define SQL_HANDLE_ENV             1
#define SQL_HANDLE_DBC             2
#define SQL_HANDLE_STMT            3
#define SQL_HANDLE_DESC            4

#define SQL_SUCCESS                 0
#define SQL_SUCCESS_WITH_INFO       1
#define SQL_NO_DATA                 100

#define SQL_ATTR_ACCESS_MODE        SQL_ACCESS_MODE
#define SQL_ATTR_AUTOCOMMIT         SQL_AUTOCOMMIT
#define SQL_ATTR_CONNECTION_TIMEOUT 113
#define SQL_ATTR_CURRENT_CATALOG    SQL_CURRENT_QUALIFIER
#define SQL_ATTR_DISCONNECT_BEHAVIOR    114
#define SQL_ATTR_ENLIST_IN_DTC      1207
#define SQL_ATTR_ENLIST_IN_XA       1208
#define SQL_ATTR_LOGIN_TIMEOUT      SQL_LOGIN_TIMEOUT
#define SQL_ATTR_ODBC_CURSORS       SQL_ODBC_CURSORS
#define SQL_ATTR_PACKET_SIZE        SQL_PACKET_SIZE
#define SQL_ATTR_QUIET_MODE         SQL_QUIET_MODE
#define SQL_ATTR_TRACE              SQL_OPT_TRACE
#define SQL_ATTR_TRACEFILE          SQL_OPT_TRACEFILE
#define SQL_ATTR_TRANSLATE_LIB      SQL_TRANSLATE_DLL
#define SQL_ATTR_TRANSLATE_OPTION   SQL_TRANSLATE_OPTION
#define SQL_ATTR_TXN_ISOLATION      SQL_TXN_ISOLATION

/* test for SQL_SUCCESS or SQL_SUCCESS_WITH_INFO */
#define SQL_SUCCEEDED(rc) (((rc)&(~1))==0)

/* flags for null-terminated string */
#define SQL_NTS                   (-3)
#define SQL_NTSL                  (-3L)

/* Options for SQLDriverConnect */
#define SQL_DRIVER_NOPROMPT             0
#define SQL_DRIVER_COMPLETE             1
#define SQL_DRIVER_PROMPT               2
#define SQL_DRIVER_COMPLETE_REQUIRED    3

/* connection attributes */
#define SQL_ACCESS_MODE                 101
#define SQL_AUTOCOMMIT                  102
#define SQL_LOGIN_TIMEOUT               103
#define SQL_OPT_TRACE                   104
#define SQL_OPT_TRACEFILE               105
#define SQL_TRANSLATE_DLL               106
#define SQL_TRANSLATE_OPTION            107
#define SQL_TXN_ISOLATION               108
#define SQL_CURRENT_QUALIFIER           109
#define SQL_ODBC_CURSORS                110
#define SQL_QUIET_MODE                  111
#define SQL_PACKET_SIZE                 112

/* SQL_ACCESS_MODE options */
#define SQL_MODE_READ_WRITE             0UL
#define SQL_MODE_READ_ONLY              1UL
#define SQL_MODE_DEFAULT                SQL_MODE_READ_WRITE

/* SQL_AUTOCOMMIT options */
#define SQL_AUTOCOMMIT_OFF              0UL
#define SQL_AUTOCOMMIT_ON               1UL
#define SQL_AUTOCOMMIT_DEFAULT          SQL_AUTOCOMMIT_ON

/* whether an attribute is a pointer or not */
#define SQL_IS_POINTER                          (-4)
#define SQL_IS_UINTEGER                         (-5)
#define SQL_IS_INTEGER                          (-6)
#define SQL_IS_USMALLINT                        (-7)
#define SQL_IS_SMALLINT                         (-8)

/* null handle used in place of parent handle when allocating HENV */
#define SQL_NULL_HANDLE     0L

/* env attribute */
#define SQL_ATTR_ODBC_VERSION               200
#define SQL_ATTR_CONNECTION_POOLING         201
#define SQL_ATTR_CP_MATCH                   202

/* values for SQL_ATTR_ODBC_VERSION */
#define SQL_OV_ODBC2                        2UL
#define SQL_OV_ODBC3                        3UL

/* transfer types for DATE, TIME, TIMESTAMP */
typedef struct tagDATE_STRUCT
{
        SQLSMALLINT    year;
        SQLUSMALLINT   month;
        SQLUSMALLINT   day;
} DATE_STRUCT;
typedef DATE_STRUCT	SQL_DATE_STRUCT;

typedef struct tagTIME_STRUCT
{
        SQLUSMALLINT   hour;
        SQLUSMALLINT   minute;
        SQLUSMALLINT   second;
} TIME_STRUCT;
typedef TIME_STRUCT	SQL_TIME_STRUCT;

typedef struct tagTIMESTAMP_STRUCT
{
        SQLSMALLINT    year;
        SQLUSMALLINT   month;
        SQLUSMALLINT   day;
        SQLUSMALLINT   hour;
        SQLUSMALLINT   minute;
        SQLUSMALLINT   second;
        SQLUINTEGER    fraction;
} TIMESTAMP_STRUCT;
typedef TIMESTAMP_STRUCT	SQL_TIMESTAMP_STRUCT;

/* internal representation of numeric data type */
#define SQL_MAX_NUMERIC_LEN		16
typedef struct tagSQL_NUMERIC_STRUCT
{
      SQLCHAR		precision;
      SQLSCHAR	scale;
      SQLCHAR		sign;	/* 1 if positive, 0 if negative */
      SQLCHAR		val[SQL_MAX_NUMERIC_LEN];
} SQL_NUMERIC_STRUCT;

/* size is 16 */
typedef struct  tagSQLGUID
{
    DWORD Data1;
    WORD Data2;
    WORD Data3;
    BYTE Data4[ 8 ];
} SQLGUID;

typedef enum
{
      SQL_IS_YEAR				= 1,
      SQL_IS_MONTH				= 2,
      SQL_IS_DAY				= 3,
      SQL_IS_HOUR				= 4,
      SQL_IS_MINUTE				= 5,
      SQL_IS_SECOND				= 6,
      SQL_IS_YEAR_TO_MONTH			= 7,
      SQL_IS_DAY_TO_HOUR				= 8,
      SQL_IS_DAY_TO_MINUTE			= 9,
      SQL_IS_DAY_TO_SECOND			= 10,
      SQL_IS_HOUR_TO_MINUTE			= 11,
      SQL_IS_HOUR_TO_SECOND			= 12,
      SQL_IS_MINUTE_TO_SECOND			= 13
} SQLINTERVAL;

typedef struct tagSQL_YEAR_MONTH
{
            SQLUINTEGER		year;
            SQLUINTEGER		month;
} SQL_YEAR_MONTH_STRUCT;

typedef struct tagSQL_DAY_SECOND
{
            SQLUINTEGER		day;
            SQLUINTEGER		hour;
            SQLUINTEGER		minute;
            SQLUINTEGER		second;
            SQLUINTEGER		fraction;
} SQL_DAY_SECOND_STRUCT;

typedef struct tagSQL_INTERVAL_STRUCT
{
    SQLINTERVAL		interval_type;
    SQLSMALLINT		interval_sign;
    union {
            SQL_YEAR_MONTH_STRUCT		year_month;
            SQL_DAY_SECOND_STRUCT		day_second;
    } intval;

} SQL_INTERVAL_STRUCT;

/* SQL data type codes */
#define SQL_UNKNOWN_TYPE    0
#define SQL_CHAR            1
#define SQL_NUMERIC         2
#define SQL_DECIMAL         3
#define SQL_INTEGER         4
#define SQL_SMALLINT        5
#define SQL_FLOAT           6
#define SQL_REAL            7
#define SQL_DOUBLE          8
#define SQL_DATETIME        9
#define SQL_VARCHAR        12

/* One-parameter shortcuts for date/time data types */
#define SQL_TYPE_DATE      91
#define SQL_TYPE_TIME      92
#define SQL_TYPE_TIMESTAMP 93

/* C datatype to SQL datatype mapping      SQL types
                                           ------------------- */
#define SQL_C_CHAR    SQL_CHAR             /* CHAR, VARCHAR, DECIMAL, NUMERIC */
#define SQL_C_TCHAR   SQL_C_CHAR
#define SQL_C_LONG    SQL_INTEGER          /* INTEGER                      */
#define SQL_C_SHORT   SQL_SMALLINT         /* SMALLINT                     */
#define SQL_C_FLOAT   SQL_REAL             /* REAL                         */
#define SQL_C_DOUBLE  SQL_DOUBLE           /* FLOAT, DOUBLE                */
#define SQL_C_NUMERIC SQL_NUMERIC
#define SQL_C_DEFAULT 99

#define SQL_SIGNED_OFFSET       (-20)
#define SQL_UNSIGNED_OFFSET     (-22)

/* C datatype to SQL datatype mapping */
#define SQL_C_DATE       SQL_DATE
#define SQL_C_TIME       SQL_TIME
#define SQL_C_TIMESTAMP  SQL_TIMESTAMP
#define SQL_C_TYPE_DATE                 SQL_TYPE_DATE
#define SQL_C_TYPE_TIME                 SQL_TYPE_TIME
#define SQL_C_TYPE_TIMESTAMP            SQL_TYPE_TIMESTAMP
#define SQL_C_INTERVAL_YEAR             SQL_INTERVAL_YEAR
#define SQL_C_INTERVAL_MONTH            SQL_INTERVAL_MONTH
#define SQL_C_INTERVAL_DAY              SQL_INTERVAL_DAY
#define SQL_C_INTERVAL_HOUR             SQL_INTERVAL_HOUR
#define SQL_C_INTERVAL_MINUTE           SQL_INTERVAL_MINUTE
#define SQL_C_INTERVAL_SECOND           SQL_INTERVAL_SECOND
#define SQL_C_INTERVAL_YEAR_TO_MONTH    SQL_INTERVAL_YEAR_TO_MONTH
#define SQL_C_INTERVAL_DAY_TO_HOUR      SQL_INTERVAL_DAY_TO_HOUR
#define SQL_C_INTERVAL_DAY_TO_MINUTE    SQL_INTERVAL_DAY_TO_MINUTE
#define SQL_C_INTERVAL_DAY_TO_SECOND    SQL_INTERVAL_DAY_TO_SECOND
#define SQL_C_INTERVAL_HOUR_TO_MINUTE   SQL_INTERVAL_HOUR_TO_MINUTE
#define SQL_C_INTERVAL_HOUR_TO_SECOND   SQL_INTERVAL_HOUR_TO_SECOND
#define SQL_C_INTERVAL_MINUTE_TO_SECOND SQL_INTERVAL_MINUTE_TO_SECOND
#define SQL_C_BINARY     SQL_BINARY
#define SQL_C_VARBOOKMARK       SQL_C_BINARY
#define SQL_C_BIT        SQL_BIT
#define SQL_C_SBIGINT   (SQL_BIGINT+SQL_SIGNED_OFFSET)     /* SIGNED BIGINT */
#define SQL_C_UBIGINT   (SQL_BIGINT+SQL_UNSIGNED_OFFSET)   /* UNSIGNED BIGINT */
#define SQL_C_TINYINT    SQL_TINYINT
#define SQL_C_SLONG      (SQL_C_LONG+SQL_SIGNED_OFFSET)    /* SIGNED INTEGER  */
#define SQL_C_SSHORT     (SQL_C_SHORT+SQL_SIGNED_OFFSET)   /* SIGNED SMALLINT */
#define SQL_C_STINYINT   (SQL_TINYINT+SQL_SIGNED_OFFSET)   /* SIGNED TINYINT  */
#define SQL_C_ULONG      (SQL_C_LONG+SQL_UNSIGNED_OFFSET)  /* UNSIGNED INTEGER*/
#define SQL_C_USHORT     (SQL_C_SHORT+SQL_UNSIGNED_OFFSET) /* UNSIGNED SMALLINT*/
#define SQL_C_UTINYINT   (SQL_TINYINT+SQL_UNSIGNED_OFFSET) /* UNSIGNED TINYINT*/
#define SQL_C_BOOKMARK   SQL_C_ULONG                       /* BOOKMARK        */
#define SQL_C_GUID  SQL_GUID
#define SQL_TYPE_NULL                   0

/* special length/indicator values */
#define SQL_NULL_DATA             (-1)
#define SQL_DATA_AT_EXEC          (-2)

/* SQL extended datatypes */
#define SQL_DATE                                9
#define SQL_INTERVAL                            10
#define SQL_TIME                                10
#define SQL_TIMESTAMP                           11
#define SQL_LONGVARCHAR                         (-1)
#define SQL_BINARY                              (-2)
#define SQL_VARBINARY                           (-3)
#define SQL_LONGVARBINARY                       (-4)
#define SQL_BIGINT                              (-5)
#define SQL_TINYINT                             (-6)
#define SQL_BIT                                 (-7)
#define SQL_GUID                			(-11)

/* Special return values for SQLGetData */
#define SQL_NO_TOTAL                    (-4)

#define SQL_WCHAR           (-8)
#define SQL_WVARCHAR        (-9)
#define SQL_WLONGVARCHAR    (-10)
#define SQL_C_WCHAR         SQL_WCHAR

/* values of NULLABLE field in descriptor */
#define SQL_NO_NULLS        0
#define SQL_NULLABLE        1

/* date/time length constants */
#define SQL_DATE_LEN           10
#define SQL_TIME_LEN            8  /* add P+1 if precision is nonzero */
#define SQL_TIMESTAMP_LEN      19  /* add P+1 if precision is nonzero */

/* SQLEndTran() options */
#define SQL_COMMIT          0
#define SQL_ROLLBACK        1

#define SQL_ALL_CATALOGS                "%"
#define SQL_ALL_SCHEMAS                 "%"
#define SQL_ALL_TABLE_TYPES             "%"


void initializeOdbcLibraryForWin32() ;

SQLRETURN SQLGetDiagRec(SQLSMALLINT HandleType, SQLHANDLE Handle, SQLSMALLINT RecNumber, SQLCHAR *Sqlstate, SQLINTEGER *NativeError, SQLCHAR* MessageText, SQLSMALLINT BufferLength, SQLSMALLINT *TextLength);
SQLRETURN SQLAllocHandle(SQLSMALLINT HandleType, SQLHANDLE InputHandle, SQLHANDLE *OutputHandle);
SQLRETURN SQLDriverConnect(SQLHDBC hdbc, SQLHWND hwnd, SQLCHAR *szConnStrIn, SQLSMALLINT cchConnStrIn, SQLCHAR *szConnStrOut, SQLSMALLINT cchConnStrOutMax, SQLSMALLINT *pcchConnStrOut, SQLUSMALLINT fDriverCompletion);
SQLRETURN SQLSetConnectAttr(SQLHDBC ConnectionHandle, SQLINTEGER Attribute, SQLPOINTER Value, SQLINTEGER StringLength);
SQLRETURN SQLDisconnect(SQLHDBC ConnectionHandle);
SQLRETURN SQLFreeHandle(SQLSMALLINT HandleType, SQLHANDLE Handle);
SQLRETURN SQLExecDirect(SQLHSTMT StatementHandle, SQLCHAR* StatementText, SQLINTEGER TextLength);
SQLRETURN SQLTables(SQLHSTMT StatementHandle, SQLCHAR *CatalogName, SQLSMALLINT NameLength1, SQLCHAR *SchemaName, SQLSMALLINT NameLength2, SQLCHAR *TableName, SQLSMALLINT NameLength3, SQLCHAR *TableType, SQLSMALLINT NameLength4);
SQLRETURN SQLSetEnvAttr(SQLHENV EnvironmentHandle, SQLINTEGER Attribute, SQLPOINTER Value, SQLINTEGER StringLength);
SQLRETURN SQLGetData(SQLHSTMT StatementHandle, SQLUSMALLINT ColumnNumber, SQLSMALLINT TargetType, SQLPOINTER TargetValue, SQLLEN BufferLength, SQLLEN *StrLen_or_IndPtr);
SQLRETURN SQLNumResultCols(SQLHSTMT StatementHandle, SQLSMALLINT *ColumnCount);
SQLRETURN SQLDescribeCol(SQLHSTMT StatementHandle, SQLUSMALLINT ColumnNumber, SQLCHAR *ColumnName, SQLSMALLINT BufferLength, SQLSMALLINT *NameLength, SQLSMALLINT *DataType, SQLULEN *ColumnSize, SQLSMALLINT *DecimalDigits, SQLSMALLINT *Nullable);
SQLRETURN SQLFetch(SQLHSTMT StatementHandle);
SQLRETURN SQLEndTran(SQLSMALLINT HandleType, SQLHANDLE Handle, SQLSMALLINT CompletionType);

#endif //WIN32