#import "FoundationCompatibility_Private.h"

#define CSCAST(X) ((_NSConstantString*)(X))
#define CSSES(X)  MSMakeSESWithBytes(CSCAST(X)->bytes, CSCAST(X)->length, NSUTF8StringEncoding)
typedef struct {
  Class isa;
  const char *bytes;
  int length;
} _NSConstantString;

@implementation NSConstantString

static inline unichar characterAtRelativeIndex(SES ses, NSUInteger *sIdx, NSUInteger relativeIndex)
{
  unichar c= 0;
  ++relativeIndex;
  while(relativeIndex > 0 && *sIdx < SESEnd(ses)) {
    c= SESIndexN(ses, sIdx);
    --relativeIndex;
  }
  return c;
}

- (NSUInteger)length
{
  SES ses= CSSES(self); NSUInteger i=SESStart(ses), len=0;
  while(i < SESEnd(ses)) {
    SESIndexN(ses, &i);
    ++len;
  }
  return len;
}

- (unichar)characterAtIndex:(NSUInteger)index
{
  SES ses= CSSES(self); NSUInteger i=SESStart(ses);
  return characterAtRelativeIndex(ses, &i, index);
}

- (void)getCharacters:(unichar*)buffer range:(NSRange)rg
{
  SES ses= CSSES(self); NSUInteger i=SESStart(ses);
  if (rg.length > 0) {
    *buffer++= characterAtRelativeIndex(ses, &i, rg.location);
    rg.length--;
    while (rg.length > 0 && i < SESEnd(ses)) {
      *buffer++= SESIndexN(ses, &i);
      rg.length--;}}
}

- (const char*)UTF8String
{
  return CSCAST(self)->bytes;
}

- (BOOL)isEqual:(id)object
  {
  if (object == (id)self) return YES;
  if (!object) return NO;
  if ([object isKindOfClass:[NSString class]]) {
    return SESEquals(SESFromString(self), SESFromString(object)); }
  return NO;
  }

- (SES)stringEnumeratorStructure
{
  return CSSES(self);
}

- (id)copyWithZone:(NSZone*)z
{
  return self;
}

- (void)describeIn:(id)result level:(int)level context:(MSDictionary*)ctx
{
  CStringAppendSES((CString*)result, CSSES(self));
}

- (instancetype)retain     { return self; }
- (oneway void)release     { }
- (instancetype)autorelease{ return self; }
- (NSUInteger)retainCount  { return 1; }

@end
