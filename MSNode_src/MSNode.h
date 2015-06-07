#ifndef MSNODE_H
#define MSNODE_H

#import <MSFoundation/MSFoundation.h>
#define MSNodeExtern LIBIMPORT
#import <MSNode/MSAsync.h>
#import <MSNode/MSCipher.h>
#import <MSNode/MSDigest.h>
#import <MSNode/MSSecureHash.h>

#import <MSNode/MSNodeWorker.h>
#import <MSNode/MSHttpServer.h>
#import <MSNode/MSHttpTransaction.h>
#import <MSNode/MSHttpClientRequest.h>

#import <MSNode/MSHttpRouter.h>
#import <MSNode/MSHttpCookieMiddleware.h>
#import <MSNode/MSHttpMSTEMiddleware.h>
#import <MSNode/MSHttpSessionMiddleware.h>
#import <MSNode/MSHttpStaticFilesMiddleware.h>
#import <MSNode/MSHttpApplication.h>

MSNodeExtern NSString* MSHttpCodeName(MSHttpCode code);
MSNodeExtern NSString* MSHttpMethodName(MSHttpMethod method);
MSNodeExtern void* MSNodeSetTimeout(void (*cb)(void* context), double delay, void *context);
MSNodeExtern void MSNodeClearTimeout(void *timeout);
MSNodeExtern void* MSNodeSetInterval(void (*cb)(void* context), double delay, void *context);
MSNodeExtern void MSNodeClearInterval(void *interval);
MSNodeExtern int MSNodeStart(void (*cb)(void* context), void* context);
MSNodeExtern int MSNodeStartApplication(Class application, NSString *path, NSDictionary *parameters);
MSNodeExtern int MSNodeStartApplicationWithParametersPath(Class application, NSString *parametersPath);
#endif // MSNODE_H
