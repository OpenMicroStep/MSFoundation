/*
 
 _CurlPrivateInterface.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Geoffrey Guilbon : gguilbon@gmail.com
 
 
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
 
 WARNING : this header file cannot be included alone, please direclty
 include <MSFoundation/MSFoundation.h>
 
 A call to the MSFoundation initialize function must be done before using
 these functions.
 */

#import "MSNet_Private.h"

#ifdef WIN32

static HINSTANCE __curl_DLL = (HINSTANCE)NULL;

typedef CURLcode        (__stdcall *DLL_MS_curl_global_init) () ;
typedef CURL *          (__stdcall *DLL_MS_curl_easy_init) () ;
typedef void            (__stdcall *DLL_MS_curl_easy_cleanup) () ;
typedef CURLcode        (__stdcall *DLL_MS_curl_easy_perform) (CURL *) ;
typedef const char *    (__stdcall *DLL_MS_curl_easy_strerror) (CURLcode) ;
typedef CURLcode        (__cdecl   *DLL_MS_curl_easy_setopt) (CURL *, CURLoption , ...) ;
typedef void            (__stdcall *DLL_MS_curl_slist_free_all) () ;
typedef void *          (__stdcall *DLL_MS_curl_slist_append) () ;

static DLL_MS_curl_global_init              __MS_curl_global_init ;
static DLL_MS_curl_easy_init                __MS_curl_easy_init ;
static DLL_MS_curl_easy_cleanup             __MS_curl_easy_cleanup ;
static DLL_MS_curl_easy_perform             __MS_curl_easy_perform ;
static DLL_MS_curl_easy_strerror            __MS_curl_easy_strerror ;
static DLL_MS_curl_easy_setopt              __MS_curl_easy_setopt ;
static DLL_MS_curl_slist_free_all           __MS_curl_slist_free_all ;
static DLL_MS_curl_slist_append             __MS_curl_slist_append ;


void CURL_initialize()
{
    if(!__curl_DLL)
    {
        __curl_DLL = MSLoadDLL(@"libcurl.dll") ;
        
        if (__curl_DLL != NULL) {
            
            __MS_curl_global_init               = (DLL_MS_curl_global_init)     GetProcAddress(__curl_DLL, "curl_global_init") ;
            __MS_curl_easy_init                 = (DLL_MS_curl_easy_init)       GetProcAddress(__curl_DLL, "curl_easy_init") ;
            __MS_curl_easy_cleanup              = (DLL_MS_curl_easy_cleanup)	GetProcAddress(__curl_DLL, "curl_easy_cleanup") ;
            __MS_curl_easy_perform              = (DLL_MS_curl_easy_perform)	GetProcAddress(__curl_DLL, "curl_easy_perform") ;
            __MS_curl_easy_strerror				= (DLL_MS_curl_easy_strerror)   GetProcAddress(__curl_DLL, "curl_easy_strerror") ;
            __MS_curl_easy_setopt				= (DLL_MS_curl_easy_setopt)		GetProcAddress(__curl_DLL, "curl_easy_setopt") ;
            __MS_curl_slist_free_all            = (DLL_MS_curl_slist_free_all)	GetProcAddress(__curl_DLL, "curl_slist_free_all") ;
            __MS_curl_slist_append              = (DLL_MS_curl_slist_append )	GetProcAddress(__curl_DLL, "curl_slist_append") ;
              
            if (!(	__MS_curl_global_init &&
                  __MS_curl_easy_init &&
                  __MS_curl_easy_cleanup &&
                  __MS_curl_easy_perform &&
                  __MS_curl_easy_strerror &&
                  __MS_curl_easy_setopt &&
                  __MS_curl_slist_free_all &&
                  __MS_curl_slist_append
                  ))
            {
                if(!__MS_curl_global_init)		NSLog(@"__MS_curl_global_init NULL");
                if(!__MS_curl_easy_init)		NSLog(@"__MS_curl_easy_init NULL");
                if(!__MS_curl_easy_cleanup)		NSLog(@"__MS_curl_easy_cleanup NULL");
                if(!__MS_curl_easy_perform)		NSLog(@"__MS_curl_easy_perform NULL");
                if(!__MS_curl_easy_strerror)    NSLog(@"__MS_curl_easy_strerror NULL");
                if(!__MS_curl_easy_setopt)		NSLog(@"__MS_curl_easy_setopt NULL");
                if(!__MS_curl_slist_free_all)	NSLog(@"__MS_curl_slist_free_all NULL");
                if(!__MS_curl_slist_append)     NSLog(@"__MS_curl_slist_append NULL");
                
                MSRaise(NSGenericException, @"Error while loading libcurl library") ;
            }
            
        }
        else {
            MSRaise(NSGenericException, @"Error while loading libcurl library") ;
        }
    }
}

#else

void CURL_initialize() { }

#define __MS_curl_global_init(X) curl_global_init(X)
#define __MS_curl_easy_init() curl_easy_init()
#define __MS_curl_easy_cleanup(X) curl_easy_cleanup(X)
#define __MS_curl_easy_perform(X) curl_easy_perform(X)
#define __MS_curl_easy_strerror(X) curl_easy_strerror(X)
#define __MS_curl_easy_setopt(X, Y, Z) curl_easy_setopt(X, Y, Z)
#define __MS_curl_slist_free_all(X) curl_slist_free_all(X)
#define __MS_curl_slist_append(X, Y) curl_slist_append(X, Y)

#endif

int             MS_curl_global_init(long flags) { return (int)__MS_curl_global_init(flags) ; }
void *          MS_curl_easy_init(void) { return (void *)__MS_curl_easy_init() ; }
void            MS_curl_easy_cleanup(void *handle) { __MS_curl_easy_cleanup((CURL *)handle) ; }
int             MS_curl_easy_perform(void * handle ) { return (int)__MS_curl_easy_perform((CURL *)handle ) ; }
const char *    MS_curl_easy_strerror(int errornum) { return __MS_curl_easy_strerror((CURLcode)errornum) ; }
void            MS_curl_slist_free_all(void* list) { return __MS_curl_slist_free_all(list) ; }
void *          MS_curl_slist_append(void * list, const char * string ) { return __MS_curl_slist_append(list, string) ; }
//struct curl_slist *curl_slist_append(struct curl_slist * list, const char * string );

int             MS_curl_easy_setopt_func(void *handle, int option, size_t (*function) (char *ptr, size_t size, size_t nmemb, void *userdata)) { return __MS_curl_easy_setopt((CURL *)handle, (CURLoption)option, function) ; }
int             MS_curl_easy_setopt_pntr(void *handle, int option, void *ptr_param) { return __MS_curl_easy_setopt((CURL *)handle, (CURLoption)option, ptr_param) ; }
int             MS_curl_easy_setopt_long(void *handle, int option, long param) { return __MS_curl_easy_setopt((CURL *)handle, (CURLoption)option, param) ; }
int             MS_curl_easy_setopt_offt(void *handle, int option, curl_off_t param) { return __MS_curl_easy_setopt((CURL *)handle, (CURLoption)option, param) ; }
