#ifdef WIN32
#import "MSFoundation_Private.h"
#import <windows.h>
#import <lm.h>

//#import <stdio.h>
//#import <tchar.h>
#import <wchar.h>

#define _MSFileSystemRepresentation(X)				(char *)[(X) fileSystemRepresentation]

static inline BOOL _MSGetFileInfo(char *path, WIN32_FILE_ATTRIBUTE_DATA *info)
{
    memset(info, 0, sizeof(WIN32_FILE_ATTRIBUTE_DATA)) ;
    return GetFileAttributesEx(path, GetFileExInfoStandard, info) ;
}
#define _MSIsDirectory(X)	(X.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY ? YES : NO)

static inline BOOL _MSFileExists(char *path, BOOL *isDirectory)
{
    WIN32_FILE_ATTRIBUTE_DATA sourceInfo ;
    if (_MSGetFileInfo(path, &sourceInfo)) {
        if (isDirectory) *isDirectory = _MSIsDirectory(sourceInfo) ;
        return YES ;
    }
    return NO ;
}

#define _MSCreateDirectory(X)	CreateDirectoryA(X, (LPSECURITY_ATTRIBUTES)NULL)
#define _MSDeleteFile(X)	DeleteFileA(X)
#define _MSRemoveDirectory(X)	RemoveDirectoryA(X)

static inline MSFileHandle _MSCreateFileForWritingAtPath(NSString *path)
{
    return (MSFileHandle)CreateFile([path cString],         // name of the write
                        GENERIC_WRITE,          // open for writing
                        0,                      // do not share
                        NULL,                   // default security
                        CREATE_NEW,             // create new file only
                        FILE_ATTRIBUTE_NORMAL,  // normal file
                        NULL);                  // no attr. template
}

static inline MSFileHandle _MSOpenFileForReadingAtPath(NSString *path)
{
    return (MSFileHandle)CreateFile([path cString],         // name of the read
                                    GENERIC_READ,           // open for reading
                                    FILE_SHARE_READ,        // share read
                                    NULL,                   // default security
                                    OPEN_EXISTING,          // existing file only
                                    FILE_ATTRIBUTE_NORMAL,  // normal file
                                    NULL);                  // no attr. template
}

static inline MSFileOperationStatus _MSWriteToFile(MSFileHandle file, const void *ptr, NSUInteger length)
{
    DWORD dwBytesWritten = 0;
    BOOL bErrorFlag = WriteFile(
                                file,            // open file handle
                                ptr,             // start of data to write
                                length,          // number of bytes to write
                                &dwBytesWritten, // number of bytes that were written
                                NULL);           // no overlapped structure
    
    if (FALSE == bErrorFlag)
    {
        return MSFileOperationFail ;
    }
    else
    {
        if (dwBytesWritten != length)
        {
            // This is an error because a synchronous write that results in
            // success (WriteFile returns TRUE) should write all data as
            // requested. This would not necessarily be the case for
            // asynchronous writes.
            return MSFileOperationFail ;
        }
        else
        {
            return MSFileOperationSuccess ;
        }
    }
}

static inline MSFileOperationStatus _MSReadFromFile(MSFileHandle file, void *ptr, NSUInteger length, NSUInteger *readBytes)
{
    DWORD  dwBytesRead = 0;
    MSFileOperationStatus ret = MSFileOperationFail ;
    
    if (TRUE == ReadFile(file, ptr, length, &dwBytesRead, NULL))
    {
        if(dwBytesRead > 0)
        {
            if (readBytes)
            {
                *readBytes = dwBytesRead ;
            }
            ret = MSFileOperationSuccess ;
        }
    }
    
    return ret ;
}

static inline MSFileOperationStatus _MSCloseFile(MSFileHandle file)
{
    if (CloseHandle(file)) return MSFileOperationSuccess;
    else return MSFileOperationFail ;
}

static inline MSFileOperationStatus _MSMoveFile(NSString *sourcePath, NSString *destPath)
{
    if(MoveFile([sourcePath cString], [destPath cString])) return MSFileOperationSuccess ;
    return MSFileOperationFail ;
}

static NSMutableDictionary *_drives = nil ;

typedef DWORD (__stdcall *WNetOpenEnumAProto) (DWORD, DWORD, DWORD, LPNETRESOURCEA, LPHANDLE) ;
typedef DWORD (__stdcall *WNetEnumResourceAProto)(HANDLE, LPDWORD, LPVOID, LPDWORD) ;
typedef DWORD (__stdcall *WNetCloseEnumProto)(HANDLE) ;

static inline unsigned _systemIsWinNt2kXpVistaCompatible()
{
    unsigned int winVersion = MSOperatingSystem();
    switch (winVersion) {
        case NSWindows2000OperatingSystem: return 1;
        case NSWindowsXPOperatingSystem: return 1;
        case NSWindowsServer2003OperatingSystem: return 1;
        case NSWindowsVistaOperatingSystem: return 1;
        case NSWindowsServer2008OperatingSystem: return 1;
        case NSWindowsNTOperatingSystem: return 1;
        case NSWindowsSevenOperatingSystem: return 1;
        case NSWindowsServer2008R2OperatingSystem: return 1;
        default: return 0;
    }
}

