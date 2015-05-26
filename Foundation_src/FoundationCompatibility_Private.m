#import "FoundationCompatibility_Private.h"

void FoundationCompatibilityExtendClass(char type, Class dstClass, SEL dstSel, Class srcClass, SEL srcSel)
{
  Method srcMethod, dstMethod; const char *error= NULL;
  if(type == '+') {
    dstClass= object_getClass(dstClass);
    srcClass= object_getClass(srcClass);
  }
  if(!dstSel) dstSel= srcSel;
  if(!srcSel) srcSel= dstSel;
  srcMethod= class_getInstanceMethod(srcClass, srcSel);
  dstMethod= class_getInstanceMethod(dstClass, dstSel);
  if(!srcMethod) {
    error= "src method not found"; }
  else if(srcMethod != dstMethod) {
    if(dstMethod && strcmp(method_getTypeEncoding(srcMethod), method_getTypeEncoding(dstMethod)) != 0) {
      error= "type encoding missmatchs";}
    else {
      class_addMethod(dstClass, dstSel, method_getImplementation(srcMethod), method_getTypeEncoding(srcMethod)); }}
  if(error) {
    fprintf(stderr, "Unable to add %c[%s %s] from %c[%s %s], %s\n",
            type,
            class_getName(dstClass), sel_getName(dstSel),
            type,
            class_getName(srcClass), sel_getName(srcSel),
            error); }
}

static void _mapMethod(Method srcMethod, const char* srcPrefix, size_t srcPrefixLen, Class dstClass, const char *dstPrefix, size_t dstPrefixLen, BOOL keepOthers)
{
  SEL dstSel= 0;
  const char *srcMethodName; size_t srcMethodLen;
  srcMethodName= sel_getName(method_getName(srcMethod));
  srcMethodLen= strlen(srcMethodName);
  if(srcMethodLen >= srcPrefixLen && strncmp(srcMethodName, srcPrefix, srcPrefixLen) == 0) {
    char dstMethodName[dstPrefixLen + srcMethodLen - srcPrefixLen];
    strncpy(dstMethodName, dstPrefix, dstPrefixLen);
    strncpy(dstMethodName, srcMethodName + srcPrefixLen, srcMethodLen - srcPrefixLen);
    dstSel= sel_registerName(dstMethodName); }
  else if(keepOthers && strncmp(srcMethodName, dstPrefix, dstPrefixLen) != 0) {
    dstSel= method_getName(srcMethod); }
  if(dstSel && !class_getInstanceMethod(dstClass, dstSel)) {
      class_addMethod(dstClass, dstSel, method_getImplementation(srcMethod), method_getTypeEncoding(srcMethod));}
}

void FoundationCompatibilityMapMutableClassMethods(Class dstClass, Class srcClass, const char *prefix, const char *mutablePrefix)
{
  Class dstMetaClass, srcMetaClass;
  Method *methods; uint32_t count; size_t prefixLen, mutablePrefixLen;
  
  prefixLen= strlen(prefix);
  mutablePrefixLen= strlen(mutablePrefix);
  dstMetaClass= object_getClass(dstClass);
  srcMetaClass= object_getClass(srcClass);
  
  // Copy +[srcClass mutablePrefix...] to +[dstClass prefix...]
  methods= class_copyMethodList(srcMetaClass, &count);
  while (count > 0) {
    _mapMethod(methods[--count], mutablePrefix, mutablePrefixLen, dstMetaClass, prefix, prefixLen, NO);
  }
  free(methods);
}

void FoundationCompatibilityMapMutableInstanceMethods(Class dstClass, Class srcClass)
{
  static const char mutableInit[]= "mutableInit";
  static const size_t mutableInitLen= sizeof(mutableInit);
  static const char init[]= "init";
  static const size_t initLen= sizeof(init);
  Method *methods; uint32_t count;
  
  // Copy -[srcClass mutableInit...] to -[dstClass init...]
  //      -[srcClass ...] to -[dstClass ...]
  methods= class_copyMethodList(srcClass, &count);
  while (count > 0) {
    _mapMethod(methods[--count], mutableInit, mutableInitLen, dstClass, init, initLen, YES);
  }
  free(methods);
}
