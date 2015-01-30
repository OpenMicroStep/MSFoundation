/* MSCouple.m
 
 This implementation file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 Eric Baradat :  k18rt@free.fr
 
 
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

#define MS_COUPLE_LAST_VERSION 300

@interface _MSCoupleEnumerator : NSEnumerator
{
@private
  NSInteger _position;
  MSCouple *_enumeredCouple;
}

- (id)initWithCouple:(MSCouple*)aCouple position:(NSInteger)position;
- (id)nextObject;

@end

#pragma mark Create functions

MSCouple *MSCreateCouple(id first, id second)
{
  return (MSCouple*)CCreateCouple(first, second);
}

@implementation MSCouple
+ (void)load{ MSInitSetInitializedClass(self); }
+ (void)msloaded{ [MSCouple setVersion:MS_COUPLE_LAST_VERSION];}

#pragma mark Initialisation

+ (id)allocWithZone:(NSZone*)zone {return MSAllocateObject(self, 0, zone);}
+ (id)alloc                       {return MSAllocateObject(self, 0, NULL);}
+ (id)new                         {return MSAllocateObject(self, 0, NULL);}

+ (id)coupleWithFirstMember:(id)o1 secondMember:(id)o2
{
  return COUPLE(o1, o2);
}

+ (id)coupleWithCouple:(MSCouple*)aCouple
{
  return AUTORELEASE(CCoupleCopy(aCouple));
}

- (id)initWithFirstMember:(id)o1 secondMember:(id)o2
{
  CCoupleSetFirstMember ((CCouple*)self, o1);
  CCoupleSetSecondMember((CCouple*)self, o2);
  return self;
}

- (id)initWithCouple:(MSCouple *)aCouple
{
  return [self initWithFirstMember:[aCouple firstMember] secondMember:[aCouple secondMember]];
}

- (id)initWithMembers:(id*)members
{
  if (members) {
    self= [self initWithFirstMember:members[0] secondMember:members[1]];}
  return self;
}

- (void)dealloc { CCoupleFreeInside(self); [super dealloc]; }

#pragma mark Copying

- (id)copyWithZone:(NSZone*)zone
{
  return zone == [self zone] ? RETAIN(self) : CCoupleCopy(self);
}
- (id)mutableCopyWithZone:(NSZone *)zone
{
  return [[MSMutableCouple allocWithZone:zone] initWithCouple:self];
}

#pragma mark Standard methods

- (id)firstMember  {return CCoupleFirstMember ((CCouple*)self);}
- (id)secondMember {return CCoupleSecondMember((CCouple*)self);}

- (BOOL)isEqual:(id)o
{
  if (o == self) return YES;
  return [o isKindOfClass:[self class]] &&
         ISEQUAL(_members[0], [o firstMember ]) &&
         ISEQUAL(_members[1], [o secondMember]);
}

- (BOOL)isEqualToCouple:(MSCouple*)couple
{
  if (couple == self) return YES;
  return ISEQUAL(_members[0], [couple firstMember ]) &&
         ISEQUAL(_members[1], [couple secondMember]);
}

// we use quite the same description as NSArray
// the difference is that we can have null values here
- (NSString *)toString
{
  return [NSString stringWithFormat:@"[%@,%@]",
         (_members[0] ? [_members[0] listItemString] : @"null"),
         (_members[1] ? [_members[1] listItemString] : @"null")];
}

- (NSString *)description { return [self toString]; }
- (NSString *)displayString
{
  return ([_members[0] length] ?
          ( [_members[1] length] ? [NSString stringWithFormat:@"%@, %@", _members[0], _members[1]] : _members[0]) :
          ( [_members[1] length] ? _members[1] : @""));
}

- (NSArray *)allObjects
{
  id ret;
  if (_members[0]) {
    ret= [NSArray arrayWithObjects:_members count:(_members[1] ? 2 : 1)];}
  else if (_members[1]) ret= [NSArray arrayWithObject:_members[1]];
  else ret= [NSArray array];
  return ret;
}

#pragma mark Enumerator

- (NSEnumerator*)objectEnumerator
{ return (NSEnumerator *)[[ALLOC(_MSCoupleEnumerator) initWithCouple:self position:-1] autorelease]; }

- (NSEnumerator*)reverseObjectEnumerator
{ return (NSEnumerator *)[[ALLOC(_MSCoupleEnumerator) initWithCouple:self position:2] autorelease]; }

- (BOOL)isTrue { return [_members[0] isTrue] && [_members[1] isTrue]; }

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if ([aDecoder allowsKeyedCoding]) {
    _members[0]= RETAIN([aDecoder decodeObjectForKey:@"first"]);
    _members[1]= RETAIN([aDecoder decodeObjectForKey:@"second"]);
  }
  else {
    [aDecoder decodeValuesOfObjCTypes:"@@",&_members];
  }
  return self;
}

- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder
{
  if ([encoder isBycopy]) return self;
  return [super replacementObjectForPortCoder:encoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  if ([aCoder allowsKeyedCoding]) {
    [aCoder encodeObject:_members[0] forKey:@"first"];
    [aCoder encodeObject:_members[1] forKey:@"second"];
  }
  else {
    [aCoder encodeValuesOfObjCTypes:"@@",_members];
  }
}

@end

#pragma mark MSMutableCouple

MSMutableCouple *MSCreateMutableCouple(id first, id second)
{
  MSMutableCouple *c= (MSMutableCouple*)MSCreateObject([MSMutableCouple class]);
  CCoupleSetFirstMember ((CCouple*)c, first );
  CCoupleSetSecondMember((CCouple*)c, second);
  return c;
}

@implementation MSMutableCouple

- (id)copyWithZone:(NSZone *)zone
{
  return CCoupleCopy(self);
  zone= nil; // unused parameter
}

- (void)setFirstMember:(id)firstMember
{
  CCoupleSetFirstMember((CCouple*)self, firstMember);
}
- (void)setSecondMember:(id)secondMember
{
  CCoupleSetSecondMember((CCouple*)self, secondMember);
}
- (void)addObject:(id)anObject
{
  if (!anObject) {
    MSRaiseFrom(NSInvalidArgumentException, self, _cmd, @"try to add nil object.");}
  else if (!_members[0]) {
    if (_members[1]) {
      MSRaiseFrom(NSInternalInconsistencyException, self, _cmd, @"try to insert object in malformed couple.");}
    else CCoupleSetFirstMember((CCouple*)self, anObject);}
  else {
    if (_members[1]) {
      MSRaiseFrom(NSRangeException, self, _cmd, @"no room left to add object.");}
    else CCoupleSetSecondMember((CCouple*)self, anObject);}
}

- (void)setCouple:(MSCouple *)couple
{
  CCoupleSetFirstMember ((CCouple*)self, [couple firstMember ]);
  CCoupleSetSecondMember((CCouple*)self, [couple secondMember]);
}

@end

#pragma mark Enumeration

@implementation _MSCoupleEnumerator

- (id)initWithCouple:(MSCouple *)aCouple position:(NSInteger)position
{
  if (!(self= [super init])) return nil;
  _enumeredCouple= [aCouple retain];
  _position= position;
  return self;
}

- (void)dealloc { RELEASE(_enumeredCouple); [super dealloc]; }

- (id)nextObject
{
  id theObject= nil;
  
  switch (_position) {
    case 2:
      theObject= [_enumeredCouple secondMember];
      _position= 1;
      if (theObject) break;
    case 1 :
      theObject= [_enumeredCouple firstMember];
      _position= NSNotFound;
      break;
    case -1:
      theObject= [_enumeredCouple firstMember];
      _position= 0;
      if (theObject) break;
    case 0 :
      theObject= [_enumeredCouple secondMember];
      _position= NSNotFound;
      break;
    default :
      break;}
  return theObject;
}

@end