static inline NSDictionary *_MSWinNetDrives()
{
    if (!_drives && _systemIsWinNt2kXpVistaCompatible()) {
        HINSTANCE mprDLL =  (HINSTANCE) NULL ;
        _drives = NEW(NSMutableDictionary) ;
        
        mprDLL = MSLoadDLL(@"MPR.DLL") ;
        
        if (mprDLL) {
            WNetOpenEnumAProto WNetOpenEnumA = (WNetOpenEnumAProto)GetProcAddress(mprDLL, "WNetOpenEnumA") ;
            WNetEnumResourceAProto WNetEnumResourceA = (WNetEnumResourceAProto)GetProcAddress(mprDLL, "WNetEnumResourceA") ;
            WNetCloseEnumProto WNetCloseEnum = (WNetCloseEnumProto)GetProcAddress(mprDLL, "WNetCloseEnum") ;
            
            if (WNetOpenEnumA && WNetEnumResourceA && WNetCloseEnum) {
                DWORD success = 0;
                HANDLE hEnum = 0;
                
                success = WNetOpenEnumA(RESOURCE_CONNECTED,
                                        RESOURCETYPE_DISK,
                                        0,
                                        0,
                                        &hEnum);
                
                if ((success == NERR_Success) && (hEnum !=0)) {
                    DWORD dwResultEnum, dwResultClose, i;
                    DWORD cEntries = -1;
                    DWORD cbBuffer = 16384;
                    LPNETRESOURCEA lpNetResource;
                    
                    lpNetResource = (LPNETRESOURCEA)GlobalAlloc(GPTR, cbBuffer);
                    if (lpNetResource) {
                        do {
                            ZeroMemory(lpNetResource, cbBuffer);
                            
                            dwResultEnum = WNetEnumResource(hEnum,
                                                            &cEntries,
                                                            lpNetResource,
                                                            &cbBuffer);
                            
                            if (dwResultEnum == NO_ERROR)
                            {
                                for(i = 0; i < cEntries; i++)
                                {
                                    if (lpNetResource[i].dwScope == RESOURCE_CONNECTED) {
                                        if (lpNetResource[i].lpRemoteName && lpNetResource[i].lpLocalName) {
                                            [_drives setObject:
                                             [NSString stringWithCString: lpNetResource[i].lpRemoteName]
                                                        forKey: [NSString stringWithCString: lpNetResource[i].lpLocalName]];
                                        }
                                    }
                                }
                            }
                            else if (dwResultEnum != ERROR_NO_MORE_ITEMS)
                            {
                                break;
                            }
                        }
                        while (dwResultEnum != ERROR_NO_MORE_ITEMS);
                        
                        GlobalFree((HGLOBAL)lpNetResource);
                        
                        dwResultClose = WNetCloseEnum(hEnum);
                        
                        if (dwResultClose != NO_ERROR) {
                            [NSException raise:NSInternalInconsistencyException
                                        format:@"Error closing network enumerator (WNetCloseEnum Win32 API)"] ;
                        }
                    }
                }
            }
            else {
                if(!WNetOpenEnumA) {
                    [NSException raise:NSInternalInconsistencyException
                                format:@"WNetOpenEnumA Win32 API not found!"] ; }
                
                if(!WNetEnumResourceA) {
                    [NSException raise:NSInternalInconsistencyException
                                format:@"WNetEnumResourceA Win32 API not found!"] ; }
                
                if(!WNetCloseEnum) {
                    [NSException raise:NSInternalInconsistencyException
                                format:@"WNetCloseEnum Win32 API not found!"] ; }
            }
        }
        else {
            [NSException raise:NSInternalInconsistencyException
                        format:@"Unable to load library MPR.DLL!"] ; }
    }
    
    return _drives ;
}

static inline NSString *_MSTransformPath(NSString *path, int mode)
{
    NSArray *components ;
    unsigned i, count ;
    NSMutableString *result = [NSMutableString string] ;
    NSString *comp ;
    if (!mode || ![path length]) return path ;

    components = [path pathComponents] ;
    count = [components count] ;
    for (i = 0 ; i < count ; i ++) {
        comp = [components objectAtIndex:i] ;
        if ([comp isEqualToString:@"/"] || [comp isEqualToString:@"\\"]) {
            if (i == 0) {
                if (mode == 1) [result appendString:@"/"] ;
                else [result appendString:@"\\"] ;
            }
        }
        else if (i < count - 1) {
            [result appendString:comp] ;
            if (mode == 1) [result appendString:@"/"] ;
            else [result appendString:@"\\"] ;
        }
        else [result appendString:comp] ;
    }
    if ([[result right:1] isEqualToString:@":"]) {
        if (mode == 1) [result appendString:@"/"] ;
        else [result appendString:@"\\"] ;
    }
    return [[result copy] autorelease] ;
}

