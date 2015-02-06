#import "FoundationCompatibility_Private.h"

#define csself ((_NSConstantString*)self)
#define csses MSMakeSESWithBytes(csself->bytes, csself->length, NSUTF8StringEncoding)
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
  while(relativeIndex > 0 && *sIdx < SESLength(ses)) {
    c= SESIndexN(ses, sIdx);
    --relativeIndex;
  }
  return c;
}

- (NSUInteger)length
{
  NSUInteger i=0, len=0; SES ses= csses;
  while(i < SESLength(ses)) {
    SESIndexN(ses, &i);
    ++len;
  }
  return len;
}

- (unichar)characterAtIndex:(NSUInteger)index
{
  NSUInteger i=0; SES ses= csses;
  return characterAtRelativeIndex(ses, &i, index);
}

- (void)getCharacters:(unichar*)buffer range:(NSRange)rg
{
  NSUInteger i=0; SES ses= csses;
  if (rg.length > 0) {
    *buffer++= characterAtRelativeIndex(ses, &i, rg.location);
    rg.length--;
    while (rg.length > 0 && i < SESLength(ses)) {
      *buffer++= SESIndexN(ses, &i);
      rg.length--;}}
}

- (const char*)UTF8String
{
  return csself->bytes;
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
  return MSMakeSESWithBytes(csself->bytes, csself->length, NSUTF8StringEncoding);
}

- (id)copyWithZone:(NSZone*)z
{
  return self;
}

- (instancetype)retain     { return self; }
- (oneway void)release     { }
- (instancetype)autorelease{ return self; }
- (NSUInteger)retainCount  { return 1; }

@end
