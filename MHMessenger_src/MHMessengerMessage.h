/*
 
 MHMessengerMessage.h
 
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

#define MESSENGER_ENV_MESSAGE_ID        @"messageID"
#define MESSENGER_ENV_SENDER            @"sender"
#define MESSENGER_ENV_RECIPIENTS        @"recipients"
#define MESSENGER_ENV_CREATION_DATE     @"creationDate"
#define MESSENGER_ENV_RECEIVING_DATE    @"receivingDate"
#define MESSENGER_ENV_THREAD            @"thread"
#define MESSENGER_ENV_VALIDITY          @"validity"
#define MESSENGER_ENV_PRIORITY          @"priority"
#define MESSENGER_ENV_ROUTE             @"route"
#define MESSENGER_ENV_STATUS            @"status"
#define MESSENGER_ENV_EXTERNAL_REF      @"externalReference"
#define MESSENGER_ENV_CONTENT_TYPE      @"contentType"

#define MESSENGER_DEFAULT_MESSAGE_VALIDITY 259200 //3 days

//URL components
#define MESSENGER_SUB_URL_SEND_MSG        @"sendMessage"
#define MESSENGER_SUB_URL_FIND_MSG        @"findMessages"
#define MESSENGER_SUB_URL_GET_MSG         @"getMessage"
#define MESSENGER_SUB_URL_GET_MSG_STATUS  @"getMessageStatus"
#define MESSENGER_SUB_URL_SET_MSG_STATUS  @"setMessageStatus"
#define MESSENGER_SUB_URL_DEL_MSG         @"deleteMessage"

//Query string parametres
#define MESSENGER_QUERY_PARAM_MESSAGE_ID      @"mid"
#define MESSENGER_QUERY_PARAM_THREAD_ID       @"tid"
#define MESSENGER_QUERY_PARAM_EXTERNAL_REF    @"xid"
#define MESSENGER_QUERY_PARAM_STATUS          @"status"
#define MESSENGER_QUERY_PARAM_MAX             @"max"
#define MESSENGER_QUERY_PARAM_POS             @"pos"
#define MESSENGER_QUERY_PARAM_RECIPIENT       @"recipient"
#define MESSENGER_QUERY_PARAM_MESSAGE_ENV     @"env"
#define MESSENGER_QUERY_PARAM_OR_SEPARATOR    @"|"
#define MESSENGER_QUERY_PARAM_URN             @"urn"

//Response contstants
#define MESSENGER_RESPONSE_FIND_MESSAGES        @"messages"
#define MESSENGER_RESPONSE_FIND_HAS_MORE        @"hasMoreMessages"
#define MESSENGER_RESPONSE_GET_STATUS           @"status"

typedef enum
{
    MHMLowPriority = -1,
	MHMNormalPriority,
    MHMHighPriority
} MHMessengerPriority ;

@interface MHMessengerMessage : NSObject
{
@private
    NSString *_messageID ;
    NSString * _sender ;
    mutable MSArray *_recipients ;
    MSTimeInterval _creationDate ;
    MSTimeInterval _receivingDate ;
    NSString *_thread ;
    MSTimeInterval _validity ;
    MSInt _priority ;
    NSString *_route ;
    MSInt _status ;
    NSString *_externalReference ;
    NSString *_contentType ;
    MSBuffer *_base64Content ;
}

//init
+ (instancetype)message;
- (void)setAsNew;
- (BOOL)checkConsistency:(NSString **)perr;

// fast get/set
- (void)fillPropertiesWithSource:(NSString *(*)(NSString *key, id arg))source context:(id)arg;
- (void)exportPropertiesWithOutput:(void(*)(id val, NSString *key, id arg))output context:(id)arg asString:(BOOL)asString;

//getters, setters
- (NSString *)messageID ;
- (void)setMessageID:(NSString *)messageID ;

- (NSString *)sender ;
- (void)setSender:(NSString *)sender ;

- (NSArray *)recipients ;
- (void)setRecipients:(NSArray *)recipients;

- (MSTimeInterval)creationDate ;
- (void)setCreationDate:(MSTimeInterval )creationDate ;

- (MSTimeInterval)receivingDate ;
- (void)setReceivingDate:(MSTimeInterval )receivingDate ;

- (NSString *)thread ;
- (void)setThread:(NSString *)thread ;

- (MSTimeInterval)validity ;
- (void)setValidity:(MSTimeInterval)validity ;
- (BOOL)isPersistent ;

- (MSInt)priority ;
- (void)setPriority:(MSInt)priority ;

- (NSString *)route ;
- (void)setRoute:(NSString *)route ;
- (void)addRouteComponent:(NSString *)component ;

- (MSInt)status ;
- (void)setStatus:(MSInt)status ;

- (NSString *)externalReference ;
- (void)setExternalReference:(NSString *)externalReference ;

- (NSString *)contentType ;
- (void)setContentType:(NSString *)contentType ;

- (MSBuffer *)base64Content ;
- (void)setBase64Content:(MSBuffer *)base64content ;

// !slow, content is stored in base64 most of the time
- (MSBuffer *)content ;
- (void)setContent:(MSBuffer *)content ;
@end

