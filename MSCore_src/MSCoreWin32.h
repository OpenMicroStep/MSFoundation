/* MSCoreWin32.h
 
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
 
 WARNING : outside the MSFoundation framework or the MSCore library,
 this header file cannot be included alone, please direclty include
 MSCore.h or MSFoundation.h
 
 */

#ifndef MS_CORE_WIN32_H
#define MS_CORE_WIN32_H

#ifdef WO451
#  define restrict
#  ifndef LLONG_MIN
#    define LLONG_MIN MSLongMin
#  endif
#  ifndef LLONG_MAX
#    define LLONG_MAX MSLongMax
#  endif
#  ifndef ULLONG_MAX
#   define ULLONG_MAX MSULongMax
#  endif
#endif

#ifdef WIN32

#define MSExport  __declspec(dllexport) extern
#define MSImport  __declspec(dllimport) extern

#ifdef MSCORE_PRIVATE_H
#define MSCoreExport MSExport
#else
#define MSCoreExport MSImport
#endif


// No need anymore
//MSCoreExport MSULong strtoull(const char *string, char **endPtr, int base) ;
//MSCoreExport MSLong strtoll(const char *string, char **endPtr, int base) ;

// TODO: To be removed when %lld will be fixed
MSCoreExport char *ulltostr(MSLong value, char *ptr, int base) ;

MSCoreExport float strtof(const char *string, char **endPtr) ;

MSCoreExport int vasprintf( char **, char *, va_list );
MSCoreExport int snprintf(char *, size_t, const char *, ...);
MSCoreExport int vsnprintf(char *, size_t, const char *, va_list);

#else // !WIN32

#define MSCoreExport extern

#endif

#endif // MS_CORE_WIN32_H
