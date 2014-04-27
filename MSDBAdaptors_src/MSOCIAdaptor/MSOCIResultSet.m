/*
 
 MSOCIResultSet.m
 
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
#import "MSOCIResultSet.h"
#import "_MSOCIConnectionPrivate.h"
#import "_MSOCIResultSetPrivate.h"
#import "MSOCIConnection.h"
#import "orl.h"

#define OCI_RESULT_NOT_INITIALIZED	0
#define OCI_POSSIBLE_RESULT		1
#define OCI_NO_MORE_RESULTS		2


#define UTF8_BYTES_PER_CHAR     4

#define OCI_NUMERIC                     1
#define OCI_DATETIME                    3
#define OCI_TEXT                        4
#define OCI_LONG                        5
#define OCI_LOB                         7
#define OCI_TIMESTAMP                   9
#define OCI_RAW                         11


//#define OCI_CDT_CURSOR                      6
//#define OCI_CDT_INTERVAL                    10
//#define OCI_CDT_FILE                        8
//#define OCI_CDT_OBJECT                      12
//#define OCI_CDT_COLLECTION                  13
//#define OCI_CDT_REF                         14

#define OCI_NUM_UNSIGNED                    2
#define OCI_NUM_SHORT                       4
#define OCI_NUM_INT                         8
#define OCI_NUM_BIGINT                      16

#define OCI_NUM_NUMBER                      32
#define OCI_NUM_DOUBLE                      64
#define OCI_NUM_USHORT                      (OCI_NUM_SHORT  | OCI_NUM_UNSIGNED)
#define OCI_NUM_UINT                        (OCI_NUM_INT    | OCI_NUM_UNSIGNED)
#define OCI_NUM_BIGUINT                     (OCI_NUM_BIGINT | OCI_NUM_UNSIGNED)

#define OCI_BLOB                            1
#define OCI_CLOB                            2
#define OCI_NCLOB                           3

#define OCI_BLONG                           1
#define OCI_CLONG                           2

#define OCI_SIZE_LONG                       (64*1024)-1

@implementation MSOCIResultSet

BOOL _OCI_ColumnMap (OCIResultset *rs,int pos)
{
    OCIColumnInfo *ci = &rs->columnInfo[pos];

    switch (ci->oracode)
    {
        case SQLT_INT:
            ci->type = OCI_NUMERIC;;
            ci->subtype = OCI_NUM_INT;
            ci->bufsize =sizeof(int);
            break;
        case SQLT_UIN:
            ci->type = OCI_NUMERIC;
            ci->subtype = OCI_NUM_UINT;
            ci->bufsize = sizeof(unsigned int);
            break;

        case SQLT_FLT:
        case SQLT_VNU:
        case SQLT_PDN:
        case SQLT_NUM:
        case SQLT_BFLOAT:
        case SQLT_BDOUBLE:
        case SQLT_IBFLOAT:
        case SQLT_IBDOUBLE:
            ci->oracode = SQLT_VNU;
            ci->type    = OCI_NUMERIC;
            ci->subtype = OCI_NUM_NUMBER;
            ci->bufsize = sizeof(OCINumber);
            break;

        case SQLT_DAT:
        case SQLT_ODT:
            ci->type = OCI_DATETIME;
            ci->bufsize = sizeof(OCIDate);
            break;

        case SQLT_BIN:
            ci->type    = OCI_RAW;
            ci->bufsize = (ub4) (ci->size + (ub2) sizeof(char));
            break;

        case SQLT_BLOB:
            ci->type    = OCI_LOB;
            ci->subtype = OCI_BLOB;
            ci->bufsize = (ub4) sizeof(OCILobLocator *);
            break;

        case SQLT_CLOB:
            ci->type    = OCI_LOB;
            ci->bufsize = (ub4) sizeof(OCILobLocator *);

            if (ci->csfrm == SQLCS_NCHAR)
                ci->subtype = OCI_NCLOB;
            else
                ci->subtype = OCI_CLOB;

            break;

        case SQLT_LNG:
        case SQLT_LVC:
        case SQLT_LBI:
        case SQLT_LVB:
        case SQLT_VBI:
            ci->type    = OCI_LONG;
            ci->bufsize =  OCI_SIZE_LONG;
            if (ci->oracode == SQLT_LBI ||
                ci->oracode == SQLT_LVB ||
                ci->oracode == SQLT_VBI) {
                ci->subtype = OCI_BLONG;
            }
                else
                {
                    ci->subtype = OCI_CLONG;
                    ci->bufsize  *= UTF8_BYTES_PER_CHAR;
                }

                break;
        case SQLT_TIMESTAMP:

            ci->type    = OCI_TIMESTAMP;
            ci->bufsize = (ub4) sizeof(OCIDateTime *);
            break;

        case SQLT_CHR:
        case SQLT_STR:
        case SQLT_VCS:
        case SQLT_AFC:
        case SQLT_AVC:
        case SQLT_VST:
        case SQLT_LAB:
        case SQLT_OSL:
        case SQLT_SLS:
            ci->type    = OCI_TEXT;
            ci->bufsize = (ub4) ((ci->size + 1) * (ub2) sizeof(char));
            ci->bufsize  *= UTF8_BYTES_PER_CHAR; //nls_utf8
            break;

        default:
            break;
    }
    return YES;
}

BOOL _OCI_DefineAlloc(OCICtx *ctx, OCIStmt *hstmt, OCIResultset *rs, int pos)
{
    BOOL res = TRUE;
    ub4 fetch_mode = 0;
    sb4 bufsize;

    OCIColumnInfo *ci = &(rs->columnInfo[pos]);
    OCIColumnDefine *def = &(rs->columnDefine[pos]);

    def->fetchBuffer=NULL;
    def->position = pos+1;

    def->handle=0;
    def->indicator=0;

    bufsize = ci->bufsize;
    fetch_mode = OCI_DEFAULT;

    switch (ci->type) {
        case OCI_LONG:
            fetch_mode = OCI_DYNAMIC_FETCH;
            def->fetchBuffer = CBufferCreate(0);
            bufsize = SB4MAXVAL;
            break;
        case OCI_LOB:
            def->fetchBuffer = NULL;
            OCI_CALL(res, ctx, OCIDescriptorAlloc(ctx->henv,(void**)&(def->lob),OCI_DTYPE_LOB,(size_t)0, (dvoid **)0));
            if (!res) { NSLog(@"Unable to alloc LOB descriptor");}
            default:

                def->fetchBuffer = CBufferCreate(bufsize);
                break;
    }

    OCI_CALL(res, ctx, OCIDefineByPos(hstmt, //OCIStmt *stmtp
                                      (OCIDefine **)&def->handle, //OCIDefine **defnp
                                      (OCIError *)ctx->herror, //OCIError *errhp
                                      (ub4)def->position, //ub4 position
                                      (void  *)(ci->type==OCI_LOB?&def->lob:(void *)def->fetchBuffer->buf), //void  *valuep
                                      (sb4   ) bufsize,      //sb4 value_sz
                                      (ub2   ) ci->oracode,   //ub2 dty                //OCI_DTYPE_LOB
                                      (void *) (&def->indicator), //void  *indp
                                      (ub2  *) (&def->width),     //ub2 *rlenp
                                      (ub2  *) NULL,		//ub2 *rcodep
                                      (ub4)fetch_mode)); //ub4 mode

    return res;

}

BOOL _OCI_ReadLOB(OCICtx *_ctx,ub2 subtype, OCILobLocator *lob,CBuffer *aBuffer)
{
    ub8 lob_size = 0;
#ifdef WO451
    ub8 maxlen = 9223372036854775807LL ; //ORASB8MAXVAL; //#define ORASB8MAXVAL    ((orasb8) 9223372036854775807)
#else
    ub8 maxlen = ORASB8MAXVAL;
#endif

    BOOL res = YES;

    OCI_CALL(res, _ctx,OCILobGetLength2(_ctx->hservice , _ctx->herror,lob, (ub8 *) &lob_size));
    if (res) {
        if (subtype==OCI_CLOB) {lob_size *=UTF8_BYTES_PER_CHAR;}

        if ( CBufferExpand(aBuffer, lob_size) ) {
            OCI_CALL(res,_ctx, OCILobRead2(_ctx->hservice , _ctx->herror,lob,&lob_size,&maxlen,1,aBuffer->buf+aBuffer->length,aBuffer->size,OCI_ONE_PIECE,NULL,NULL,0,SQLCS_IMPLICIT));
            aBuffer->length = aBuffer->size;
        }

    }
    return res;
}

void _OCI_Cleanup(OCIResultset *rs, BOOL all)
{
    if (rs) {
        int i = 0 ;

        for (i=0; i<rs->colCount; i++) {
            if (rs->columnInfo[i].type == OCI_LOB && rs->columnDefine[i].lob ) {
                OCIDescriptorFree((dvoid *)rs->columnDefine[i].lob, (ub4)OCI_DTYPE_LOB);
                rs->columnDefine[i].lob = NULL;
            }

            FREE(rs->columnDefine[i].fetchBuffer, "_OCI_Cleanup");
            rs->columnDefine[i].fetchBuffer = NULL;
        }

        if (all) {
            FREE(rs->columnInfo,"_OCI_Cleanup");rs->columnInfo=NULL;
            FREE(rs->columnDefine,"_OCI_Cleanup");rs->columnDefine=NULL;
        }
    }
}

BOOL _OCI_FetchPieces(OCICtx *ctx,OCIStmt *hstmt , OCIResultset *rs)
{
    ub4 type, iter, dx;
    ub1 in_out, piece;
    void *handle;
    int index = -1;
    BOOL res = TRUE;
    sword status = OCI_NEED_DATA;
    ub4 piecesize ;
    CBuffer *fb ;
    int i = 0 ;

    piece  = OCI_NEXT_PIECE;
    iter   = 0;
    handle = NULL;

    OCI_CALL(res, ctx,  OCIStmtGetPieceInfo(hstmt,ctx->herror, &handle,  &type, &in_out, &iter, &dx, &piece);)


//    NSLog(@"OCIStmtGetPieceInfo = %u handle = %lu ",piece,(unsigned long)handle);

    //Search define ...

    for (i=0; i<rs->colCount ; i++) {
        if ((rs->columnInfo[i].type == OCI_LONG) && (rs->columnDefine[i].handle == handle)) {
            index = i;
            break ;
        }
    }

    if (index==-1) {return NO;}

    fb = rs->columnDefine[index].fetchBuffer ;
    fb->length = 0 ;

    while ((res == TRUE) && (status == OCI_NEED_DATA))
    {
        piecesize = OCI_SIZE_LONG ;
        if (!CBufferExpand(fb, piecesize)) {
//            NSLog(@"CBufferGrow failed");
            // what do we do if we cannot make the buffer growing
        }

        OCI_CALL(res, ctx,  OCIStmtSetPieceInfo(rs->columnDefine[index].handle,OCI_HTYPE_DEFINE, ctx->herror,(fb->buf + fb->length),&piecesize,piece,NULL,(ub2 *) NULL));

        status = OCIStmtFetch2(hstmt,ctx->herror, (ub4)1, (ub2) OCI_FETCH_NEXT, (sb4) 0, (ub4) OCI_DEFAULT) ;
        OCI_CALL(res, ctx,  OCIStmtGetPieceInfo(hstmt,ctx->herror, &handle,  &type, &in_out, &iter, &dx, &piece);)

            if (res) { fb->length += piecesize ;}
   }

//   NSLog(@"index = %u",index);

    return YES;
}


#define _GET_NUMBER_VALUE_METHOD(NAME, TYPE) \
- (BOOL)get ## NAME ## At:(TYPE *)aValue column:(NSUInteger)column error:(MSInt *)errorPtr \
{ \
    MSInt error = MSNoColumn ; \
	BOOL good = NO ; \
    TYPE value=0; \
    sword status; \
    if (_state == OCI_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; } \
	else if (_state == OCI_NO_MORE_RESULTS) { error = MSFetchIsOver ; } \
	else if (column <  MSACount(_columnsDescription->_keys)) { \
       OCIColumnInfo *ci = [(_MSOCIRowKeys *)_columnsDescription infoAtIndex:column];\
       OCIColumnDefine *def= [(_MSOCIRowKeys *)_columnsDescription defineAtIndex:column];\
        if ( def->indicator ==-1){ \
            error = MSNullFetch; \
        } else { \
            switch (ci->type) \
            { \
                case OCI_NUMERIC:\
                {\
                    NSLog(@"indicator = %u  width = %u",def->indicator,def->width); \
                    if (ci->subtype == OCI_NUM_NUMBER) {\
                        OCI_CALL_NO_WARNING(status, _ctx, OCINumberToReal(_ctx->herror,(OCINumber*)def->fetchBuffer->buf, sizeof(*aValue) , &value)); \
                    } else {\
                        uword sign = OCI_NUMBER_SIGNED; \
                        OCI_CALL_NO_WARNING(status, _ctx, OCINumberToInt(_ctx->herror,(OCINumber*)def->fetchBuffer->buf, sizeof(*aValue) , sign, &value)); \
                    }\
                    if (status == OCI_SUCCESS) { \
                        if (aValue) *aValue = value ; \
                        error = MSFetchOK ; good = YES; \
                    } else { \
                        error = MSNotConverted ; \
                        break ; \
                    } \
                    break; \
                } \
                default: \
                    error = MSNotConverted ;\
                    break ;\
            }\
        }\
    }\
    if (errorPtr) *errorPtr = error ; \
    return good;\
}

_GET_NUMBER_VALUE_METHOD(Char, MSChar)
_GET_NUMBER_VALUE_METHOD(Byte, MSByte)
_GET_NUMBER_VALUE_METHOD(Short, MSShort)
_GET_NUMBER_VALUE_METHOD(Int, MSInt)
_GET_NUMBER_VALUE_METHOD(Long, MSLong)

_GET_NUMBER_VALUE_METHOD(Double, double)
_GET_NUMBER_VALUE_METHOD(Float, float)

- (BOOL)getStringAt:(CUnicodeBuffer *)aString column:(NSUInteger)column error:(MSInt *)errorPtr ; 
{
    MSInt error = MSNoColumn ; 
    BOOL good = NO ; 
    if (_state == OCI_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; } 
        else if (_state == OCI_NO_MORE_RESULTS) { error = MSFetchIsOver ; } 
        else if (column <  MSACount(_columnsDescription->_keys)) { 
            
            OCIColumnInfo *ci = [(_MSOCIRowKeys *)_columnsDescription infoAtIndex:column];
            OCIColumnDefine *def= [(_MSOCIRowKeys *)_columnsDescription defineAtIndex:column];
            
            if (def->indicator ==-1){ 
                error = MSNullFetch; 
            } else { 
                switch (ci->type) 
                { 
                    case OCI_TEXT:
                    {
                        error = MSFetchOK ;
                        good = CUnicodeBufferAppendUTF8Bytes(aString, (void *)def->fetchBuffer->buf, def->fetchBuffer->length) ;	
                        break; 
                    } 
                    default: 
                        error = MSNotConverted ;
                        break ;
                }
            }
        }
        if (errorPtr) *errorPtr = error ; 
        return good;
    }
 
- (BOOL)getBufferAt:(CBuffer *)aBuffer column:(NSUInteger)column error:(MSInt *)errorPtr
{
    MSInt error = MSNoColumn ;
    BOOL good = NO ;
    if (_state == OCI_RESULT_NOT_INITIALIZED) { error = MSNotInitalizedFetch ; }
    else if (_state == OCI_NO_MORE_RESULTS) { error = MSFetchIsOver ; }
    else if (column <  MSACount(_columnsDescription->_keys)) {
        OCIColumnInfo *ci = [(_MSOCIRowKeys *)_columnsDescription infoAtIndex:column];
        OCIColumnDefine *def= [(_MSOCIRowKeys *)_columnsDescription defineAtIndex:column];

        if (def->indicator ==-1){
            error = MSNullFetch;
        } else {

            if (ci->type == OCI_LOB) {
                good =_OCI_ReadLOB(_ctx,ci->subtype, def->lob,aBuffer);
            } else {
                good = CBufferAppendBytes(aBuffer, def->fetchBuffer->buf, def->fetchBuffer->length);
            }

            error = MSFetchOK ;
        }
    }
    if (errorPtr) *errorPtr = error ;
    return good;
}


- (id)initWithStatement:(OCIStmt*)statement connection:(MSDBConnection *)connection
{
    if ((self = [super initWithDatabaseConnection:connection])) {
        int i = 0 ;
        short count = 0;
        MSArray *keys ;

        OCIParam  *param;
        BOOL res = YES;
        text *colName;
        ub4  colNameLen;

        OCIResultset *rs;
        OCIColumnInfo *ci;

        _ctx = [(MSOCIConnection*)connection context];
        _hstmt = statement ;

        OCI_CALL(res, _ctx,OCIAttrGet ((dvoid *)statement, (ub4) OCI_HTYPE_STMT, (dvoid *) &count, (ub4 *) 0, (ub4)OCI_ATTR_PARAM_COUNT,(OCIError *)_ctx->herror));

        if (!res) { RELEASE(self) ; return nil ; }

        if (!(keys = MSCreateArray(count))) { RELEASE(self) ; return nil ; }


        if (!(rs = (OCIResultset *)MSMalloc(sizeof(OCIResultset), "-[MSOCIResultSet initWithStatement:connection:]"))) { RELEASE(keys) ; RELEASE(self) ; return nil ; }

        rs->colCount = count;
        rs->hstmt=statement;

        //Alloc Columns info and define
        rs->columnInfo = (OCIColumnInfo *)calloc(count,sizeof(OCIColumnInfo));
        rs->columnDefine = (OCIColumnDefine *)calloc(count,sizeof(OCIColumnDefine));

        if (!(rs->columnInfo || rs->columnDefine)) {
            if (rs->columnInfo) { MSFree(rs->columnInfo, "MSOCIResultSet.columnInfo");}
            if (rs->columnDefine) { MSFree(rs->columnDefine, "MSOCIResultSet.columnDefine");}
            return nil;
        }

        for	(i = 0 ; i < count ; i++) {
            MSASCIIString *s;

            ci = &(rs->columnInfo[i]);

            OCI_CALL(res, _ctx, OCIParamGet ((dvoid *)statement, OCI_HTYPE_STMT, _ctx->herror, (dvoid*) &param, i+1));

            /* sql code */
            OCI_CALL(res, _ctx, OCIAttrGet((dvoid *) param, (ub4) OCI_DTYPE_PARAM, (dvoid *) &(ci->oracode),(ub4 *) 0, OCI_ATTR_DATA_TYPE, _ctx->herror ));
            /* size */
            OCI_CALL(res, _ctx, OCIAttrGet((dvoid *) param, (ub4) OCI_DTYPE_PARAM, (dvoid *) &(ci->size),(ub4 *) NULL, OCI_ATTR_DATA_SIZE, _ctx->herror ));
            /* scale */
            OCI_CALL(res, _ctx, OCIAttrGet((dvoid *) param, (ub4) OCI_DTYPE_PARAM, (dvoid *) &(ci->scale),(ub4 *) NULL, OCI_ATTR_SCALE, _ctx->herror ));
            /* precision */
            OCI_CALL(res, _ctx, OCIAttrGet((dvoid *) param, (ub4) OCI_DTYPE_PARAM, (dvoid *) &(ci->prec), (ub4 *) NULL, OCI_ATTR_PRECISION, _ctx->herror ));
            /*column name */
            OCI_CALL(res, _ctx, OCIAttrGet((dvoid *) param, (ub4) OCI_DTYPE_PARAM, (dvoid**) &colName,(ub4 *) &colNameLen, OCI_ATTR_NAME, _ctx->herror ));

            /* charset form */
            OCI_CALL(res, _ctx, OCIAttrGet((dvoid *) param, (ub4) OCI_DTYPE_PARAM, (dvoid *) &(ci->csfrm), (ub4 *) NULL, OCI_ATTR_CHARSET_FORM, _ctx->herror ));

            /* type of column length for string based column */
            OCI_CALL(res, _ctx, OCIAttrGet((dvoid *) param, (ub4) OCI_DTYPE_PARAM, (dvoid *) &(ci->charused),(ub4 *) NULL,(ub4) OCI_ATTR_CHAR_USED, _ctx->herror));
            /* char size */
            OCI_CALL(res, _ctx, OCIAttrGet((dvoid *) param, (ub4) OCI_DTYPE_PARAM, (dvoid *) &(ci->charsize), (ub4 *) NULL, (ub4) OCI_ATTR_CHAR_SIZE, _ctx->herror));


            if (res) {
                _OCI_ColumnMap(rs,i);
                _OCI_DefineAlloc(_ctx,_hstmt,rs,i);
            }

            s = MSCreateASCIIStringWithBytes(colName, colNameLen, NO, NO);
            // NSLog(@"Col: %@ - Type %u - Size : %u - Prec : %u",s,ci->oracode ,ci->bufsize,ci->prec);

            if (!s || !res) {
                _OCI_Cleanup(rs,YES);
                RELEASE(keys) ; RELEASE(self) ; return nil ;
            }

            MSAAddUnretained(keys, s) ;
        }

        _columnsDescription = RETAIN([_MSOCIRowKeys rowKeysWithKeys:keys]) ;

        ((_MSOCIRowKeys *) _columnsDescription)->_rs = rs ; // possible because _MSODBCRowKeys is a private subclass.

        RELEASE(keys) ;
        if (!_columnsDescription) { RELEASE(self) ; return nil ; }

        _state = OCI_RESULT_NOT_INITIALIZED ;
    }
    return self ;
}

