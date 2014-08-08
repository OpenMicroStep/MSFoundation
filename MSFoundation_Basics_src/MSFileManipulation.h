
typedef enum {
    MSFileOperationSuccess = 0,
    MSFileOperationFail = 1
} MSFileOperationStatus ;

MSFoundationExport BOOL MSFileExistsAtPath(NSString *path, BOOL *isDirectory) ;
MSFoundationExport BOOL MSIsValidFile(NSString *path) ;
MSFoundationExport BOOL MSIsValidDirectory(NSString *path) ;
MSFoundationExport BOOL MSGetFileSize(NSString *path, MSLong *size) ;

MSFoundationExport NSString *MSPathForCommand(NSString *command) ;

MSFoundationExport NSString *MSAbsolutePath(NSString *path) ;
MSFoundationExport NSString *MSAbsoluteUnixPath(NSString *path) ;
MSFoundationExport NSString *MSAbsoluteWindowsPath(NSString *path) ;

MSFoundationExport BOOL MSCreateDirectory(NSString *directory) ;
MSFoundationExport BOOL MSCreateRecursiveDirectory(NSString *path) ;
MSFoundationExport BOOL MSDeleteFile(NSString *file) ;
MSFoundationExport BOOL MSRemoveDirectory(NSString *directory) ;
MSFoundationExport BOOL MSRemoveRecursiveDirectory(NSString *directory) ;


MSFoundationExport NSString *MSRandomFile(NSString *extension) ;
MSFoundationExport NSString *MSTemporaryDirectory(void) ;
MSFoundationExport NSString *MSTemporaryPath(NSString *extension) ;
MSFoundationExport NSString *MSDisposableFolder(NSString *extension) ;
MSFoundationExport NSString *MSTemporaryFile(NSString *extension) ;

MSFoundationExport MSFileHandle MSCreateFileForWritingAtPath(NSString *path) ;
MSFoundationExport MSFileHandle MSOpenFileForReadingAtPath(NSString *path) ;
MSFoundationExport MSFileOperationStatus MSWriteToFile(MSFileHandle file, const void *ptr, NSUInteger length);
MSFoundationExport MSFileOperationStatus MSReadFromFile(MSFileHandle file, void *ptr, NSUInteger length, NSUInteger *readBytes);
MSFoundationExport MSFileOperationStatus MSCloseFile(MSFileHandle file);

MSFoundationExport MSFileOperationStatus MSMoveFile(NSString *sourcePath, NSString *destPath);

MSFoundationExport NSString *MSUNCPath(NSString *path) ;

MSFoundationExport NSArray *MSDirectoryContentsAtPath(NSString *path) ;

MSFoundationExport const unsigned char *bmh_memmem(const unsigned char *haystack, size_t hlen, const unsigned char *needle, size_t nlen) ;

#ifdef WIN32
MSFoundationExport char *strtok_r(char *s, const char *delim, char **last) ;
MSFoundationExport char *strnstr(const char *s1, const char *s2, size_t n) ;
#endif

