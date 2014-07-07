/*
 
 MHOpenSSLPrivate.h
 
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
 */

#import "MSNet_Private.h"
#import <openssl/ssl.h>

// Pointer to array of locks.
static mutex_t *lock_cs;

// This function allocates and initializes the lock array
// and registers the callbacks. This should be called
// after the OpenSSL library has been initialized and
// before any new threads are created.  
static void _thread_setup()
{
    int i;
    
    // Allocate lock array according to OpenSSL's requirements
    lock_cs=OPENSSL_CRYPTO_malloc((int)(OPENSSL_CRYPTO_num_locks() * sizeof(mutex_t)),__FILE__,__LINE__);

    // Initialize the locks
    for (i=0; i<OPENSSL_CRYPTO_num_locks(); i++)
    {
        mutex_init((lock_cs[i]));
    }
    
    // Register callbacks
    OPENSSL_CRYPTO_THREADID_set_callback((void (*)(void *))mash_thread_id_callback);
    OPENSSL_CRYPTO_set_locking_callback((void (*)())mash_locking_callback);
}

// This function deallocates the lock array and deregisters the
// callbacks. It should be called after all threads have
// terminated.  
static void _thread_cleanup()
{
    int i;
    
    // Deregister locking callback. No real need to
    // deregister id callback.
    OPENSSL_CRYPTO_set_locking_callback(NULL);
    
    // Destroy the locks
    for (i=0; i<OPENSSL_CRYPTO_num_locks(); i++)
    {
        mutex_delete((lock_cs[i]));
    }
    
    // Release the lock array.
    OPENSSL_CRYPTO_free(lock_cs);
}

SSL_CTX* MHCreateClientSSLContext(long sslOptions) {
    SSL_METHOD *method ;
    SSL_CTX *ctx ;
    
    method = (SSL_METHOD *) OPENSSL_SSLv23_method() ;  /* create new server-method instance */
    ctx = OPENSSL_SSL_CTX_new(method) ;   /* create new context from method */
    if ( ctx == NULL )
    {
        MHServerLogWithLevel(MHLogError, MSGetOpenSSLErrStr()) ;
        return NULL ;
    }
    
    //Set options
    if(sslOptions) { OPENSSL_SSL_CTX_set_options(ctx, sslOptions) ; }
    
    OPENSSL_SSL_CTX_set_mode(ctx, SSL_MODE_AUTO_RETRY) ;
    
    return ctx ;
}

SSL_CTX* MHCreateServerSSLContext(long sslOptions, BOOL twoWayAuth)
{
    SSL_CTX *ctx = MHCreateClientSSLContext(sslOptions) ;
    
    if(twoWayAuth)
    {
        int authCtxID = [MHSSLServerSocket twoWayAuthCtxID] ;
        OPENSSL_SSL_CTX_set_session_id_context(ctx, (void *)&authCtxID, sizeof(authCtxID)) ;
        OPENSSL_SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER|SSL_VERIFY_FAIL_IF_NO_PEER_CERT, NULL) ;
        
    } else {
        int authCtxID = [MHSSLServerSocket oneWayAuthCtxID] ;
        OPENSSL_SSL_CTX_set_session_id_context(ctx, (void *)&authCtxID, sizeof(authCtxID)) ;
        OPENSSL_SSL_CTX_set_verify(ctx, SSL_VERIFY_NONE, NULL) ;
    }
    
    return ctx;  
}  

MSInt MHLoadCertificate(SSL_CTX* ctx, char* certFile, char* keyFile)
{
    /* set the local certificate from CertFile */  
    if ( OPENSSL_SSL_CTX_use_certificate_file(ctx, certFile, SSL_FILETYPE_PEM) <= 0 )  
    {  
        OPENSSL_ERR_print_errors_fp(stderr);  
        return EXIT_FAILURE;  
    }  
    /* set the private key from KeyFile (may be the same as CertFile) */  
    if ( OPENSSL_SSL_CTX_use_PrivateKey_file(ctx, keyFile, SSL_FILETYPE_PEM) <= 0 )  
    {  
        OPENSSL_ERR_print_errors_fp(stderr);  
        return EXIT_FAILURE;  
    }  
    /* verify private key */  
    if ( !OPENSSL_SSL_CTX_check_private_key(ctx) )
    {  
        MHServerLogWithLevel(MHLogCritical, @"Private key does not match the public certificate") ;
        return EXIT_FAILURE;  
    }
    
    return EXIT_SUCCESS;
}

void MHInitSSL()
{
    OPENSSL_initialize() ; //load openssl functions
    OPENSSL_SSL_library_init() ; //initializes open ssl
    OPENSSL__add_all_algorithms();  /* load & register all cryptos, etc. */
    OPENSSL_SSL_load_error_strings();   /* load all error messages */ 
    
    _thread_setup();
}

void MHCleanSSL(SSL_CTX *ctx)
{
    OPENSSL_SSL_CTX_free(ctx);
    _thread_cleanup() ;
}

// Locking callback. The type, file and line arguments are
// ignored. The file and line may be used to identify the site of the
// call in the OpenSSL library for diagnostic purposes if required.
void mash_locking_callback(int mode, int type, char *file, int line)
{
    if (mode & CRYPTO_LOCK)
    {
        mutex_lock((lock_cs[type]));
    }
    else
    {
        mutex_unlock((lock_cs[type]));
    }
}

// Thread id callback.
void mash_thread_id_callback(CRYPTO_THREADID *id)
{
    OPENSSL_CRYPTO_THREADID_set_numeric(id, (unsigned long)thread_id()) ;
}