- (id)objectAtColumn:(NSUInteger)column
{
    sword status;

    if (_state == OCI_POSSIBLE_RESULT) {
        if (column < MSACount(_columnsDescription->_keys)) {

            OCIColumnInfo *ci = [(_MSOCIRowKeys *)_columnsDescription infoAtIndex:column];
            OCIColumnDefine *def = [(_MSOCIRowKeys *)_columnsDescription defineAtIndex:column];

            switch (ci->type) {

                case OCI_NUMERIC:
                {

                    if (ci->subtype==OCI_NUM_NUMBER) {
                        double value;
                        OCI_CALL_NO_WARNING(status, _ctx, OCINumberToReal(_ctx->herror,(OCINumber *)(def->fetchBuffer->buf), sizeof(value) , &value));
                        return [NSNumber numberWithDouble:value];
                    } else {
                        long long value;
                        OCI_CALL_NO_WARNING(status, _ctx, OCINumberToInt(_ctx->herror,(OCINumber *)(def->fetchBuffer->buf), sizeof(value) , OCI_NUMBER_SIGNED, &value));
                        return [NSNumber numberWithLongLong:value];
                    }
                    break ;
                }
                case OCI_DATETIME:
                    break ;

                case OCI_TEXT: {
#ifdef WO451
                    NSData *data = [NSData dataWithBytes:def->fetchBuffer->buf length:(NSUInteger)def->width] ;
                    return	AUTORELEASE([ALLOC(NSString) initWithData:data encoding:NSUTF8StringEncoding]);
#else
                    return	AUTORELEASE([ALLOC(NSString) initWithBytes:def->fetchBuffer->buf length:def->width encoding:NSUTF8StringEncoding]);
#endif

                    break ;
                }
                case OCI_LONG: {
                    if (ci->subtype==OCI_CLONG) {
#ifdef WO451
                        NSData *data = [NSData dataWithBytes:def->fetchBuffer->buf length:(NSUInteger)def->fetchBuffer->length] ;
                        return	AUTORELEASE([ALLOC(NSString) initWithData:data encoding:NSUTF8StringEncoding]);
#else
                        return	AUTORELEASE([ALLOC(NSString) initWithBytes:def->fetchBuffer->buf length:def->fetchBuffer->length encoding:NSUTF8StringEncoding]);
#endif
                    } else {
                        return [NSData dataWithBytes:def->fetchBuffer->buf length:(NSUInteger)def->fetchBuffer->length];
                    }
                    break ;
                }
                case OCI_LOB:
                {
                    CBuffer *aBuffer;
                    NSData *data = NULL;
                    BOOL res=YES;

                    aBuffer = CBufferCreate(0);
                    res = _OCI_ReadLOB(_ctx,ci->subtype, def->lob,aBuffer);
                    if (res) {data = [NSData dataWithBytes:aBuffer->buf length:(NSUInteger)aBuffer->length];}
                    CBufferFree(aBuffer);

                    return data;
                    break ;
                }
                case OCI_TIMESTAMP:
                    break ;

                case OCI_RAW:
                    break ;

                default:
                    break ;
            }
        }
       else {
            MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"try to reach undefined column at index %lu", (unsigned long)column) ;
        }
   }
    return NULL;
}

