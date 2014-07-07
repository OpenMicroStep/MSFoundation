/*
 
 _CurlPrivateInterface.h
 
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

#import <curl/curl.h>

//OpenSSL cross-plateform functions
MSExport void			CURL_initialize(void) ;

MSExport int            MS_curl_global_init(long flags);
MSExport void *			MS_curl_easy_init(void) ;
MSExport void			MS_curl_easy_cleanup(void *handle) ;
MSExport int			MS_curl_easy_perform(void * handle ) ;
MSExport const char *   MS_curl_easy_strerror(int errornum) ;
MSExport void			MS_curl_slist_free_all(void *list) ;
MSExport void *			MS_curl_slist_append(void * list, const char * string ) ;

//Rewrite argument specific functions since we cannot wrap the function that uses a va_list to hide te type of the argument
MSExport int            MS_curl_easy_setopt_func(void *handle, int option, size_t (*function) ( char *ptr, size_t size, size_t nmemb, void *userdata)) ;
MSExport int            MS_curl_easy_setopt_pntr(void *handle, int option, void *ptr_param) ;
MSExport int            MS_curl_easy_setopt_long(void *handle, int option, long param) ;
MSExport int            MS_curl_easy_setopt_offt(void *handle, int option, curl_off_t param) ;

