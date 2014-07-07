/*
 
 _MHResourcePrivate.m
 
 This file is is a part of the MicroStep Application Server over Http Framework.
 
 Initial copyright LOGITUD Solutions (logitud@logitud.fr) since 2012
 
 Herve Malaingre : herve@malaingre.com
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 Geoffrey Guilbon : gguilbon@gmail.com
 
 
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

@implementation MHResource (Private)

- (void)setURL:(NSString *)url { ASSIGN(_url, [url stringWithURLEncoding:NSISOLatin1StringEncoding]) ; }

- (MSLong)bigResourceSize { return MHRESOURCE_BIGRESOURCE_LENGTH ; }
- (BOOL)isBigResource { return [self size] > MHRESOURCE_BIGRESOURCE_LENGTH ; }
- (void)setValidityDuration:(MSULong)duration { _validityDuration = duration ; }

- (void)setResourcePathOndisk:(NSString *)path { ASSIGN(_resourcePathOndisk, path); }
- (void)destroyBuffer { DESTROY(_buffer) ; }

- (MHApplication *)application { return _application ; }
- (NSString *)resourcePathOndisk { return _resourcePathOndisk ; }
- (BOOL)isInitWithBigFile { return _isInitWithBigFile ; }
- (BOOL)mustDeleteFileOnCLean { return _deleteFileOnCLean ; }
- (void)setMustDeleteFileOnCLean:(BOOL)deleteFile { _deleteFileOnCLean = deleteFile ; }

- (BOOL)useOnce { [self notImplemented:_cmd] ; return NO ; }

- (MSULong)validityDuration { return _validityDuration ; }

@end

@implementation MHDownloadResource (Private)

- (void)setUseOnce:(BOOL)useOnce { _useOnce = useOnce ; }
- (BOOL)useOnce { return _useOnce ; }

- (void)setParentResource:(MHResource *)resource { ASSIGN(_parentResource, resource) ; }
- (void)setChildrenResources:(NSArray *)resources
{
    NSEnumerator *e = [resources objectEnumerator] ;
    MHDownloadResource *resource ;
    
    ASSIGN(_childrenResources, resources) ;
    
    while ((resource = [e nextObject]))
        [resource setParentResource:self] ;
    
}

- (NSString *)baseDirPathOndisk { return _baseDirPathOndisk ; }
- (void)setBaseDirPathOndisk:(NSString *)baseDir { ASSIGN(_baseDirPathOndisk, baseDir) ; }

@end

@implementation MHUploadResource (Private)

- (BOOL)useOnce { return YES ; }

- (BOOL)isBigResource { return [self expectedSize] > MHRESOURCE_BIGRESOURCE_LENGTH ; }

@end
