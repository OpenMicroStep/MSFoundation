#import "FoundationCompatibility_Private.h"

NSString * const NSFileType = @"NSFileType";
NSString * const NSFileSize = @"NSFileSize";
NSString * const NSFileModificationDate = @"NSFileModificationDate";
NSString * const NSFileReferenceCount = @"NSFileReferenceCount";
NSString * const NSFileDeviceIdentifier = @"NSFileDeviceIdentifier";
NSString * const NSFileOwnerAccountName = @"NSFileOwnerAccountName";
NSString * const NSFileGroupOwnerAccountName = @"NSFileGroupOwnerAccountName";
NSString * const NSFilePosixPermissions = @"NSFilePosixPermissions";
NSString * const NSFileSystemNumber = @"NSFileSystemNumber";
NSString * const NSFileSystemFileNumber = @"NSFileSystemFileNumber";
NSString * const NSFileExtensionHidden = @"NSFileExtensionHidden";
// NSString * const NSFileHFSCreatorCode = @"NSFileHFSCreatorCode";
// NSString * const NSFileHFSTypeCode = @"NSFileHFSTypeCode";
NSString * const NSFileImmutable = @"NSFileImmutable";
NSString * const NSFileAppendOnly = @"NSFileAppendOnly";
NSString * const NSFileCreationDate = @"NSFileCreationDate";
NSString * const NSFileOwnerAccountID = @"NSFileOwnerAccountID";
NSString * const NSFileGroupOwnerAccountID = @"NSFileGroupOwnerAccountID";
NSString * const NSFileBusy = @"NSFileBusy";

NSString * const NSFileTypeDirectory = @"NSFileTypeDirectory";
NSString * const NSFileTypeRegular = @"NSFileTypeRegular";
NSString * const NSFileTypeSymbolicLink = @"NSFileTypeSymbolicLink";
NSString * const NSFileTypeSocket = @"NSFileTypeSocket";
NSString * const NSFileTypeCharacterSpecial = @"NSFileTypeCharacterSpecial";
NSString * const NSFileTypeBlockSpecial = @"NSFileTypeBlockSpecial";
NSString * const NSFileTypeUnknown = @"NSFileTypeUnknown";

NSString * NSFileOwnerAccountNumber= @"NSFileOwnerAccountNumber";
NSString * NSFileGroupOwnerAccountNumber= @"NSFileGroupOwnerAccountNumber";

static NSFileManager *__defaultManager;
static once_flag __defaultManager_once = ONCE_FLAG_INIT;
static void __defaultManager_init() {
  __defaultManager= [NSFileManager new];
}

@interface NSDirectoryEnumerator (Private)
- (instancetype)_initWithPath:(NSString *)path;
@end

@implementation NSFileManager
+ (NSFileManager *)defaultManager
{
  call_once(&__defaultManager_once, __defaultManager_init);
  return __defaultManager;
}

- (NSString *)currentDirectoryPath
{
#ifdef WIN32
  /* MAX_PATH is in characters, not bytes. Make sure we have enough headroom. */
  char buffer[MAX_PATH * 4];
#else
  char buffer[PATH_MAX];
#endif
  size_t sz= sizeof(buffer);
  if(uv_cwd(buffer, &sz) == 0)
    return [NSString stringWithUTF8String:buffer];
  return nil;
}
- (BOOL)changeCurrentDirectoryPath:(NSString *)path
{
  return uv_chdir([path UTF8String]) == 0;
}

- (BOOL)createDirectoryAtPath:(NSString *)path attributes:(NSDictionary *)attributes
{ return [self createDirectoryAtPath:path withIntermediateDirectories:NO attributes:attributes error:NULL]; }

