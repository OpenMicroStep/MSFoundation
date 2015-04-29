// MSCMessage.c

#include "MSCore_Private.h"

#pragma mark initialize

CString* KDate;
CString* KType;
CString* KFile;
CString* KLine;
CString* KFunction;
CString* KMethod;
CString* KTags;
CString* KMessage;

BOOL     CMessageDebugOn= NO;
CString* CMessageDebug;       // CBehaviorReportToConsole
CString* CMessageAnalyse;     // CBehaviorReportToFile
CString* CMessageFatalError;  // CBehaviorReportToFile CBehaviorReportToUser CBehaviorFatal
CString* CMessageWarning;     // CBehaviorReportToFile CBehaviorReportToUser
CString* CMessageInformation; //                       CBehaviorReportToUser
CString* _CMessageDefault;    // CBehaviorReportToFile CBehaviorReportToUser

CDictionary *_Behaviors4MessageType;

CString* KAssert;
CString* CMessageAssert;      // CBehaviorAssert
void CBehaviorAssert(CDictionary* context, CString* message);

#pragma mark CTX

static inline const char *_basename(const char *path)
{
  const char* basename;
  basename= strrchr(path, '/');
  return basename ? basename + 1 : path;
}
mutable CDictionary* CCreateCtxv(const char *file, int line, const char *fct, const char *mtd, va_list vp)
  {
  CDictionary* ctx= CCreateDictionary(0);
  id o;
  o= (id)CSCreate((char*)_basename(file));
  CDictionarySetObjectForKey(ctx, o, (id)KFile);
  RELEASE(o);
  o= (id)CCreateString(0); CStringAppendFormat((CString*)o, "%d", line);
  CDictionarySetObjectForKey(ctx, o, (id)KLine);
  RELEASE(o);
  if (fct) {
    o= (id)CSCreate((char*)fct);
    CDictionarySetObjectForKey(ctx, o, (id)KFunction);
    RELEASE(o);}
  if (mtd) {
    o= (id)CSCreate((char*)mtd);
    CDictionarySetObjectForKey(ctx, o, (id)KMethod);
    RELEASE(o);}
  if ((o= va_arg(vp, id))) {
    if (!ISARRAY(o)) {
      CArray *a= CCreateArray(0);
      CArrayAddObject(a,o);
      while ((o= va_arg(vp, id))) CArrayAddObject(a,o);
      o= (id)a;}
    else RETAIN(o);
    CDictionarySetObjectForKey(ctx, o, (id)KTags);
    RELEASE(o);}
//printf("CCreateCtx %s %d\n\n",file,line);
  return ctx;
  }

mutable CDictionary* CCreateCtx(const char *file, int line, const char *fct, const char *mtd, ...)
  {
  CDictionary* ctx;
  va_list vp;
  va_start(vp, mtd);
  ctx= CCreateCtxv(file, line, fct, mtd, vp);
  va_end(vp);
  return ctx;
  }

#pragma mark CBehaviorFatal

void CBehaviorFatal(CDictionary* context, CString* message)
  {
  exit(EXIT_FAILURE);
  }

#pragma mark CBehaviorReportToFile

static CString* _CBehaviorReportFilePath= NULL;
CString* CBehaviorReportFilePath()
  {
  if (!_CBehaviorReportFilePath) {
    // TODO: Something like : /opt/microstep/platform+env/log/programName
    // Et aussi vérifier/créer les répertoires jusqu'à log
    _CBehaviorReportFilePath= CSCreate("/opt/microstep/log/programName.log");
    }
  return _CBehaviorReportFilePath;
  }
void CBehaviorSetReportFilePath(CString* path)
  {
  id *x= (id*)&_CBehaviorReportFilePath;
  ASSIGN(*x, path);
  }

