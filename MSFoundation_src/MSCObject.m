/* MSCObject.m

 This file is is a part of the MicroStep Framework.

 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
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

 WARNING : the CObject mechanism is NOT Thread Safe. Each object
 must be allocated, retained, autoreleased, released in the same thread.

 */

#import "MSFoundation_Private.h"

#pragma mark NSObject hash:

@interface NSObject (Private)
- (NSUInteger)hash:(unsigned)depth;
- (MSArray*)retainedSubs:(MSDictionary*)ctx;
- (void)describeIn:(id)result level:(int)level context:(MSDictionary*)ctx;
@end

void MSFinishLoadingCore();
static void MSFinishLoadingFoundation() {
  MSFinishLoadingCore();
  _MSColorInitialize();
}

@implementation NSObject (Private)

+ (void)load {MSFinishLoadingConfigure(8, MSFinishLoadingFoundation);}

- (NSUInteger)hash:(unsigned)depth {return [self hash]; MSUnused(depth);}

- (MSArray*)retainedSubs:(MSDictionary*)ctx {return nil; MSUnused(ctx);}
- (void)describeIn:(id)result level:(int)level context:(MSDictionary*)ctx
{
  CStringAppendSES((CString*)result, SESFromString([self description]));
  MSUnused(level); MSUnused(ctx);
}
@end

#pragma mark MSCore compatibility

Class _MIsa(id obj)
{
  return ISA(obj);
}

const char *_MNameOfClass(id obj)
{
  return NAMEOFCLASS(obj);
}

id _MRetain(id obj)
{
  return [obj retain];
}

void _MRelease(id obj)
{
  [obj release];
}

id _MAutorelease(id obj)
{
  return [obj autorelease];
}

NSUInteger _MRetainCount(id obj)
{
  return [obj retainCount];
}

BOOL _MObjectIsEqual(id obj1, id obj2)
{
  BOOL ok= (obj1 == obj2) || [obj1 isEqual:obj2];
  return ok;
}

NSUInteger _MObjectHashDepth(id obj, unsigned depth)
{
  return [obj hash:depth];
}

NSUInteger _MObjectHash(id obj)
{
  return [obj hash:0];
}

id _MObjectCopy(id obj)
{
  return [obj copyWithZone:NULL];
}

CArray *_MObjectSubs(id obj, mutable CDictionary *ctx)
{
  return (CArray*)[obj retainedSubs:(MSDictionary*)ctx];
}

void _MObjectDescribe(id obj, id result, int level, mutable CDictionary *ctx)
{
  [obj describeIn:result level:level context:(MSDictionary*)ctx];
}

const CString* _MObjectRetainedDescription(id obj)
{
  id d= [obj description];
  if(!d || [d isKindOfClass:[MSString class]]) return (const CString*)[d retain];
  return CCreateStringWithSES(SESFromString(d));
}

BOOL _MIsArray(id obj)
{
  return [obj isKindOfClass:[NSArray class]];
}

int _MSEnv()
{
#ifdef MSFOUNDATION_FORCOCOA
  return 1;
#else
  return 2;
#endif
}

static Class        __Class4ClassIndex[CClassIndexMax+1]= {0};
static CDictionary *__ElementSize4Class= NULL;

void _CObjectInitialize(void); // used in MSFinishLoadingCore
void _CObjectInitialize()
{
  __Class4ClassIndex[CArrayClassIndex     ]= NSClassFromString(@"MSArray");
  __Class4ClassIndex[CBufferClassIndex    ]= NSClassFromString(@"MSBuffer");
  __Class4ClassIndex[CColorClassIndex     ]= NSClassFromString(@"_MSRGBAColor");
  __Class4ClassIndex[CCoupleClassIndex    ]= NSClassFromString(@"MSCouple");
  __Class4ClassIndex[CDateClassIndex      ]= NSClassFromString(@"MSDate");
  __Class4ClassIndex[CDecimalClassIndex   ]= NSClassFromString(@"MSDecimal");
  __Class4ClassIndex[CDictionaryClassIndex]= NSClassFromString(@"MSDictionary");
  __Class4ClassIndex[CStringClassIndex    ]= NSClassFromString(@"MSString");
  __ElementSize4Class= CCreateDictionaryWithOptions(5, CDictionaryPointer, CDictionaryNatural);
}

