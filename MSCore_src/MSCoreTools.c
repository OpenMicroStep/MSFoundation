/*
 
 MSCoreTools.c
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 Eric Baradat :  k18rt@free.fr
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

#include "MSCore.h"

#pragma mark ***** Sort

// good value for stride factor is not well
#define STRIDE_FACTOR 3 // understood 3 is a fairly good choice (Sedgewick)

void MSSort(void **ps, NSUInteger count, NSComparisonResult (*compareFunction)(void*, void*, void*), void *context)
  {
  NSUInteger c, d, stride= 1; // Shell sort algorithm from SortingInAction (an old NeXT example)
  BOOL found;
  
  while (stride <= count) stride= stride * STRIDE_FACTOR + 1;
  
  while (stride > (STRIDE_FACTOR - 1)) {
    // loop to sort for each value of stride
    stride= stride / STRIDE_FACTOR;
    for (c= stride; c < count; c++) {
      found= NO;
      
      if (stride > c) break;
      d= c - stride;
      while (!found) { // move to left until the correct place is found
        id a= ps[d + stride];
        id b= ps[d];
        
        if ((*compareFunction)(a, b, context) == NSOrderedAscending) {
          ps[d + stride]= b;
          ps[d]= a;
          if (stride > d) break;
          // jump by stride factor
          d-= stride;}
        else found= YES;}}}
  }
