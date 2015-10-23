
FoundationExtern NSString * const NSFileType;
FoundationExtern NSString * const NSFileSize;
FoundationExtern NSString * const NSFileModificationDate;
FoundationExtern NSString * const NSFileReferenceCount;
FoundationExtern NSString * const NSFileDeviceIdentifier;
FoundationExtern NSString * const NSFileOwnerAccountName;
FoundationExtern NSString * const NSFileGroupOwnerAccountName;
FoundationExtern NSString * const NSFilePosixPermissions;
FoundationExtern NSString * const NSFileSystemNumber;
FoundationExtern NSString * const NSFileSystemFileNumber;
FoundationExtern NSString * const NSFileExtensionHidden;
// FoundationExtern NSString * const NSFileHFSCreatorCode;
// FoundationExtern NSString * const NSFileHFSTypeCode;
FoundationExtern NSString * const NSFileImmutable;
FoundationExtern NSString * const NSFileAppendOnly;
FoundationExtern NSString * const NSFileCreationDate;
FoundationExtern NSString * const NSFileOwnerAccountID;
FoundationExtern NSString * const NSFileGroupOwnerAccountID;
FoundationExtern NSString * const NSFileBusy;

FoundationExtern NSString * const NSFileTypeDirectory;
FoundationExtern NSString * const NSFileTypeRegular;
FoundationExtern NSString * const NSFileTypeSymbolicLink;
FoundationExtern NSString * const NSFileTypeSocket;
FoundationExtern NSString * const NSFileTypeCharacterSpecial;
FoundationExtern NSString * const NSFileTypeBlockSpecial;
FoundationExtern NSString * const NSFileTypeUnknown;

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

- (NSDictionary*)attributesOfItemAtPath:(NSString *)path error:(NSError **)error;
- (BOOL)changeFileAttributes:(NSDictionary *)attributes atPath:(NSString *)path;
- (BOOL)isExecutableFileAtPath:(NSString *)path;
- (BOOL)isReadableFileAtPath:(NSString *)path;
- (BOOL)isWritableFileAtPath:(NSString *)path;
- (NSDirectoryEnumerator *)enumeratorAtPath:(NSString *)path;
- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;
- (BOOL)fileExistsAtPath:(NSString *)path;
- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory;

@end
