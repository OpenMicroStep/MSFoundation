/*
 
 MSMySQLStatement.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 
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

#import "MSMySQLAdaptorKit.h"

#define MYSQL_SUCCEEDED(X) ({ BOOL __r__ = (X == 0); if(!__r__) ASSIGN(_lastError, [NSString stringWithUTF8String:mysql_stmt_error(_stmt)]); __r__; })

static inline void _bind_param(char * buffer, MYSQL_BIND *bind, MSMysqlBindParamInfo *bindInfos, enum enum_field_types mysql_type, my_bool is_null, unsigned long length, my_bool is_unsigned)
{
    bind->buffer_type= mysql_type;
    bind->buffer= buffer;
    bindInfos->is_null= is_null;
    bind->is_null= is_null ? &bindInfos->is_null : NULL;
    bindInfos->length= length;
    bind->length= length ? &bindInfos->length : NULL;
    bind->is_unsigned= is_unsigned;
}

static inline void _bind_param_no_copy(MYSQL_BIND *bind, MSMysqlBindParamInfo *bindInfos, enum enum_field_types mysql_type, const void * value, my_bool is_null, unsigned long length, my_bool is_unsigned)
{
    bind->buffer_type= mysql_type;
    bind->buffer= (void *)value;
    bindInfos->is_null= is_null;
    bind->is_null= is_null ? &bindInfos->is_null : NULL;
    bindInfos->length= length;
    bind->length= length ? &bindInfos->length : NULL;
    bind->is_unsigned= is_unsigned;
}

#define BIND_PARAM_COMPLEX_BEGIN(_name, _type) \
  -(BOOL)_name:(_type)value at:(MSUInt)parameterIndex { \
    if(parameterIndex < _bindSize) { \
      MYSQL_BIND *bind= _bind + parameterIndex; \
      MSMysqlBindParamInfo *bindInfo= _bindInfos + parameterIndex;

#define BIND_PARAM_COMPLEX_END \
    } \
    return NO; \
  }

#define BIND_PARAM(_name, _type, _mysql_type, _is_null, _length, _is_unsigned) \
  -(BOOL)_name:(_type)value at:(MSUInt)parameterIndex { \
    if(parameterIndex < _bindSize) { \
      MYSQL_BIND *bind= _bind + parameterIndex; \
      MSMysqlBindParamInfo *bindInfo= _bindInfos + parameterIndex; \
      bindInfo->u._ ## _type=value; \
      _bind_param((char *)&bindInfo->u._ ## _type, bind, bindInfo, _mysql_type, _is_null, _length, _is_unsigned); \
      return YES; \
    } \
    return NO; \
  }

@implementation MSMySQLStatement


- (id)initWithDatabaseConnection:(MSDBConnection *)connection withRequest:(NSData *)request withMYSQL:(MYSQL *)mysql
{
    if((self= [super initWithDatabaseConnection:connection])) {
        _stmt= mysql_stmt_init(mysql);
        if(mysql_stmt_prepare(_stmt, [request bytes], [request length]) == MYSQL_RET_OK) {
            _bindSize= mysql_stmt_param_count(_stmt);
            _bindInfos= (MSMysqlBindParamInfo *)calloc(_bindSize, sizeof(MSMysqlBindParamInfo));
            _bind= (MYSQL_BIND *)calloc(_bindSize, sizeof(MYSQL_BIND));
        }
        else RELEAZEN(self);
    }
    return self;
}

- (void)terminateOperation
{
    if(_bind && _bindInfos) {
        size_t i;
        MYSQL_BIND *bind;
        MSMysqlBindParamInfo *bindInfo;
        for(i= 0; i < _bindSize; ++i) {
            bind= _bind + i;
            bindInfo= _bindInfos + i;
            switch (bind->buffer_type) {
                case MYSQL_TYPE_STRING:
                case MYSQL_TYPE_BLOB:
                    [bindInfo->u._id release];
                    bindInfo->u._id= nil;
                    break;
                case MYSQL_TYPE_DATETIME:
                    free(bindInfo->u._time);
                    break;
                default:
                    break;
            }
        }
        free(_bind);
        free(_bindInfos);
        _bind= NULL;
        _bindInfos= NULL;
    }
    if(_stmt) {
      mysql_stmt_close(_stmt);
      _stmt= NULL;
    }
    [super terminateOperation];
}

BIND_PARAM(bindChar, MSChar, MYSQL_TYPE_TINY, 0, 0, 0);
BIND_PARAM(bindByte, MSByte, MYSQL_TYPE_TINY, 0, 0, 1);
BIND_PARAM(bindShort, MSShort, MYSQL_TYPE_SHORT, 0, 0, 0);
BIND_PARAM(bindUnsignedShort, MSUShort, MYSQL_TYPE_SHORT, 0, 0, 1);
BIND_PARAM(bindInt, MSInt, MYSQL_TYPE_LONG, 0, 0, 0);
BIND_PARAM(bindUnsignedInt, MSUInt, MYSQL_TYPE_LONG, 0, 0, 1);
BIND_PARAM(bindLong, MSLong, MYSQL_TYPE_LONGLONG, 0, 0, 0);
BIND_PARAM(bindUnsignedLong, MSULong, MYSQL_TYPE_LONGLONG, 0, 0, 1);
BIND_PARAM(bindFloat, float, MYSQL_TYPE_FLOAT, 0, 0, 0);
BIND_PARAM(bindDouble, double, MYSQL_TYPE_DOUBLE, 0, 0, 0);

BIND_PARAM_COMPLEX_BEGIN(bindDate, MSDate*)
    MYSQL_TIME *time;
    time= (MYSQL_TIME *)calloc(1, sizeof(MYSQL_TIME));
    time->year= [value yearOfCommonEra];
    time->month= [value monthOfYear];
    time->day= [value dayOfMonth];
    time->hour= [value hourOfDay];
    time->month= [value minuteOfHour];
    time->second= [value secondOfMinute];
    _bind_param_no_copy(bind, bindInfo, MYSQL_TYPE_DATETIME, time, 0, 0, 0);
    return YES;
BIND_PARAM_COMPLEX_END

BIND_PARAM_COMPLEX_BEGIN(bindString, NSString*)
    NSData *d= [(MSMySQLConnection*)_connection sqlDataFromString:value];
    bindInfo->u._id= [d retain];
    _bind_param_no_copy(bind, bindInfo, MYSQL_TYPE_STRING, [d bytes], 0, [d length], 0);
    return YES;
BIND_PARAM_COMPLEX_END

BIND_PARAM_COMPLEX_BEGIN(bindBuffer, MSBuffer*)
    bindInfo->u._id= [value retain];
    _bind_param_no_copy(bind, bindInfo, MYSQL_TYPE_BLOB, [value bytes], 0, [value length], 0);
    return YES;
BIND_PARAM_COMPLEX_END

- (BOOL)bindNullAt:(MSUInt)parameterIndex
{
    if(parameterIndex < _bindSize) {
        _bind_param_no_copy(_bind + parameterIndex, _bindInfos + parameterIndex, MYSQL_TYPE_NULL, NULL, 1, 0, 0);
        return YES;
    }
    return NO;
}

- (MSDBResultSet *)fetch
{
    if(MYSQL_SUCCEEDED(mysql_stmt_bind_param(_stmt, _bind)) &&
       MYSQL_SUCCEEDED(mysql_stmt_execute(_stmt))) {
        return AUTORELEASE([ALLOC(MSMySQLResultSet) initWithStatement:_stmt withConnection:(MSMySQLConnection*)_connection withMSStatement:self]);
    }
    return nil;
}

- (MSInt)execute
{
    if(MYSQL_SUCCEEDED(mysql_stmt_bind_param(_stmt, _bind)) &&
       MYSQL_SUCCEEDED(mysql_stmt_execute(_stmt))) {
        return (MSInt)mysql_stmt_affected_rows(_stmt);
    }
    mysql_stmt_reset(_stmt);
    return MSSQL_ERROR;
}

@end
