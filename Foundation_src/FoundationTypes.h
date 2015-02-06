#import <objc/objc.h>

#ifdef FOUNDATION_PRIVATE_H
#define FoundationExtern LIBEXPORT
#else
#define FoundationExtern LIBIMPORT
#endif

#define NS_INLINE static inline

#ifdef __clang__
    #define NS_ROOT_CLASS __attribute__((objc_root_class))
#else
    #define NS_ROOT_CLASS
#endif

#if !defined(NS_REQUIRES_NIL_TERMINATION)
  // Both recent version of GCC & Clang support the sentinel compilation check
  #define NS_REQUIRES_NIL_TERMINATION __attribute__((sentinel))
#endif

#if !defined(NS_FORMAT_FUNCTION)
  // Both recent version of GCC & Clang support the NSString formatting compilation check
  #define NS_FORMAT_FUNCTION(F,A) __attribute__((format(__NSString__, F, A)))
#endif

/*#if !defined(NS_FORMAT_ARGUMENT)
  // Both recent version of GCC & Clang support the va_arg formatting compilation check
  #define NS_FORMAT_ARGUMENT(A) __attribute__ ((format_arg(A)))
#endif*/

#if !__has_feature(objc_instancetype)
#undef instancetype
#define instancetype id
#endif

#define NS_ENUM(_type, _name) _type _name; enum
#define NS_OPTIONS(_type, _name) _type _name; enum

#define NS_DURING @try {
#define NS_HANDLER } @catch(NSException *localException) {
#define NS_ENDHANDLER }
#define NS_VALUERETURN(val,type) { return val; }
#define NS_VOIDRETURN { return; }
