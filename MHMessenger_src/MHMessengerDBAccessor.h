/*
 
 MHMessengerDBAccessor.h
 
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

@class MHMessenger ;

//tables and colums
#define DB_TABLE_MESSAGE                        @"message"
#define DB_TABLE_MESSAGE_COL_MESSAGE_ID         @"messageID"
#define DB_TABLE_MESSAGE_COL_MESSAGE_GROUP      @"messageGroup"
#define DB_TABLE_MESSAGE_COL_TYPE               @"envelopeType"
#define DB_TABLE_MESSAGE_COL_SENDER             @"sender"
#define DB_TABLE_MESSAGE_COL_RECIPIENT          @"recipient"
#define DB_TABLE_MESSAGE_COL_CREATION_DATE      @"creationDate"
#define DB_TABLE_MESSAGE_COL_RECEIVING_DATE     @"receivingDate"
#define DB_TABLE_MESSAGE_COL_THREAD             @"thread"
#define DB_TABLE_MESSAGE_COL_VALIDITY           @"validity"
#define DB_TABLE_MESSAGE_COL_PRIORITY           @"priority"
#define DB_TABLE_MESSAGE_COL_ROUTE              @"route"
#define DB_TABLE_MESSAGE_COL_STATUS             @"status"
#define DB_TABLE_MESSAGE_COL_EXTERNAL_REF       @"externalReference"
#define DB_TABLE_MESSAGE_COL_CONTENT_TYPE       @"contentType"
#define DB_TABLE_MESSAGE_COL_CONTENT            @"content"

#define DB_TABLE_PARAMETERS                     @"parameters"
#define DB_TABLE_PARAMETERS_COL_NAME            @"name"
#define DB_TABLE_PARAMETERS_COL_VALUE1          @"value1"
#define DB_TABLE_PARAMETERS_COL_VALUE2          @"value2"
#define DB_TABLE_PARAMETERS_COL_VALUE3          @"value3"

#define DB_TABLE_INDEXES                        @"indexes"
#define DB_TABLE_INDEXES_COL_NAME               @"name"
#define DB_TABLE_INDEXES_COL_VALUE              @"value"

//values
#define DB_VERSION_PARAM                        @"dbVersion"
#define MESSAGE_GROUP_INDEX                     @"messageGroup"

@interface MHMessengerDBAccessor : NSObject{
  MSDBConnection *_connection;
}

+ (instancetype)messengerDBWithConnectionDictionary:(NSDictionary *)connectionDictionary;
- (instancetype)initWithConnectionDictionary:(NSDictionary *)connectionDictionary;

- (NSArray *)createIDAndstoreMessage:(MHMessengerMessage *)message ;
- (NSDictionary *)findMessagesForURN:(NSString *)urn andParameters:(NSDictionary *)parameters ;
- (MHMessengerMessage *)getMessageForURN:(NSString *)urn andMessageID:(NSString *)messageID ;
- (BOOL)deleteMessageForURN:(NSString *)urn andMessageID:messageID ;
- (NSDictionary *)getMessageStatusForURN:(NSString *)urn andMessageID:(NSString *)messageID ;
- (BOOL)setMessageStatusForURN:(NSString *)urn andMessageID:(NSString *)messageID newStatus:(MSInt)status ;

- (BOOL)cleanObsoleteMessages ;

- (MSInt)getDBVersion ;
- (BOOL)runSQLScript:(NSString *)scriptPath ;

@end