- (MSArray *)allValues
{
    if (_state == OCI_POSSIBLE_RESULT) {
        NSUInteger columnsCount = MSACount(_columnsDescription->_keys) ;
        MSArray *values = MSCreateArray(columnsCount) ;
        if (columnsCount && values) {
            NSUInteger i ;
            for (i = 0; i < columnsCount ; i++) {
                id o = [self objectAtColumn:i] ;
                if (!o) { o = MSNull ; }
                MSAAdd(values, o) ;
            }
        }
        return AUTORELEASE(values) ;
    }
    return nil ;
}

- (MSRow *)rowDictionary
{
    if (_state == OCI_POSSIBLE_RESULT) {
        NSUInteger columnsCount = MSACount(_columnsDescription->_keys) ;
        if (columnsCount) {
            NSUInteger i ;
            MSArray *values = MSCreateArray(columnsCount) ;
            if (values) {
                MSRow *row ;
                for (i = 0; i < columnsCount ; i++) {
                    id o = [self objectAtColumn:i] ;
                    if (!o) { o = MSNull ; }
                    MSAAdd(values, o) ;
                }
                row = [ALLOC(MSRow) initWithRowKeys:_columnsDescription values:values] ;
                RELEASE(values) ;
                return AUTORELEASE(row) ;
            }
        }
    }
    return nil ;
}

