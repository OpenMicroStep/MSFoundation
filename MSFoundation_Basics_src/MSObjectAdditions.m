/* MSObjectAdditions.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
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

#import "MSFoundation_Private.h"

#pragma mark Declarations

static NSString *MSDelayedPostingNotification=           @"MSDelayedPostingNotification";
static NSString *MSDelayedPostingWithObjectNotification= @"MSDelayedPostingWithObjectNotification";

@interface _MSDelayedPostingManager : NSObject
+ (_MSDelayedPostingManager *)defaultDelayedManager;
- (void)postAction:(SEL)action to:(id)target withObject:(id)argument;
- (void)postAction:(SEL)action to:(id)target;
@end
static _MSDelayedPostingManager *__theMSDelayedPostingManager= nil;

@interface _MSUnaryObjectEnumerator : NSEnumerator
{
  id _object;
}
+ (id)unaryEnumeratorWithObject:(id)object;
@end

#pragma mark Implementations

@implementation NSObject (MSObjectAdditions)

- (NSString*)toString           { return @""; }
- (NSString*)listItemString     { return [self toString]; }
- (NSString*)displayString      { return @""; }
- (NSString*)htmlRepresentation { return [[self toString] htmlRepresentation]; }
- (NSString*)jsonRepresentation { return [self toString]; }
- (const char *)UTF8String      { return [[self toString] UTF8String]; }

- (BOOL)isTrue        { return  NO; }
- (BOOL)isNull        { return  NO; }
- (BOOL)isSignificant { return YES; }

- (void)delayedPerformSelector:(SEL)aSelector
{
  [[_MSDelayedPostingManager defaultDelayedManager] postAction:aSelector to:self];
}
- (void)delayedPerformSelector:(SEL)aSelector withObject:(id)argument
{
  [[_MSDelayedPostingManager defaultDelayedManager] postAction:aSelector to:self withObject:argument];
}

- (NSEnumerator *)objectEnumerator
{
  return [_MSUnaryObjectEnumerator unaryEnumeratorWithObject:self];
}

- (NSString *)className { return NSStringFromClass([self class]); }
+ (NSString *)className { return NSStringFromClass((Class)self); }

#ifndef GNUSTEP
- (id)notImplemented:(SEL)aSel // for Gnustep compatibilkity
{ MSRaiseFrom(NSGenericException, self, aSel, @"method not implemented"); return nil;}
#endif

- (id)notYetImplemented:(SEL)aSel
{ MSRaiseFrom(NSGenericException, self, aSel, @"hey dude, this method should be implemented!"); return nil;}

- (BOOL)performTestSelector:(SEL)aSelector
{ return (*((BOOL (*)(id,SEL))objc_msgSend))(self, aSelector); }

- (BOOL)performTestSelector:(SEL)aSelector withObject:(id)object
{ return (*((BOOL (*)(id,SEL,id))objc_msgSend))(self, aSelector, object); }

- (BOOL)performTestSelector:(SEL)aSelector withObject:(id)o1 withObject:(id)o2
{ return (*((BOOL (*)(id,SEL,id,id))objc_msgSend))(self, aSelector, o1, o2); }

@end

@implementation _MSUnaryObjectEnumerator
+ (id)unaryEnumeratorWithObject:(id)object
{
  _MSUnaryObjectEnumerator *e= MSAllocateObject(self, 0, NULL);
  e->_object= RETAIN(object);
  return AUTORELEASE(e);
}
- (id)nextObject
{
  id ret= AUTORELEASE(_object);
  ASSIGN(_object,nil);
  return ret;
}
- (void)dealloc { RELEASE(_object); [super dealloc]; }
@end

NSNull *MSNull= nil;

@implementation _MSDelayedPostingManager

// OK, we use a load on a private class for something it's not made for.
// But it's free and in the right file, so why not
+ (void)load{ MSNull= RETAIN([NSNull null]); }

// warning, this class method is not thread safe...
+ (_MSDelayedPostingManager *)defaultDelayedManager
{
  if (!__theMSDelayedPostingManager) {
    NSNotificationCenter *dc= [NSNotificationCenter defaultCenter];
    __theMSDelayedPostingManager= NEW(_MSDelayedPostingManager);
    [dc addObserver:__theMSDelayedPostingManager
           selector:@selector(_selectorToPost:)
               name:MSDelayedPostingNotification
             object:__theMSDelayedPostingManager];
    [dc addObserver:__theMSDelayedPostingManager
           selector:@selector(_selectorWithObjectToPost:)
               name:MSDelayedPostingWithObjectNotification
             object:__theMSDelayedPostingManager];}
  return __theMSDelayedPostingManager;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void)_selectorWithObjectToPost:(NSNotification *)notif
{
  NSDictionary *userInfo= [notif userInfo];
  SEL selector= NSSelectorFromString([userInfo objectForKey:@"selector"]);
  id target= [userInfo objectForKey:@"target"];
  id argument= [userInfo objectForKey:@"argument"];
  [target performSelector:selector withObject:argument];
}

- (void)_selectorToPost:(NSNotification *)notif
{
  NSDictionary *userInfo= [notif userInfo];
  SEL selector= NSSelectorFromString([userInfo objectForKey:@"selector"]);
  id target= [userInfo objectForKey:@"target"];
  [target performSelector:selector];
}

- (void)postAction:(SEL)action to:(id)target
{
  NSString *name;
  if (action && [(name= NSStringFromSelector(action)) length] && target) {
    NSNotification *notif;
    NSDictionary *userInfo= [MSDictionary dictionaryWithKeysAndObjects:@"selector",name, @"target",target, nil];
    notif= [NSNotification notificationWithName:MSDelayedPostingNotification
                                         object:self
                                       userInfo:userInfo];
    /* TODO with NSNotificationCenter
    [[NSNotificationQueue defaultQueue] enqueueNotification:notif
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];*/}
}

