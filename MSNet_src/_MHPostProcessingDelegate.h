//
//  _MHPostProcessingDelegate.h
//  MSFoundation
//
//  Created by Geoffrey Guilbon on 21/01/13.
//
//
@class MHResource ;

@interface MHPostProcessingDelegate : NSObject

- (BOOL)postProcessInput:(MHDownloadResource *)input
          withParameters:(MHDownloadResource *)parameters
        toOutputResource:(MHDownloadResource **)output
 andToOutputHTMLResource:(MHDownloadResource **)html
usingExternalExecutablesDefinitions:(NSDictionary *)exeDefinitions
            postedValues:(NSDictionary *)values;

@end
