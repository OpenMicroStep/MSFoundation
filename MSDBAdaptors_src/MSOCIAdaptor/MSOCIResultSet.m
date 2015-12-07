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

#import "MSOCIAdaptorKit.h"

@implementation MSOCIResultSet

static inline BOOL _check(MSOCIResultSet *self, sword ociReturnValue) {
  NSString *error= nil; BOOL ret;
  if (!(ret= _check_err(ociReturnValue, self->_ctx->herror, &error)))
    NSLog(@"MSOCIResultSet: %@", error);
  return ret;
}


static sb4 _OCICallbackDefine(void *octxp, OCIDefine *defnp, ub4 iter, void **bufpp, ub4 **alenpp, ub1 *piecep, void **indpp, ub2 **rcodep)
{
  OCIFieldInfo *info= (OCIFieldInfo *)octxp; NSUInteger len= **alenpp;
  if (*piecep == OCI_FIRST_PIECE) {
    DESTROY(info->output);
    info->output= CCreateBuffer(len);
  }
  if (info->output->size < len)
    CBufferGrow(info->output, len - info->output->size, NO);
  info->output->length= info->output->size;
  *bufpp= CBufferBytes(info->output);
  return OCI_SUCCESS;
}

- (CBuffer *)_readLob:(OCILobLocator *)lob charsize:(ub4)charsize
{
  ub4 lob_size; CBuffer *buf= NULL; ub1 csfrm;
  if (!_check(self, OCILobCharSetForm(_ctx->henv, _ctx->herror, lob, &csfrm)))
    csfrm= 0;
  if (_check(self, OCILobGetLength(_ctx->hservice, _ctx->herror, lob, &lob_size))) {
    buf= CCreateBuffer(lob_size);
    buf->length= lob_size;
    if (lob_size > 0 && !_check(self, OCILobRead(_ctx->hservice, _ctx->herror, lob, &lob_size, 1, CBufferBytes(buf), lob_size * charsize, NULL, NULL, OCI_UTF16ID, csfrm)))
      DESTROY(buf);
  }
  return buf;
}

