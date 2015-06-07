#ifndef MSNODE_PUBLIC_H
#define MSNODE_PUBLIC_H

#import <MSFoundation/MSFoundation.h>
#define MSNodeExtern LIBEXPORT

#import "MSAsync.h"
#import "MSCipher.h"
#import "MSDigest.h"
#import "MSSecureHash.h"

#import "MSNodeWorker.h"
#import "MSHttpServer.h"
#import "MSHttpTransaction.h"
#import "MSHttpClientRequest.h"

#import "MSHttpRouter.h"
#import "MSHttpCookieMiddleware.h"
#import "MSHttpMSTEMiddleware.h"
#import "MSHttpSessionMiddleware.h"
#import "MSHttpStaticFilesMiddleware.h"
#import "MSHttpApplication.h"

MSNodeExtern NSString* MSHttpCodeName(MSHttpCode code);
MSNodeExtern NSString* MSHttpMethodName(MSHttpMethod method);
MSNodeExtern void* MSNodeSetTimeout(void (*cb)(void* context), double delay, void *context);
MSNodeExtern void MSNodeClearTimeout(void *timeout);
MSNodeExtern void* MSNodeSetInterval(void (*cb)(void* context), double delay, void *context);
MSNodeExtern void MSNodeClearInterval(void *interval);
MSNodeExtern int MSNodeStart(void (*cb)(void* context), void* context);
MSNodeExtern int MSNodeStartApplication(Class application, NSString *path, NSDictionary *parameters);
MSNodeExtern int MSNodeStartApplicationWithParametersPath(Class application, NSString *parametersPath);
#endif // MSNODE_PUBLIC_H
