/*
 
 _MASHPrivate.h
 
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
 
 */

//#import <MSFoundation/MSFoundation.h>
#import "MSNet_Private.h"

#ifdef WO451

#ifdef __cplusplus
#define MASHExport					extern "C" __declspec(dllimport)
#define MASHImport					extern "C" __declspec(dllimport)
#define MASHPrivate					extern
#else
#define MASHExport					__declspec(dllexport) extern
#define MASHImport					__declspec(dllimport) extern
#define MASHPrivate					extern
#endif

#else

#ifdef __cplusplus
#define MASHExport					extern "C"
#define MASHImport					extern "C"
#define MASHPrivate					extern "C"
#else
#define MASHExport					extern
#define MASHImport					extern
#if defined(MAC_OS_X_VERSION_MAX_ALLOWED)
#define MASHPrivate					extern
#else
#define MASHPrivate					__private_extern__
#endif
#endif

#endif

#import "_MHThreadPrivate.h"
#import "_MHOpenSSLPrivate.h"
#import "MHSSLSocket.h"
#import "_MHSSLSocketPrivate.h"
#import "_MHQueuePrivate.h"
#import "MHLogging.h"
#import "_MHBunchAllocatorPrivate.h"
#import "_MHBunchRegisterPrivate.h"
#import "_MHQueuePrivate.h"

#import "MHPublicProtocols.h"

#import "MHBunchableObject.h"
#import "MHHTTPMessage.h"
#import "_MHHTTPMessagePrivate.h"
#import "_CHTTPMessagePrivate.h"
#import "MHApplication.h"
#import "_MHApplicationPrivate.h"
#import "MHNotification.h"
#import "_MHNotificationPrivate.h"
#import "_MHContext.h"
#import "_MHSession.h"
#import "_MHServerPrivate.h"

#import "_CNotificationPrivate.h"
#import "MHResource.h"
#import "_MHResourcePrivate.h"
#import "_MHPostProcessingDelegate.h"

#import "_MHAdminApplication.h"
//#import "MHNetRepositoryApplication.h"
#import "MHMessengerMessage.h"
#import "_MHMessengerMessagePrivate.h"

#import "MHServer.h"

#import "MHApplicationClient.h"
#import "MHCertificateAdditions.h"

#import "MHApplicationClient.h"
#import "MHMessengerClient.h"
//#import "MHNetRepositoryClient.h"