- (BOOL)_initColumnField:(OCIFieldInfo *)info atIndex:(ub4)i keys:(CArray *)keys
{
  BOOL ok; OCIParam  *param; text *colName; ub4 colNameLen= 0;
  ub2 colType, colLength, colCharSz; sb2 colPrecision; sb1 colScale; ub1 colIsNull;
  ub2 outType; ub4 fetchMode; dvoid *fetchValue= 0; sb4 fetchSize;

  if((ok= _check(self, OCIParamGet((dvoid *)_stmt, OCI_HTYPE_STMT, _ctx->herror, (dvoid*)&param, i)))) {
    ok= ok && _check(self,  OCIAttrGet(param, OCI_DTYPE_PARAM, &colType     ,           0, OCI_ATTR_DATA_TYPE, _ctx->herror));
    ok= ok && _check(self,  OCIAttrGet(param, OCI_DTYPE_PARAM, &colName     , &colNameLen, OCI_ATTR_NAME     , _ctx->herror));
    ok= ok && _check(self,  OCIAttrGet(param, OCI_DTYPE_PARAM, &colLength   ,           0, OCI_ATTR_DATA_SIZE, _ctx->herror));
    ok= ok && _check(self,  OCIAttrGet(param, OCI_DTYPE_PARAM, &colCharSz   ,           0, OCI_ATTR_CHAR_SIZE, _ctx->herror));
    ok= ok && _check(self,  OCIAttrGet(param, OCI_DTYPE_PARAM, &colPrecision,           0, OCI_ATTR_PRECISION, _ctx->herror));
    ok= ok && _check(self,  OCIAttrGet(param, OCI_DTYPE_PARAM, &colScale    ,           0, OCI_ATTR_SCALE    , _ctx->herror));
    ok= ok && _check(self,  OCIAttrGet(param, OCI_DTYPE_PARAM, &colIsNull   ,           0, OCI_ATTR_IS_NULL  , _ctx->herror));
    if (ok) {
      info->oraType= colType;
      info->name= CCreateStringWithBytes(NSUTF16StringEncoding, colName, colNameLen);
      CArrayAddObject(keys, (id)info->name);
      if (colType == SQLT_RDD || colType == SQLT_INTERVAL_YM || colType == SQLT_INTERVAL_DS)
        fetchSize= 50;
      else if (colType == SQLT_NUM || colType == SQLT_VNU)
        fetchSize= colPrecision > 0 ? colPrecision : 38;
      else
        fetchSize= colLength;
      fetchMode= OCI_DEFAULT;
      switch(colType) {
        case SQLT_INT:
        case SQLT_FLT:
        case SQLT_NUM:
        case SQLT_VNU:
        case SQLT_UIN:
          fetchSize= (fetchSize + 1) * sizeof(unichar);
          outType= SQLT_STR; // For exact precision
          info->type= MSOCITypeDecimal; // char * -> MSDecimal
          break;

        case SQLT_VBI:
        case SQLT_BIN:
        case SQLT_LBI:
        case SQLT_LVC:
        case SQLT_LVB:
        case SQLT_BLOB:
        case SQLT_FILE:
        case SQLT_NTY:
        case SQLT_REF:
        case SQLT_RID:
          if (colType == SQLT_BIN || colType == SQLT_LBI || colType == SQLT_CLOB)
            outType= colType;
          else
            outType= SQLT_BLOB;
          if (colType == SQLT_BIN) {
            fetchMode= OCI_DYNAMIC_FETCH;}
          else if (colType == SQLT_LBI) {
            fetchMode= OCI_DYNAMIC_FETCH;
            fetchSize= SB4MAXVAL;}
          else {
            ok= ok && _check(self, OCIDescriptorAlloc(_ctx->henv, (void**)&info->lob, OCI_DTYPE_LOB, 0, 0));
            fetchValue= &info->lob;
            fetchSize= -1;
          }
          info->type= colType == SQLT_CLOB ? MSOCITypeString : MSOCITypeBuffer;
          break;

        case SQLT_DAT:
        case SQLT_ODT:
        case SQLT_TIMESTAMP:
        case SQLT_TIMESTAMP_TZ:
        case SQLT_TIMESTAMP_LTZ:
          outType= SQLT_DAT;
          info->type= MSOCITypeDateTime;
          break;

        case SQLT_LNG:
          fetchMode= OCI_DYNAMIC_FETCH;
          fetchSize= SB4MAXVAL;
          outType= SQLT_LNG;
          info->type= MSOCITypeString;
          break;

        case SQLT_STR:
        case SQLT_VST:
        case SQLT_CHR:
        case SQLT_AFC:
        case SQLT_VCS:
        case SQLT_AVC:
        case SQLT_RDD:
        case SQLT_INTERVAL_YM:
        case SQLT_INTERVAL_DS:
        default:
          fetchSize= (fetchSize + 1) * sizeof(unichar);
          outType= SQLT_STR;
          info->type= MSOCITypeString;
          break;
      }
      if (!fetchValue && fetchMode != OCI_DYNAMIC_FETCH) {
        info->output= CCreateBuffer(fetchSize);
        info->output->length= info->output->size;
        fetchValue= CBufferBytes(info->output);
      }
      ok = ok && _check(self, OCIDefineByPos(_stmt, &info->def, _ctx->herror, i, fetchValue, fetchSize, outType, &info->indicator, 0, 0, fetchMode));
      if (ok && fetchMode == OCI_DYNAMIC_FETCH) {
        info->output= CCreateBuffer(0);
        ok= _check(self, OCIDefineDynamic(info->def, _ctx->herror, info, _OCICallbackDefine));
      }
      if (ok && info->type == MSOCITypeString) {
        ub1 charsetForm= SQLCS_NCHAR;
        ub2 charset= OCI_UTF16ID;
        OCIAttrSet(info->def, OCI_HTYPE_DEFINE, &charsetForm, 0, OCI_ATTR_CHARSET_FORM, 0);
        OCIAttrSet(info->def, OCI_HTYPE_DEFINE, &charset, 0, OCI_ATTR_CHARSET_ID, 0);
      }
    }
  }

  return ok;
}

- (id)initWithConnection:(MSOCIConnection *)connection ocistmt:(OCIStmt *)stmt stmt:(MSOCIStatement *)msstmt
{
  if ((self = [super initWithDatabaseConnection:connection])) {
    BOOL ok; ub4 i, count= 0; CArray *keys;

    keys= CCreateArray(0);
    _ctx= [(MSOCIConnection*)connection context];
    _stmt= stmt ;
    _msstmt= RETAIN(msstmt);

    if ((ok= _check(self, OCIAttrGet((dvoid *)stmt, (ub4)OCI_HTYPE_STMT, (dvoid *)&count, (ub4 *)0, (ub4)OCI_ATTR_PARAM_COUNT, _ctx->herror)))) {
      _columns= MSCalloc(count, sizeof(OCIFieldInfo), "MSOCIResultSet._columns");
      for(i= 0; ok && i < count; ++i) {
        ok= [self _initColumnField:_columns + i atIndex:i + 1 keys:keys];
      }
    }
    _colCount= count;
    _columnsDescription= RETAIN([MSRowKeys rowKeysWithKeys:(id)keys]);
    RELEASE(keys);
    if (!ok)
      DESTROY(self);
  }
  return self ;
}

