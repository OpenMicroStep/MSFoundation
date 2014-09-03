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

#warning __errno use is not thread safe
static MSUInt __errno = 0 ;
#define ERANGE		34

static char cvtIn[] = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9,               /* '0' - '9' */
    100, 100, 100, 100, 100, 100, 100,          /* punctuation */
    10, 11, 12, 13, 14, 15, 16, 17, 18, 19,     /* 'A' - 'Z' */
    20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
    30, 31, 32, 33, 34, 35,
    100, 100, 100, 100, 100, 100,               /* punctuation */
    10, 11, 12, 13, 14, 15, 16, 17, 18, 19,     /* 'a' - 'z' */
    20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
    30, 31, 32, 33, 34, 35};


/*CONST char *string;	     String of ASCII digits, possibly
 * preceded by white space.  For bases
 * greater than 10, either lower- or
 * upper-case digits may be used.
 */
/*char **endPtr;	     Where to store address of terminating
 * character, or NULL. */
/*int base;			 Base for conversion.  Must be less
 * than 37.  If 0, then the base is chosen
 * from the leading characters of string:
 * "0x" means hex, "0" means octal, anything
 * else means decimal.
 */
MSULong strtoull(const char *string, char **endPtr, int base)
{
    register const char *p;
    register MSULong result = 0;
    register unsigned digit;
    register MSULong shifted;
    int anyDigits = 0, negative = 0;
    
    /*
     * Skip any leading blanks.
     */
    
    p = string;
    while (isspace((unsigned char)(*p))) {	/* INTL: locale-dependent */
        p += 1;
    }
    
    /*
     * Check for a sign.
     */
    
    if (*p == '-') {
        p += 1;
        negative = 1;
    } else {
        if (*p == '+') {
            p += 1;
        }
    }
    
    /*
     * If no base was provided, pick one from the leading characters
     * of the string.
     */
    
    if (base == 0) {
        if (*p == '0') {
            p += 1;
            if (*p == 'x' || *p == 'X') {
                p += 1;
                base = 16;
            } else {
                
                /*
                 * Must set anyDigits here, otherwise "0" produces a
                 * "no digits" error.
                 */
                
                anyDigits = 1;
                base = 8;
            }
        } else {
            base = 10;
        }
    } else if (base == 16) {
        
        /*
         * Skip a leading "0x" from hex numbers.
         */
        
        if ((p[0] == '0') && (p[1] == 'x' || *p == 'X')) {
            p += 2;
        }
    }
    
    /*
     * Sorry this code is so messy, but speed seems important.  Do
     * different things for base 8, 10, 16, and other.
     */
    
    if (base == 8) {
        for ( ; ; p += 1) {
            digit = *p - '0';
            if (digit > 7) {
                break;
            }
            shifted = result << 3;
            if ((shifted >> 3) != result) {
                goto overflow;
            }
            result = shifted + digit;
            if ( result < shifted ) {
                goto overflow;
            }
            anyDigits = 1;
        }
    } else if (base == 10) {
        for ( ; ; p += 1) {
            digit = *p - '0';
            if (digit > 9) {
                break;
            }
            shifted = 10 * result;
            if ((shifted / 10) != result) {
                goto overflow;
            }
            result = shifted + digit;
            if ( result < shifted ) {
                goto overflow;
            }
            anyDigits = 1;
        }
    } else if (base == 16) {
        for ( ; ; p += 1) {
            digit = *p - '0';
            if (digit > ('z' - '0')) {
                break;
            }
            digit = cvtIn[digit];
            if (digit > 15) {
                break;
            }
            shifted = result << 4;
            if ((shifted >> 4) != result) {
                goto overflow;
            }
            result = shifted + digit;
            if ( result < shifted ) {
                goto overflow;
            }
            anyDigits = 1;
        }
    } else if ( base >= 2 && base <= 36 ) {
        for ( ; ; p += 1) {
            digit = *p - '0';
            if (digit > ('z' - '0')) {
                break;
            }
            digit = cvtIn[digit];
            if (digit >= (unsigned) base) {
                break;
            }
            shifted = result * base;
            if ((shifted/base) != result) {
                goto overflow;
            }
            result = shifted + digit;
            if ( result < shifted ) {
                goto overflow;
            }
            anyDigits = 1;
        }
    }
    
    /*
     * Negate if we found a '-' earlier.
     */
    
    if (negative) {
        result = (MSULong)(-((MSLong)result));
    }
    
    /*
     * See if there were any digits at all.
     */
    
    if (!anyDigits) {
        p = string;
    }
    
    if (endPtr != 0) {
        *endPtr = (char *) p;
    }
    
    return result;
    
    /*
     * On overflow generate the right output
     */
    
overflow:
    __errno = ERANGE;
    if (endPtr != 0) {
        for ( ; ; p += 1) {
            digit = *p - '0';
            if (digit > ('z' - '0')) {
                break;
            }
            digit = cvtIn[digit];
            if (digit >= (unsigned) base) {
                break;
            }
        }
        *endPtr = (char *) p;
    }
    return (MSULong)(-1);
}

MSLong strtoll(const char *string, char **endPtr, int base)
{
    register const char *p;
    MSLong result = (MSLong)0;
    MSULong uwResult;
    
    /*
     * Skip any leading blanks.
     */
    
    p = string;
    while (isspace((unsigned char)(*p))) {
        p += 1;
    }
    
    /*
     * Check for a sign.
     */
    
    __errno = 0;
    if (*p == '-') {
        p += 1;
        uwResult = strtoull(p, endPtr, base);
        if (__errno != ERANGE) {
            if (uwResult > ((MSULong)MSLongMax+1)) {
                __errno = ERANGE;
                return (MSLong)(MSLongMin);
            } else if (uwResult > MSLongMax) {
                return ~((MSLong)MSLongMax);
            } else {
                result = -((MSLong) uwResult);
            }
        }
    } else {
        if (*p == '+') {
            p += 1;
        }
        uwResult = strtoull(p, endPtr, base);
        if (__errno != ERANGE) {
            if (uwResult > MSLongMax) {
                __errno = ERANGE;
                return (MSLong)(MSLongMax);
            } else {
                result = uwResult;
            }
        }
    }
    if ((result == 0) && (endPtr != 0) && (*endPtr == p)) {
        *endPtr = (char *) string;
    }
    return result;
}


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
