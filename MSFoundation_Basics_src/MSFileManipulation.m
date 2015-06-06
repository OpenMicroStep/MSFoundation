#import "MSFoundation_Private.h"
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
    NSDictionary *env = [[NSProcessInfo processInfo] environment] ;
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

/*
NSString *MSRandomFile(NSString *extension)
{
    unsigned long long ts = (MSULong)ABS(GMTNow()) * 1000UL ;
    NSString *s = [NSString stringWithFormat:@"%04x%08x%08x%08x", ms_get_current_process_id(), __increment++, (unsigned int)(ts >> 32), (unsigned int)(ts & 0xffffffff)] ;
    if ([extension length]) s = [s stringByAppendingPathExtension:extension] ;
    return s ;
}

NSString *MSTemporaryDirectory(void) { return [NSTemporaryDirectory() stringByResolvingSymlinksInPath] ; }

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
*/

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

MSFileHandle MSCreateFileForWritingAtPath(NSString *path) { return _MSCreateFileForWritingAtPath(path) ; }
MSFileHandle MSOpenFileForReadingAtPath(NSString *path) { return _MSOpenFileForReadingAtPath(path) ; }
MSFileOperationStatus MSWriteToFile(MSFileHandle file, const void *ptr, NSUInteger length) { return _MSWriteToFile(file, ptr, length) ; }
MSFileOperationStatus MSReadFromFile(MSFileHandle file, void *ptr, NSUInteger length, NSUInteger *readBytes) { return _MSReadFromFile(file, ptr, length, readBytes) ; }
MSFileOperationStatus MSCloseFile(MSFileHandle file) { return _MSCloseFile(file) ; }

MSFileOperationStatus MSMoveFile(NSString *sourcePath, NSString *destPath) { return _MSMoveFile(sourcePath, destPath) ; }

NSString *MSUNCPath(NSString *path) { return _MSUNCPath(path) ; }

typedef id (*MY_IMP)(id, SEL, ...);
NSArray * MSDirectoryContentsAtPath(NSString *path) {
    NSDirectoryEnumerator	*direnum;
    CArray	*content;
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
    content = CCreateArray(128);
    
    while ((path = [direnum nextObject]))
    {
      CArrayAddObject(content, path);
    }
    //RELEASE(direnum);
    
    return AUTORELEASE(content) ;
}

#ifndef APPLE
char *strnstr(const char *s1, const char *s2, size_t n)
{
    return (char *)bmh_memmem((const unsigned char *)s1, n,
                              (const unsigned char *)s2, strlen(s2)) ;
}
#endif

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

