/*
 
 MHResource.m
 
 This file is is a part of the MicroStep Application Server over Http Framework.
 
 Initial copyright LOGITUD Solutions (logitud@logitud.fr) since 2012
 
 Herve Malaingre : herve@malaingre.com
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 
 
 This software is a computer program whose purpose is to [describe
 functionalities and technical features of your software].
 
 This software is governed by the CeCILL-C license under French law and
 abiding by the rules of distribution of free software.  You can  use, 
 modify and/ or redistribute the software under the terms of the CeCILL-C
 license as circulated by CEA, CNRS and INRIA at the following URL
 "http://www.cecill.info". 
 
 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability. 
 
 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or 
 data to be ensured and,  more generally, to use and operate it in the 
 same conditions as regards security. 
 
 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL-C license and that you accept its terms.
 
 A Special homage to Steve Jobs who permits the Objective-C technology
 to meet the world. Without him, this years-long work should not have
 been existing at all. Thank you Steve and rest in peace.
 
 */

#import "MSNet_Private.h"

static NSDictionary *__mimeTypes = nil ;

@implementation MHResource

+ (id)alloc { return MSCreateObject([self class]) ; }
+ (id)allocWithZone:(NSZone *)zone { return MSAllocateObject([self class], 0, zone) ; }
+ (id)new { return MSCreateObject([self class]) ; }

- (void)dealloc
{
    DESTROY(_url) ;
    DESTROY(_mimeType) ;
    DESTROY(_buffer) ;
    DESTROY(_resourcePathOndisk) ;
    DESTROY(_application) ;
    
    [super dealloc] ;
}

- (id)init
{
    _firstActivity = GMTNow() ;
    _validityDuration = MHRESOURCE_SHORT_LIFETIME ;
    _size = [_buffer length] ;
    _isInitWithBigFile = NO ;
    [self setMustDeleteFileOnCLean:NO] ;
    
    return self ;
}

- (MSBuffer *)buffer
{
    if( !_buffer && [_resourcePathOndisk length])
    {
        MHServerLogWithLevel(MHLogDebug, @"loading cache buffer from disk for url '%@'",[self url]) ;
        
        if (!(_buffer = [MSBuffer bufferWithContentsOfFile:_resourcePathOndisk]))
        {
            MHServerLogWithLevel(MHLogError, @"failed reading buffer from disk cache at '%@'",_resourcePathOndisk) ;
        } else
        {
            MHServerLogWithLevel(MHLogDebug, @"buffer loaded from disk cache at '%@'",_resourcePathOndisk) ;
        }
        
        RETAIN(_buffer) ;
    }
    return _buffer ;
}

- (NSString *)url { return _url ; }
- (NSString *)name { return _name ; }
- (void)setName:(NSString *)name { ASSIGN(_name, name) ; }
- (NSString *)mimeType { return _mimeType ; }
- (void)setMimeType:(NSString *)mimeType { ASSIGN(_mimeType, mimeType) ; }

- (MSTimeInterval)firstActivity { return _firstActivity ; }

- (void)setIsCached { _isCached = YES ; }
- (BOOL)isCached {return _isCached ; }

- (BOOL)isCachedOnDisk { return _resourcePathOndisk ? YES : NO ; }

- (MSLong)size { return _size ; }

- (BOOL)isValid { return NO ; }

@end

@implementation MHDownloadResource

+ (void)initialize
{
    if(!__mimeTypes) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"mimeTypes" ofType:@"plist"] ;
        __mimeTypes = [[NSDictionary dictionaryWithContentsOfFile:path] retain] ;
        if (!__mimeTypes) {
            [NSException raise:NSGenericException format:@"Impossible to load mimeTypes.plist file at path \"%@\"", path] ;
        }
    }
}

- (void)dealloc
{
    DESTROY(_parentResource) ;
    DESTROY(_childrenResources) ;
    DESTROY(_baseDirPathOndisk) ;
    
    [super dealloc] ;
}

- (id)init
{
    if ((self = [super init]))
    {
        _lastActivity = _firstActivity ;
        return self ;
    }
    
    return nil ;
}

