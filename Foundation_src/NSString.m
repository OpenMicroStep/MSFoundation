#import "FoundationCompatibility_Private.h"

@implementation NSString
+ (void)load{ MSFinishLoadingAddClass(self); }

+ (void)finishLoading {
  FoundationCompatibilityExtendClass('+', self, 0, [MSString class], @selector(string));
  FoundationCompatibilityExtendClass('+', self, 0, [MSString class], @selector(stringWithString:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSString class], @selector(stringWithCharacters:length:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSString class], @selector(stringWithUTF8String:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSString class], @selector(stringWithFormat:));
  FoundationCompatibilityExtendClass('+', self, 0, [MSString class], @selector(localizedStringWithFormat:));
  
  FoundationCompatibilityExtendClass('-', self, 0, [MSString class], @selector(lowercaseString));
  FoundationCompatibilityExtendClass('-', self, 0, [MSString class], @selector(uppercaseString));
  FoundationCompatibilityExtendClass('-', self, 0, [MSString class], @selector(capitalizedString));
  FoundationCompatibilityExtendClass('-', self, 0, [MSString class], @selector(isEqualToString:));
  FoundationCompatibilityExtendClass('-', self, 0, [MSString class], @selector(description));
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  if(self == [NSString class]) self= [MSString class];
  return [super allocWithZone:zone];
}

- (NSUInteger)length{ [self notImplemented:_cmd]; return 0; }
- (unichar)characterAtIndex:(NSUInteger)index{ [self notImplemented:_cmd]; return 0; }

- (void)getCharacters:(unichar*)buffer range:(NSRange)rg
{
  NSUInteger i, end;
  i= rg.location;
  end= i + rg.length;
  for (; i<end; i++) {*buffer++= [self characterAtIndex:i];}
}
- (BOOL)isEqual:(id)object
{
  if (object == (id)self) return YES;
  return [object isKindOfClass:[NSString class]] && [self isEqualToString:object];
}

@end

@implementation NSMutableString

@end
