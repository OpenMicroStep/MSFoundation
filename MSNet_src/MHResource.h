/*
 
 MHResource.h
 
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

#define MHRESOURCE_INFINITE_LIFETIME 0
#define MHRESOURCE_USEONCE_LIFETIME 60
#define MHRESOURCE_SHORT_LIFETIME 3600
#define MHRESOURCE_LONG_LIFETIME 86400


@class MSBuffer ;

@interface MHResource : NSObject
{
    NSString *_url ;
    NSString *_name ;
    NSString *_mimeType ;
    MSBuffer *_buffer ;
    MSTimeInterval _firstActivity ;
    
    BOOL _isCached ;

    MSULong _validityDuration ;
    NSString *_resourcePathOndisk ;
    BOOL _isInitWithBigFile ;
    BOOL _deleteFileOnCLean ;

    MSLong _size;
    MHApplication *_application ;
}

- (NSString *)url ;
- (NSString *)name ;
- (void)setName:(NSString *)name ;
- (NSString *)mimeType ;
- (void)setMimeType:(NSString *)mimeType ;
- (MSTimeInterval)firstActivity ;
- (void)setIsCached ;
- (BOOL)isCached ;
- (BOOL)isCachedOnDisk ;
- (BOOL)isValid ;
- (MSBuffer *)buffer ;
- (MSLong)size ;

@end

@interface MHDownloadResource : MHResource
{
    MSTimeInterval _lastActivity ;
    BOOL _useOnce ;
    NSArray *_childrenResources ;
    MHResource *_parentResource ;
    NSString *_baseDirPathOndisk ;    
}
+ (id)resourceWithBuffer:(MSBuffer *)buffer name:(NSString *)name mimeType:(NSString *)mimeType forApplication:(MHApplication *)application ;
- (id)initWithBuffer:(MSBuffer *)buffer name:(NSString *)name mimeType:(NSString *)mimeType forApplication:(MHApplication *)application ;

+ (id)resourceWithContentsOfFile:(NSString *)path name:(NSString *)name mimeType:(NSString *)mimeType forApplication:(MHApplication *)application ;
+ (id)resourceWithContentsOfFile:(NSString *)path name:(NSString *)name mimeType:(NSString *)mimeType forApplication:(MHApplication *)application deleteFileOnClean:(BOOL)deleteFileOnClean ;
- (id)initWithContentsOfFile:(NSString *)path name:(NSString *)name mimeType:(NSString *)mimeType forApplication:(MHApplication *)application  deleteFileOnClean:(BOOL)deleteFileOnClean ;

+ (NSString *)publicResourceURLComponent ;
+ (NSString *)authenticatedResourceURLComponent ;
+ (NSString *)resourceUNCURLComponent ;

- (MSTimeInterval)lastActivity ;
- (NSArray *)childrenResources ;
- (MHResource *)parentResource ;
- (BOOL)isParentResource ;

- (void)touch ;


@end

typedef enum {
	UPLOAD_REQUESTED = 0,
	UPLOAD_PROGRESS,
	UPLOAD_COMPLETED,
	UPLOAD_ERROR,
	UPLOAD_UNKNOWN_ID
} MHUploadResourceStatus ;

@interface MHUploadResource : MHResource
{
    MSFileHandle _fd ;
    BOOL _isValidFD ;
    MHUploadResourceStatus _status ;
    MSULong _expectedSize ;
    MSULong _receivedSize ;
    MSULong _receivedSizeWithBoundary ;
}

+ (id)resourceWithUploadIdentifier:(NSString *)upId forApplication:(MHApplication *)application ;
- (id)initWithUploadIdentifier:(NSString *)upId forApplication:(MHApplication *)application ;

+ (NSString *)uploadPathComponent ;

- (BOOL)addBytes:(void *)bytes length:(NSUInteger)length boundaryLength:(NSUInteger)boundaryLength ;
- (BOOL)cancelUpload ;
- (NSString *)storeToDiskInDir:(NSString *)path ;
- (NSString *)storeToDiskInDir:(NSString *)path withName:(NSString*)name;

- (MHUploadResourceStatus)status ;
- (void)setStatus:(MHUploadResourceStatus)status ;

- (MSULong)expectedSize ;
- (void)setExpectedSize:(MSULong)expectedSize ;

- (MSULong)receivedSize ;
- (MSULong)receivedSizeWithBoundary ;
@end