- (void)postAction:(SEL)action to:(id)target withObject:(id)argument
{
  NSString *name;
  if (action && [(name= NSStringFromSelector(action)) length] && target) {
    NSNotification *notif;
    NSDictionary *userInfo= [MSDictionary dictionaryWithKeysAndObjects:@"selector",name, @"target",target, @"argument", argument, nil];
    notif= [NSNotification notificationWithName:MSDelayedPostingWithObjectNotification
                                         object:self
                                       userInfo:userInfo];
    /* TODO with NSNotificationCenter                                       
    [[NSNotificationQueue defaultQueue] enqueueNotification:notif
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];*/}
}

@end

#pragma mark NSString completude to toString, listeItemString, isTrue, etc

@implementation NSNumber (MSObjectAdditions)
- (BOOL)isTrue
{
  const char *c= [self objCType];
  if (c) {
    switch (*c) {
      case 'f':
        return ([self floatValue] == (float)0.0 ? NO : YES);
      case 'd':
        return ([self doubleValue] == (double)0.0 ? NO : YES);
      case 'q':
        return ([self longLongValue] == 0 ? NO : YES);
      case 'Q':
        return ([self unsignedLongLongValue] == 0 ? NO : YES);
      default:
        return ([self intValue] == 0 ? NO : YES);
    }
  }
  return NO;
}

- (NSString *)toString { return [self description]; }

@end

@implementation NSNull (MSObjectAdditions)
- (NSString *)description        { return @""; }
- (NSString *)toString           { return @"null"; }
- (NSString *)listItemString     { return @"null"; }
- (NSString *)displayString      { return @""; }
- (NSString *)htmlRepresentation { return @""; }

- (BOOL)isNull        { return YES; }
- (BOOL)isSignificant { return  NO; }
@end

/************************** TO DO IN THIS FILE  ****************
 
 (1)  a more efficient NSNumber toString method
 (2)  a better isTrue method on NSDecimalNumber. On MacOSX
 the WO451 implementation gives 2 links error
 
 *************************************************************/
