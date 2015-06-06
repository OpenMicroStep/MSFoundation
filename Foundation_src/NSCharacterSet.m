#import "FoundationCompatibility_Private.h"

static NSCharacterSet *__controlCharacterSet = nil;
static NSCharacterSet *__whitespaceCharacterSet = nil;
static NSCharacterSet *__whitespaceAndNewlineCharacterSet = nil;
static NSCharacterSet *__decimalDigitCharacterSet = nil;
static NSCharacterSet *__letterCharacterSet = nil;
static NSCharacterSet *__lowercaseLetterCharacterSet = nil;
static NSCharacterSet *__uppercaseLetterCharacterSet = nil;
static NSCharacterSet *__nonBaseCharacterSet = nil;
static NSCharacterSet *__alphanumericCharacterSet = nil;
static NSCharacterSet *__decomposableCharacterSet = nil;
static NSCharacterSet *__illegalCharacterSet = nil;
static NSCharacterSet *__punctuationCharacterSet = nil;
static NSCharacterSet *__capitalizedLetterCharacterSet = nil;
static NSCharacterSet *__symbolCharacterSet = nil;

static BOOL _unicharIsWhitespace(unichar ch)
{
  return ch == 0x0020 || ch == 0x0009;
}
static BOOL _todo(unichar ch)
{
  return NO;
}

@interface NSCharacterSetUnicharChecker : NSCharacterSet {
  BOOL (*_isMember)(unichar c);
  BOOL _inverted;
}
- (instancetype)initWithChecker:(BOOL (*)(unichar c))isMember inverted:(BOOL)inverted;
@end

@interface _NSCharacterSetBitmap: NSCharacterSet {
@public // private to this file
  MSByte _bitmap[8192];
}
@end

@interface _NSCharacterSetData: NSCharacterSet {
@public // private to this file
  NSData *_data;
}
@end

@implementation NSCharacterSet

+ (void)initialize {
  if([self class] == [NSCharacterSet class]) {
    __controlCharacterSet              =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:CUnicharIsControl inverted:NO];
    __whitespaceCharacterSet           =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:_unicharIsWhitespace inverted:NO];
    __whitespaceAndNewlineCharacterSet =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:CUnicharIsSpaceOrEOL inverted:NO];
    __decimalDigitCharacterSet         =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:CUnicharIsDigit inverted:NO];
    __letterCharacterSet               =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:CUnicharIsLetter inverted:NO];
    __lowercaseLetterCharacterSet      =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:CUnicharIsLower inverted:NO];
    __uppercaseLetterCharacterSet      =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:CUnicharIsUpper inverted:NO];
    __nonBaseCharacterSet              =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:_todo inverted:NO];
    __alphanumericCharacterSet         =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:CUnicharIsAlnum inverted:NO];
    __decomposableCharacterSet         =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:_todo inverted:NO];
    __illegalCharacterSet              =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:CUnicharIsPrintable inverted:YES];
    __punctuationCharacterSet          =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:CUnicharIsPunct inverted:NO];
    __capitalizedLetterCharacterSet    =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:_todo inverted:NO];
    __symbolCharacterSet               =[ALLOC(NSCharacterSetUnicharChecker) initWithChecker:_todo inverted:NO];
  }
}
+ (NSCharacterSet *)controlCharacterSet
{ return __controlCharacterSet; }
+ (NSCharacterSet *)whitespaceCharacterSet
{ return __whitespaceCharacterSet; }
+ (NSCharacterSet *)whitespaceAndNewlineCharacterSet
{ return __whitespaceAndNewlineCharacterSet; }
+ (NSCharacterSet *)decimalDigitCharacterSet
{ return __decimalDigitCharacterSet; }
+ (NSCharacterSet *)letterCharacterSet
{ return __letterCharacterSet; }
+ (NSCharacterSet *)lowercaseLetterCharacterSet
{ return __lowercaseLetterCharacterSet; }
+ (NSCharacterSet *)uppercaseLetterCharacterSet
{ return __uppercaseLetterCharacterSet; }
+ (NSCharacterSet *)nonBaseCharacterSet
{ return __nonBaseCharacterSet; }
+ (NSCharacterSet *)alphanumericCharacterSet
{ return __alphanumericCharacterSet; }
+ (NSCharacterSet *)decomposableCharacterSet
{ return __decomposableCharacterSet; }
+ (NSCharacterSet *)illegalCharacterSet
{ return __illegalCharacterSet; }
+ (NSCharacterSet *)punctuationCharacterSet
{ return __punctuationCharacterSet; }
+ (NSCharacterSet *)capitalizedLetterCharacterSet
{ return __capitalizedLetterCharacterSet; }
+ (NSCharacterSet *)symbolCharacterSet
{ return __symbolCharacterSet; }

+ (NSCharacterSet *)characterSetWithCharactersInString:(NSString *)aString
{
  _NSCharacterSetBitmap *cs= [_NSCharacterSetBitmap new];
  SES ses= SESFromString(aString);
  if(SESOK(ses)) {
    NSUInteger i, e; unichar u;
    for(i= SESStart(ses), e= SESEnd(ses); i < e;) {
      u= SESIndexN(ses, &i);
      cs->_bitmap[u >> 3] |= (1 << (u & 7));
    }
  }
  return AUTORELEASE(cs);
}

- (id)copyWithZone:(NSZone *)zone
{ return [self retain]; }
@end

@implementation NSCharacterSetUnicharChecker 

- (instancetype)initWithChecker:(BOOL (*)(unichar c))isMember inverted:(BOOL)inverted
{
  if((self= [self init])) {
    _isMember= isMember;
    _inverted= inverted;
  }
  return self;
}
- (BOOL)characterIsMember:(unichar)aCharacter
{
  return _inverted ^ _isMember(aCharacter);
}

- (NSCharacterSet *)invertedSet
{
  return AUTORELEASE([ALLOC(NSCharacterSetUnicharChecker) initWithChecker:_isMember inverted:!_inverted]);
}

@end

@implementation _NSCharacterSetData
- (BOOL)characterIsMember:(unichar)u
{
  MSByte b;
  [_data getBytes:&b range:NSMakeRange(u >> 3, 1)];
  return (b & (1 << ((MSByte)u & 7))) > 0;
}
- (NSData *)bitmapRepresentation
{ return _data; }
@end

@implementation _NSCharacterSetBitmap
- (BOOL)characterIsMember:(unichar)u
{
  return (_bitmap[u >> 3] & (1 << ((MSByte)u & 7))) > 0;
}
- (NSData *)bitmapRepresentation
{ return AUTORELEASE(CCreateBufferWithBytesNoCopyNoFree(_bitmap, 8192)); }
@end
