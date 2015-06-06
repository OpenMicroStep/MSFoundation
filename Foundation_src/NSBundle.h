@class NSString, NSArray;

@interface NSBundle : NSObject {
@private
	uint32_t _type;
	uint32_t _state;
    NSDictionary *_info;
    NSString *_path;
    NSString *_exePath;
    NSString *_rscPath;
    mtx_t _mutex;
}

/* Methods for creating or retrieving bundle instances. */
+ (NSBundle *)mainBundle;
+ (NSBundle *)bundleWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;

+ (NSBundle *)bundleForClass:(Class)aClass;
+ (NSBundle *)bundleWithIdentifier:(NSString *)identifier;

+ (NSArray *)allBundles;
+ (NSArray *)allFrameworks;

- (BOOL)load;
- (BOOL)isLoaded;
- (BOOL)unload;

- (NSString *)bundlePath;
- (NSString *)resourcePath;
- (NSString *)executablePath;
- (NSString *)pathForAuxiliaryExecutable:(NSString *)executableName;

- (NSString *)privateFrameworksPath;
- (NSString *)sharedFrameworksPath;
- (NSString *)sharedSupportPath;
- (NSString *)builtInPlugInsPath;

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)bundlePath;
+ (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)bundlePath;

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext;
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath;

- (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)subpath;


/* Methods for obtaining various information about a bundle. */
- (NSString *)bundleIdentifier;
- (NSDictionary *)infoDictionary;
- (id)objectForInfoDictionaryKey:(NSString *)key;
- (Class)classNamed:(NSString *)className;
- (Class)principalClass;

@end

