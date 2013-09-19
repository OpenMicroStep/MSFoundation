/*
 
 MSMutableArray.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 
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

#import "MSFoundation.h"

@interface NSArray (Private)
- (BOOL)_isMS;
@end
@interface MSMutableArray (Private)
- (BOOL)_isMS;
@end
@implementation MSMutableArray (Private)
- (BOOL)_isMS {return YES;}
@end

@implementation MSMutableArray

#pragma mark alloc / init

+ (id)allocWithZone:(NSZone*)zone {return MSAllocateObject(self, 0, zone);}
+ (id)alloc                       {return (id)CCreateArray(0) ;}
+ (id)new                         {return (id)CCreateArray(0) ;}
+ (id)array           {return AUTORELEASE((id)CCreateArray(0));}
+ (id)arrayWithObject:(id)anObject
  {
  return AUTORELEASE((id)CCreateArrayWithObject(anObject));
  }
+ (id)arrayWithObjects:(id*)objs count:(NSUInteger)n
  {
  return AUTORELEASE([(id)CCreateArray(n) initWithObjects:objs count:n copyItems:NO]);
  }
+ (id)arrayWithFirstObject:(id)firstObject arguments:(va_list)ap
  {
  return AUTORELEASE([(id)CCreateArray(1) initWithFirstObject:firstObject arguments:ap]);
  }
+ (id)arrayWithObjects:(id)firstObject, ...
  {
  id ret;
  va_list ap;
  va_start(ap, firstObject);
  ret= [self arrayWithFirstObject:firstObject arguments:ap];
  va_end(ap);
  return AUTORELEASE(ret);
  }
+ (id)arrayWithArray:(NSArray*)array
  {
  return AUTORELEASE([(id)CCreateArray([array count]) initWithArray:array copyItems:NO]);
  }

- (id)init
  {
  return self;
  }
- (id)initWithObject:(id)o
  {
  CArrayAddObject((CArray*)self,o);
  return self;
  }
- (id)initWithObjects:(id*)objects count:(NSUInteger)n
  {
  return [self initWithObjects:objects count:n copyItems:NO];
  }

- (id)initWithObjects:(id*)objects count:(NSUInteger)n copyItems:(BOOL)copy
  {
  CArrayAddObjects((CArray*)self, objects, n, copy);
  return self;
  }

- (id)initWithObjects:(id)firstObject, ...
  {
  va_list ap;
  va_start(ap, firstObject);
  self= [self initWithFirstObject:firstObject arguments:ap];
  va_end(ap);
  return self;
  }
- (id)initWithFirstObject:(id)o arguments:(va_list)ap
  {
  CArrayAddObject((CArray*)self,o);
  while ((o= va_arg (ap, id))) CArrayAddObject((CArray*)self,o);
  return self;
  }

- (id)initWithArray:(NSArray*)array
  {
  return [self initWithArray:array copyItems:NO];
  }

static inline void _addArray(CArray *self, NSArray *a, BOOL copyItems)
  {
  if ([a _isMS]) CArrayAddArray(self, (CArray*)a, copyItems);
  else {
    id e,o;
    CArrayGrow(self, [a count]);
    for (e= [a objectEnumerator]; (o= [e nextObject]);) {
      CArrayAddObjects(self,&o,1,copyItems);}}
  }
- (id)initWithArray:(NSArray*)array copyItems:(BOOL)copy
  {
  _addArray((CArray*)self, array, copy);
  return self;
  }

- (id)initWithCapacity:(NSUInteger)capacity
  {
  return [self initWithCapacity:capacity  noRetainRelease:NO nilItems:NO];
  }
- (id)initWithCapacity:(NSUInteger)capacity noRetainRelease:(BOOL)noRR nilItems:(BOOL)nilItems
  {
  CArrayGrow((CArray*)self, capacity);
  self->_flags.noRR=     noRR    ?1:0;
  self->_flags.nilItems= nilItems?1:0;
  return self ;
  }
- (NSUInteger)capacity {return _size;}

- (void)dealloc
  {
  CArrayFreeInside(self);
  [super dealloc];
  }

#pragma mark Primitives

- (NSUInteger)count {return _count;}

- (id)objectAtIndex:(NSUInteger)i
  {
  return CArrayObjectAtIndex((CArray*)self,i);
  }

#pragma mark Global methods


@end
