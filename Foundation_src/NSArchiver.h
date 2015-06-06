
@interface NSArchiver : NSCoder {
@private
  NSMutableData *_data;
  CDictionary *_clsMap;
  CDictionary *_refs;
  CDictionary *_replacements;
  NSUInteger _refCounter;
}

+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path;
+ (NSData *)archivedDataWithRootObject:(id)rootObject;
- (instancetype)initForWritingWithMutableData:(NSMutableData *)data;
- (NSMutableData *)archiverData;
- (NSString *)classNameEncodedForTrueClassName:(NSString *)trueName;
- (void)encodeClassName:(NSString *)trueName intoClassName:(NSString *)inArchiveName;
- (void)encodeConditionalObject:(id)object;
- (void)encodeRootObject:(id)rootObject;
- (void)replaceObject:(id)object withObject:(id)newObject;

@end