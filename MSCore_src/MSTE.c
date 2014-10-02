/* MSTE.c
 
 This file is is a part of the MicroStep Framework.
 
 Copyright Herve MALAINGRE & Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 
 
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

#include "MSCore_Private.h"

#pragma mark initialize

id MSTENull;
id MSTETrue;
id MSTEFalse;
id MSTEDistantPast;
id MSTEDistantFuture;
id MSTEEmptyString;

static id _MSTEConstants[26];
void _MSTEInitializeCommon(void); // used in MSSystemInitialize
void _MSTEInitializeCommon(void)
{
  NSUInteger i;
  for (i=0; i<26; i++) _MSTEConstants[i]= nil;
  _MSTEConstants[MSTE_NULL_VALUE]=           MSTENull;
  _MSTEConstants[MSTE_TRUE_VALUE]=           MSTETrue;
  _MSTEConstants[MSTE_FALSE_VALUE]=          MSTEFalse;
  _MSTEConstants[MSTE_DISTANT_PAST_VALUE]=   MSTEDistantPast;
  _MSTEConstants[MSTE_DISTANT_FUTURE_VALUE]= MSTEDistantFuture;
  _MSTEConstants[MSTE_EMPTY_STRING_VALUE]=   MSTEEmptyString;
}

// In MSTE c only and MSTE.m
void _MSTEInitialize(void);
id _MSTEBinaryObject(NSUInteger type, void *pValue);

void _MSTEInitialize(void)
{
  id classKey; CDictionary *d; CString *s;
  classKey= (id)MCSCreate("MSTE-Class");
  d= CCreateDictionary(1);
  s= MCSCreate("NULL");
  CDictionarySetObjectForKey(d, (id)s, classKey); RELEAZEN(s);
  MSTENull= (id)d;
  d= CCreateDictionary(1);
  s= MCSCreate("TRUE");
  CDictionarySetObjectForKey(d, (id)s, classKey); RELEAZEN(s);
  MSTETrue= (id)d;
  d= CCreateDictionary(1);
  s= MCSCreate("FALSE");
  CDictionarySetObjectForKey(d, (id)s, classKey); RELEAZEN(s);
  MSTEFalse= (id)d;
  RELEAZEN(classKey);
  MSTEDistantPast=   (id)CDateDistantPast;
  MSTEDistantFuture= (id)CDateDistantFuture;
  MSTEEmptyString= (id)MCSCreate(NULL);
  _MSTEInitializeCommon();
}

id _MSTEBinaryObject(NSUInteger type, void *pValue)
{
  static size_t sz[10]= {1,1,2,2,4,4,8,8,4,8};
  id k; CDictionary *d; CString *s; CBuffer *b; CDecimal *i;
  k= (id)MCSCreate("MSTE-Class");
  d= CCreateDictionary(3);
  s= MCSCreate("Binary");
  CDictionarySetObjectForKey(d, (id)s, k); RELEAZEN(s); RELEAZEN(k);
  k= (id)MCSCreate("MSTE-Buffer");
  b= CCreateBuffer(sz[type-MSTE_CHAR_VALUE]);
  CBufferAppendBytes(b, pValue, sz[type-MSTE_CHAR_VALUE]);
  CDictionarySetObjectForKey(d, (id)b, k); RELEAZEN(b); RELEAZEN(k);
  k= (id)MCSCreate("MSTE-Type");
  i= CCreateDecimalWithLongLong((MSLong)type);
  CDictionarySetObjectForKey(d, (id)i, k); RELEAZEN(i); RELEAZEN(s);
  return (id)d;
}

#pragma mark decode

typedef struct _MSTEDecodeStruct {
  SES ses;
  NSUInteger nbToken,nbClass,nbKey,currentToken;
  CArray *classes;
  CArray *keys;
  CArray *refs;
  }
_MSTEDecode;

static inline BOOL _isSpace(char c)
{
  return (c==' ' || c=='\t');
}

#define NOT_STR 1
#define STR     2
#define BAD_STR 3
static inline SES _readToken(_MSTEDecode *src, int *type)
// On s'attend à: des blancs, ", des caractères éventuellement escapés, "
// Ou des blans, des caractères pour des nombres, la fin du token (,)
// type= 0 si token vide ou plus de token à lire
// type= 1 pour les non-chaînes (nombre ou [)
// type= 2 pour les chaînes
// type= 3 si chaîne sans " final ou malformée ex:"\uA"
{
  SES ses; int state; char c; NSUInteger i;
  ses= src->ses; state=0; i= 0; *type= 0;
  if (src->currentToken>=src->nbToken) {ses.length= 0; return ses;}
  while (state==0 && SESLength(ses)) {
    c= ((char*)SESSource(ses))[SESStart(ses)+i];
    if (_isSpace(c)) {ses.start++; ses.length--;}
    else state= 1;}
  if (state==1 && SESLength(ses)) {
    c= ((char*)SESSource(ses))[SESStart(ses)+i];
    if      (c=='"') {*type= 2; state= 2; ses.start++; ses.length--;}
    else if (c==',') {state= 4; ses.length= 0;} // empty token
    else {*type= 1; state= 3; i++;}}
  while (state==2 && i<SESLength(ses)) { // une chaîne
    c= ((char*)SESSource(ses))[SESStart(ses)+i];
    if (c=='\\') {
      if (++i<SESLength(ses)) {
        c= ((char*)SESSource(ses))[SESStart(ses)+i];
        i+= (c=='u')?5:1;}}
    else if (c=='"') {state= 4; ses.length= i;}
    else i++;}
  if (state==2) {state= 4; *type= 3;}
  while (state==3 && i<SESLength(ses)) { // un nombre
    c= ((char*)SESSource(ses))[SESStart(ses)+i];
    if (c==',') {state= 4; ses.length= i;}
    else i++;}
  if (state==3) {state= 4; ses.length= i;}
//printf("X1 type: %d %ld %ld\n",*type,ses.start,ses.length);
  return ses;
}

static inline void _number(SES sesTk, int type, void *res)
{
  char c,*end,*p; NSUInteger endTk; CDecimal *dec; BOOL intOnly; SES rSes;
  double d;
  c= ((char*)SESSource(sesTk))[endTk= SESEnd(sesTk)];
  ((char*)SESSource(sesTk))[endTk]= 0x00;
  p= ((char*)SESSource(sesTk))+SESStart(sesTk);
  intOnly= (type!=MSTE_FLOAT_VALUE && type!=MSTE_DOUBLE_VALUE);
  dec= CCreateDecimalWithSES(sesTk, intOnly, NULL, &rSes);
  if (!dec || endTk!=SESEnd(rSes)) { // badly-formed number (not critical)
    }
  switch (type) {
    case MSTE_CHAR_VALUE:   *(MSChar*)res=   CDecimalCharValue(  dec); break;
    case MSTE_UCHAR_VALUE:  *(MSByte*)res=   CDecimalByteValue(  dec); break;
    case MSTE_SHORT_VALUE:  *(MSShort*)res=  CDecimalShortValue( dec); break;
    case MSTE_USHORT_VALUE: *(MSUShort*)res= CDecimalUShortValue(dec); break;
    case MSTE_INT_VALUE:    *(MSInt*)res=    CDecimalIntValue(   dec); break;
    case MSTE_UINT_VALUE:   *(MSUInt*)res=   CDecimalUIntValue(  dec); break;
    case MSTE_LONG_VALUE:   *(MSLong*)res=   CDecimalLongValue(  dec); break;
    case MSTE_ULONG_VALUE:  *(MSULong*)res=  CDecimalULongValue( dec); break;
    // TODO CDecimalDoubleValue
    case MSTE_FLOAT_VALUE:  d=  strtod( p, &end); *(float*)res=  (float)d;  break;
    case MSTE_DOUBLE_VALUE: d=  strtod( p, &end); *(double*)res= (double)d; break;}
  RELEAZEN(dec);
  ((char*)SESSource(sesTk))[endTk]= c;
}

static inline CDictionary *_err(int num, char *fmt, ...)
{
  CDictionary *d; id k,v; va_list args;
  d= CCreateDictionary(0);
  k= (id)MCSCreate("error");
  v= (id)CCreateDecimalWithLongLong(num);
  CDictionarySetObjectForKey(d, v, k);
  RELEASE(k); RELEASE(v);
  if (fmt) {
    k= (id)MCSCreate("description");
    v= (id)MCSCreate(NULL);
    va_start(args, fmt);
    CStringAppendEncodedFormatArguments((CString*)v, NSUTF8StringEncoding, fmt, args);
    va_end(args);
    CDictionarySetObjectForKey(d, v, k);
    RELEASE(k); RELEASE(v);}
  return d;
}
static inline int _ERROR(char *w, int ret, int err, NSUInteger currentToken, char *str, CDictionary **error)
  {
  *error= _err(ret, "%s-Ret %d-Err %d-Token %d-%s",w,ret,err,currentToken,str);
  return ret;
  }
#define RETURN_NIL(W,S) do {_ERROR(W,1,1,src.currentToken,S,error); return nil;} while (1)
#define STOPPING_ERROR(W)       _ERROR(W,2,10,src.currentToken,"Stopping error while reading token.",error)
#define NOT_STOPPING_ERROR(W,E) _ERROR(W,3, E,src.currentToken,"Error while reading token.",error)

static inline int _moveToNewToken(_MSTEDecode *src, SES sesTk, int errLevel, char *w, char *s, CDictionary **error)
// On va jusqu'à la prochaine virgule.
// Retourne 0 si tout est normal et (nouveau token ou fin atteinte).
// Retourne 1 si on a trouvé des choses bizarre entre.
// Retourne 2 si on a atteind la fin mais qu'il reste encore des tokens à lire.
// Retourne 3 si fin des tokens mais encore des choses à lire.
{
  int err= 0, end;
  NSUInteger endTk,endSrc,delta; char c;
  c= ((char*)SESSource(src->ses))[endTk= SESEnd(sesTk)];
  if (c=='"') endTk++;
  end= 0; endSrc= SESEnd(src->ses);
  while (end!=2 && endTk<endSrc) {
    c= ((char*)SESSource(src->ses))[endTk];
    if (end==0) {
      if (c==',') end= 2;
      else if (c=='"') {end= 1; err= 1;}
      else if (!_isSpace(c)) err= 1;}
    else if (end==1) {
      if (c=='\\') {if (++endTk==endSrc) endTk--;}
      else if (c=='"') end= 0;}
    endTk++;}
  delta= endTk-SESStart(src->ses); src->ses.start+= delta; src->ses.length-= delta;
  src->currentToken++;
  if (!err) {
    if      (!src->ses.length && src->currentToken  <  src->nbToken) err= 2;
    else if ( src->ses.length && src->currentToken  >= src->nbToken) err= 3;}
  if (err) {
    if      (errLevel==1) _ERROR(w,1,err,src->currentToken,s,error);
    else if (errLevel==2) _ERROR(w,2,err,src->currentToken,s,error);
    else if (errLevel==3) {
      if (!*error) _ERROR(w,3,err,src->currentToken,s,error);}}
//printf("_moveToNewToken: %d %lu %lu %lu\n",err,src->currentToken,src->ses.start,src->ses.length);
  return err;
}

static inline int _readClassesOrKeys(_MSTEDecode *src, NSUInteger *nb, CArray **a, CDictionary **error)
{
  int err= 0;
  SES ses,ses2; int type; NSUInteger i; CString *s;
  ses= _readToken(src, &type);
  if (type!=NOT_STR) err= _ERROR("MSTE-25",1,1,src->currentToken,"Bad number of classes or keys.",error);
  if (!err) {
    _number(ses, MSTE_ULONG_VALUE, nb);
    if (_moveToNewToken(src,ses,1,"MSTE-26","Bad while reading number of classes or keys.",error)) err= 1;}
  if (!err) {
    if (*nb) *a= CCreateArray(*nb);
    for (i= 0; i<*nb && SESLength(src->ses)>0; i++) {
      ses= _readToken(src, &type);
      if (type!=STR) err= _ERROR("MSTE-30",1,1,src->currentToken,"Bad class or key.",error);
      else {
        ses2= ses; ses2.chai= utf8JsonStringChaiN;
        s= CCreateStringWithSES(ses2);
        if (!s) err= _ERROR("MSTE-31",1,1,src->currentToken,"Bad class or key.",error);
        else CArrayAddObject(*a, (id)s);
        RELEAZEN(s);
        if (!err && _moveToNewToken(src,ses,1,"MSTE-32","Bad class.",error)) err= 1;}}}
  if (!err && *nb!=CArrayCount(*a))
    err= _ERROR("MSTE-33",1,1,src->currentToken,"Bad number of classes or keys.",error);
  return err;
}

id MSTECreateRootObjectFromBuffer(CBuffer *source, CDictionary *options, CDictionary **error)
{
  id ret= nil;
  NSStringEncoding srcEncoding;
  SES ses,sesCmp,sesRes; int type,stop; NSUInteger i,delta,crc1,crc2; char crc[9]; // *crcend;
  _MSTEDecode src;
  NSUInteger code;
  id o,ref;
  *error= nil;
  memset(&src, 0, sizeof(_MSTEDecode));
  srcEncoding= NSUTF8StringEncoding;

  // -------------------------------------------------------------------- HEADER

  if (!source)                  RETURN_NIL("MSTE-1","No entry to decode.");
  if (CBufferLength(source)<32) RETURN_NIL("MSTE-2","Header badly-formed.");
  src.ses= MSMakeSESWithBytes(MSBPointer(source), MSBLength(source), srcEncoding);
  ///// Les [ et ]
  if (((char*)SESSource(src.ses))[                   0]!='[') RETURN_NIL("MSTE-5","No begin character ([).");
  if (((char*)SESSource(src.ses))[SESLength(src.ses)-1]!=']') RETURN_NIL("MSTE-6","No end character (]).");
  src.ses.start+= 1; src.ses.length-= 2;
  ///// MSTE0101
  src.nbToken= 2;
  ses= _readToken(&src, &type);
  if (type!=STR)                            RETURN_NIL("MSTE-10","Bad first token.");
  sesCmp= MSMakeSESWithBytes("MSTE0101", 8, NSUTF8StringEncoding);
  sesRes= SESCommonPrefix(ses, sesCmp);
  if (SESLength(sesRes)!=SESLength(sesCmp)) RETURN_NIL("MSTE-11","Bad first token.");
  if (_moveToNewToken(&src,ses,1,"MSTE-12","Bad first token.",error)) return nil; // Critical because on the header
  ///// lecture du nombre de tokens
  ses= _readToken(&src, &type);
  if (type!=NOT_STR)                        RETURN_NIL("MSTE-15","Bad number of tokens.");
  _number(ses, MSTE_ULONG_VALUE, &src.nbToken); src.currentToken= 0;
  if (src.nbToken < 5)                      RETURN_NIL("MSTE-16","Bad number of tokens (<5).");
  else src.currentToken++; // 0:MSTE0101 1:nbToken
  if (_moveToNewToken(&src,ses,1,"MSTE-17","Bad number of tokens.",error)) return nil;
  ///// CRC
  ses= _readToken(&src, &type);
  if (type!=STR)                            RETURN_NIL("MSTE-20","Bad CRC.");
  sesCmp= MSMakeSESWithBytes("CRC", 3, NSUTF8StringEncoding);
  sesRes= SESCommonPrefix(ses, sesCmp);
  if (SESLength(sesRes)!=SESLength(sesCmp)) RETURN_NIL("MSTE-21","Bad CRC.");
  // Verif du crc
// TODO: vérifier le calcul du CRC
// http://www.fileformat.info/tool/hash.htm?text=%5B%22MSTE0101%22%2C5%2C%22CRC00000000%22%2C0%2C0%5D
  delta= SESLength(sesRes); ses.start+= delta; ses.length-= delta;
  if (ses.length!=8)                        RETURN_NIL("MSTE-22","Bad CRC.");
  for (i= 0; i < ses.length; i++) {
    crc[i]= ((char*)ses.source)[SESStart(ses)+i];
    ((char*)ses.source)[SESStart(ses)+i]= '0';}
  crc[8]= 0x00; crc1= MSHexaStringToULong(crc, 8); // strtoul(crc, &crcend, 16);
  crc2= MSBytesLargeCRC(src.ses.source, src.ses.length);
if(crc1!=crc2)printf("crc: in:%lu %s real:%lu %s\n",crc1,crc,crc2,MSBPointer(source));
  if (crc1!=crc2)                           RETURN_NIL("MSTE-23","Bad CRC.");
  for (i= 0; i < ses.length; i++) {((char*)ses.source)[SESStart(ses)+i]= crc[i];}
  if (_moveToNewToken(&src,ses,1,"MSTE-24","Bad CRC.",error)) return nil;

  // ------------------------------------------------------------------- CLASSES

  if (_readClassesOrKeys(&src, &(src.nbClass), &(src.classes), error)) return nil;

  // ---------------------------------------------------------------------- KEYS

  if (_readClassesOrKeys(&src, &(src.nbKey), &(src.keys), error)) return nil;

  // -------------------------------------------------------------------- STREAM

  code= NSUIntegerMax; o= nil; ref= nil; stop= 0;
  while (!stop && src.ses.length && src.currentToken < src.nbToken) {
    ses= _readToken(&src, &type);
    if (code==NSUIntegerMax) {
      if (type!=NOT_STR) stop= STOPPING_ERROR("MSTE-50");
      else {
        _number(ses, MSTE_ULONG_VALUE, &code);
        if (code < 26 && (o= RETAIN(_MSTEConstants[code]))) {} // Done !
        }}
    else if (MSTE_CHAR_VALUE<=code && code<=MSTE_DOUBLE_VALUE) {
      NSUInteger v;
      _number(ses, (int)code, &v);
      o= _MSTEBinaryObject(code, &v);}
    else if (code>=MSTE_USER_CLASS) {
      }
    else switch (code) {
      case MSTE_NUMBER: {
        double x;
        _number(ses, MSTE_DOUBLE_VALUE, &x);
        ref= (id)CCreateDecimalWithDouble(x);
        break;}
      case MSTE_STRING: {
        SES s2= ses; s2.chai= utf8JsonStringChaiN;
        ref= (id)CCreateStringWithSES(s2);
        break;}
      case MSTE_DATE: {
        MSTimeInterval v;
        _number(ses, MSTE_LONG_VALUE, &v);
        ref= (id)CCreateDateWithSecondsFrom20010101(v-CDateSecondsFrom19700101To20010101);
        break;}
      case MSTE_COLOR: {
        MSUInt c; MSByte r,g,b,a;
        _number(ses, MSTE_UINT_VALUE, &c);
        b= c&0x000000FF; c>>= 8; g= c&0x000000FF; c>>= 8; r= c&0x000000FF; c>>= 8; a= 255-(MSByte)(c&0x000000FF);
        ref= (id)CCreateColor(r, g, b, a);
        break;}
      case MSTE_DICTIONARY: {
        NSUInteger n;
        _number(ses, MSTE_ULONG_VALUE, &n);
        ref= (id)CCreateDictionary(n);
        for (i= 0; i<n; i++) {
          
          }
        break;}
      case MSTE_REFERENCE: {
        break;}
      case MSTE_ARRAY: {
        break;}
      case MSTE_NATURAL_ARRAY: {
        break;}
      case MSTE_COUPLE: {
        break;}
      case MSTE_BASE64_DATA: {
        break;}
      default: break;} // NOT_STOPPING_ERROR
    
    if (!ret) ret= o?o:ref;
    if (o) {
      o= nil; code= NSUIntegerMax;}
    else if (ref) {
      ref= nil; code= NSUIntegerMax;}
    _moveToNewToken(&src,ses,3,"MSTE-70","Stream.",error);
    }

  // ----------------------------------------------------------------------- END

  RELEAZEN(src.classes);
  RELEAZEN(src.keys);
  RELEAZEN(src.refs);
  return ret;
  options= nil; // Unused parameter
}
