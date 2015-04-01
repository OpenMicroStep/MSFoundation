/* MSCorePlatform_Private.h
 
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
 
 WARNING : this header file IS PRIVATE, don't use it directly
 AND NEVER INCLUDE IT IN MSFoundation framework, it is maint to
 be exclusively used in MSCore standalone mode
 
 */

#ifndef MSCORE_PLATFORM_PRIVATE_H
#define MSCORE_PLATFORM_PRIVATE_H

void uuid_generate_string(char dst[37]);

MSLong         gmt_micro(void);
MSTimeInterval gmt_now(void);
MSTimeInterval gmt_to_local(MSTimeInterval tIn);
MSTimeInterval gmt_from_local(MSTimeInterval t);


// Needed for UNIX-gmt_from_local()
// Implemented in MSCDate.c
#pragma mark _dtm declarations

typedef struct _dtmStruct {
  unsigned long long year:32;
  unsigned long long month:4;
  unsigned long long day:5;
  unsigned long long hour:5;
  unsigned long long minute:6;
  unsigned long long second:6;
  unsigned long long dayOfWeek:3;
  unsigned long long :3;
  }
_dtm;

_dtm _dtmCast(MSTimeInterval ref);

#endif // MSCORE_PLATFORM_PRIVATE_H