/*
 
 MHServer.m
 
 This file is is a part of the MicroStep Application Server over Http Framework.
 
 Initial copyright LOGITUD Solutions (logitud@logitud.fr) since 2012
 
 Herve Malaingre : herve@malaingre.com
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 Nicolas Surribas : nicolas.surribas@gmail.com
 
 
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
#import "_MHServerPrivate.h"

static MSUInt MHStartServer(NSArray *params, Class staticApplication)
{
    MSInt error ;

    // Initialize server
#ifdef WO451
    [[NSRunLoop currentRunLoop] configureAsServer] ;
#endif
    
    error = MHServerInitialize(params, staticApplication) ;
    if (error != EXIT_SUCCESS) return error ;
    
    return MHMainThread() ;
}

MSUInt MHStartBundleServer(NSArray *params) { return MHStartServer(params, nil) ; }
MSUInt MHStartStaticServer(NSArray *params, NSString *staticAppClassName) {
    
    Class staticApplication = NSClassFromString(staticAppClassName) ;
    
    if (! staticApplication) {
        MSRaise(NSInternalInconsistencyException, @"MHStartStaticServer : cannot find class '%@' terminating...",staticAppClassName) ;
    }
    
    return MHStartServer(params, staticApplication) ;
}

#ifdef WIN32
LPSTR _decodeError(MSInt ErrorCode)

{
    static char Message[1024];
    // If this program was multi-threaded, we'd want to use FORMAT_MESSAGE_ALLOCATE_BUFFER
    // instead of a static buffer here.
    // (And of course, free the buffer when we were done with it)
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS |
                  FORMAT_MESSAGE_MAX_WIDTH_MASK, NULL, ErrorCode,
                  MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPSTR)Message, 1024, NULL);
    return Message;
}
#endif

SOCKET MHNewSocketOnServerPort(NSString *aServer, MSUInt aPort, BOOL isBlocking, NSString **anError)
{
    MSInt socketID ;
    struct sockaddr_in adr ;
    MSUInt serverAddress = _MHIPAddressFromString(aServer) ;
    
#ifdef WIN32
    unsigned long nonblocking = 1 ;
#else
    int set_option = 1;
    int flags ;
#endif
    
    if (aPort == MHBadPort) {
        if (anError) *anError = @"BAD Port" ;
        return -1 ;
    }
    if (serverAddress == MHBadAddress) {
        if (anError) *anError = @"BAD Address" ;
        return -1 ;
    }
    socketID = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) ;
    if (socketID < 0) {
        MHServerLogWithLevel(MHLogError, @"MHNewSocketOnServerPort => socketID < 0 - Impossible to get a new socket!") ;
        if (anError) *anError = @"Impossible to get a new socket" ;
        return -1 ;
    }
    
    if(!isBlocking)
    {
#ifdef WIN32
        ioctlsocket(socketID, FIONBIO, &nonblocking);
#else
        flags = fcntl(socketID, F_GETFL, 0);
        fcntl(socketID, F_SETFL, flags | O_NONBLOCK);
#endif
    }
    
#ifdef APPLE
    if (setsockopt(socketID, SOL_SOCKET, SO_NOSIGPIPE, &set_option, sizeof(set_option)) == SOCKET_ERROR)
    {
        _fatal_error("client setsockopt()", cerrno);
    }
#endif
#ifdef LINUX
    signal(SIGPIPE, SIG_IGN);
#endif
    
    memset((char*)&adr, 0, sizeof(adr)) ;
    adr.sin_family=AF_INET;
    adr.sin_port = htons(aPort) ;
    adr.sin_addr.s_addr = htonl(serverAddress) ;
    
    if (connect(socketID,(struct sockaddr*)&adr,sizeof(adr))) {
        MSInt lastError = cerrno ;
        BOOL error = YES ;
        
        if(!isBlocking)
        {
            struct timeval tv = {5, 0};
            fd_set wset ;
            
            if (lastError == EINPROGRESS || lastError == EWOULDBLOCK) {
                FD_ZERO(&wset);
                FD_SET(socketID, &wset);
                
                if (select(socketID+1, NULL, &wset, NULL, &tv) > 0) { error = NO ; }
                else { lastError = cerrno ; }
            }
        }
        
        if(error) {
#ifdef WIN32
            MHServerLogWithLevel(MHLogError, @"MHNewSocketOnServerPort connect KO - errorCode = %d (%s)", lastError, _decodeError(lastError)) ;
#else
            MHServerLogWithLevel(MHLogError, @"MHNewSocketOnServerPort connect KO - errorCode = %d", lastError) ;
#endif
            if (anError) *anError = @"Connection error" ;
            MHCloseSocket(socketID) ;
            return -1 ;
        }
    }    
    return socketID ;
}

MSLong MHReceiveDataOnConnectedSocket(MSInt socket, void *buffer, MSInt length)
{
    return recv(socket, buffer, length, 0) ;
}

BOOL MHCloseSocket(MSInt fd)
{
    MSInt result = -1 ;
    MSInt sock_error;

    shutdown(fd, 2);
    result = closesocket(fd) ;

    if(result == SOCKET_ERROR)
    {
        sock_error = cerrno;
        _fatal_error("MHCloseSocket()", sock_error);
    }
    return (result != SOCKET_ERROR) ;
}

