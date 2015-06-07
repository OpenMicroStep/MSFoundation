/*
 
 MHMessengerMessage.m
 
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

//#import "MSNet_Private.h"
//#import "MHMessengerMessage.h"

#import "MHMessenger_Private.h"

@implementation MHMessengerMessage

+ (instancetype)message
{ return AUTORELEASE([ALLOC(self) init]); }
- (instancetype)init
{
  if ((self= [super init])) {
    _validity= MESSENGER_DEFAULT_MESSAGE_VALIDITY;
  }
  return self;
}

- (void)setAsNew
{
  _creationDate= [[NSDate date] timeIntervalSinceReferenceDate];
}

- (void)dealloc
{
  [_messageID release];
  [_sender release];
  [_recipients release];
  [_thread release];
  [_route release];
  [_externalReference release];
  [_contentType release];
  [_base64Content release];
  [super dealloc];
}

static BOOL checkStringArray(NSArray *arr)
{
  NSEnumerator *e; BOOL ok; NSString *s;
  ok= [arr count] > 0;
  for (e= [arr objectEnumerator]; ok && (s= [e nextObject]); ) 
    ok= [s length] > 0;
  return ok;
}
- (BOOL)checkConsistency:(NSString **)perr
{
  id error= nil;

  if(![_messageID length])
    error= @"message ID can't be empty";
  else if(![_sender length])
    error= @"sender can't be empty";
  else if(!checkStringArray(_recipients))
    error= @"recipients can't be empty or contain empty value";
  else if(![_thread length])
    error= @"thread can't be empty";
  else if(_creationDate < 0)
    error= @"creationDate is invalid";
  else if(_validity < 0)
    error= @"validity is invalid";
  else if(_priority == MSIntMin)
    error= @"priority is invalid";
  else if(_status == MSIntMin)
    error= @"status is invalid";
  else if(![_contentType length])
    error= @"contentType can't be empty";
  else if(![_base64Content length])
    error= @"content can't be empty";

  if (error && perr)
    *perr= error;
  return error == nil;  
}
static NSString * checkString(id s)
{
  return s;
}
static MSLong checkLong(id s, MSLong defaultValue, MSLong errValue)
{
  SES fd, ses;
  if (!s) return defaultValue;
  if (SESOK(ses= SESFromString(s)) 
   && SESOK(fd= SESExtractPart(ses, CUnicharIsIsoDigit))
   && SESStart(ses) == SESStart(fd) && SESLength(ses) == SESLength(fd)) {
    errValue= [s longLongValue];}
  return errValue;
}
- (void)fillPropertiesWithSource:(NSString *(*)(NSString *key, id arg))source context:(id)arg
{
  [self setMessageID:        checkString(source(MESSENGER_ENV_MESSAGE_ID    , arg))];
  [self setSender:           checkString(source(MESSENGER_ENV_SENDER        , arg))];
  [self setJoinedRecipients: checkString(source(MESSENGER_ENV_RECIPIENTS    , arg))];
  [self setCreationDate:     checkLong  (source(MESSENGER_ENV_CREATION_DATE , arg), 0, MSIntMin)];
  [self setReceivingDate:    checkLong  (source(MESSENGER_ENV_RECEIVING_DATE, arg), 0, MSIntMin)];
  [self setThread:           checkString(source(MESSENGER_ENV_THREAD        , arg))];
  [self setValidity:         checkLong  (source(MESSENGER_ENV_VALIDITY      , arg), MESSENGER_DEFAULT_MESSAGE_VALIDITY, MSIntMin)];
  [self setPriority:         checkLong  (source(MESSENGER_ENV_PRIORITY      , arg), 0, MSIntMin)];
  [self setRoute:            checkString(source(MESSENGER_ENV_ROUTE         , arg))];
  [self setStatus:           checkLong  (source(MESSENGER_ENV_STATUS        , arg), 0, MSIntMin)];
  [self setExternalReference:checkString(source(MESSENGER_ENV_EXTERNAL_REF  , arg))];
  [self setContentType:      checkString(source(MESSENGER_ENV_CONTENT_TYPE  , arg))];
}
- (void)exportPropertiesWithOutput:(void(*)(id val, NSString *key, id arg))output context:(id)arg asString:(BOOL)asString
{
  output([self messageID        ], MESSENGER_ENV_MESSAGE_ID    , arg);
  output([self sender           ], MESSENGER_ENV_SENDER        , arg);
  output([self recipientsJoined ], MESSENGER_ENV_RECIPIENTS    , arg);
  output([self thread           ], MESSENGER_ENV_THREAD        , arg);
  output([self route            ], MESSENGER_ENV_ROUTE         , arg);
  output([self externalReference], MESSENGER_ENV_EXTERNAL_REF  , arg);
  output([self contentType      ], MESSENGER_ENV_CONTENT_TYPE  , arg);
  if (asString) {
    output([NSString stringWithFormat:@"%d",   [self status       ]], MESSENGER_ENV_STATUS        , arg);
    output([NSString stringWithFormat:@"%d",   [self priority     ]], MESSENGER_ENV_PRIORITY      , arg);
    output([NSString stringWithFormat:@"%lld", [self creationDate ]], MESSENGER_ENV_CREATION_DATE , arg);
    output([NSString stringWithFormat:@"%lld", [self receivingDate]], MESSENGER_ENV_RECEIVING_DATE, arg);
    output([NSString stringWithFormat:@"%lld", [self validity     ]], MESSENGER_ENV_VALIDITY      , arg);
  }
  else {
    output([NSNumber numberWithInt:     [self status       ]], MESSENGER_ENV_STATUS        , arg);
    output([NSNumber numberWithInt:     [self priority     ]], MESSENGER_ENV_PRIORITY      , arg);
    output([NSNumber numberWithLongLong:[self creationDate ]], MESSENGER_ENV_CREATION_DATE , arg);
    output([NSNumber numberWithLongLong:[self receivingDate]], MESSENGER_ENV_RECEIVING_DATE, arg);
    output([NSNumber numberWithLongLong:[self validity     ]], MESSENGER_ENV_VALIDITY      , arg);
  }
}

- (NSString *)messageID                    { return _messageID ; }
- (void)setMessageID:(NSString *)messageID { ASSIGN(_messageID, messageID) ; }

- (NSString *)sender                 { return _sender ; }
- (void)setSender:(NSString *)sender { ASSIGN(_sender, sender) ; }

- (MSArray *)recipients { return _recipients ; }
- (void)setRecipients:(NSArray *)recipients { 
  ASSIGN(_recipients, recipients);
}
- (NSString*)recipientsJoined
{ return [_recipients componentsJoinedByString:@","]; }
- (void)setJoinedRecipients:(NSString *)recipients
{ [self setRecipients:[recipients componentsSeparatedByString:@","]]; }

- (MSTimeInterval)creationDate { return _creationDate ; }
- (void)setCreationDate:(MSTimeInterval )creationDate { _creationDate = creationDate ; }

- (MSTimeInterval)receivingDate { return _receivingDate ; }
- (void)setReceivingDate:(MSTimeInterval )receivingDate { _receivingDate = receivingDate ; }

- (NSString *)thread                 { return _thread ; }
- (void)setThread:(NSString *)thread { ASSIGN(_thread, thread) ; }

- (MSTimeInterval)validity { return _validity ; }
- (void)setValidity:(MSTimeInterval)validity { _validity = validity ; }
- (BOOL)isPersistent { return _validity == 0 ; }

- (MSInt)priority { return _priority ; }
- (void)setPriority:(MSInt)priority { _priority = priority ; }

- (NSString *)route { return _route ; }
- (void)setRoute:(NSString *)route { ASSIGN(_route, route) ; }
- (void)addRouteComponent:(NSString *)component {
  if([component length]) {
    if([_route length]) {
      NSString *newRoute= [component stringByAppendingFormat:@".%@",_route] ;
      ASSIGN(_route, newRoute) ; }
    else { ASSIGN(_route, component) ; }}
}

- (MSInt)status  {  return _status ; }
- (void)setStatus:(MSInt)status { _status = status ; }

- (NSString *)externalReference { return _externalReference ; }
- (void)setExternalReference:(NSString *)externalReference { ASSIGN(_externalReference, externalReference) ; }

- (NSString *)contentType { return _contentType ; }
- (void)setContentType:(NSString *)contentType { ASSIGN(_contentType, contentType) ; }

- (NSData *)base64Content { return _base64Content ; }
- (void)setBase64Content:(NSData *)base64Content { ASSIGN(_base64Content, base64Content); }

- (NSData *)content {
  CBuffer *b= CCreateBuffer(0);
  CBufferBase64EncodeAndAppendBytes(b, [_base64Content bytes], [_base64Content length]);
  return AUTORELEASE(b);
}
- (void)setContent:(NSData *)content {
  CBuffer *b= CCreateBuffer(0);
  if (!CBufferBase64DecodeAndAppendBytes(b, [_base64Content bytes], [_base64Content length]))
    DESTROY(b);
  [_base64Content release];
  _base64Content= (MSBuffer *)b;
}
@end