- (id)_initWithName:(NSString *)name mimeType:(NSString *)mimeType forApplication:(MHApplication *)application deleteFileOnClean:(BOOL)deleteFileOnClean
{
    if ([name length] && application)
    {
        if(!mimeType)
        {
            NSString * ext = [name pathExtension] ;
            
            if([__mimeTypes objectForKey:ext]){
                ASSIGN(_mimeType,[__mimeTypes objectForKey:ext]);
            }
            else{
                ASSIGN(_mimeType,@"text/plain");
            }
        }
        else
        {
            ASSIGN(_mimeType, mimeType) ;
        }
        
        ASSIGN(_name, name) ;
		ASSIGN(_application, application) ;
        [self setMustDeleteFileOnCLean:deleteFileOnClean] ;
        
        return [self init] ;
    }
    return nil ;
}

+ (id)resourceWithBuffer:(MSBuffer *)buffer name:(NSString *)name mimeType:(NSString *)mimeType forApplication:(MHApplication *)application
{
    NSString *compatibleName = [name replaceOccurrencesOfString:@"\\" withString:@"/"] ;
    return [[[self alloc] initWithBuffer:buffer name:compatibleName mimeType:mimeType forApplication:application] autorelease] ;
}

- (id)initWithBuffer:(MSBuffer *)buffer name:(NSString *)name mimeType:(NSString *)mimeType forApplication:(MHApplication *)application
{
    if (buffer && [self _initWithName:name mimeType:mimeType forApplication:application deleteFileOnClean:NO])
    {
        ASSIGN(_buffer, buffer) ;
        _size = [buffer length] ;
        return self ;
    }
    return nil ;
}

- (id)initWithContentsOfFile:(NSString *)path name:(NSString *)name mimeType:(NSString *)mimeType forApplication:(MHApplication *)application deleteFileOnClean:(BOOL)deleteFileOnClean
{
    if ([path length])
    {
        BOOL isDir = NO ;
        MSLong fileSize = 0 ;
        
        if (! (MSFileExistsAtPath(path, &isDir) && !isDir))
        {
            MSRaise(NSGenericException, @"cannot create MHResource. file '%@' does not exist", path) ;
        }
        
        if (! MSGetFileSize(path, &fileSize))
        {
            MSRaise(NSGenericException, @"cannot create MHResource. could not get file size for '%@'", path) ;
        }
        
        if (fileSize >= [self bigResourceSize]) //can be used because _size is defined
        {
            if ([self _initWithName:name mimeType:mimeType forApplication:application deleteFileOnClean:deleteFileOnClean])
            {
                _isInitWithBigFile = YES ;
                ASSIGN(_resourcePathOndisk, path) ;
                _size = fileSize ;
                return self ;
            }
        }else
        {
            id ret;
            MSBuffer *buffer = [ALLOC(MSBuffer) initWithContentsOfFile:path] ;
            if(!buffer) MSRaise(NSGenericException, @"cannot create MHResource from data with file '%@'", path) ;
            ret = [self initWithBuffer:buffer name:name mimeType:mimeType forApplication:application] ;
            RELEASE(buffer) ;
            return ret ;
        }
    }
    return nil ;

}

+ (id)resourceWithContentsOfFile:(NSString *)path name:(NSString *)name mimeType:(NSString *)mimeType forApplication:(MHApplication *)application deleteFileOnClean:(BOOL)deleteFileOnClean
{
    return [[[self alloc] initWithContentsOfFile:path name:name mimeType:mimeType forApplication:application deleteFileOnClean:deleteFileOnClean] autorelease] ;
}

+ (id)resourceWithContentsOfFile:(NSString *)path name:(NSString *)name mimeType:(NSString *)mimeType forApplication:(MHApplication *)application
{
    return [[[self alloc] initWithContentsOfFile:path name:name mimeType:mimeType forApplication:application deleteFileOnClean:NO] autorelease] ;
}

+ (NSString *)publicResourceURLComponent
{
    return RESOURCE_PUBLIC_URL_COMPONENT ;
}

