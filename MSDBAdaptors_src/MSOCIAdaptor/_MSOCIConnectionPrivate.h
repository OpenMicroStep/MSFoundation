/*
 
 _MSOCIConnectionPrivate.h
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011

 Jean-Michel BERTHEAS : jean-michel.bertheas@club-internet.fr
 Frederic Olivi : fred.olivi@free.fr
 
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
 
 WARNING : this header file IS PRIVATE, please direclty
 include <MSFoundation/MSFoundation.h>
 */

#import <oci.h>

typedef struct {
    OCIEnv* henv;  
	OCIError* herror;
    OCIServer* hserver;
    OCISvcCtx* hservice;
    OCISession *hsesssion;
   
} OCICtx;



@interface _MSOCIThreadContext : NSObject
{
    @private
    OCICtx _ctx;
}

- (OCICtx *)context ;

@end

#define OCI_SUCCEEDED(rc)	(((rc) & (~1)) == 0)
#define OCI_NO_ERROR(res)   ((res) == OCI_SUCCESS)
#define OCI_NO_WARNING(status) ( ((status) == OCI_SUCCESS) || ((status) == OCI_NO_DATA) || ((status) == OCI_NEED_DATA) || ((status) == OCI_SUCCESS_WITH_INFO) )


#define OCI_CALL(res, ctx, fct)             \
{                                                  \
    if ((res) == TRUE)                                 \
    {                                                  \
        (res) = (BOOL) fct;                             \
        if (OCI_NO_ERROR((res)) == FALSE)                  \
        {                                                  \
            text errbuf[512];\
            sb4 errcode = 0;\
            (res) = ((res) == OCI_SUCCESS_WITH_INFO);          \
            (void) OCIErrorGet((dvoid *)ctx->herror, (ub4) 1, (text *) NULL, &errcode,errbuf, (ub4) sizeof(errbuf), OCI_HTYPE_ERROR);\
                NSLog(@"Error - errcode = %u : %@", errcode, [NSString stringWithFormat:@"%s",errbuf]); \
        }                                                  \
        else                                               \
            (res) = TRUE;                                      \
    }                                                  \
}


#define OCI_CALL_NO_WARNING(status, ctx, fct)     \
{                                                  \
    (status) = fct;                                    \
    if (OCI_NO_WARNING((status)) == FALSE)             \
    {                                                  \
        text errbuf[512];\
        sb4 errcode = 0;\
        (void) OCIErrorGet((dvoid *)ctx->herror, (ub4) 1, (text *) NULL, &errcode,errbuf, (ub4) sizeof(errbuf), OCI_HTYPE_ERROR); \
        NSLog(@"Error - %@", [NSString stringWithFormat:@"%s",errbuf]); \
    }                                                  \
}
