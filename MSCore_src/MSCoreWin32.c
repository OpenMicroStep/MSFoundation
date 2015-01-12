/* MSCoreWin32.c
 
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

#ifdef WIN32

#include "MSCore_Private.h"

float strtof(const char *string, char **endPtr)
{
    return (float)strtod(string, endPtr) ;
}

char *ulltostr(MSLong value, char *ptr, int base)
{
    MSLong t = 0, res = 0;
    MSLong tmp = value;
    int count = 0;
    
    if (NULL == ptr)
    {
        return NULL;
    }
    
    if (tmp == 0)
    {
        count++;
    }
    
    while(tmp > 0)
    {
        tmp = tmp/base;
        count++;
    }
    ptr += count;
    *ptr = '\0';
    do
    {
        res = value - base * (t = value / base);
        if (res < 10)
        {
            * --ptr = '0' + res;
        }
        else if ((res >= 10) && (res < 16))
        {
            * -- ptr = 'A' - 10 + res;
        }
    } while ((value = t) != 0);
    
    return(ptr);
}

int vasprintf( char **sptr, char *fmt, va_list argv )
{
    int wanted = vsnprintf( *sptr = NULL, 0, fmt, argv );
    if( (wanted > 0) && ((*sptr = malloc( 1 + wanted )) != NULL) )
        return vsprintf( *sptr, fmt, argv );
    
    return wanted;
}

int snprintf(char *str, size_t size, const char *format, ...)
{
  int ret;
  va_list ap;
  va_start(ap, format);
  ret = (int)_vsnprintf(str, size, format, ap);
  va_end(ap);
  return ret;
}

int vsnprintf(char *str, size_t size, const char *format, va_list ap)
{ return _vsnprintf(str, size, format, ap); }

#endif
