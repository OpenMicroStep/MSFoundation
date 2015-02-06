#import "MSFoundation_Private.h"
//#import "MSStringAdditions.h"
#ifdef WIN32
#import "MSFileManipulation_win32_Private.i"
#else
#import "MSFileManipulation_unix_Private.i"
#endif

#define _MSFileSystemRepresentation(X)				(char *)[(X) fileSystemRepresentation]

static unsigned int __increment = 0 ;

BOOL MSFileExistsAtPath(NSString *path, BOOL *isDirectory)
{
    char *s = (char *)[path cStringUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO] ;
    return s ? _MSFileExists(s, isDirectory) : NO ;
}

BOOL MSIsValidFile(NSString *path)
{
    BOOL isDir = NO ;
    return (([path length] && (MSFileExistsAtPath(path, &isDir) && !isDir)) ? YES : NO) ;
}

BOOL MSIsValidDirectory(NSString *path)
{
    BOOL isDir = NO ;
    return (([path length] && (MSFileExistsAtPath(path, &isDir) && isDir)) ? YES : NO) ;
}

BOOL MSGetFileSize(NSString *path, MSLong *size) 
{
    if(size && [path length])
    {
        return _MSGetFileSize(_MSFileSystemRepresentation(path), size) ;
    }
    return NO ;
}

NSString *MSAbsolutePath(NSString *path) { return _MSAbsolutePath(path, 0) ; }

NSString *MSAbsoluteUnixPath(NSString *path) { return _MSAbsolutePath(path, 1) ; }

NSString *MSAbsoluteWindowsPath(NSString *path) { return _MSAbsolutePath(path, 2) ; }

NSString *MSPathForCommand(NSString *command)
{
#warning MSPathForCommand is missing NSProcessInfo
    NSDictionary *env = nil; //[[NSProcessInfo processInfo] environment] ;
#ifdef WIN32
    NSString *envPath = [env objectForKey:@"Path"] ;
    NSString *c = ([command hasExtension:@"exe"] ? command : [command stringByAppendingPathExtension:@"exe"]) ;
#else
    NSString *envPath = [env objectForKey:@"path"] ;
    NSString *c = command ;
#endif
    NSString *path ;
    NSEnumerator *e = [[envPath componentsSeparatedByString:@";"] objectEnumerator] ;
    while ((path = [e nextObject])) {
        path = [path stringByAppendingPathComponent:c] ;
        if (MSIsValidFile(path)) return path ;
    }
    return nil ;
}

static int _MSPid(void)
{ 
#ifdef WIN32
	return (int)GetCurrentProcessId();
#else
	return (int)getpid() ;
#endif	
}
NSString *MSRandomFile(NSString *extension)
{
	unsigned long long ts = (MSULong)ABS(GMTNow()) * 1000UL ;
	NSString *s = [NSString stringWithFormat:@"%04x%08x%08x%08x", _MSPid(), __increment++, (unsigned int)(ts >> 32), (unsigned int)(ts & 0xffffffff)] ;
	if ([extension length]) s = [s stringByAppendingPathExtension:extension] ;
	return s ;
}

NSString *MSTemporaryDirectory(void) { return nil; /*[NSTemporaryDirectory() stringByResolvingSymlinksInPath] ;*/ }

NSString *MSTemporaryPath(NSString *extension) { return [MSTemporaryDirectory() stringByAppendingPathComponent:MSTemporaryFile(extension)] ; }

NSString *MSDisposableFolder(NSString *extension)
{
    NSString *path = MSTemporaryPath(extension) ;
    if (path) {
        NSFileManager *manager = [NSFileManager defaultManager] ;
        if ([manager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:NULL]) {
            return path ;
        }
    }
    return nil ;
}

NSString *MSTemporaryFile(NSString *extension)
{ return [MSTemporaryDirectory() stringByAppendingPathComponent:MSRandomFile(extension)] ; }


BOOL MSDeleteFile(NSString *file) { return _MSDeleteFile(_MSFileSystemRepresentation(file)) ; }
BOOL MSRemoveDirectory(NSString *directory) { return _MSRemoveDirectory(_MSFileSystemRepresentation(directory)) ; }
BOOL MSRemoveRecursiveDirectory(NSString *directory) { return _MSRemoveRecursiveDirectory(directory) ; }

BOOL MSCreateDirectory(NSString *directory)
{
    const char *s = [directory cStringUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO] ;
    return s ? _MSCreateDirectory(s) : NO ;
}

