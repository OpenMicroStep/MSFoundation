/* MSCorePlatform-unix.c
 
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

#include "MSCore_Private.h"

#ifdef UNIX

#include <uuid/uuid.h>
#include <sys/time.h> // for gettimeofday

void uuid_generate_string(char dst[37])
{
  uuid_t uuid;
  uuid_generate_random ( uuid );
  uuid_unparse ( uuid, dst );
}

MSLong gmt_micro(void)
{
  MSLong t;
  struct timeval tv;
  gettimeofday(&tv,NULL);
  t= ((MSTimeInterval)tv.tv_sec - CDateSecondsFrom19700101To20010101)*1000000 + tv.tv_usec;
  return t;
}

MSTimeInterval gmt_now(void)
{
  MSTimeInterval t;
  time_t timet= time(NULL);
  t= (MSTimeInterval)timet - CDateSecondsFrom19700101To20010101;
  return t;
}

MSTimeInterval gmt_to_local(MSTimeInterval tIn)
{
  MSTimeInterval tOut;
  struct tm tm;
  time_t timet= tIn + CDateSecondsFrom19700101To20010101;
  (void)localtime_r(&timet, &tm);
  tOut= (MSTimeInterval)timet - CDateSecondsFrom19700101To20010101 + (MSTimeInterval)(tm.tm_gmtoff);
  return tOut;
}

MSTimeInterval gmt_from_local(MSTimeInterval t)
{
  _dtm dtm= _dtmCast(t);
  struct tm tm= {dtm.second,dtm.minute,dtm.hour,
                 dtm.day,dtm.month-1,(int)(dtm.year-1900),0,0,-1,0,NULL};
  time_t timet= mktime(&tm);
  t= (MSTimeInterval)timet-CDateSecondsFrom19700101To20010101;
  return t;
}

#endif
