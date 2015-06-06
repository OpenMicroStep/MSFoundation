#import "FoundationCompatibility_Private.h"

@implementation NSNotification
+ (instancetype)notificationWithName:(NSString *)name object:(id)sender
{ return [self notificationWithName:name object:sender userInfo:nil]; }
+ (instancetype)notificationWithName:(NSString *)name object:(id)sender userInfo:(NSDictionary *)userInfo
{ return AUTORELEASE([ALLOC(self) initWithName:name object:sender userInfo:userInfo]); }

- (instancetype)initWithName:(NSString *)name object:(id)sender userInfo:(NSDictionary *)userInfo
{
  if ((self= [super init])) {
    _name= [name retain];
    _object= [sender retain];
    _userInfo= [userInfo retain];
  }
  return self;
}
- (void)dealloc
{
  [_name release];
  [_object release];
  [_userInfo release];
  [super dealloc];
}

- (NSString *)name
{ return _name; }
- (id)object
{ return _object; }
- (NSDictionary *)userInfo
{ return _userInfo; }


- (id)initWithCoder:(NSCoder *)aDecoder
{
  return [self initWithName:[aDecoder decodeObject] object:[aDecoder decodeObject] userInfo:[aDecoder decodeObject]];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:_name];
  [aCoder encodeObject:_object];
  [aCoder encodeObject:_userInfo];
}

- (id)copyWithZone:(NSZone *)zone
{ return [self retain]; }

@end
