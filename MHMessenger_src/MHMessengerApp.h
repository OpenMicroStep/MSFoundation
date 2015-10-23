/*
 
 MHMessenger.h
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Geoffrey Guilbon : gguilbon@gmail.com
 Jean-Michel Berthéas : jean-michel.bertheas@club-internet.fr
 
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

@class MHMessengerDBAccessor ;
@class MHNetRepositoryClient ;

@interface MHMessengerSession : MHNetRepositoryDistantSession {
  NSString *_senderURN, *_recipientURN;
  id _allowedRecipients;
}
// A middleware took care of updating sender & recipient URNs
- (NSString *)senderURN; // Always the real URN of the user
- (void)setSenderURN:(NSString *)senderURN;
- (NSString *)recipientURN; // Can be the application URN if the user ask for it with the recipient=URN url parameters
- (void)setRecipientURN:(NSString *)recipientURN;
@end

@interface MHMessengerApplication : MSHttpApplication <MSHttpSessionAuthenticator> {
  MHMessengerDBAccessor *_messengerDBAccessor ;
}

- (void)authenticate:(MSHttpTransaction *)tr;


- (void)GET_auth:(MSHttpTransaction *)tr;

- (void)POST_sendMessage:(MSHttpTransaction *)tr;

// /findMessages?tid=GVeMIFsTours&status=1&xid=42=max=3&recipient=urn
- (void)GET_findMessages:(MSHttpTransaction *)tr;

// /getMessage?mid=UID&recipient=urn
- (void)GET_getMessage:(MSHttpTransaction *)tr;

// /getMessageStatus?mid=UID&recipient=urn
- (void)GET_getMessageStatus:(MSHttpTransaction *)tr;

// /setMessageStatus?mid=42&status=2
- (void)GET_setMessageStatus:(MSHttpTransaction *)tr;

// /deleteMessage?mid=UID
- (void)GET_deleteMessage:(MSHttpTransaction *)tr;

@end