- (void)terminateOperation
{
  if (_columns) {
    NSUInteger i;
    for(i= 0; i < _colCount; ++i) {
      RELEASE(_columns[i].name);
      RELEASE(_columns[i].output);
      if (_columns[i].lob)
        OCIDescriptorFree(_columns[i].lob, OCI_DTYPE_LOB);
    }
    MSFree(_columns, "MSOCIResultSet._columns");
    _columns= NULL;}
  if (!_msstmt && _stmt) {
    OCIHandleFree((dvoid *)_stmt, (ub4)OCI_HTYPE_STMT);
    _stmt= NULL; }
  DESTROY(_msstmt);
  _state = OCI_NO_MORE_RESULTS;
  [super terminateOperation];
}

/*
- (BOOL)_fetchPieces
{
  BOOL ok= YES;
  int status= OCI_NEED_DATA;
  OCIDefine *def;
  ub4 type;
  ub1 in_out;
  ub4 iter;
  ub4 idx;
  ub1 piece;
  NSUInteger fieldIdx;
  CBuffer *pieceData ;
  OCIFieldInfo *column;

  while (ok && status == OCI_NEED_DATA && (ok= _check(self, OCIStmtGetPieceInfo(_stmt, _ctx->herror, &def, &type, &in_out, &iter, &idx, &piece)))) {
    for (fieldIdx= 0; fieldIdx < _colCount && _columns[fieldIdx]->def != def; ++fieldIdx)
      ;
    if ((ok= fieldIdx < _colCount)) {
      column= _columns[fieldIdx];
      CBufferGrow(column->output, 65535);
      column->output->length= column->output->size;
      dataSize= _column->output->size;
      ok= _check(self, OCIStmtSetPieceInfo(def, OCI_HTYPE_DEFINE, _ctx->herror, data, &dataSize, piece, NULL, NULL));
    }
    if (ok) {
      status= OCIStmtFetch2(_stmt, _ctx->herror, 1, OCI_FETCH_NEXT, OCI_DEFAULT);
      ok= (status == OCI_SUCCESS || status == OCI_SUCCESS_WITH_INFO || status == OCI_NEED_DATA);
    }
  }
  return ok;
}
*/
- (BOOL)nextRow
{
  BOOL ret= NO; int r;
  if (_state != OCI_NO_MORE_RESULTS) {
    r= OCIStmtFetch2(_stmt, _ctx->herror, 1, OCI_FETCH_NEXT, 0, OCI_DEFAULT);
    if (r == OCI_NO_DATA)
      _state= OCI_NO_MORE_RESULTS;
    if (r == OCI_SUCCESS || r == OCI_SUCCESS_WITH_INFO) {
      ret= YES;
      _state= OCI_POSSIBLE_RESULT;
    }
  }
  return ret;
}

- (id)objectForKey:(id)aKey
{
  id o = nil ;
  if (aKey && _columnsDescription) {
    NSUInteger idx = [_columnsDescription indexForKey:[aKey uppercaseString]] ;
    if (idx != NSNotFound) {
      o = [self objectAtColumn:idx] ;
    }
  }
  return o ;
}

- (id)objectAtColumn:(NSUInteger)column
{
  id ret= nil;
  OCIFieldInfo *field;

  if (_state == OCI_POSSIBLE_RESULT && column < _colCount) {
    field= _columns + column;
    if (field->indicator == -1) {
      ret= MSNull;
    }
    else {
      switch(field->type) {
        case MSOCITypeString: {
          unichar *str; NSUInteger length; CBuffer *b;
          b= field->lob ? [self _readLob:field->lob charsize:2] : field->output;
          str= (unichar*)CBufferBytes(b);
          length= _utf16len(str, CBufferLength(b) / 2);
          ret= [MSString stringWithCharacters:str length:length];
          break;
        }

        case MSOCITypeDecimal: {
          SES ses; unichar *str; NSUInteger length;
          str= (unichar*)CBufferBytes(field->output);
          length= _utf16len(str, CBufferLength(field->output) / 2);
          ses= MSMakeSESWithSytes(str, length, NSUTF16StringEncoding);
          ret= AUTORELEASE(CCreateDecimalWithSES(ses,NO,NULL,NULL));
          break;
        }

        case MSOCITypeBuffer: {
          if (field->lob) {
            ret= AUTORELEASE([self _readLob:field->lob charsize:1]);
          }
          else {
            ret= AUTORELEASE(RETAIN(field->output));
          }
          break;
        }

        case MSOCITypeDateTime: {
          char *date; unsigned c, y, M, d, h, m, s;
          date= (char *)CBufferBytes(field->output);
          c = (unsigned)date[0];
          if(c >= 100) {
              y = ((c-100)*100) + (((unsigned)date[1])-100);
              M= date[2];
              d= date[3];
              h= date[4] - 1;
              m= date[5] - 1;
              s= date[6] - 1;
              return [MSDate dateWithYear:y month:M day:d hour:h minute:m second:s];
          }
          break;
        }

        default:
          break;
      }
    }
  }
  return ret;
}

@end
