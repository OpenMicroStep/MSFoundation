@interface NSDirectoryEnumerator : NSEnumerator {
@private
  NSString *_path;
  NSString *_current;
  void *_uv_fs_req;
  BOOL _skipDescendents;
  NSString *_base;
  NSDirectoryEnumerator *_child;
}
- (NSDictionary *)directoryAttributes;
- (NSDictionary *)fileAttributes;
- (void)skipDescendents;
@end

@interface NSFileManager : NSObject <NSCopying>

+ (NSFileManager *)defaultManager;

- (NSString *)currentDirectoryPath;
- (BOOL)changeCurrentDirectoryPath:(NSString *)path;
- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents attributes:(NSDictionary *)attributes;
- (BOOL)createDirectoryAtPath:(NSString *)path attributes:(NSDictionary *)attributes;
- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)error;

- (BOOL)changeFileAttributes:(NSDictionary *)attributes atPath:(NSString *)path;
- (BOOL)isExecutableFileAtPath:(NSString *)path;
- (BOOL)isReadableFileAtPath:(NSString *)path;
- (BOOL)isWritableFileAtPath:(NSString *)path;
- (NSDirectoryEnumerator *)enumeratorAtPath:(NSString *)path;
- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;
@end