BOOL MSCreateRecursiveDirectory(NSString *path)
{
    BOOL isDir ;
    if(MSFileExistsAtPath(path,&isDir))
    {
        return isDir ? YES : NO ;
    }
    else
    {
        NSEnumerator *e ;
        NSString *pathComponent ;
        NSString *buildPath = @"" ;
        BOOL isUNC = NO ;
        BOOL firstComponent = YES ;
        
        if ([path hasPrefix:@"\\\\"]) {
            isUNC = YES ;
            path = [path substringAfterString:@"\\\\"] ;
        }
        e = [[path pathComponents] objectEnumerator] ;
        
        while ((pathComponent = [e nextObject]))
        {
            if (firstComponent) {
                if (isUNC) {
                    buildPath = [NSString stringWithFormat:@"\\\\%@", pathComponent] ;
                }
                else {
                    buildPath = [buildPath stringByAppendingPathComponent:pathComponent] ;
                }
                firstComponent = NO ;
            }
            else {
                buildPath = [buildPath stringByAppendingPathComponent:pathComponent] ;

                if(MSFileExistsAtPath(buildPath,&isDir))
                {
                    if (!isDir) {
                        return NO ;
                    }
                }
                else {
                    if(!MSCreateDirectory(buildPath)) {
                        return NO ;
                    }
                }
            }
        }
    }
    return YES ;
}

MSFileHandle MSCreateFileForWritingAtPath(NSString *path) { return fopen([path UTF8String], "w+"); }
MSFileHandle MSOpenFileForReadingAtPath(NSString *path) { return fopen([path UTF8String], "r+") ; }
MSFileOperationStatus MSWriteToFile(MSFileHandle file, const void *ptr, NSUInteger length) { return fwrite(ptr, length, 1, file) == length ? MSFileOperationSuccess : MSFileOperationFail ; }
MSFileOperationStatus MSReadFromFile(MSFileHandle file, void *ptr, NSUInteger length, NSUInteger *readBytes) { return (*readBytes= fread(ptr, length, 1, file)) > 0 ? MSFileOperationSuccess : MSFileOperationFail ; }
MSFileOperationStatus MSCloseFile(MSFileHandle file) { return fclose(file) == 0 ? MSFileOperationSuccess : MSFileOperationFail; }

MSFileOperationStatus MSMoveFile(NSString *sourcePath, NSString *destPath) { return rename([sourcePath UTF8String], [destPath UTF8String]) == 0 ? MSFileOperationSuccess : MSFileOperationFail  ; }

NSString *MSUNCPath(NSString *path) { return _MSUNCPath(path) ; }


typedef id (*IMP_LOCAL)(id, SEL, ...); /// TODO: TO BE REPLACED BY IMP ???
NSArray * MSDirectoryContentsAtPath(NSString *path) {
    NSDirectoryEnumerator	*direnum;
    NSMutableArray	*content;
    IMP_LOCAL			nxtImp;
    IMP_LOCAL			addImp;
    BOOL			is_dir;
    
    /*
     * See if this is a directory (don't follow links).
     */
    if(MSFileExistsAtPath(path,&is_dir) == NO || is_dir == NO )
    {
        return nil;
    }
    /* We initialize the directory enumerator with justContents == YES,
     which tells the NSDirectoryEnumerator code that we only enumerate
     the contents non-recursively once, and exit.  NSDirectoryEnumerator
     can perform some optimisations using this assumption. */
    
    /*direnum = [[NSDirectoryEnumerator alloc] initWithDirectoryPath: path
                                         recurseIntoSubdirectories: NO
                                                    followSymlinks: NO
                                                      justContents: YES
                                                               for: self];*/
    direnum = [[NSFileManager defaultManager] enumeratorAtPath:path] ;
    content = [NSMutableArray arrayWithCapacity: 128];
    
    nxtImp = (IMP_LOCAL)[direnum methodForSelector: @selector(nextObject)];
    addImp = (IMP_LOCAL)[content methodForSelector: @selector(addObject:)];
    
    while ((path = ((id(*)(id, SEL))(*nxtImp))(direnum, @selector(nextObject))) != nil)
    {
        ((id(*)(id, SEL, id))(*addImp))(content, @selector(addObject:), path);
    }
    //RELEASE(direnum);
    
    return content ;
}

// Boyer–Moore–Horspool memmem
const unsigned char * bmh_memmem(const unsigned char* haystack, size_t hlen,
                                 const unsigned char* needle,   size_t nlen)
{
    size_t scan = 0;
    size_t last;
    size_t bad_char_skip[UCHAR_MAX + 1];
    
    if (nlen <= 0 || !haystack || !needle)
        return NULL;
    
    for (scan = 0; scan <= UCHAR_MAX; scan = scan + 1)
        bad_char_skip[scan] = nlen;
    
    last = nlen - 1;
    
    for (scan = 0; scan < last; scan = scan + 1)
        bad_char_skip[needle[scan]] = last - scan;
    
    while (hlen >= nlen)
    {
        for (scan = last; haystack[scan] == needle[scan]; scan = scan - 1)
            if (scan == 0)
                return haystack;
        
        hlen     -= bad_char_skip[haystack[last]];
        haystack += bad_char_skip[haystack[last]];
    }
    
    return NULL;
}