+ (NSString *)authenticatedResourceURLComponent
{
    return RESOURCE_AUTHENTICATED_URL_COMPONENT ;
}

+ (NSString *)resourceUNCURLComponent
{
    return RESOURCE_URL_UNC_COMPONENT ;
}

- (MSTimeInterval)lastActivity { return _lastActivity ; }

- (NSArray *)childrenResources { return _childrenResources ; }
- (MHResource *)parentResource { return _parentResource ; }
- (BOOL)isParentResource { return (_parentResource == nil) ; }

/* resource is valid if it is a children resource.
 resource is valid if it is a parent resource within duration limits.
 else resource is not valid.
 Destruction of a father resoure, destructs chilren too
 */

- (BOOL)isValid
{
    if (_parentResource || (_validityDuration == MHRESOURCE_INFINITE_LIFETIME)) return YES ; //children resource or infinite resource
    
    return (_lastActivity + _validityDuration) >= GMTNow() ;
}


- (void)touch { _lastActivity = GMTNow() ; }


@end


@implementation MHUploadResource

+ (id)resourceWithUploadIdentifier:(NSString *)upId forApplication:(MHApplication *)application
{
    return [[[self alloc] initWithUploadIdentifier:upId forApplication:application] autorelease] ;
}

- (id)initWithUploadIdentifier:(NSString *)upId forApplication:(MHApplication *)application
{
    if ((self = [super init]))
    {
        _status = UPLOAD_REQUESTED ;
        _expectedSize = 0 ;
        _receivedSize = 0 ;
        _fd = 0 ;
        _isValidFD = NO ;
        
        //make url : /ville/group/app/upload/uploadId
        [self setURL:[[[application baseURL] stringByAppendingURLComponent:RESOURCE_UPLOAD_URL_COMPONENT] stringByAppendingURLComponent:upId]] ;

        return self ;
    }

    return nil ;
}

+ (NSString *)uploadPathComponent
{
    return RESOURCE_UPLOAD_URL_COMPONENT ;
}

- (void)_closeFd
{
    MH_LOG_ENTER(@"_closeFd")
    if(_fd && _isValidFD)
    {
#ifndef WIN32
        if(fsync(_fd)) { _isValidFD = NO ; MSRaise(NSGenericException, @"MHUploadResource _closeFd : fsync() error") ; }
#endif
        if (MSFileOperationFail == MSCloseFile(_fd)) { _isValidFD = NO ; MSRaise(NSGenericException, @"MHUploadResource _closeFd : close() error") ; }
        _isValidFD = NO ;
    }
    
    MH_LOG_LEAVE(@"_closeFd")
}

- (void)dealloc
{
    [self _closeFd] ;
    [super dealloc] ;
}

- (BOOL)isValid
{

    if(_status == UPLOAD_ERROR || _status == UPLOAD_UNKNOWN_ID)
    {
        return NO ;
    }
    else
    {
        return (_firstActivity + _validityDuration) >= GMTNow() ;
    }
}

- (BOOL)addBytes:(void *)bytes length:(NSUInteger)length boundaryLength:(NSUInteger)boundaryLength 
{
    BOOL success = YES ;
    
    if(!_expectedSize) MSRaise(NSInternalInconsistencyException, @"MHUploadResource addBytes : must call 'setExpectedSize' before using the method") ;

    if([self isBigResource]) //store to file
    {
        if(!_fd) //first time, create file on disk
        {
            ASSIGN(_resourcePathOndisk, MHMakeTemporaryFileName()) ;
            _fd = MSCreateFileForWritingAtPath(_resourcePathOndisk) ;
            if(_fd == MSInvalidFileHandle)
            {
                _status = UPLOAD_ERROR ;
                success = NO ;
                //_isValidFD = NO (init)
            }
            else
            {
                _isValidFD = YES ;
                _status = UPLOAD_PROGRESS ;
                _firstActivity = GMTNow() ;
            }
        }
        
        if(!_isValidFD) { success = NO ; }

        if(success) {
            if (MSFileOperationFail == MSWriteToFile(_fd, bytes, length)) {
                _status = UPLOAD_ERROR ;
                success = NO ;
            }
        }
    }
    else // store to memory
    {
        if (!_buffer) {
            _buffer = MSCreateBufferWithBytes((void *)bytes, length);
            success = (_buffer != nil) ;
        }
        else {
            CBufferAppendBytes((CBuffer *)_buffer, bytes, length) ;
        }
    }

    if(success) {
        _receivedSize += length ;
        _receivedSizeWithBoundary += (length + boundaryLength) ;

        if(_receivedSizeWithBoundary == _expectedSize)
        {
            _status = UPLOAD_COMPLETED ;
            _firstActivity = GMTNow() ;
        }
        else if(_receivedSizeWithBoundary > _expectedSize)
        {
            _status = UPLOAD_ERROR ;
            success = NO ;
        }
    }
    return success ;
}


