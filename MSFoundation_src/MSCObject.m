/* MSCObject.m
 
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
 
 WARNING : the CObject mechanism is NOT Thread Safe. Each object
 must be allocated, retained, autoreleased, released in the same thread.
 
 */

#import "MSFoundation_Private.h"

#pragma mark NSObject hash:

@interface NSObject (Private)
- (NSUInteger)hash:(unsigned)depth;
@end
@implementation NSObject (Private)
- (NSUInteger)hash:(unsigned)depth {return [self hash]; depth=0;}
@end

#pragma mark MSCore compatibility

Class _MIsa(id obj)
{
  return ISA(obj);
}

const char *_MNameOfClass(id obj)
{
  return NAMEOFCLASS(obj);
}

id _MRetain(id obj)
{
  return [obj retain];
}

void _MRelease(id obj)
{
  [obj release];
}

id _MAutorelease(id obj)
{
  return [obj autorelease];
}

NSUInteger _MRetainCount(id obj)
{
  return [obj retainCount];
}

BOOL _MObjectIsEqual(id obj1, id obj2)
{
  return (obj1 == obj2) || [obj1 isEqual:obj2];
}

NSUInteger _MObjectHashDepth(id obj, unsigned depth)
{
  return [obj hash:depth];
}

NSUInteger _MObjectHash(id obj)
{
  return [obj hash:0];
}

id _MObjectCopy(id obj)
{
  return [obj copyWithZone:NULL];
}

void _MSFoundationCoreSystemInitialize()
{
}

id MSCreateObjectWithClassIndex(CClassIndex classIndex)
{
  static NSString *__allCLikeClasses[CClassIndexMax+1]= {
    @"MSArray",
    @"MSBuffer",
    @"_MSRGBAColor",
    @"MSCouple",
    @"MSDate",
    @"MSDecimal",
    @"MSDictionary",
    0,//MSMutex,
    @"MSString"};
  
  Class aClass= NSClassFromString(__allCLikeClasses[classIndex]);
  id obj= nil;
  if (!aClass) {
    MSReportError(MSInvalidArgumentError, MSFatalError, MSNULLPointerError,
                  "%s(): try to allocate object with classIndex %lu.",
                  "MSCreateObjectWithClassIndex",(unsigned long)classIndex);}
  else {obj= [MSAllocateObject(aClass, 0, NULL) init];}
  return obj;
}