static BOOL _createDirectoryAtPath(const char *cpath, NSDictionary *attributes)
{
  uv_fs_t req; BOOL ret;
  ret= uv_fs_mkdir(uv_default_loop(), &req, cpath, 0777, NULL) == 0;
  uv_fs_req_cleanup(&req);
  //printf("mkdir %s %d\n", cpath, (int)ret);
  if (attributes) {
    NSDate *d; NSNumber *n1, *n2; uv_fs_t sreq;
    uv_fs_stat(uv_default_loop(), &sreq, cpath, NULL);
    if ((d= [attributes objectForKey:NSFileModificationDate])) {
      // TODO: uv_fs_utime(uv_default_loop(), &req, cpath, req.statbuf.st_atime -> double, double mtime, NULL);
    }
    if (ret && (n1= [attributes objectForKey:NSFilePosixPermissions])) {
      ret= uv_fs_chmod(uv_default_loop(), &req, cpath, [n1 intValue], NULL) == 0;
      uv_fs_req_cleanup(&req);
    }
#ifdef UNIX    
    if (ret && ((n1= [attributes objectForKey:NSFileGroupOwnerAccountNumber]) || (n2= [attributes objectForKey:NSFileOwnerAccountNumber]))) {
      uv_uid_t uid= n2 ? [n2 intValue] : req.statbuf.st_uid;
      uv_uid_t gid= n1 ? [n1 intValue] : req.statbuf.st_gid;
      ret= uv_fs_chown(uv_default_loop(), &req, cpath, uid, gid, NULL) == 0;
      uv_fs_req_cleanup(&req);
    }
#endif
    uv_fs_req_cleanup(&sreq);
  }
  return ret;
}
static inline BOOL _isPathSeparator(MSByte c)
{
#ifdef WIN32
  return c == '/' || c == '\\';
#else
  return c == '/';
#endif
}
- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)error
{
  BOOL ret= NO;
  if(!createIntermediates) {
    ret= _createDirectoryAtPath([path UTF8String], attributes); }
  else {
    NSUInteger i, len;
    CBuffer *b= CCreateBuffer(0);
    CBufferAppendSES(b, SESFromString(path), NSUTF8StringEncoding);
    ret= _createDirectoryAtPath((const char *)CBufferCString(b), attributes);
    if (!ret) {
      for (i= 0, len=CBufferLength(b); i < len; ++i) {
        if (_isPathSeparator(b->buf[i])) {
          b->buf[i]= '\0';
          ret= _createDirectoryAtPath((const char *)b->buf, attributes);
          b->buf[i] = '/';}}
      if (i < len) {
        ret= _createDirectoryAtPath((const char *)CBufferCString(b), attributes);}}
    RELEASE(b);
  }
  return ret;
}

- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)contents attributes:(NSDictionary *)attributes
{
  uv_fs_t req; BOOL ret; int fd; const char *cpath= [path UTF8String];
  fd= uv_fs_open(uv_default_loop(), &req, cpath, O_WRONLY | O_CREAT | O_TRUNC, 0777, NULL);
  ret= fd > 0;
  uv_fs_req_cleanup(&req);
  if (ret) {
    if (contents) {
      uv_buf_t buf;
      buf.base= (char *)[contents bytes];
      buf.len= [contents length];
      ret= uv_fs_write(uv_default_loop(), &req, fd, &buf, 1, 0, NULL) == buf.len;
      uv_fs_req_cleanup(&req);}
    ret= uv_fs_close(uv_default_loop(), &req, fd, NULL) == 0 && ret;
    uv_fs_req_cleanup(&req);
    if (attributes) {
      NSDate *d; NSNumber *n1, *n2; uv_fs_t sreq;
      uv_fs_fstat(uv_default_loop(), &sreq, fd, NULL);
      if ((d= [attributes objectForKey:NSFileModificationDate])) {
        // TODO: uv_fs_futime(uv_default_loop(), &req, fd, req.statbuf.st_atime -> double, double mtime, NULL);
      }
      if (ret && (n1= [attributes objectForKey:NSFilePosixPermissions])) {
        ret= uv_fs_fchmod(uv_default_loop(), &req, fd, [n1 intValue], NULL) == 0;
        uv_fs_req_cleanup(&req);
      }
#ifdef UNIX    
      if (ret && ((n1= [attributes objectForKey:NSFileGroupOwnerAccountNumber]) || (n2= [attributes objectForKey:NSFileOwnerAccountNumber]))) {
        uv_uid_t uid= n2 ? [n2 intValue] : req.statbuf.st_uid;
        uv_uid_t gid= n1 ? [n1 intValue] : req.statbuf.st_gid;
        ret= uv_fs_fchown(uv_default_loop(), &req, fd, uid, gid, NULL) == 0;
        uv_fs_req_cleanup(&req);
      }
#endif
      uv_fs_req_cleanup(&sreq);
    }
  }
  return ret;
}

