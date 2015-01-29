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
    #if TARGET_OS_WIN32
        #define NS_REQUIRES_NIL_TERMINATION
    #else
        #if defined(__APPLE_CC__) && (__APPLE_CC__ >= 5549)
            #define NS_REQUIRES_NIL_TERMINATION __attribute__((sentinel(0,1)))
        #else
            #define NS_REQUIRES_NIL_TERMINATION __attribute__((sentinel))
        #endif
    #endif
#endif

#define NS_ENUM(_type, _name) _type _name; enum
#define NS_OPTIONS(_type, _name) _type _name; enum

#define NS_DURING @try {
#define NS_HANDLER } @catch(NSException *localException) {
#define NS_ENDHANDLER }
#define NS_VALUERETURN(val,type) { return val; }
#define NS_VOIDRETURN { return; }
