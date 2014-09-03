NAME = MSNet_src

PROJECT_TYPE = Component
MAKEFILE = subproj.make

SUBPROJECTS = Crypto_src

HFILES = MHApplication.h MHApplicationClient.h MHApplicationClientPrivate.h MHBunchableObject.h MHHTTPMessage.h MHLogging.h MHNotification.h MHPublicProtocols.h MHResource.h MHSSLSocket.h MHServer.h MSCurlHandler.h MSCurlInterface_Private.h MSCurlSendMail.h MSHTTPRequest.h MSHTTPResponse.h MSJSONEncoder.h MSNet.h MSNetWin32.h MSNet_Private.h _CHTTPMessagePrivate.h _CNotificationPrivate.h _MHAdminApplication.h _MHApplicationPrivate.h _MHBunchAllocatorPrivate.h _MHBunchRegisterPrivate.h _MHContext.h _MHHTTPMessagePrivate.h _MHNotificationPrivate.h _MHOpenSSLPrivate.h _MHPostProcessingDelegate.h _MHQueuePrivate.h _MHResourcePrivate.h _MHSSLSocketPrivate.h _MHServerPrivate.h _MHSession.h _MHThreadPrivate.h

MFILES = MHApplication.m MHApplicationClient.m MHApplicationClientPrivate.m MHBunchableObject.m MHHTTPMessage.m MHLogging.m MHNotification.m MHResource.m MHSSLSocket.m MHServer.m MSCurlHandler.m MSCurlInterface_Private.m MSCurlSendMail.m MSHTTPRequest.m MSHTTPResponse.m MSJSONEncoder.m _MHAdminApplication.m _MHApplicationPrivate.m _MHBunchAllocatorPrivate.m _MHBunchRegisterPrivate.m _MHContext.m _MHHTTPMessagePrivate.m _MHNotificationPrivate.m _MHOpenSSLPrivate.m _MHPostProcessingDelegate.m _MHQueuePrivate.m _MHResourcePrivate.m _MHSSLSocketPrivate.m _MHServerPrivate.m _MHSession.m _MHThreadPrivate.m

PUBLIC_HEADERS = MHApplication.h MHApplicationClient.h MHBunchableObject.h MHHTTPMessage.h MHLogging.h MHNotification.h MHPublicProtocols.h MHResource.h MHSSLSocket.h MHServer.h MSCurlHandler.h MSCurlSendMail.h MSHTTPRequest.h MSHTTPResponse.h MSJSONEncoder.h MSNet.h MSNetWin32.h _MHAdminApplication.h _MHContext.h _MHPostProcessingDelegate.h _MHSession.h

HEADER_PATHS = -I../3rdparty/wo451/include -I../MHMessenger_src -I../MHRepositoryServer_src -I../MSCore_src -I../MSCore_src/MAPM_src -I../MSFoundation_Basics_src -I../MSFoundation_src -ICrypto_src

include $(MAKEFILEDIR)/platform.make
include $(MAKEFILEDIR)/$(MAKEFILE)
