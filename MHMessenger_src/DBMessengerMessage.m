/*
 
 DBMessengerMessage.m
 
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

//#import <MASH/MASH.h>
//#import "DBMessengerMessage.h"

#import "MHMessenger_Private.h"

#define ADD_STR(DIC,S,K) { id _str_ = nil; _str_ = S ? S : @""; [DIC setObject:_str_ forKey:K] ; }
#define ADD_DAT(DIC,D,K) { id _dat_ = nil; _dat_ = D ? D : [NSData data]; [DIC setObject:_dat_ forKey:K] ; } 
#define ADD_NUM(DIC,N,K) { id _num_ = nil; _num_ = N ? N : [NSNumber numberWithInt:0] ; [DIC setObject:_num_ forKey:K] ; }

@implementation DBMessengerMessage


- (MSULong)messageGroup { return _messageGroup ; }
- (void)setMessageGroup:(MSULong)group { _messageGroup = group ; }

- (NSDictionary *)databaseDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary] ;
    
    ADD_STR(dict, [self messageID], DB_TABLE_MESSAGE_COL_MESSAGE_ID) ;
    ADD_NUM(dict, [NSNumber numberWithLongLong:[self messageGroup]], DB_TABLE_MESSAGE_COL_MESSAGE_GROUP) ;
    ADD_STR(dict, [self contentType], DB_TABLE_MESSAGE_COL_CONTENT_TYPE) ;
    ADD_STR(dict, [self sender], DB_TABLE_MESSAGE_COL_SENDER) ;
    ADD_STR(dict, [[self recipients] componentsJoinedByString:@","], DB_TABLE_MESSAGE_COL_RECIPIENT) ;
    ADD_NUM(dict, [NSNumber numberWithLongLong:[self creationDate]], DB_TABLE_MESSAGE_COL_CREATION_DATE) ;
    ADD_NUM(dict, [NSNumber numberWithLongLong:[self receivingDate]], DB_TABLE_MESSAGE_COL_RECEIVING_DATE) ;
    ADD_STR(dict, [self thread], DB_TABLE_MESSAGE_COL_THREAD) ;
    ADD_NUM(dict, [NSNumber numberWithLongLong:[self validity]], DB_TABLE_MESSAGE_COL_VALIDITY) ;
    ADD_STR(dict, [self route], DB_TABLE_MESSAGE_COL_ROUTE) ;
    ADD_NUM(dict, [NSNumber numberWithInt:[self priority]], DB_TABLE_MESSAGE_COL_PRIORITY) ;
    ADD_NUM(dict, [NSNumber numberWithInt:[self status]], DB_TABLE_MESSAGE_COL_STATUS) ;
    ADD_STR(dict, [self externalReference],DB_TABLE_MESSAGE_COL_EXTERNAL_REF) ;
    ADD_DAT(dict, [self base64Content], DB_TABLE_MESSAGE_COL_CONTENT);
    
    return dict ;
}

@end