- (NSDictionary*)attributesOfItemAtPath:(NSString *)path error:(NSError **)error
{
  uv_fs_t statreq; int res; const char *utf8Path= [path UTF8String];
  NSDictionary *ret= nil; NSString *filetype= NSFileTypeUnknown;
  res= uv_fs_stat(uv_default_loop(), &statreq, utf8Path, NULL);
  if (res == 0) {
    if ((statreq.statbuf.st_mode & S_IFREG) > 0)
      filetype= NSFileTypeRegular;
    else if ((statreq.statbuf.st_mode & S_IFDIR) > 0)
      filetype= NSFileTypeDirectory;
    else if ((statreq.statbuf.st_mode & S_IFLNK) > 0)
      filetype= NSFileTypeSymbolicLink;
#ifndef WIN32
    else if ((statreq.statbuf.st_mode & S_IFSOCK) > 0)
      filetype= NSFileTypeSocket;
    else if ((statreq.statbuf.st_mode & S_IFBLK) > 0)
      filetype= NSFileTypeBlockSpecial;
    else if ((statreq.statbuf.st_mode & S_IFCHR) > 0)
      filetype= NSFileTypeCharacterSpecial;
#endif

    ret= @{
      NSFileCreationDate: [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)statreq.statbuf.st_ctim.tv_sec],
      NSFileModificationDate: [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)statreq.statbuf.st_mtim.tv_sec],
      NSFilePosixPermissions: [NSNumber numberWithShort:(MSShort)(statreq.statbuf.st_mode & 0777)],
      NSFileSize: [NSNumber numberWithUnsignedLongLong:statreq.statbuf.st_size],
      NSFileType: filetype
    };
  }
  else if(error) {
    *error= FMT(@"%s", uv_strerror(res));
  }
  uv_fs_req_cleanup(&statreq);
  return ret;
}
- (BOOL)changeFileAttributes:(NSDictionary *)attributes atPath:(NSString *)path
{
  // @"NSFileModificationDate" nsdate
  // @"NSFilePosixPermissions" nsnumber
  [self notImplemented:_cmd];
  return NO;
}

- (NSData *)contentsAtPath:(NSString *)path
{
  uv_fs_t req; int fd, r; NSUInteger size; CBuffer *ret= NULL;
  fd= uv_fs_open(uv_default_loop(), &req, [path UTF8String], O_RDONLY, 0, NULL);
  uv_fs_req_cleanup(&req);
  if (fd >= 0) {
    if ((r= uv_fs_fstat(uv_default_loop(), &req, fd, NULL)) == 0)
      size= (NSUInteger)req.statbuf.st_size;
    uv_fs_req_cleanup(&req);
    if (r == 0) {
      uv_buf_t buf;
      ret= CCreateBuffer(size);
      CBufferGrow(ret, size, NO);
      buf.base= (char *)CBufferBytes(ret);
      buf.len= CBufferLength(ret);
      r= uv_fs_read(uv_default_loop(), &req, fd, &buf, 1, 0, NULL);
      uv_fs_req_cleanup(&req);
      if (r <= 0 || (NSUInteger)r != size)
        DESTROY(ret);
    }
    uv_fs_close(uv_default_loop(), &req, fd, NULL);
    uv_fs_req_cleanup(&req);
  }
  return AUTORELEASE(ret);
}

- (BOOL)contentsEqualAtPath:(NSString *)path1 andPath:(NSString *)path2
{
  [self notImplemented:_cmd];
  return NO;
}

