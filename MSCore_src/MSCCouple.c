/* MSCCouple.c
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Eric Baradat :  k18rt@free.fr
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

#include "MSCore_Private.h"

#pragma mark c-like class methods

void CCoupleFreeInside(id self)
{
  if (self) {
    RELEASE(((CCouple*)self)->members[0]);
    RELEASE(((CCouple*)self)->members[1]);}
}
void CCoupleFree(id self)
{
  CCoupleFreeInside(self);
  MSFree(self, "CCoupleFree() [self]");
}

BOOL CCoupleIsEqual(id self, id other)
{
  return _CClassIsEqual(self,other,(CObjectEq)CCoupleEquals);
}

NSUInteger CCoupleHash(id self, unsigned depth)
{
  if (depth == MSMaxHashingHop) {
    return (((CCouple*)self)->members[0] ? 1 : 0) +
           (((CCouple*)self)->members[1] ? 2 : 0);}
  else {
    depth++;
    return HASHDEPTH(((CCouple*)self)->members[0], depth) ^
           HASHDEPTH(((CCouple*)self)->members[1], depth);
  }
}

id CCoupleCopy(id self)
{
  CCouple *newCpl;
  if (!self) return nil;
  newCpl= (CCouple*)MSCreateObjectWithClassIndex(CCoupleClassIndex);
  CCoupleSetFirstMember (newCpl, ((CCouple*)self)->members[0]);
  CCoupleSetSecondMember(newCpl, ((CCouple*)self)->members[1]);
  return (id)newCpl;
}

const CString* CCoupleRetainedDescription(id self)
{
  CString *s; const CCouple *a;
  if(!self) return nil;
  a= (CCouple *)self;
  s= CCreateString(0);
  CStringAppendFormat(s, "[%@, %@]", a->members[0], a->members[1]);
  return s;
}

#pragma mark Equality

BOOL CCoupleEquals(const CCouple *self, const CCouple *other)
{
  if (self == other) return YES;
  if (self && other) {
    return  ISEQUAL(self->members[0], other->members[0]) &&
            ISEQUAL(self->members[1], other->members[1]);}
  return NO;
}

#pragma mark Creation

CCouple *CCreateCouple(id firstMember, id secondMember)
{
  CCouple *newCpl;
  newCpl= (CCouple*)MSCreateObjectWithClassIndex(CCoupleClassIndex);
  CCoupleSetFirstMember (newCpl, firstMember );
  CCoupleSetSecondMember(newCpl, secondMember);
  return newCpl;
}

#pragma mark Management

id CCoupleFirstMember (CCouple *self) { return self ? self->members[0] : nil; }
id CCoupleSecondMember(CCouple *self) { return self ? self->members[1] : nil; }

void CCoupleSetFirstMember (CCouple *self, id member)
{
  if (self) ASSIGN(self->members[0], member);
}
void CCoupleSetSecondMember(CCouple *self, id member)
{
  if (self) ASSIGN(self->members[1], member);
}
