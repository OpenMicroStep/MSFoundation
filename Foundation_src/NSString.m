#import "FoundationCompatibility_Private.h"

@interface _MSMString : MSString
// Mutable version of MSString with some changes to follow NSMutableString specs
@end

@implementation NSString
+ (void)initialize {
  if (self==[NSString class]) {
    Class fromClass= [MSString class];
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(string));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(stringWithString:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(stringWithCharacters:length:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(stringWithUTF8String:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(stringWithFormat:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(localizedStringWithFormat:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(stringWithCString:encoding:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(stringWithContentsOfFile:encoding:error:));
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(stringWithContentsOfFile:usedEncoding:error:));

    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(lowercaseString));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(uppercaseString));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(capitalizedString));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(isEqualToString:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(description));

    // Encoding
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(cStringUsingEncoding:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(cStringUsingEncoding:allowLossyConversion:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(dataUsingEncoding:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(dataUsingEncoding:allowLossyConversion:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(UTF8String));

    // Search
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(rangeOfString:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(rangeOfString:options:));

    // Line range
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(getLineStart:end:contentsEnd:forRange:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(lineRangeForRange:));

    // Dividing strings
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(componentsSeparatedByString:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(substringFromIndex:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(substringToIndex:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(substringWithRange:));

    // Combining strings
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(stringByAppendingFormat:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(stringByAppendingString:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(stringByPaddingToLength:withString:startingAtIndex:));

    // Compare strings
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(caseInsensitiveCompare:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(compare:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(hasPrefix:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(hasSuffix:));

    // Path extension
    FoundationCompatibilityExtendClass('+', self, 0, fromClass, @selector(pathWithComponents:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(pathComponents));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(fileSystemRepresentation));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(isAbsolutePath));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(lastPathComponent));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(pathExtension));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(stringByAppendingPathComponent:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(stringByAppendingPathExtension:));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(stringByDeletingLastPathComponent));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(stringByDeletingPathExtension));
    FoundationCompatibilityExtendClass('-', self, 0, fromClass, @selector(stringsByAppendingPaths:));}
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  return (self == [NSString class]) ? [[MSString class] allocWithZone:zone] : [super allocWithZone:zone];
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
-(id)copyWithZone:(NSZone *)zone
{
  return [self retain];
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
  return [ALLOC(_MSMString) initWithString:self];
}
- (const unichar *)UTF16String
{
  const static unichar end= 0;
  CBuffer *ret= CCreateBuffer(0);
  CBufferAppendSES(ret, SESFromString(self), NSUnicodeStringEncoding);
  CBufferAppendBytes(ret, &end, sizeof(end));
  AUTORELEASE(ret);
  return (const unichar *)CBufferBytes(ret);
}
@end

@implementation NSMutableString
+ (instancetype)allocWithZone:(NSZone *)zone
{
  return (self == [NSMutableString class]) ? [_MSMString allocWithZone:zone] : [super allocWithZone:zone];
}
+ (instancetype)stringWithCapacity:(NSUInteger)capacity
{
  return AUTORELEASE([ALLOC(self) initWithCapacity:capacity]);
}
-(id)copyWithZone:(NSZone *)zone
{
  return [ALLOC(MSString) initWithString:self];
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
  return [ALLOC(_MSMString) initWithString:self];
}
@end

@implementation _MSMString
+ (void)initialize
{
  if (self==[_MSMString class]) {
    Class fromClass= [MSString class];
    FoundationCompatibilityExtendClass('-', self, @selector(initWithCapacity:), fromClass, @selector(mutableInitWithCapacity:));
  }
}
+ (instancetype)allocWithZone:(NSZone *)zone
{
  id o= [super allocWithZone:zone];
  CGrowSetForeverMutable(o);
  return o;
}
@end
