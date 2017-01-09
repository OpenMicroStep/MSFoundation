#import "FoundationCompatibility_Private.h"

@implementation NSFileHandle {
	int _fd;
	BOOL _closeOnDealloc;
	uint64_t _offset;
}

static NSFileHandle * __fileHandleWithStandardError= nil;
static NSFileHandle * __fileHandleWithStandardInput= nil;
static NSFileHandle * __fileHandleWithStandardOutput= nil;
static NSFileHandle * __fileHandleWithNullDevice= nil;

static inline id _fileHandleForAtPath(int mode, NSString *path)
{
  NSFileHandle *ret= nil; uv_fs_t req; int fd;
  fd= uv_fs_open(uv_default_loop(), &req, [path UTF8String], mode, 0, NULL);
  if(fd >= 0)
    ret= AUTORELEASE([ALLOC(NSFileHandle) initWithFileDescriptor:fd]);
  uv_fs_req_cleanup(&req);
  return ret;
}

+ (void)load {
  __fileHandleWithStandardInput=  [ALLOC(NSFileHandle) initWithFileDescriptor:0];
  __fileHandleWithStandardOutput= [ALLOC(NSFileHandle) initWithFileDescriptor:1];
  __fileHandleWithStandardError=  [ALLOC(NSFileHandle) initWithFileDescriptor:2];
  __fileHandleWithNullDevice=     [ALLOC(NSFileHandle) initWithFileDescriptor:-1];
}

+ (instancetype)fileHandleForReadingAtPath:(NSString *)path
{ return _fileHandleForAtPath(O_RDONLY, path); }
+ (instancetype)fileHandleForWritingAtPath:(NSString *)path
{ return _fileHandleForAtPath(O_WRONLY, path); }
+ (instancetype)fileHandleForUpdatingAtPath:(NSString *)path
{ return _fileHandleForAtPath(O_RDWR, path); }
+ (NSFileHandle *)fileHandleWithStandardError
{ return __fileHandleWithStandardError; }
+ (NSFileHandle *)fileHandleWithStandardInput
{ return __fileHandleWithStandardInput; }
+ (NSFileHandle *)fileHandleWithStandardOutput
{ return __fileHandleWithStandardOutput; }
+ (NSFileHandle *)fileHandleWithNullDevice
{ return __fileHandleWithNullDevice; }

- (id)initWithFileDescriptor:(int)fileDescriptor
{ return [self initWithFileDescriptor:fileDescriptor closeOnDealloc:YES]; }
- (id)initWithFileDescriptor:(int)fileDescriptor closeOnDealloc:(BOOL)flag
{
  _fd= fileDescriptor;
  _closeOnDealloc= flag;
  return self;
}

- (void)dealloc
{
  if(_closeOnDealloc)
    [self closeFile];
  [super dealloc];
}

- (NSData *)availableData
{
  return [self readDataToEndOfFile];
}
- (NSData *)readDataOfLength:(NSUInteger)length
{
  CBuffer *cbuf; uv_fs_t req; uv_buf_t buf;
  cbuf= CCreateBuffer(length);
  CBufferGrow(cbuf, length, NO);
  buf.base= (char *)CBufferBytes(cbuf);
  buf.len= CBufferLength(cbuf);
  uv_fs_read(uv_default_loop(), &req, _fd, &buf, 1, _offset, NULL);
  _offset += buf.len;
  uv_fs_req_cleanup(&req);
  return (NSData *)cbuf;
}
- (NSData *)readDataToEndOfFile
{
    uv_fs_t req; uint64_t size;
    uv_fs_fstat(uv_default_loop(), &req, _fd, NULL);
    size= req.statbuf.st_size;
    uv_fs_req_cleanup(&req);
    return [self readDataOfLength:size];
}

- (void)writeData:(NSData *)data
{
    uv_fs_t req;
    uv_buf_t buf;
    buf.base= (char *)[data bytes];
    buf.len= [data length];
    uv_fs_write(uv_default_loop(), &req, _fd, &buf, 1, _offset, NULL);
    _offset += buf.len;
    uv_fs_req_cleanup(&req);
}

- (unsigned long long)offsetInFile
{ return _offset; }

- (unsigned long long)seekToEndOfFile
{
    uv_fs_t req;
    uv_fs_fstat(uv_default_loop(), &req, _fd, NULL);
    _offset= req.statbuf.st_size;
    uv_fs_req_cleanup(&req);
    return _offset;
}

- (void)seekToFileOffset:(unsigned long long)offset
{ _offset= offset; }

- (void)closeFile
{
    uv_fs_t req;
    uv_fs_close(uv_default_loop(), &req, _fd, NULL);
    uv_fs_req_cleanup(&req);
}

- (void)synchronizeFile
{
    uv_fs_t req;
    uv_fs_fsync(uv_default_loop(), &req, _fd, NULL);
    uv_fs_req_cleanup(&req);
}

- (void)truncateFileAtOffset:(unsigned long long)offset
{
    uv_fs_t req;
    uv_fs_ftruncate(uv_default_loop(), &req, _fd, offset, NULL);
    uv_fs_req_cleanup(&req);
}

@end