#import "FoundationCompatibility_Private.h"

@implementation NSMethodSignature

+ (NSMethodSignature *)signatureWithObjCTypes:(const char *)types
{
  return AUTORELEASE([ALLOC(self) initWithObjCTypes:types]);
}

- (instancetype)initWithObjCTypes:(const char *)types
{ // v12@0:4@8
  const char *next, *current;
  NSUInteger size, align, length, idx, pos;
  CBuffer *buf;
  CArray *idxs;

  idx= 0;
  next= current= types;
  _types= buf= CCreateBuffer(0);
  _typesIndexes= idxs= CCreateArrayWithOptions(0, YES, YES);
  while(*next && (next= NSGetSizeAndAlignment(current, &size, &align))) {
    length= next - current;
    CBufferAppendBytes(buf, current, length * sizeof(char));
    CBufferAppendByte(buf, 0);
    CArrayAddObject(idxs, (id)idx);
    pos= 0;
    while ('0' <= *next && *next <= '9') {
      pos= pos + (*next - '0');
      ++next;}
    CArrayAddObject(idxs, (id)pos);
    idx += length + 1;
    current= next;
  }
  return self;
}

- (void)dealloc
{
  RELEASE(_types);
  RELEASE(_typesIndexes);
  [super dealloc];
}

- (BOOL)isOneway
{
  return CBufferByteAtIndex(_types, 0) == 'V';
}

- (NSUInteger)frameLength
{
  return (NSUInteger)CArrayObjectAtIndex(_typesIndexes, 1);
}

- (NSUInteger)numberOfArguments
{
  return CArrayCount(_typesIndexes)/2 - 1;
}

- (const char *)getArgumentTypeAtIndex:(NSUInteger)index
{
  return (const char *)(CBufferBytes(_types) + ((NSUInteger)CArrayObjectAtIndex(_typesIndexes, (index + 1) * 2)));
}

- (const char *)methodReturnType
{
  return (const char *)CBufferBytes(_types);
}

- (NSUInteger)methodReturnLength
{
  NSUInteger size,align;
  NSGetSizeAndAlignment((const char *)CBufferBytes(_types), &size, &align);
  return size;
}

@end