// file:line[:function][:method]
void CStringAppendContextWhere(CString* str, CDictionary* ctx)
  {
  CString *x;
  CStringAppendString(str, (CString*)CDictionaryObjectForKey(ctx,(id)KFile));
  if ((x= (CString*)CDictionaryObjectForKey(ctx,(id)KFunction))) {
    CStringAppendCharacter(str, ':'); CStringAppendString(str, x);}
  if ((x= (CString*)CDictionaryObjectForKey(ctx,(id)KMethod))) {
    CStringAppendCharacter(str, ':'); CStringAppendString(str, x);}
  CStringAppendCharacter(str, ':');
  CStringAppendString(str, (CString*)CDictionaryObjectForKey(ctx,(id)KLine));
  }
// date messageType file:line[:function][:method]
//   message
static CBuffer* _CreateUtf8Message(CDictionary* context, CString* message)
  {
  CBuffer *b,*ba; id o; CArray *a; NSUInteger n;
  CString *m;
  m= CCreateString(0);
  CStringAppendCDateDescription(m,(CDate*)CDictionaryObjectForKey(context,(id)KDate));
  CStringAppendCharacter(m, ' ');
  CStringAppendString(m, (CString*)CDictionaryObjectForKey(context,(id)KType));
  CStringAppendCharacter(m, ' ');
  CStringAppendContextWhere(m, context);
  CStringAppendFormat(m, "\n    ");
  if ((a= (CArray*)CDictionaryObjectForKey(context, (id)KTags)) && (n= CArrayCount(a))) {
    CStringAppendFormat(m, "tags(%llu):",n);
    ba= CCreateUTF8BufferWithObjectDescription((id)a);
    CStringAppendFormat(m, " %s", CBufferCString(ba));
    RELEASE(ba);
    CStringAppendFormat(m, "\n    ");}
  if ((o= CDictionaryObjectForKey(context, (id)KAssert))) {
    CStringAppendFormat(m, "testing: ");
    CStringAppendString(m, (const CString*)o);
    CStringAppendFormat(m, "\n    ");}
  CStringAppendString(m, message);
  b= CCreateBufferWithString(m, NSUTF8StringEncoding);
  CBufferAppendByte(b, '\n');
  RELEASE(m);
  return b;
  }

void CBehaviorReportToFile(CDictionary* context, CString* message)
  {
  CBuffer *p= CCreateBufferWithString(CBehaviorReportFilePath(), NSUTF8StringEncoding);
  CBuffer *m= _CreateUtf8Message(context, message);
  FILE *f= fopen((const char *)CBufferCString(p), "ab");
  if (f) {
    fwrite(CBufferBytes(m), 1, CBufferLength(m), f);
    fclose (f);}
  RELEASE(m);
  RELEASE(p);
  }

#pragma mark CBehaviorReportToConsole

void CBehaviorReportToConsole(CDictionary* context, CString* message)
  {
  CBuffer *m= _CreateUtf8Message(context, message);
  fprintf(stderr, "%s", CBufferCString(m));
  fflush(stderr);
  RELEASE(m);
  }

#pragma mark CBehaviorReportToUser

CBehaviorCallback _CBehaviorReportToUserCallback= CBehaviorReportToConsole;
void CBehaviorSetReportToUserCallback(CBehaviorCallback callback)
  {
  _CBehaviorReportToUserCallback= callback;
  }

void CBehaviorReportToUser(CDictionary* context, CString* message)
  {
  if (_CBehaviorReportToUserCallback) _CBehaviorReportToUserCallback(context,message);
  }

#pragma mark CBehavior and message types

void CMessageAddBehaviorForType(CBehaviorCallback behavior, CString* messageType)
  {
  CArray *bs= (CArray*)CDictionaryObjectForKey(_Behaviors4MessageType, (id)messageType);
  if (!bs) {
    bs= CCreateArrayWithOptions(1, YES, NO);
    CDictionarySetObjectForKey(_Behaviors4MessageType, (id)bs, (id)messageType);}
  CArrayAddObject(bs, (id)behavior);
  }
void CMessageRemoveBehaviorForType(CBehaviorCallback behavior, CString* messageType)
  {
  CArray *bs= (CArray*)CDictionaryObjectForKey(_Behaviors4MessageType, (id)messageType);
  if (bs) CArrayRemoveIdenticalObject(bs, (id)behavior);
  }

