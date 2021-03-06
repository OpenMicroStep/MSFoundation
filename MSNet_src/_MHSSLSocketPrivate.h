/*
 
 _MHSSLSocketPrivate.h
 
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
typedef enum {
	SOCKET_IS_NONBLOCKING,
	SOCKET_IS_BLOCKING,
	SOCKET_HAS_TIMED_OUT,
	SOCKET_HAS_BEEN_CLOSED,
	SOCKET_OPERATION_OK
} timeout_state;

@interface MHSSLSocket (Private)

- (SSL *)SSLSocket ;
- (void)setSSLSocket:(SSL *)secureSocket ;

- (MSInt)localPort ;

- (void)close ;

- (MSInt)readHeadersIn:(void *)buf length:(MSUInt)length ;
- (MSUInt)singleNonBlockingReadIn:(void *)buf length:(MSUInt)length ; //tries to read on a non blocking socket, returns 0 if nothing to read yet, or number of read bytes on success

- (MSCertificate *)getPeerCertificate ;

@end

@interface MHSSLServerSocket : MHSSLSocket

+ (id)sslSocketWithContext:(SSL_CTX *)ctx andSocket:(SOCKET)sd isBlockingIO:(BOOL)isBlockingIO ;
- (id)initWithContext:(SSL_CTX *)ctx andSocket:(SOCKET)sd isBlockingIO:(BOOL)isBlockingIO ;

+ (int)oneWayAuthCtxID ;
+ (int)twoWayAuthCtxID ;

- (BOOL)accept ;

@end