- (BOOL)nextRow
{
    if (_state != OCI_NO_MORE_RESULTS) {
        sword status;

        OCI_CALL_NO_WARNING(status, _ctx,OCIStmtFetch2(_hstmt,_ctx->herror, (ub4)1, (ub2) OCI_FETCH_NEXT, (sb4) 0, (ub4) OCI_DEFAULT) );
        //NSLog(@"OCIStmtFetch2 statut= %d",status);

        if (status == OCI_NEED_DATA) {
            OCIResultset *rs =[((_MSOCIRowKeys *)_columnsDescription) resultset];

            NSLog(@"OCI_NEED_DATA");

            _OCI_FetchPieces(_ctx,_hstmt,rs);
        }

        if (OCI_NO_WARNING(status) ==YES) {
            if (status == OCI_NO_DATA) {
                _state =OCI_NO_MORE_RESULTS;
            }
            else {
                _state = OCI_POSSIBLE_RESULT ;
                return YES;
            }
        }
    }
    return NO ;
}

- (void)terminateOperation
{
    OCIResultset *rs ;
    if (_connection) {
        if (_hstmt) { OCIHandleFree(_hstmt, OCI_HTYPE_STMT);}
        _hstmt = NULL ;
        _state = OCI_NO_MORE_RESULTS ;

        rs = [(_MSOCIRowKeys *)_columnsDescription resultset];
        _OCI_Cleanup(rs,NO);

        [(_MSDBGenericConnection *)_connection unregisterOperation:self] ;
        [super terminateOperation] ;
    }
}


@end

@implementation _MSOCIRowKeys : MSRowKeys

- (OCIResultset*)resultset ;
{
	return _rs;   
}

- (OCIColumnInfo *)infoAtIndex:(NSUInteger)idx ;
{
    if (idx >= MSACount(_keys)) {
        MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"column %lu out of bounds [0, %lu]", (unsigned long)idx, (unsigned long)MSACount(_keys)) ;
    }
    return &_rs->columnInfo[idx] ;
}

- (OCIColumnDefine *)defineAtIndex:(NSUInteger)idx ;
{
    if (idx >= MSACount(_keys)) {
        MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"column %lu out of bounds [0, %lu]", (unsigned long)idx, (unsigned long)MSACount(_keys)) ;
    }
    return &_rs->columnDefine[idx] ;

}

- (void)dealloc
{
    _OCI_Cleanup(_rs,YES);
    FREE(_rs, "-[_MSOCIRowKeys dealloc]");
    [super dealloc] ;
}

@end
