@class NSError;

@interface NSData : NSObject
- (NSUInteger)length;
- (const void *)bytes;
@end

typedef NS_OPTIONS(NSUInteger, NSDataReadingOptions) {
    NSDataReadingMappedIfSafe = 1UL << 0,	// Hint to map the file in if possible and safe
    NSDataReadingUncached     = 1UL << 1,	// Hint to get the file not to be cached in the kernel
    NSDataReadingMappedAlways = 1UL << 3,	// Hint to map the file in if possible. This takes precedence over NSDataReadingMappedIfSafe if both are given.
};

@interface NSData (NSDataCreation)

+ (instancetype)data;
+ (instancetype)dataWithData:(NSData *)data;
+ (instancetype)dataWithBytes:(const void *)bytes length:(NSUInteger)length;
+ (instancetype)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length;
+ (instancetype)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b;
+ (instancetype)dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
+ (instancetype)dataWithContentsOfFile:(NSString *)path;
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length;
- (instancetype)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length;
- (instancetype)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b;
- (instancetype)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
- (instancetype)initWithContentsOfFile:(NSString *)path;
@end

@interface NSMutableData : NSData

@end