id MSCreateObjectWithClassIndex(CClassIndex classIndex)
{
  Class aClass= __Class4ClassIndex[classIndex];
  id obj= nil;
  if (!aClass) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSNULLPointerError,
                  "%s(): try to allocate object with classIndex %lu.",
                  "MSCreateObjectWithClassIndex",(unsigned long)classIndex);}
//else {obj= [MSAllocateObject(aClass, 0, NULL) coreInit];}
  else {obj= MSAllocateObject(aClass, 0, NULL);}
  return obj;
}

#define _esz(X)       (((CGrow*)(X))->flags.elementBytes)
#define _setEsz(X,SZ)  ((CGrow*)(X))->flags.elementBytes= (MSUInt)(SZ)

@implementation MSArray (CGrowElementSize)
- (NSUInteger)_growElementSize  { return sizeof(id); }
@end
@implementation MSBuffer (CGrowElementSize)
- (NSUInteger)_growElementSize  { return sizeof(MSByte); }
@end
@implementation MSDictionary (CGrowElementSize)
- (NSUInteger)_growElementSize  { return sizeof(void*); }
@end
@implementation MSString (CGrowElementSize)
- (NSUInteger)_growElementSize  { return sizeof(unichar); }
@end
@implementation MSASCIIString (CGrowElementSize)
- (NSUInteger)_growElementSize  { return sizeof(char); }
@end

NSUInteger CGrowElementSize(id self)
{
  NSUInteger r= 0;
  if ((r= _esz(self))==0) {
    Class c= ISA(self);
    if ((r= (NSUInteger)CDictionaryObjectForKey(__ElementSize4Class, c))==0 || r==NSNotFound) {
      r= [self _growElementSize];
      if (r > 63) MSRaise(@"CGrowElementSize", @"size too big %ld", r);
      CDictionarySetObjectForKey(__ElementSize4Class, (id)r, (id)c);}
    _setEsz(self,r);}
  return r;
}

#define MSIMPLEMENTATION_FOR_NSMUTABLE_PROBLEM(MSCLASS, NSMUTABLECLASS)                             \
@implementation MSCLASS (MSMUTABLECLASS)                                                            \
- (BOOL)isKindOfClass:(Class)aClass                                                                 \
{                                                                                                   \
  return [super isKindOfClass:aClass]                                                                \
      || (!CGrowIsForeverImmutable(self) && aClass == [NSMUTABLECLASS class]);                         \
}                                                                                                   \
- (void)forwardInvocation:(NSInvocation *)anInvocation                                              \
{                                                                                                   \
  _MSForwardInvocationToNSMutable(self, anInvocation, [NSMUTABLECLASS class], [MSCLASS class]);     \
}                                                                                                   \
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector                                    \
{                                                                                                   \
  NSMethodSignature *ret;                                                                           \
  ret= [super methodSignatureForSelector:aSelector];                                                \
  if (!ret) ret= _NSMethodSignatureForSelector([NSMUTABLECLASS class], aSelector);                  \
  return ret;                                                                                       \
}                                                                                                   \
@end

static void _MSForwardInvocationToNSMutable(id self, NSInvocation *inv, Class mutableCls, Class selfCls)
{
  Method method= NULL; SEL sel;
  sel= [inv selector];
  if (!CGrowIsForeverImmutable(self) && (method= class_getInstanceMethod(mutableCls, sel))) {
    class_addMethod(selfCls, sel, method_getImplementation(method), method_getTypeEncoding(method));
    [inv invoke];
  }
  else {
    [self doesNotRecognizeSelector:sel];
  }
}

NSMethodSignature *_NSMethodSignatureForSelector(Class cls, SEL sel)
{
   Method method; const char *types;

   method= class_getInstanceMethod(cls, sel);
   types= method_getTypeEncoding(method);

   return types ? [NSMethodSignature signatureWithObjCTypes:types] : nil;
}

MSIMPLEMENTATION_FOR_NSMUTABLE_PROBLEM(MSArray     , NSMutableArray     );
MSIMPLEMENTATION_FOR_NSMUTABLE_PROBLEM(MSString    , NSMutableString    );
MSIMPLEMENTATION_FOR_NSMUTABLE_PROBLEM(MSDictionary, NSMutableDictionary);
MSIMPLEMENTATION_FOR_NSMUTABLE_PROBLEM(MSBuffer    , NSMutableData      );
