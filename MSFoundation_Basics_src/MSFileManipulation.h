
typedef enum {
    MSFileOperationSuccess = 0,
    MSFileOperationFail = 1
} MSFileOperationStatus ;

MSExport BOOL MSFileExistsAtPath(NSString *path, BOOL *isDirectory) ;
MSExport BOOL MSIsValidFile(NSString *path) ;
MSExport BOOL MSIsValidDirectory(NSString *path) ;
MSExport BOOL MSGetFileSize(NSString *path, MSLong *size) ;

MSExport NSString *MSPathForCommand(NSString *command) ;

MSExport NSString *MSAbsolutePath(NSString *path) ;
MSExport NSString *MSAbsoluteUnixPath(NSString *path) ;
MSExport NSString *MSAbsoluteWindowsPath(NSString *path) ;

MSExport BOOL MSCreateDirectory(NSString *directory) ;
MSExport BOOL MSCreateRecursiveDirectory(NSString *path) ;
MSExport BOOL MSDeleteFile(NSString *file) ;
MSExport BOOL MSRemoveDirectory(NSString *directory) ;
MSExport BOOL MSRemoveRecursiveDirectory(NSString *directory) ;


MSExport NSString *MSRandomFile(NSString *extension) ;
MSExport NSString *MSTemporaryDirectory(void) ;
MSExport NSString *MSTemporaryPath(NSString *extension) ;
MSExport NSString *MSDisposableFolder(NSString *extension) ;
MSExport NSString *MSTemporaryFile(NSString *extension) ;

MSExport MSFileHandle MSCreateFileForWritingAtPath(NSString *path) ;
MSExport MSFileHandle MSOpenFileForReadingAtPath(NSString *path) ;
MSExport MSFileOperationStatus MSWriteToFile(MSFileHandle file, const void *ptr, NSUInteger length);
MSExport MSFileOperationStatus MSReadFromFile(MSFileHandle file, void *ptr, NSUInteger length, NSUInteger *readBytes);
MSExport MSFileOperationStatus MSCloseFile(MSFileHandle file);

MSExport MSFileOperationStatus MSMoveFile(NSString *sourcePath, NSString *destPath);

MSExport NSString *MSUNCPath(NSString *path) ;

MSExport NSArray *MSDirectoryContentsAtPath(NSString *path) ;

MSExport const unsigned char *bmh_memmem(const unsigned char *haystack, size_t hlen, const unsigned char *needle, size_t nlen) ;

#ifdef WIN32
MSExport char *strtok_r(char *s, const char *delim, char **last) ;
MSExport char *strnstr(const char *s1, const char *s2, size_t n) ;
#endif

