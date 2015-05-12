
typedef enum {
    MSFileOperationSuccess = 0,
    MSFileOperationFail = 1
} MSFileOperationStatus ;

MSFoundationExtern BOOL MSFileExistsAtPath(NSString *path, BOOL *isDirectory) ;
MSFoundationExtern BOOL MSIsValidFile(NSString *path) ;
MSFoundationExtern BOOL MSIsValidDirectory(NSString *path) ;
MSFoundationExtern BOOL MSGetFileSize(NSString *path, MSLong *size) ;

MSFoundationExtern NSString *MSPathForCommand(NSString *command) ;

MSFoundationExtern NSString *MSAbsolutePath(NSString *path) ;
MSFoundationExtern NSString *MSAbsoluteUnixPath(NSString *path) ;
MSFoundationExtern NSString *MSAbsoluteWindowsPath(NSString *path) ;

MSFoundationExtern BOOL MSCreateDirectory(NSString *directory) ;
MSFoundationExtern BOOL MSCreateRecursiveDirectory(NSString *path) ;
MSFoundationExtern BOOL MSDeleteFile(NSString *file) ;
MSFoundationExtern BOOL MSRemoveDirectory(NSString *directory) ;
MSFoundationExtern BOOL MSRemoveRecursiveDirectory(NSString *directory) ;


MSFoundationExtern NSString *MSRandomFile(NSString *extension) ;
MSFoundationExtern NSString *MSTemporaryDirectory(void) ;
MSFoundationExtern NSString *MSTemporaryPath(NSString *extension) ;
MSFoundationExtern NSString *MSDisposableFolder(NSString *extension) ;
MSFoundationExtern NSString *MSTemporaryFile(NSString *extension) ;

MSFoundationExtern MSFileHandle MSCreateFileForWritingAtPath(NSString *path) ;
MSFoundationExtern MSFileHandle MSOpenFileForReadingAtPath(NSString *path) ;
MSFoundationExtern MSFileOperationStatus MSWriteToFile(MSFileHandle file, const void *ptr, NSUInteger length);
MSFoundationExtern MSFileOperationStatus MSReadFromFile(MSFileHandle file, void *ptr, NSUInteger length, NSUInteger *readBytes);
MSFoundationExtern MSFileOperationStatus MSCloseFile(MSFileHandle file);

MSFoundationExtern MSFileOperationStatus MSMoveFile(NSString *sourcePath, NSString *destPath);

MSFoundationExtern NSString *MSUNCPath(NSString *path) ;

MSFoundationExtern NSArray *MSDirectoryContentsAtPath(NSString *path) ;

MSFoundationExtern const unsigned char *bmh_memmem(const unsigned char *haystack, size_t hlen, const unsigned char *needle, size_t nlen) ;

#ifdef WO451
MSFoundationExtern char *strtok_r(char *s, const char *delim, char **last) ;
#endif
#ifdef WIN32
MSFoundationExtern char *strnstr(const char *s1, const char *s2, size_t n) ;
#endif

