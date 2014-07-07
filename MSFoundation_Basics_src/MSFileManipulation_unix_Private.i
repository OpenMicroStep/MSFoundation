#ifndef WIN32
#import "MSFoundation_Private.h"

#define _MSFileSystemRepresentation(X)				(char *)[(X) fileSystemRepresentation]

static inline BOOL _MSFileExists(char *path, BOOL *isDirectory)
{
    struct stat statbuf;
    
    if (!stat(path, &statbuf)) {
        if (isDirectory) *isDirectory = ((statbuf.st_mode & S_IFMT) == S_IFDIR);
        return YES ;
    }
    return NO ;
}

#define _MSDeleteFile(X)		(unlink(X) == 0 ? YES : NO)
#define _MSRemoveDirectory(X)	((rmdir(X) == 0) ? YES : NO)
#define _MSCreateDirectory(X)	(mkdir(X, 0777) != 0 ? NO : YES)

static inline NSString *_MSAbsolutePath(NSString *path, int mode)
{
#warning TO BE IMPLEMENTED
    [[NSNull null] notImplemented:nil] ;
    return nil ;
    path= nil; // Unused parameter
    mode= 0; // Unused parameter
}

static inline MSFileHandle _MSCreateFileForWritingAtPath(NSString *path)
{
    MSFileHandle fd = open([path UTF8String], O_CREAT|O_TRUNC|O_WRONLY, S_IRWXU | S_IRGRP | S_IROTH) ;
    fchmod(fd, S_IRWXU | S_IRGRP | S_IROTH);
    return fd ;
}

static inline MSFileHandle _MSOpenFileForReadingAtPath(NSString *path)
{
    MSFileHandle fd = open([path UTF8String],O_RDONLY) ;
    return fd ;
}

static inline MSFileOperationStatus _MSWriteToFile(MSFileHandle file, const void *ptr, NSUInteger length)
{
    ssize_t writen = write(file, ptr, length);

    if (writen>0 && (NSUInteger)writen == length) return MSFileOperationSuccess ;
    else return MSFileOperationFail ;
}

static inline MSFileOperationStatus _MSReadFromFile(MSFileHandle file, void *ptr, NSUInteger length, NSUInteger *readBytes)
{
    ssize_t nbRead = read(file, ptr, length) ;
    MSFileOperationStatus ret = MSFileOperationFail ;
    
    if (nbRead > 0)
    {
        if (readBytes) *readBytes = (NSUInteger)nbRead ;
        ret = MSFileOperationSuccess ;
    }
    
    return ret ;
}


static inline MSFileOperationStatus _MSCloseFile(MSFileHandle file)
{
    if (!close(file)) return MSFileOperationSuccess;
    else return MSFileOperationFail ;
}

static inline MSFileOperationStatus _MSMoveFile(NSString *sourcePath, NSString *destPath)
{
    if(rename([sourcePath UTF8String], [destPath UTF8String])) return MSFileOperationFail ;
    return MSFileOperationSuccess ;

}

static inline NSString *_MSUNCPath(NSString *path) { MSRaise(NSInternalInconsistencyException, @"_MSUNCPath() not implemented!") ; return nil ; path= nil; }

static inline BOOL _MSRemoveRecursiveDirectory(NSString *path)
{
    BOOL		is_dir;
    char *lpath = _MSFileSystemRepresentation(path) ;
    
    if ([path isEqualToString: @"."] || [path isEqualToString: @".."])
    {
        [NSException raise: NSInvalidArgumentException
                    format: @"Attempt to remove illegal path"];
    }
        
    if (lpath == 0 || *lpath == 0)
    {
        [NSException raise: NSGenericException
                    format: @"Could not remove - no path"];
    }
    else
    {
        struct stat statbuf;
        
        if (lstat(lpath, &statbuf) != 0)
        {
            return NO;
        }
        is_dir = ((statbuf.st_mode & S_IFMT) == S_IFDIR);
    }
    
    if (!is_dir)
    {
            if (unlink(lpath) < 0)
            {
                [NSException raise: NSGenericException format:@"failed to remove file at path %@", path] ;
            }
            else
            {
                return YES;
            }
    }
    else
    {
        NSArray   *contents = MSDirectoryContentsAtPath(path) ;
        NSUInteger	count = [contents count];
        unsigned	i;
        
        for (i = 0; i < count; i++)
        {
            NSString		*item;
            NSString		*next;
            BOOL			result;
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init] ;
            
            item = [contents objectAtIndex: i];
            next = [path stringByAppendingPathComponent: item];
            result = _MSRemoveRecursiveDirectory(next) ;
            RELEASE(pool);
            if (result == NO)
            {
                return NO;
            }
        }
        
        if (rmdir(lpath) < 0)
        {            
            [NSException raise: NSGenericException format:@"failed to remove directory at path %s", lpath] ;
        }
        else
        {
            return YES;
        }
    }
    return NO ;
}

static inline BOOL _MSGetFileSize(char *path, MSLong *size)
{
    struct stat st;
    int res = stat(path, &st) ;
    *size = st.st_size ;
    
    return res == 0 ;
}

#endif
