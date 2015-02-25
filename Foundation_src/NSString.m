#import "FoundationCompatibility_Private.h"

@interface _MSMString : MSString
// Mutable version of MSString with some changes to follow NSMutableString specs
@end

@implementation NSString
+ (void)load {MSFinishLoadingAddClass(self);}
+ (void)finishLoading {
  if (self==[NSString class]) {
    FoundationCompatibilityExtendClass('+', self, 0, [MSString class], @selector(string));
    FoundationCompatibilityExtendClass('+', self, 0, [MSString class], @selector(stringWithString:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSString class], @selector(stringWithCharacters:length:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSString class], @selector(stringWithUTF8String:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSString class], @selector(stringWithFormat:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSString class], @selector(localizedStringWithFormat:));
    FoundationCompatibilityExtendClass('+', self, 0, [MSString class], @selector(stringWithCString:encoding:));

    FoundationCompatibilityExtendClass('-', self, 0, [MSString class], @selector(lowercaseString));
    FoundationCompatibilityExtendClass('-', self, 0, [MSString class], @selector(uppercaseString));
    FoundationCompatibilityExtendClass('-', self, 0, [MSString class], @selector(capitalizedString));
    FoundationCompatibilityExtendClass('-', self, 0, [MSString class], @selector(isEqualToString:));
    FoundationCompatibilityExtendClass('-', self, 0, [MSString class], @selector(description));}
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if (self == [NSString class]) return [[MSString class] allocWithZone:zone];
  return [super allocWithZone:zone];
}

- (NSUInteger)length                          { [self notImplemented:_cmd]; return 0; }
- (unichar)characterAtIndex:(NSUInteger)index { [self notImplemented:_cmd]; return 0; }

- (void)getCharacters:(unichar*)buffer range:(NSRange)rg
{
  NSUInteger i, end;
  i= rg.location;
  end= i + rg.length;
  for (; i<end; i++) {*buffer++= [self characterAtIndex:i];}
}
- (BOOL)isEqual:(id)object
{
  if (object == self) return YES;
  return [object isKindOfClass:[NSString class]] && [self isEqualToString:object];
}

@end

@implementation NSMutableString
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if (self == [NSMutableString class]) return [[_MSMString class] allocWithZone:zone];
  return [super allocWithZone:zone];
}
+ (instancetype)stringWithCapacity:(NSUInteger)capacity
{ return AUTORELEASE([ALLOC(self) initWithCapacity:capacity]); }
@end

@implementation _MSMString
+ (void)load {MSFinishLoadingAddClass(self);}
+ (void)finishLoading
{
  if (self==[_MSMString class]) {
    FoundationCompatibilityExtendClass('-', self, @selector(initWithCapacity:), self, @selector(mutableInitWithCapacity:));}
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  id o= [super allocWithZone:zone];
  CGrowSetForeverMutable(o);
  return o;
}
- (Class)_classForCopy {return [MSString class];}

- (Class)superclass
{ 
  return [NSMutableString class]; 
}
- (BOOL)isKindOfClass:(Class)aClass
{
  return (aClass == [NSMutableString class]) || [super isKindOfClass:aClass];
}

@end
