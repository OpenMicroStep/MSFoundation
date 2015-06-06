
@interface NSUnarchiver : NSCoder {
@private
  NSData *_data;
  NSUInteger _pos;
  CDictionary *_clsMap;
  CDictionary *_refs;
  CDictionary *_replacements;
  NSUInteger _refCounter;
}
+ (id)unarchiveObjectWithFile:(NSString *)path;
- (id)initForReadingWithData:(NSData *)data;
- (void)replaceObject:(id)object withObject:(id)newObject;
- (void)decodeClassName:(NSString *)nameInArchive asClassName:(NSString *)trueName;
- (NSString *)classNameDecodedForArchiveClassName:(NSString *)nameInArchive;
- (BOOL)isAtEnd;
@end