void _CMessageInitialize(void); // used in MSFinishLoadingCore
void _CMessageInitialize()
{
  KDate=     CSCreate("date");
  KType=     CSCreate("type");
  KFile=     CSCreate("file");
  KLine=     CSCreate("line");
  KFunction= CSCreate("function");
  KMethod=   CSCreate("method");
  KMessage=  CSCreate("message");
  KTags=     CSCreate("tags");
  KAssert=   CSCreate("assert");
  CMessageDebug=       CSCreate("CMessageDebug");
  CMessageAnalyse=     CSCreate("CMessageAnalyse");
  CMessageFatalError=  CSCreate("CMessageFatalError");
  CMessageWarning=     CSCreate("CMessageWarning");
  CMessageInformation= CSCreate("CMessageInformation");
  _CMessageDefault=    CSCreate("CMessageDefault");
  _Behaviors4MessageType= CCreateDictionary(4);
  CMessageAddBehaviorForType(CBehaviorReportToConsole, CMessageDebug);
  CMessageAddBehaviorForType(CBehaviorReportToFile   , CMessageAnalyse);
  CMessageAddBehaviorForType(CBehaviorReportToFile   , CMessageFatalError);
  CMessageAddBehaviorForType(CBehaviorReportToUser   , CMessageFatalError);
  CMessageAddBehaviorForType(CBehaviorFatal          , CMessageFatalError);
  CMessageAddBehaviorForType(CBehaviorReportToFile   , CMessageWarning);
  CMessageAddBehaviorForType(CBehaviorReportToUser   , CMessageWarning);
  CMessageAddBehaviorForType(CBehaviorReportToUser   , CMessageInformation);
  CMessageAddBehaviorForType(CBehaviorReportToFile   , _CMessageDefault);
  CMessageAddBehaviorForType(CBehaviorReportToUser   , _CMessageDefault);

  CMessageAssert= CSCreate("CMessageAssert");
  CMessageAddBehaviorForType(CBehaviorAssert      , CMessageAssert);
  CMessageAddBehaviorForType(CBehaviorReportToFile, CMessageAssert);
}

CArray* CMessageBehaviorsForType(CString* messageType)
  {
  return (CArray*)CDictionaryObjectForKey(_Behaviors4MessageType, (id)messageType);
  }

#pragma mark CMessage action !

void CMessageAdvisev(CString* messageType, mutable CDictionary* ctx, const char *msgFmt, va_list vp)
  {
  CDate *now; CArray *bs; NSUInteger i,n;
  CString *msg= CCreateString(0);
  CStringAppendFormatv(msg, msgFmt, vp);
  now= CCreateDateNow();
  CDictionarySetObjectForKey(ctx, (id)now, (id)KDate);
  RELEASE(now);
  CDictionarySetObjectForKey(ctx, (id)messageType, (id)KType);
  bs= CMessageBehaviorsForType(messageType);
  if (!bs) bs= CMessageBehaviorsForType(_CMessageDefault);
  for (n= CArrayCount(bs), i= 0; i<n; i++) {
    CBehaviorCallback b= (CBehaviorCallback)CArrayObjectAtIndex(bs, i);
    if (b) b(ctx,msg);}
  RELEASE(ctx);
  }

void CMessageAdvise(CString* messageType, mutable CDictionary* ctx, const char *msgFmt, ...)
  {
  va_list vp;
  va_start(vp, msgFmt);
  CMessageAdvisev(messageType, ctx, msgFmt, vp);
  va_end(vp);
  }

#pragma mark ASSERT

void CBehaviorAssert(CDictionary* ctx, CString* msg)
  {
  CDictionarySetObjectForKey(ctx, (id)msg, (id)KMessage);
  }

mutable CDictionary* ACreateCtx(const char *file, int line, const char *fct, const char *mtd, const char *assert, ...)
  {
  CDictionary* ctx;
  va_list vp;
  va_start(vp, assert);
  ctx= CCreateCtxv(file, line, fct, mtd, vp);
  if (assert) {
    CString *a=  CSCreate((char*)assert);
    CDictionarySetObjectForKey(ctx, (id)a, (id)KAssert);
    RELEASE(a);}
  va_end(vp);
  return ctx;
  }