static inline BOOL _fsaccess(NSString *path, int mode)
{
  uv_fs_t req; BOOL ret;
  ret= uv_fs_access(uv_default_loop(), &req, [path UTF8String], mode, NULL) == 0;
  uv_fs_req_cleanup(&req);
  return ret;
}
- (BOOL)isExecutableFileAtPath:(NSString *)path
{ return _fsaccess(path, X_OK); }
- (BOOL)isReadableFileAtPath:(NSString *)path
{ return _fsaccess(path, R_OK); }
- (BOOL)isWritableFileAtPath:(NSString *)path
{ return _fsaccess(path, W_OK); }
- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error
{
  uv_fs_t statreq, req; BOOL ret; const char *utf8Path= [path UTF8String];
  ret= uv_fs_stat(uv_default_loop(), &statreq, utf8Path, NULL) == 0;
  if (ret) {
    if (statreq.statbuf.st_mode & S_IFDIR) {
      NSString *subPath;
      NSDirectoryEnumerator *e= [ALLOC(NSDirectoryEnumerator) _initWithPath:path];
      [e skipDescendents];
      while (ret && (subPath= [e nextObject])) {
        ret= [self removeItemAtPath:[path stringByAppendingPathComponent:subPath] error:error];}
      [e release];
      if (ret) {
        ret= ret && uv_fs_rmdir(uv_default_loop(), &req, utf8Path, NULL) == 0;
        uv_fs_req_cleanup(&req);
        /*printf("rmdir %s %d\n", utf8Path, (int)ret);*/}}
    else {
      ret= uv_fs_unlink(uv_default_loop(), &req, utf8Path, NULL) == 0;
      uv_fs_req_cleanup(&req);
      /*printf("unlink %s %d\n", utf8Path, (int)ret);*/}
  }
  uv_fs_req_cleanup(&statreq);
  return ret;
}
- (NSDirectoryEnumerator *)enumeratorAtPath:(NSString *)path
{ return AUTORELEASE([ALLOC(NSDirectoryEnumerator) _initWithPath:path]); }

- (id)copyWithZone:(NSZone*)zone
{ return [self retain]; }
@end

@implementation NSDirectoryEnumerator
- (instancetype)_initWithPath:(NSString *)path
{
  if ((self= [super init])) {
    _path= [path retain];
    _uv_fs_req= MSMallocFatal(sizeof(uv_fs_t), "NSDirectoryEnumerator init");
    if(uv_fs_scandir(uv_default_loop(), (uv_fs_t*)_uv_fs_req, [path UTF8String], 0, NULL) != 0) {
      MSFree(_uv_fs_req, "NSDirectoryEnumerator init");
      _uv_fs_req= NULL;
      DESTROY(self);
    } 
  }
  return self;
}
- (void)dealloc
{
  if(_uv_fs_req)
    uv_fs_req_cleanup((uv_fs_t*)_uv_fs_req);
  MSFree(_uv_fs_req, "NSDirectoryEnumerator dealloc");
  [_child release];
  [_path release];
  [_base release];
  [_current release];
  [super dealloc];
}
- (id)nextObject
{
  uv_dirent_t ent; NSString *name= nil;
  if (_child && !(name= [_child nextObject]))
    DESTROY(_child);
  if (name) {
    name= [_base stringByAppendingPathComponent:name];}
  else {
    if (uv_fs_scandir_next((uv_fs_t*)_uv_fs_req, &ent) != UV_EOF) {
      name= [NSString stringWithUTF8String:ent.name];
      if(ent.type == UV_DIRENT_DIR && !_skipDescendents) {
        _child= [ALLOC(NSDirectoryEnumerator) _initWithPath:[_path stringByAppendingPathComponent:name]];
        ASSIGN(_base, name);}
    }
  }
  ASSIGN(_current, name);
  return name;
}
- (NSDictionary *)directoryAttributes
{
  [self notImplemented:_cmd];
  return nil;
}
- (NSDictionary *)fileAttributes
{
  [self notImplemented:_cmd];
  return nil;
}
- (void)skipDescendents
{
  _skipDescendents= YES;
}
@end