
@interface NSFileHandle : NSObject
+ (instancetype)fileHandleForReadingAtPath:(NSString *)path;
+ (instancetype)fileHandleForWritingAtPath:(NSString *)path;
+ (instancetype)fileHandleForUpdatingAtPath:(NSString *)path;
+ (NSFileHandle *)fileHandleWithStandardError;
+ (NSFileHandle *)fileHandleWithStandardInput;
+ (NSFileHandle *)fileHandleWithStandardOutput;
+ (NSFileHandle *)fileHandleWithNullDevice;

- (id)initWithFileDescriptor:(int)fileDescriptor;
- (id)initWithFileDescriptor:(int)fileDescriptor closeOnDealloc:(BOOL)flag;

- (NSData *)availableData;
- (NSData *)readDataOfLength:(NSUInteger)length;
- (NSData *)readDataToEndOfFile;

- (void)writeData:(NSData *)data;

- (unsigned long long)offsetInFile;
- (unsigned long long)seekToEndOfFile;
- (void)seekToFileOffset:(unsigned long long)offset;

- (void)closeFile;
- (void)synchronizeFile;
- (void)truncateFileAtOffset:(unsigned long long)offset;

@end