- (BOOL)cancelUpload
{
    _status = UPLOAD_ERROR ;
    [self _closeFd] ; //force write sync and close to be deletion-ready
    
    return YES ;
}

- (NSString *)storeToDiskInDir:(NSString *)path { return [self storeToDiskInDir:path withName:_name] ; }


- (NSString *)storeToDiskInDir:(NSString *)path withName:(NSString*)name
{
    BOOL isDir ;
    NSString *completePath = [path stringByAppendingPathComponent:name] ;
    

    // directory creation if needed
    if(MSFileExistsAtPath(path, &isDir))
    {
        if(!isDir)
        {
            MHServerLogWithLevel(MHLogError, @"Failed to move resource : canont create dir in '%@', a file already exist with that name", path) ;
            return nil ;
        }
    }else
    {
        if(! MSCreateRecursiveDirectory(path))
        {
            MHServerLogWithLevel(MHLogError, @"Failed to move resource : canont create dir in '%@'", path) ;
            return nil ;
        }
    }

    //search a unique name for the file, including date and increment if needed
    if(MSFileExistsAtPath(completePath, &isDir))
    {
        NSString *fileExtention = [name pathExtension] ;
        int increment = 1 ;
        NSString *dateDesc = GMTdescriptionRfc1123(GMTNow());
        NSString *fileName = [NSString stringWithFormat:@"%@_%@",[name stringByDeletingPathExtension], dateDesc] ;

        completePath = [path stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:fileExtention]] ;

        while(MSFileExistsAtPath(completePath, &isDir))
        {
            fileName = [NSString stringWithFormat:@"%@_%d", fileName, increment++] ;
            completePath = [path stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:fileExtention]] ;
        }
    }

    //move file
    if([_resourcePathOndisk length]) // move fd
    {
        if(MSMoveFile(_resourcePathOndisk, completePath) == MSFileOperationFail)
        {
            MHServerLogWithLevel(MHLogError, @"Failed to move resource : cannot move file '%@' to '%@'", _resourcePathOndisk, completePath) ;
            return nil ;
        }
        RELEASE(_resourcePathOndisk) ;
    }
    else //write buffer to file
    {
        if (![_buffer writeToFile:completePath atomically:NO]) {
            MHServerLogWithLevel(MHLogError, @"Failed to move resource : cannot save file to '%@'", completePath) ;
            return nil ;
        }
    }

    return completePath ;
}

- (MHUploadResourceStatus)status { return _status ; }
- (void)setStatus:(MHUploadResourceStatus)status {
    _status = status ;
    
    switch (_status) {
        case UPLOAD_COMPLETED:
            [self _closeFd] ;
            _receivedSizeWithBoundary = _expectedSize ;
            break;
        case UPLOAD_ERROR:
            [self _closeFd] ;
            break;
        default:
            break;
    }
}

- (MSULong)expectedSize { return _expectedSize ; }
- (void)setExpectedSize:(MSULong)expectedSize { _size = _expectedSize = expectedSize ; }

- (MSULong)receivedSize { return _receivedSize ; }
- (MSULong)receivedSizeWithBoundary { return _receivedSizeWithBoundary ; }


@end