static inline NSString *MSWindowsPath(NSString *path) { return _MSTransformPath(path, 2) ; }
static inline NSString *MSUnixPath(NSString *path) { return _MSTransformPath(path, 1) ; }

static inline NSString *_MSAbsolutePath(NSString *path, int mode)
{
    NSFileManager *fm = [NSFileManager defaultManager] ;
    NSString *currentDirectory = [fm currentDirectoryPath] ;
    unsigned len = [path length] ;
    NSArray *components ;
    unichar c ;
    NSString *comp ;
    if (!len) return _MSTransformPath(currentDirectory, mode) ;
    components = [path pathComponents] ;
    comp = [components objectAtIndex:0] ;
    if (![comp length]) return MSUnixPath(currentDirectory) ; // ne devrait servir a rien
    if ([comp isEqualToString:@"/"] || [comp isEqualToString:@"\\"]) {
        if (mode == 2) {
            if ([currentDirectory length] > 1 && [currentDirectory characterAtIndex:1] == ':') {
                path = [[currentDirectory left:2] stringByAppendingString:path] ;
            }
            else path = [@"C:" stringByAppendingString:path] ;
        }
        if (mode == 0) {
            if ([currentDirectory length] > 1 && [currentDirectory characterAtIndex:1] == ':') {
                path = [[currentDirectory left:2] stringByAppendingString:path] ;
            }
            else path = [@"C:" stringByAppendingString:path] ;
        }
        return _MSTransformPath(path, mode);
    }
    c = [comp characterAtIndex:0] ;
    if ([comp length] == 2 && ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')) &&
        [comp characterAtIndex:1] == ':') {
        // on est sur un path absolu windows
        return _MSTransformPath(path, mode) ;
    }
    // dans tous les autres cas on est dans un chemin relatif
    return _MSTransformPath([currentDirectory stringByAppendingPathComponent:path], mode) ;
}

static inline NSString *_MSUNCPath(NSString *path)
{
    if (![path hasPrefix:@"\\\\"]) {
        NSDictionary *drives = _MSWinNetDrives()  ;
        NSString *p = MSAbsoluteWindowsPath(path) ;
        NSString *retour = nil ;
        
        if ([p length]) {
            NSString *left = [p left:2] ;
            NSString *unc = [drives objectForKey:left] ;
            if (unc) {
                retour = [unc stringByAppendingString:[p mid:2]] ;
            }
            else retour = p ;
        }
        return retour ;
    }
    return path ;
}

BOOL _MSRemoveRecursiveDirectory(NSString *path)
{
    BOOL is_dir = NO ;
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
        DWORD res;
       
        res = GetFileAttributesA(lpath);
        if (res == ((DWORD)0xFFFFFFFF))
        {
            return NO;
        }
        
        if (res & FILE_ATTRIBUTE_DIRECTORY)
        {
            is_dir = YES;
        }
        else
        {
            is_dir = NO;
        }
    }
    
    if (!is_dir)
    {
        if (DeleteFileA(lpath) == FALSE)
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
        unsigned	count = [contents count];
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
        
        if (RemoveDirectoryA(lpath) < 0)
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

// Taken from the OpenBSD's libc
// not available in WebObjects
char *strtok_r(char *s, const char *delim, char **last)
{
    char *spanp;
    int c, sc;
    char *tok;
    
    
    if (s == NULL && (s = *last) == NULL)
        return (NULL);
    
cont:
    c = *s++;
    for (spanp = (char *)delim; (sc = *spanp++) != 0;) {
        if (c == sc)
            goto cont;
    }
    
    if (c == 0) {   /* no non-delimiter characters */
        *last = NULL;
        return (NULL);
    }
    tok = s - 1;
    
    for (;;) {
        c = *s++;
        spanp = (char *)delim;
        do {
            if ((sc = *spanp++) == c) {
                if (c == 0)
                    s = NULL;
                else
                    s[-1] = 0;
                *last = s;
                return (tok);
            }
        } while (sc != 0);
    }
}

char *strnstr(const char *s1, const char *s2, size_t n)
{
    return (char *)bmh_memmem((const unsigned char *)s1, n,
                      (const unsigned char *)s2, strlen(s2)) ;
}

static inline BOOL _MSGetFileSize(char *path, MSLong *size)
{
    BOOL res = NO ;
	LARGE_INTEGER largeInt ;
    WIN32_FILE_ATTRIBUTE_DATA info ;
    
    if (GetFileAttributesEx(path, GetFileExInfoStandard, &info))
    {
        largeInt.u.HighPart = info.nFileSizeHigh ;
		largeInt.u.LowPart = info.nFileSizeLow ;
        
        *size = info.nFileSizeHigh << 32 ;
        *size += info.nFileSizeLow ;
        
        res = YES ;
    }
	return res ;
}

#endif
