//
//  MSOBDCStatement.h
//  _MicroStep
//
//  Created by Vincent Rouillé on 28/11/2014.
//
//

@class MSODBCConnection;

typedef struct  {
    union {
        id _id;
        SQL_TIMESTAMP_STRUCT* _timestamp;
        MSChar _MSChar;
        MSByte _MSByte;
        MSShort _MSShort;
        MSUShort _MSUShort;
        MSInt _MSInt;
        MSUInt _MSUInt;
        MSLong _MSLong;
        MSULong _MSULong;
        float _float;
        double _double;
    } u;
    SQLLEN len;
    SQLSMALLINT type;
} MSODBCBindParamInfo;

@interface MSODBCStatement : MSDBStatement {
    SQLHSTMT _stmt;
    MSODBCBindParamInfo *_bindInfos;
    size_t _bindSize;
}

- (id)initWithStatement:(SQLHSTMT)stmt withConnection:(MSODBCConnection *)connection;

@end
