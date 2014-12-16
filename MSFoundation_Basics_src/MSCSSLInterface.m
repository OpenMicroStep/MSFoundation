/*
 
 MSCSSLInterface.c
 
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
 */

#import "MSFoundation_Private.h"
#import <openssl/ssl.h>
//#import <openssl/crypto.h>
#import <openssl/err.h>
#import <openssl/rand.h>
//#import <openssl/evp.h>


#ifdef WIN32

#warning Was in ".c" before targetting wo451, MUST BE checked

#define APPLINK_STDIN	1
#define APPLINK_STDOUT	2
#define APPLINK_STDERR	3
#define APPLINK_FPRINTF	4
#define APPLINK_FGETS	5
#define APPLINK_FREAD	6
#define APPLINK_FWRITE	7
#define APPLINK_FSETMOD	8
#define APPLINK_FEOF	9
#define APPLINK_FCLOSE 	10	/* should not be used */

#define APPLINK_FOPEN	11	/* solely for completeness */
#define APPLINK_FSEEK	12
#define APPLINK_FTELL	13
#define APPLINK_FFLUSH	14
#define APPLINK_FERROR	15
#define APPLINK_CLEARERR 16
#define APPLINK_FILENO	17	/* to be used with below */

#define APPLINK_OPEN	18	/* formally can't be used, as flags can vary */
#define APPLINK_READ	19
#define APPLINK_WRITE	20
#define APPLINK_LSEEK	21
#define APPLINK_CLOSE	22
#define APPLINK_MAX	22	/* always same as last macro */

#ifndef APPMACROS_ONLY
#include <stdio.h>
#include <io.h>
#include <fcntl.h>

static void *app_stdin(void)		{ return stdin;  }
static void *app_stdout(void)		{ return stdout; }
static void *app_stderr(void)		{ return stderr; }
static int   app_feof(FILE *fp)		{ return feof(fp); }
static int   app_ferror(FILE *fp)	{ return ferror(fp); }
static void  app_clearerr(FILE *fp)	{ clearerr(fp); }
static int   app_fileno(FILE *fp)	{ return _fileno(fp); }
static int   app_fsetmod(FILE *fp,char mod)
{ return _setmode (_fileno(fp),mod=='b'?_O_BINARY:_O_TEXT); }

void ** _OPENSSL_Applink(void)
{ static int once=1;
    static void *OPENSSL_ApplinkTable[APPLINK_MAX+1]={(void *)APPLINK_MAX};
    
    if (once)
    {	OPENSSL_ApplinkTable[APPLINK_STDIN]	= app_stdin;
        OPENSSL_ApplinkTable[APPLINK_STDOUT]	= app_stdout;
        OPENSSL_ApplinkTable[APPLINK_STDERR]	= app_stderr;
        OPENSSL_ApplinkTable[APPLINK_FPRINTF]	= fprintf;
        OPENSSL_ApplinkTable[APPLINK_FGETS]	= fgets;
        OPENSSL_ApplinkTable[APPLINK_FREAD]	= fread;
        OPENSSL_ApplinkTable[APPLINK_FWRITE]	= fwrite;
        OPENSSL_ApplinkTable[APPLINK_FSETMOD]	= app_fsetmod;
        OPENSSL_ApplinkTable[APPLINK_FEOF]	= app_feof;
        OPENSSL_ApplinkTable[APPLINK_FCLOSE]	= fclose;
        
        OPENSSL_ApplinkTable[APPLINK_FOPEN]	= fopen;
        OPENSSL_ApplinkTable[APPLINK_FSEEK]	= fseek;
        OPENSSL_ApplinkTable[APPLINK_FTELL]	= ftell;
        OPENSSL_ApplinkTable[APPLINK_FFLUSH]	= fflush;
        OPENSSL_ApplinkTable[APPLINK_FERROR]	= app_ferror;
        OPENSSL_ApplinkTable[APPLINK_CLEARERR]	= app_clearerr;
        OPENSSL_ApplinkTable[APPLINK_FILENO]	= app_fileno;
        
        OPENSSL_ApplinkTable[APPLINK_OPEN]	= _open;
        OPENSSL_ApplinkTable[APPLINK_READ]	= _read;
        OPENSSL_ApplinkTable[APPLINK_WRITE]	= _write;
        OPENSSL_ApplinkTable[APPLINK_LSEEK]	= _lseek;
        OPENSSL_ApplinkTable[APPLINK_CLOSE]	= _close;
        
        once = 0;
    }
    
    return OPENSSL_ApplinkTable;
}

#endif


static HINSTANCE __libeay_DLL = (HINSTANCE)NULL;
static HINSTANCE __libssl_DLL = (HINSTANCE)NULL;

typedef void (__stdcall *DLL_OPENSSL_RSA_generate_key_callback)(int ,int ,void *);
typedef void (__stdcall *DLL_OPENSSL_ERR_load_crypto_strings) ();
typedef void (__stdcall *DLL_OPENSSL_ERR_error_string_n) (unsigned long, char *, size_t);
typedef unsigned long (__stdcall *DLL_OPENSSL_ERR_get_error) ();
typedef int (__stdcall *DLL_OPENSSL_RAND_bytes) (unsigned char *, int);
typedef int (__stdcall *DLL_OPENSSL_EVP_BytesToKey) (const EVP_CIPHER *,const EVP_MD *,const unsigned char *,const unsigned char *,int,int,unsigned char *,unsigned char *);
typedef void (__stdcall *DLL_OPENSSL_EVP_CIPHER_CTX_init) (EVP_CIPHER_CTX *);
typedef int (__stdcall *DLL_OPENSSL_EVP_CipherInit_ex) (EVP_CIPHER_CTX *, const EVP_CIPHER *, ENGINE *, unsigned char *, unsigned char *, int);
typedef int (__stdcall *DLL_OPENSSL_EVP_CipherUpdate) (EVP_CIPHER_CTX *, unsigned char *, int *, unsigned char *, int);
typedef int (__stdcall *DLL_OPENSSL_EVP_CipherFinal_ex) (EVP_CIPHER_CTX *, unsigned char *, int *);
typedef int (__stdcall *DLL_OPENSSL_EVP_CIPHER_CTX_cleanup) (EVP_CIPHER_CTX *);
typedef RSA * (__stdcall *DLL_OPENSSL_RSA_generate_key) (int , unsigned long , DLL_OPENSSL_RSA_generate_key_callback, void *);
typedef RSA * (__stdcall *DLL_OPENSSL_PEM_read_bio_RSA_PUBKEY) (BIO *, RSA **, pem_password_cb *, void *);
typedef RSA * (__stdcall *DLL_OPENSSL_PEM_read_bio_RSAPrivateKey) (BIO *, RSA **, pem_password_cb *, void *);
typedef int (__stdcall *DLL_OPENSSL_RSA_public_encrypt) (int, unsigned char *, unsigned char *, RSA *, int);
typedef int (__stdcall *DLL_OPENSSL_RSA_private_decrypt) (int , unsigned char *, unsigned char *, RSA *, int);
typedef int (__stdcall *DLL_OPENSSL_RSA_sign) (int, const unsigned char *, unsigned int, unsigned char *, unsigned int *, RSA *);
typedef int (__stdcall *DLL_OPENSSL_RSA_verify) (int, const unsigned char *, unsigned int, unsigned char *, unsigned int , RSA *);
typedef int (__stdcall *DLL_OPENSSL_PEM_write_bio_RSAPrivateKey) (BIO *, RSA *, const EVP_CIPHER *, unsigned char *, int ,	pem_password_cb *, void *);
typedef int (__stdcall *DLL_OPENSSL_PEM_write_bio_RSA_PUBKEY) (BIO *, RSA *);
typedef void (__stdcall *DLL_OPENSSL_RSA_free) (RSA *);
typedef BIO * (__stdcall *DLL_OPENSSL_BIO_new) (BIO_METHOD *);
typedef BIO * (__stdcall *DLL_OPENSSL_BIO_new_mem_buf) (void *, int);
typedef BIO_METHOD * (__stdcall *DLL_OPENSSL_BIO_s_mem) ();
typedef size_t (__stdcall *DLL_OPENSSL_BIO_ctrl_pending) (BIO *);
typedef int (__stdcall *DLL_OPENSSL_BIO_read) (BIO *, void *, int);
typedef void (__stdcall *DLL_OPENSSL_BIO_free_all) (BIO *);
typedef int (__stdcall *DLL_OPENSSL_BIO_free) (BIO *);
typedef int (__stdcall *DLL_OPENSSL_EVP_CIPHER_key_length) (const EVP_CIPHER *);
typedef int (__stdcall *DLL_OPENSSL_EVP_CIPHER_iv_length) (const EVP_CIPHER *);
typedef const EVP_CIPHER * (__stdcall *DLL_OPENSSL_EVP_aes_256_cbc) ();
typedef const EVP_CIPHER * (__stdcall *DLL_OPENSSL_EVP_aes_192_cbc) ();
typedef const EVP_CIPHER * (__stdcall *DLL_OPENSSL_EVP_aes_128_cbc) ();
typedef const EVP_CIPHER * (__stdcall *DLL_OPENSSL_EVP_bf_cbc) ();
typedef const EVP_CIPHER * (__stdcall *DLL_OPENSSL_EVP_bf_cfb64) ();
typedef const EVP_CIPHER * (__stdcall *DLL_OPENSSL_EVP_bf_ofb) ();
typedef int (__stdcall *DLL_OPENSSL_RSA_size) (const RSA *);
typedef EVP_CIPHER_CTX * (__stdcall *DLL_OPENSSL_EVP_CIPHER_CTX_new) ();
typedef void (__stdcall *DLL_OPENSSL_EVP_CIPHER_CTX_free) (EVP_CIPHER_CTX *a);
typedef const EVP_MD * (__stdcall *DLL_OPENSSL_EVP_md5) ();
typedef const EVP_MD * (__stdcall *DLL_OPENSSL_EVP_sha1) ();
typedef const EVP_MD * (__stdcall *DLL_OPENSSL_EVP_sha256) ();
typedef const EVP_MD * (__stdcall *DLL_OPENSSL_EVP_sha512) ();
typedef const EVP_MD * (__stdcall *DLL_OPENSSL_EVP_dss1) ();
typedef const EVP_MD * (__stdcall *DLL_OPENSSL_EVP_mdc2) ();
typedef const EVP_MD * (__stdcall *DLL_OPENSSL_EVP_ripemd160) ();
typedef void (__stdcall *DLL_OPENSSL_EVP_MD_CTX_init) (EVP_MD_CTX *ctx);
typedef int (__stdcall *DLL_OPENSSL_EVP_DigestInit_ex) (EVP_MD_CTX *ctx, const EVP_MD *type, ENGINE *impl);
typedef int (__stdcall *DLL_OPENSSL_EVP_DigestUpdate) (EVP_MD_CTX *ctx, const void *d, size_t cnt);
typedef int (__stdcall *DLL_OPENSSL_EVP_DigestFinal_ex) (EVP_MD_CTX *ctx, unsigned char *md, unsigned int *s);
typedef int (__stdcall *DLL_OPENSSL_EVP_MD_CTX_cleanup) (EVP_MD_CTX *ctx);
typedef BIO_METHOD * (__stdcall *DLL_OPENSSL_BIO_f_base64) ();
typedef BIO * (__stdcall *DLL_OPENSSL_BIO_push) (BIO *b,BIO *append);
typedef int (__stdcall *DLL_OPENSSL_BIO_write) (BIO *b, const void *data, int len);
typedef int (__stdcall *DLL_OPENSSL_BIO_ctrl) (BIO *bp,int cmd,long larg,void *parg);
typedef int (__stdcall *DLL_OPENSSL_BIO_set_flags) (BIO *b, int flags);
typedef void (__stdcall *DLL_OPENSSL_add_all_algorithms) ();
typedef void (__stdcall *DLL_OPENSSL_ERR_print_errors_fp) (FILE *fp);
typedef int (__stdcall *DLL_OPENSSL_SSL_library_init) ();
typedef const SSL_METHOD * (__stdcall *DLL_OPENSSL_SSLv23_method) ();
typedef const SSL_METHOD * (__stdcall *DLL_OPENSSL_SSLv2_method) ();
typedef const SSL_METHOD * (__stdcall *DLL_OPENSSL_SSLv3_method) ();
typedef const SSL_METHOD * (__stdcall *DLL_OPENSSL_TLSv1_method) ();
typedef const SSL_METHOD * (__stdcall *DLL_OPENSSL_TLSv1_1_method) ();
typedef void (__stdcall *DLL_OPENSSL_SSL_load_error_strings) ();
typedef SSL * (__stdcall *DLL_OPENSSL_SSL_new) (SSL_CTX *ctx);
typedef SSL_CTX * (__stdcall *DLL_OPENSSL_SSL_CTX_new) (const SSL_METHOD *meth);
typedef void (__stdcall *DLL_OPENSSL_SSL_CTX_free) (SSL_CTX *);
typedef int (__stdcall *DLL_OPENSSL_SSL_CTX_use_certificate_file) (SSL_CTX *ctx, const char *file, int type);
typedef int (__stdcall *DLL_OPENSSL_SSL_CTX_use_PrivateKey_file) (SSL_CTX *ctx, const char *file, int type);
typedef int (__stdcall *DLL_OPENSSL_SSL_CTX_check_private_key) (const SSL_CTX *ctx);
typedef int (__stdcall *DLL_OPENSSL_SSL_accept) (SSL *ssl);
typedef int (__stdcall *DLL_OPENSSL_SSL_read) (SSL *ssl,void *buf,int num);
typedef int (__stdcall *DLL_OPENSSL_SSL_write) (SSL *ssl,const void *buf,int num);
typedef int (__stdcall *DLL_OPENSSL_SSL_get_fd) (const SSL *s);
typedef int (__stdcall *DLL_OPENSSL_SSL_set_fd) (SSL *s, int fd);
typedef void (__stdcall *DLL_OPENSSL_SSL_free) (SSL *ssl);
typedef void * (__stdcall *DLL_OPENSSL_CRYPTO_malloc) (int num, const char *file, int line);
typedef int (__stdcall *DLL_OPENSSL_CRYPTO_num_locks) ();
typedef void (__stdcall *DLL_OPENSSL_CRYPTO_THREADID_set_numeric) (CRYPTO_THREADID *id, unsigned long val);
typedef void (__stdcall *DLL_OPENSSL_CRYPTO_THREADID_set_callback_callback)(CRYPTO_THREADID *);
typedef void (__stdcall *DLL_OPENSSL_CRYPTO_set_locking_callback_callback)(int mode,int type, const char *file,int line);
typedef int (__stdcall *DLL_OPENSSL_CRYPTO_THREADID_set_callback) (DLL_OPENSSL_CRYPTO_THREADID_set_callback_callback);
typedef void (__stdcall *DLL_OPENSSL_CRYPTO_set_locking_callback) (DLL_OPENSSL_CRYPTO_set_locking_callback_callback);
typedef void (__stdcall *DLL_OPENSSL_CRYPTO_free) (void *);
typedef SSL_CTX * (__stdcall *DLL_OPENSSL_SSL_get_SSL_CTX) (const SSL *ssl);
typedef int (__stdcall *DLL_OPENSSL_SSL_connect) (SSL *ssl);
typedef int (__stdcall *DLL_OPENSSL_CRYPTO_set_mem_functions) (void *(*m)(size_t),void *(*r)(void *,size_t), void (*f)(void *));
typedef int (__stdcall *DLL_OPENSSL_SSL_get_error) (const void *ssl, int ret);
typedef int (__stdcall *DLL_OPENSSL_SSL_CTX_ctrl) (void *ctx,int cmd, long larg, void *parg);
typedef int (__stdcall *DLL_OPENSSL_SSL_shutdown) (void *ssl);
typedef int (__stdcall *DLL_OPENSSL_SSL_get_shutdown) (void *ssl) ;
typedef int (__stdcall *DLL_OPENSSL_SSL_verify_callback) (int mode, void *store_ctx) ;
typedef void (__stdcall *DLL_OPENSSL_SSL_CTX_set_verify) (void *s, int mode, DLL_OPENSSL_SSL_verify_callback) ;
typedef void (__stdcall *DLL_OPENSSL_SSL_set_verify) (void *s, int mode, DLL_OPENSSL_SSL_verify_callback) ;
typedef void * (__stdcall *DLL_OPENSSL_SSL_get_peer_certificate) (const void *s) ;
typedef int (__stdcall *DLL_OPENSSL_SSL_CTX_set_session_id_context) (void *ctx, const unsigned char *sid_ctx, unsigned int sid_ctx_len) ;
typedef int (__stdcall *DLL_OPENSSL_SSL_CTX_load_verify_locations) (void *ctx, const char *CAfile, const char *CApath) ;
typedef void (__stdcall *DLL_OPENSSL_SSL_CTX_set_verify_depth) (void *ctx, int depth) ;
typedef void (__stdcall *DLL_OPENSSL_SSL_set_verify_depth) (void *s, int depth) ;
typedef int (__stdcall *DLL_OPENSSL_SSL_renegotiate) (void *s) ;
typedef int (__stdcall *DLL_OPENSSL_SSL_do_handshake) (void *s) ;
typedef void (__stdcall *DLL_OPENSSL_X509_free) (void *a) ;
typedef void * (__stdcall *DLL_OPENSSL_PEM_read_bio_X509) (void *bp, void **x, void *cb, void *u) ;
typedef void * (__stdcall *DLL_OPENSSL_d2i_X509_bio) (void *bp,void **x509) ;
typedef int (__stdcall *DLL_OPENSSL_OBJ_obj2txt) (char *buf, int buf_len, const void *a, int no_name) ;
typedef int (__stdcall *DLL_OPENSSL_ASN1_STRING_to_UTF8) (unsigned char **out, void *in) ;
typedef int (__stdcall *DLL_OPENSSL_X509_NAME_entry_count) (void *name) ;
typedef void * (__stdcall *DLL_OPENSSL_X509_NAME_get_entry) (void *name, int loc) ;
typedef void * (__stdcall *DLL_OPENSSL_X509_NAME_ENTRY_get_object) (void *ne) ;
typedef void * (__stdcall *DLL_OPENSSL_X509_NAME_ENTRY_get_data) (void *ne) ;
typedef void * (__stdcall *DLL_OPENSSL_X509_get_serialNumber) (void *x) ;
typedef long (__stdcall *DLL_OPENSSL_ASN1_INTEGER_get) (const void *a) ;
typedef int (__stdcall *DLL_OPENSSL_i2c_ASN1_INTEGER) (void *a,unsigned char **pp) ;
typedef void * (__stdcall *DLL_OPENSSL_X509_get_issuer_name) (void *a) ;
typedef void * (__stdcall *DLL_OPENSSL_X509_get_subject_name) (void *a) ;
typedef int (__stdcall *DLL_OPENSSL_X509_digest) (const void *data,const void *type,unsigned char *md, unsigned int *len) ;
typedef int (__stdcall *DLL_OPENSSL_HMAC_Init_ex) (void *ctx, const void *key, int len, const void *md, void *impl) ;
typedef void (__stdcall *DLL_OPENSSL_HMAC_CTX_init) (void *ctx) ;
typedef int (__stdcall *DLL_OPENSSL_HMAC_Update) (void *ctx, const unsigned char *data, size_t len) ;
typedef int (__stdcall *DLL_OPENSSL_HMAC_Final) (void *ctx, unsigned char *md, unsigned int *len) ;
typedef int (__stdcall *DLL_OPENSSL_RAND_add) (const void *buf,int num,double entropy) ;
typedef int (__stdcall *DLL_OPENSSL_EVP_CipherInit) (void *ctx,const void *cipher,const unsigned char *key,const unsigned char *iv,int enc);
typedef int (__stdcall *DLL_OPENSSL_EVP_CIPHER_CTX_set_padding) (void *c,int pad);
typedef int (__stdcall *DLL_OPENSSL_EVP_CipherFinal) (void *ctx, unsigned char *outm, int *outl);
typedef int (__stdcall *DLL_OPENSSL_EVP_CIPHER_block_size) (void *cipher);
typedef int (__stdcall *DLL_OPENSSL_EVP_MD_size) (const void *md);
typedef const void * (__stdcall *DLL_OPENSSL_EVP_get_cipherbyname) (const char *name);
typedef int (__stdcall *DLL_OPENSSL_PKCS5_PBKDF2_HMAC_SHA1) (const char *pass, int passlen,const unsigned char *salt, int saltlen, int iter,int keylen, unsigned char *out);
typedef void (__stdcall *DLL_OPENSSL_HMAC_CTX_cleanup) (void *ctx) ;
typedef void (__stdcall *DLL_OPENSSL_EVP_cleanup) () ;
typedef const char * (__stdcall *DLL_OPENSSL_OBJ_nid2sn) (int n) ;
typedef int(__stdcall *DLL_OPENSSL_EVP_CIPHER_nid) (const void* cipher) ;
typedef void *(__stdcall *DLL_OPENSSL_ASN1_TIME_to_generalizedtime) (void *t, void **out) ;
typedef void  * (__stdcall *DLL_OPENSSL_ASN1_INTEGER_to_BN) (const void *ai, void *bn) ;
typedef char  * (__stdcall *DLL_OPENSSL_BN_bn2hex) (const void *a) ;



static DLL_OPENSSL_ERR_load_crypto_strings		__openssl_err_load_crypto_strings;
static DLL_OPENSSL_ERR_error_string_n			__openssl_err_error_string_n;
static DLL_OPENSSL_ERR_get_error				__openssl_err_get_error;
static DLL_OPENSSL_RAND_bytes					__openssl_rand_bytes;
static DLL_OPENSSL_EVP_BytesToKey				__openssl_evp_bytestokey;
static DLL_OPENSSL_EVP_CIPHER_CTX_init			__openssl_evp_cipher_ctx_init;
static DLL_OPENSSL_EVP_CipherInit_ex			__openssl_evp_cipherinit_ex;
static DLL_OPENSSL_EVP_CipherUpdate				__openssl_evp_cipherupdate;
static DLL_OPENSSL_EVP_CipherFinal_ex			__openssl_evp_cipherfinal_ex;
static DLL_OPENSSL_EVP_CIPHER_CTX_cleanup		__openssl_evp_cipher_ctx_cleanup;
static DLL_OPENSSL_RSA_generate_key				__openssl_rsa_generate_key;
static DLL_OPENSSL_PEM_read_bio_RSA_PUBKEY      __openssl_pem_read_bio_rsa_pubkey;
static DLL_OPENSSL_PEM_read_bio_RSAPrivateKey	__openssl_pem_read_bio_rsaprivatekey;
static DLL_OPENSSL_RSA_public_encrypt			__openssl_rsa_public_encrypt;
static DLL_OPENSSL_RSA_private_decrypt			__openssl_rsa_private_decrypt;
static DLL_OPENSSL_RSA_sign                     __openssl_rsa_sign;
static DLL_OPENSSL_RSA_verify                   __openssl_rsa_verify;
static DLL_OPENSSL_PEM_write_bio_RSAPrivateKey	__openssl_pem_write_bio_rsaprivatekey;
static DLL_OPENSSL_PEM_write_bio_RSA_PUBKEY     __openssl_pem_write_bio_rsa_pubkey;
static DLL_OPENSSL_RSA_free						__openssl_rsa_free;
static DLL_OPENSSL_BIO_new						__openssl_bio_new;
static DLL_OPENSSL_BIO_new_mem_buf				__openssl_bio_new_mem_buf;
static DLL_OPENSSL_BIO_s_mem					__openssl_bio_s_mem;
static DLL_OPENSSL_BIO_ctrl_pending				__openssl_bio_ctrl_pending;
static DLL_OPENSSL_BIO_read						__openssl_bio_read;
static DLL_OPENSSL_BIO_free_all					__openssl_bio_free_all;
static DLL_OPENSSL_BIO_free						__openssl_bio_free;
static DLL_OPENSSL_EVP_CIPHER_key_length		__openssl_evp_cipher_key_length;
static DLL_OPENSSL_EVP_CIPHER_iv_length			__openssl_evp_cipher_iv_length;
static DLL_OPENSSL_EVP_aes_256_cbc				__openssl_evp_aes_256_cbc;
static DLL_OPENSSL_EVP_aes_192_cbc				__openssl_evp_aes_192_cbc;
static DLL_OPENSSL_EVP_aes_128_cbc				__openssl_evp_aes_128_cbc;
static DLL_OPENSSL_EVP_bf_cbc					__openssl_evp_bf_cbc;
static DLL_OPENSSL_EVP_bf_cfb64					__openssl_evp_bf_cfb64;
static DLL_OPENSSL_EVP_bf_ofb					__openssl_evp_bf_ofb;
static DLL_OPENSSL_RSA_size						__openssl_rsa_size;
static DLL_OPENSSL_EVP_CIPHER_CTX_new			__openssl_evp_cipher_ctx_new;
static DLL_OPENSSL_EVP_CIPHER_CTX_free			__openssl_evp_cipher_ctx_free;
static DLL_OPENSSL_EVP_md5						__openssl_evp_md5;
static DLL_OPENSSL_EVP_sha1						__openssl_evp_sha1;
static DLL_OPENSSL_EVP_sha256					__openssl_evp_sha256;
static DLL_OPENSSL_EVP_sha512					__openssl_evp_sha512;
static DLL_OPENSSL_EVP_dss1						__openssl_evp_dss1;
static DLL_OPENSSL_EVP_mdc2						__openssl_evp_mdc2;
static DLL_OPENSSL_EVP_ripemd160				__openssl_evp_ripemd160;
static DLL_OPENSSL_EVP_MD_CTX_init				__openssl_evp_md_ctx_init;
static DLL_OPENSSL_EVP_DigestInit_ex			__openssl_evp_digestinit_ex;
static DLL_OPENSSL_EVP_DigestUpdate				__openssl_evp_digestupdate;
static DLL_OPENSSL_EVP_DigestFinal_ex			__openssl_evp_digestfinal_ex;
static DLL_OPENSSL_EVP_MD_CTX_cleanup			__openssl_evp_md_ctx_cleanup;
static DLL_OPENSSL_BIO_f_base64                 __openssl_bio_f_base64;
static DLL_OPENSSL_BIO_push                     __openssl_bio_push;
static DLL_OPENSSL_BIO_write                    __openssl_bio_write;
static DLL_OPENSSL_BIO_ctrl                     __openssl_bio_ctrl;
static DLL_OPENSSL_BIO_set_flags                __openssl_bio_set_flags;
static DLL_OPENSSL_add_all_algorithms           __openssl_add_all_algorithms;
static DLL_OPENSSL_ERR_print_errors_fp          __openssl_err_print_errors_fp;
static DLL_OPENSSL_SSL_library_init             __openssl_ssl_library_init;
static DLL_OPENSSL_SSLv23_method                __openssl_sslv23_method;
static DLL_OPENSSL_SSLv2_method                 __openssl_sslv2_method;
static DLL_OPENSSL_SSLv3_method                 __openssl_sslv3_method;
static DLL_OPENSSL_TLSv1_method                 __openssl_tlsv1_method;
static DLL_OPENSSL_TLSv1_1_method               __openssl_tlsv1_1_method;
static DLL_OPENSSL_SSL_load_error_strings       __openssl_ssl_load_error_strings;
static DLL_OPENSSL_SSL_new                      __openssl_ssl_new;
static DLL_OPENSSL_SSL_CTX_new                  __openssl_ssl_ctx_new;
static DLL_OPENSSL_SSL_CTX_free                 __openssl_ssl_ctx_free;
static DLL_OPENSSL_SSL_CTX_use_certificate_file __openssl_ssl_ctx_use_certificate_file;
static DLL_OPENSSL_SSL_CTX_use_PrivateKey_file  __openssl_ssl_ctx_use_PrivateKey_file;
static DLL_OPENSSL_SSL_CTX_check_private_key    __openssl_ssl_ctx_check_private_key;
static DLL_OPENSSL_SSL_accept                   __openssl_ssl_accept;
static DLL_OPENSSL_SSL_read                     __openssl_ssl_read;
static DLL_OPENSSL_SSL_write                    __openssl_ssl_write;
static DLL_OPENSSL_SSL_get_fd                   __openssl_ssl_get_fd;
static DLL_OPENSSL_SSL_set_fd                   __openssl_ssl_set_fd;
static DLL_OPENSSL_SSL_free                     __openssl_ssl_free;
static DLL_OPENSSL_CRYPTO_malloc                __openssl_crypto_malloc;
static DLL_OPENSSL_CRYPTO_num_locks             __openssl_crypto_num_locks;
static DLL_OPENSSL_CRYPTO_THREADID_set_numeric  __openssl_crypto_threadid_set_numeric;
static DLL_OPENSSL_CRYPTO_THREADID_set_callback __openssl_crypto_threadid_set_callback;
static DLL_OPENSSL_CRYPTO_set_locking_callback  __openssl_crypto_set_locking_callback;
static DLL_OPENSSL_CRYPTO_free                  __openssl_crypto_free;
static DLL_OPENSSL_SSL_get_SSL_CTX              __openssl_ssl_get_ssl_ctx;
static DLL_OPENSSL_SSL_connect                  __openssl_ssl_connect;
static DLL_OPENSSL_CRYPTO_set_mem_functions     __openssl_crypto_set_mem_functions;
static DLL_OPENSSL_SSL_get_error                __openssl_ssl_get_error;
static DLL_OPENSSL_SSL_CTX_ctrl                 __openssl_ssl_ctx_ctrl;
static DLL_OPENSSL_SSL_shutdown                 __openssl_ssl_shutdown;
static DLL_OPENSSL_SSL_get_shutdown             __openssl_ssl_get_shutdown ;
static DLL_OPENSSL_SSL_CTX_set_verify           __openssl_ssl_ctx_set_verify ;
static DLL_OPENSSL_SSL_set_verify               __openssl_ssl_set_verify ;
static DLL_OPENSSL_SSL_get_peer_certificate      __openssl_ssl_get_peer_certificate ;
static DLL_OPENSSL_SSL_CTX_set_session_id_context   __openssl_ssl_ctx_set_session_id_context ;
static DLL_OPENSSL_SSL_CTX_load_verify_locations    __openssl_ssl_ctx_load_verify_locations ;
static DLL_OPENSSL_SSL_CTX_set_verify_depth     __openssl_ssl_ctx_set_verify_depth ;
static DLL_OPENSSL_SSL_set_verify_depth         __openssl_ssl_set_verify_depth ;
static DLL_OPENSSL_SSL_renegotiate              __openssl_ssl_renegotiate ;
static DLL_OPENSSL_SSL_do_handshake             __openssl_ssl_do_handshake ;
static DLL_OPENSSL_X509_free                    __openssl_x509_free ;
static DLL_OPENSSL_PEM_read_bio_X509            __openssl_pem_read_bio_x509 ;
static DLL_OPENSSL_d2i_X509_bio                 __openssl_d2i_x509_bio ;
static DLL_OPENSSL_OBJ_obj2txt                  __openssl_obj_obj2txt ;
static DLL_OPENSSL_ASN1_STRING_to_UTF8          __openssl_asn1_string_to_utf8 ;
static DLL_OPENSSL_X509_NAME_entry_count        __openssl_x509_name_entry_count ;
static DLL_OPENSSL_X509_NAME_get_entry          __openssl_x509_name_get_entry ;
static DLL_OPENSSL_X509_NAME_ENTRY_get_object   __openssl_x509_name_entry_get_object ;
static DLL_OPENSSL_X509_NAME_ENTRY_get_data     __openssl_x509_name_entry_get_data ;
static DLL_OPENSSL_X509_get_serialNumber        __openssl_x509_get_serialnumber ;
static DLL_OPENSSL_ASN1_INTEGER_get             __openssl_asn1_integer_get ;
static DLL_OPENSSL_i2c_ASN1_INTEGER             __openssl_i2c_asn1_integer ;
static DLL_OPENSSL_X509_get_issuer_name         __openssl_x509_get_issuer_name ;
static DLL_OPENSSL_X509_get_subject_name        __openssl_x509_get_subject_name ;
static DLL_OPENSSL_X509_digest                  __openssl_x509_digest ;
static DLL_OPENSSL_ASN1_TIME_to_generalizedtime __openssl_asn1_time_to_generalizedtime ;
static DLL_OPENSSL_HMAC_Init_ex                 __openssl_hmac_init_ex ;
static DLL_OPENSSL_HMAC_CTX_init                __openssl_hmac_ctx_init ;
static DLL_OPENSSL_HMAC_Update                  __openssl_hmac_update ;
static DLL_OPENSSL_HMAC_Final                   __openssl_hmac_final ;
static DLL_OPENSSL_RAND_add                     __openssl_rand_add ;
static DLL_OPENSSL_EVP_CipherInit               __openssl_evp_cipherinit ;
static DLL_OPENSSL_EVP_CIPHER_CTX_set_padding   __openssl_evp_cipher_ctx_set_padding ;
static DLL_OPENSSL_EVP_CipherFinal              __openssl_evp_cipherfinal ;
static DLL_OPENSSL_EVP_CIPHER_block_size        __openssl_evp_cipher_block_size ;
static DLL_OPENSSL_EVP_MD_size                  __openssl_evp_md_size ;
static DLL_OPENSSL_EVP_get_cipherbyname         __openssl_evp_get_cipherbyname ;
static DLL_OPENSSL_PKCS5_PBKDF2_HMAC_SHA1       __openssl_pkcs5_pbkdf2_hmac_sha1 ;
static DLL_OPENSSL_HMAC_CTX_cleanup             __openssl_hmac_ctx_cleanup ;
static DLL_OPENSSL_EVP_cleanup                  __openssl_evp_cleanup ;
static DLL_OPENSSL_OBJ_nid2sn                   __openssl_obj_nid2sn ;
static DLL_OPENSSL_EVP_CIPHER_nid               __openssl_evp_cipher_nid ;
static DLL_OPENSSL_ASN1_INTEGER_to_BN           __openssl_asn1_integer_to_bn ;
static DLL_OPENSSL_BN_bn2hex                    __openssl_bn_bn2hex ;

static int OPENSSL_initialize_done = 0;
void OPENSSL_initialize()
{
    if(OPENSSL_initialize_done)
        return;
    
    if(!__libeay_DLL)
    {
        __libeay_DLL = MSLoadDLL(@"libeay32.dll") ;

        if (__libeay_DLL != NULL) {
            __openssl_err_load_crypto_strings		= (DLL_OPENSSL_ERR_load_crypto_strings)		GetProcAddress(__libeay_DLL, "ERR_load_crypto_strings") ;
            __openssl_err_error_string_n			= (DLL_OPENSSL_ERR_error_string_n)			GetProcAddress(__libeay_DLL, "ERR_error_string_n") ;
            __openssl_err_get_error                 = (DLL_OPENSSL_ERR_get_error)				GetProcAddress(__libeay_DLL, "ERR_get_error") ;
            __openssl_rand_bytes					= (DLL_OPENSSL_RAND_bytes)					GetProcAddress(__libeay_DLL, "RAND_bytes") ;
            __openssl_evp_bytestokey				= (DLL_OPENSSL_EVP_BytesToKey)				GetProcAddress(__libeay_DLL, "EVP_BytesToKey") ;
            __openssl_evp_cipher_ctx_init			= (DLL_OPENSSL_EVP_CIPHER_CTX_init)			GetProcAddress(__libeay_DLL, "EVP_CIPHER_CTX_init") ;
            __openssl_evp_cipherinit_ex             = (DLL_OPENSSL_EVP_CipherInit_ex)			GetProcAddress(__libeay_DLL, "EVP_CipherInit_ex") ;
            __openssl_evp_cipherupdate				= (DLL_OPENSSL_EVP_CipherUpdate)			GetProcAddress(__libeay_DLL, "EVP_CipherUpdate") ;
            __openssl_evp_cipherfinal_ex			= (DLL_OPENSSL_EVP_CipherFinal_ex)			GetProcAddress(__libeay_DLL, "EVP_CipherFinal_ex") ;
            __openssl_evp_cipher_ctx_cleanup		= (DLL_OPENSSL_EVP_CIPHER_CTX_cleanup)		GetProcAddress(__libeay_DLL, "EVP_CIPHER_CTX_cleanup") ;
            __openssl_rsa_generate_key              = (DLL_OPENSSL_RSA_generate_key)            GetProcAddress(__libeay_DLL, "RSA_generate_key") ;
            __openssl_pem_read_bio_rsa_pubkey       = (DLL_OPENSSL_PEM_read_bio_RSA_PUBKEY)     GetProcAddress(__libeay_DLL, "PEM_read_bio_RSA_PUBKEY") ;
            __openssl_pem_read_bio_rsaprivatekey	= (DLL_OPENSSL_PEM_read_bio_RSAPrivateKey)	GetProcAddress(__libeay_DLL, "PEM_read_bio_RSAPrivateKey") ;
            __openssl_rsa_public_encrypt			= (DLL_OPENSSL_RSA_public_encrypt)			GetProcAddress(__libeay_DLL, "RSA_public_encrypt") ;
            __openssl_rsa_private_decrypt			= (DLL_OPENSSL_RSA_private_decrypt)			GetProcAddress(__libeay_DLL, "RSA_private_decrypt") ;
            __openssl_rsa_sign                      = (DLL_OPENSSL_RSA_sign)                    GetProcAddress(__libeay_DLL, "RSA_sign") ;
            __openssl_rsa_verify                    = (DLL_OPENSSL_RSA_verify)                  GetProcAddress(__libeay_DLL, "RSA_verify") ;
            __openssl_pem_write_bio_rsaprivatekey	= (DLL_OPENSSL_PEM_write_bio_RSAPrivateKey)	GetProcAddress(__libeay_DLL, "PEM_write_bio_RSAPrivateKey") ;
            __openssl_pem_write_bio_rsa_pubkey      = (DLL_OPENSSL_PEM_write_bio_RSA_PUBKEY)	GetProcAddress(__libeay_DLL, "PEM_write_bio_RSA_PUBKEY") ;
            __openssl_rsa_free						= (DLL_OPENSSL_RSA_free)					GetProcAddress(__libeay_DLL, "RSA_free") ;
            __openssl_bio_new						= (DLL_OPENSSL_BIO_new)						GetProcAddress(__libeay_DLL, "BIO_new") ;
            __openssl_bio_new_mem_buf				= (DLL_OPENSSL_BIO_new_mem_buf)				GetProcAddress(__libeay_DLL, "BIO_new_mem_buf") ;
            __openssl_bio_s_mem                     = (DLL_OPENSSL_BIO_s_mem)					GetProcAddress(__libeay_DLL, "BIO_s_mem") ;
            __openssl_bio_ctrl_pending				= (DLL_OPENSSL_BIO_ctrl_pending)			GetProcAddress(__libeay_DLL, "BIO_ctrl_pending") ;
            __openssl_bio_read						= (DLL_OPENSSL_BIO_read)					GetProcAddress(__libeay_DLL, "BIO_read") ;
            __openssl_bio_free_all					= (DLL_OPENSSL_BIO_free_all)				GetProcAddress(__libeay_DLL, "BIO_free_all") ;
            __openssl_bio_free						= (DLL_OPENSSL_BIO_free)					GetProcAddress(__libeay_DLL, "BIO_free") ;
            __openssl_evp_cipher_key_length         = (DLL_OPENSSL_EVP_CIPHER_key_length)		GetProcAddress(__libeay_DLL, "EVP_CIPHER_key_length") ;
            __openssl_evp_cipher_iv_length			= (DLL_OPENSSL_EVP_CIPHER_iv_length)		GetProcAddress(__libeay_DLL, "EVP_CIPHER_iv_length") ;
            __openssl_evp_aes_256_cbc				= (DLL_OPENSSL_EVP_aes_256_cbc)				GetProcAddress(__libeay_DLL, "EVP_aes_256_cbc") ;
            __openssl_evp_aes_192_cbc				= (DLL_OPENSSL_EVP_aes_192_cbc)				GetProcAddress(__libeay_DLL, "EVP_aes_192_cbc") ;
            __openssl_evp_aes_128_cbc				= (DLL_OPENSSL_EVP_aes_128_cbc)				GetProcAddress(__libeay_DLL, "EVP_aes_128_cbc") ;
            __openssl_evp_bf_cbc					= (DLL_OPENSSL_EVP_bf_cbc)					GetProcAddress(__libeay_DLL, "EVP_bf_cbc") ;
            __openssl_evp_bf_cfb64					= (DLL_OPENSSL_EVP_bf_cfb64)				GetProcAddress(__libeay_DLL, "EVP_bf_cfb64") ;
            __openssl_evp_bf_ofb					= (DLL_OPENSSL_EVP_bf_ofb)					GetProcAddress(__libeay_DLL, "EVP_bf_ofb") ;
            __openssl_rsa_size						= (DLL_OPENSSL_RSA_size)					GetProcAddress(__libeay_DLL, "RSA_size") ;
            __openssl_evp_cipher_ctx_new			= (DLL_OPENSSL_EVP_CIPHER_CTX_new)			GetProcAddress(__libeay_DLL, "EVP_CIPHER_CTX_new") ;
            __openssl_evp_cipher_ctx_free			= (DLL_OPENSSL_EVP_CIPHER_CTX_free)			GetProcAddress(__libeay_DLL, "EVP_CIPHER_CTX_free") ;
            __openssl_evp_md5						= (DLL_OPENSSL_EVP_md5)						GetProcAddress(__libeay_DLL, "EVP_md5") ;
            __openssl_evp_sha1						= (DLL_OPENSSL_EVP_sha1)					GetProcAddress(__libeay_DLL, "EVP_sha1") ;
            __openssl_evp_sha256					= (DLL_OPENSSL_EVP_sha256)					GetProcAddress(__libeay_DLL, "EVP_sha256") ;
            __openssl_evp_sha512					= (DLL_OPENSSL_EVP_sha512)					GetProcAddress(__libeay_DLL, "EVP_sha512") ;
            __openssl_evp_dss1						= (DLL_OPENSSL_EVP_dss1)					GetProcAddress(__libeay_DLL, "EVP_dss1") ;
            __openssl_evp_mdc2                      = (DLL_OPENSSL_EVP_mdc2)                    GetProcAddress(__libeay_DLL, "EVP_mdc2") ;
            __openssl_evp_ripemd160                 = (DLL_OPENSSL_EVP_ripemd160)				GetProcAddress(__libeay_DLL, "EVP_ripemd160") ;
            __openssl_evp_md_ctx_init				= (DLL_OPENSSL_EVP_MD_CTX_init)				GetProcAddress(__libeay_DLL, "EVP_MD_CTX_init") ;
            __openssl_evp_digestinit_ex             = (DLL_OPENSSL_EVP_DigestInit_ex)			GetProcAddress(__libeay_DLL, "EVP_DigestInit_ex") ;
            __openssl_evp_digestupdate				= (DLL_OPENSSL_EVP_DigestUpdate)			GetProcAddress(__libeay_DLL, "EVP_DigestUpdate") ;
            __openssl_evp_digestfinal_ex			= (DLL_OPENSSL_EVP_DigestFinal_ex)			GetProcAddress(__libeay_DLL, "EVP_DigestFinal_ex") ;
            __openssl_evp_md_ctx_cleanup			= (DLL_OPENSSL_EVP_MD_CTX_cleanup)			GetProcAddress(__libeay_DLL, "EVP_MD_CTX_cleanup") ;
            __openssl_bio_f_base64                  = (DLL_OPENSSL_BIO_f_base64)                GetProcAddress(__libeay_DLL, "BIO_f_base64") ;
            __openssl_bio_push                      = (DLL_OPENSSL_BIO_push)                    GetProcAddress(__libeay_DLL, "BIO_push") ;
            __openssl_bio_write                     = (DLL_OPENSSL_BIO_write)                   GetProcAddress(__libeay_DLL, "BIO_write") ;
            __openssl_bio_ctrl                      = (DLL_OPENSSL_BIO_ctrl)                    GetProcAddress(__libeay_DLL, "BIO_ctrl") ;
            __openssl_bio_set_flags                 = (DLL_OPENSSL_BIO_set_flags)               GetProcAddress(__libeay_DLL, "BIO_set_flags") ;
            __openssl_add_all_algorithms            = (DLL_OPENSSL_add_all_algorithms)          GetProcAddress(__libeay_DLL, "OPENSSL_add_all_algorithms_noconf") ;
            __openssl_err_print_errors_fp           = (DLL_OPENSSL_ERR_print_errors_fp)         GetProcAddress(__libeay_DLL, "ERR_print_errors_fp") ;
            __openssl_crypto_malloc                 = (DLL_OPENSSL_CRYPTO_malloc)               GetProcAddress(__libeay_DLL, "CRYPTO_malloc") ;
            __openssl_crypto_num_locks              = (DLL_OPENSSL_CRYPTO_num_locks)            GetProcAddress(__libeay_DLL, "CRYPTO_num_locks") ;
            __openssl_crypto_threadid_set_numeric   = (DLL_OPENSSL_CRYPTO_THREADID_set_numeric) GetProcAddress(__libeay_DLL, "CRYPTO_THREADID_set_numeric") ;
            __openssl_crypto_threadid_set_callback  = (DLL_OPENSSL_CRYPTO_THREADID_set_callback)GetProcAddress(__libeay_DLL, "CRYPTO_THREADID_set_callback") ;
            __openssl_crypto_set_locking_callback   = (DLL_OPENSSL_CRYPTO_set_locking_callback) GetProcAddress(__libeay_DLL, "CRYPTO_set_locking_callback") ;
            __openssl_crypto_free                   = (DLL_OPENSSL_CRYPTO_free)                 GetProcAddress(__libeay_DLL, "CRYPTO_free") ;
            __openssl_crypto_set_mem_functions      = (DLL_OPENSSL_CRYPTO_set_mem_functions)    GetProcAddress(__libeay_DLL, "CRYPTO_set_mem_functions") ;
            __openssl_x509_free                     = (DLL_OPENSSL_X509_free)                   GetProcAddress(__libeay_DLL, "X509_free") ;
            __openssl_pem_read_bio_x509             = (DLL_OPENSSL_PEM_read_bio_X509)           GetProcAddress(__libeay_DLL, "PEM_read_bio_X509") ;
            __openssl_d2i_x509_bio                  = (DLL_OPENSSL_d2i_X509_bio)                GetProcAddress(__libeay_DLL, "d2i_X509_bio") ;
            __openssl_obj_obj2txt                   = (DLL_OPENSSL_OBJ_obj2txt)                 GetProcAddress(__libeay_DLL, "OBJ_obj2txt") ;
            __openssl_asn1_string_to_utf8           = (DLL_OPENSSL_ASN1_STRING_to_UTF8)         GetProcAddress(__libeay_DLL, "ASN1_STRING_to_UTF8") ;
            __openssl_x509_name_entry_count         = (DLL_OPENSSL_X509_NAME_entry_count)       GetProcAddress(__libeay_DLL, "X509_NAME_entry_count") ;
            __openssl_x509_name_get_entry           = (DLL_OPENSSL_X509_NAME_get_entry)         GetProcAddress(__libeay_DLL, "X509_NAME_get_entry") ;
            __openssl_x509_name_entry_get_object    = (DLL_OPENSSL_X509_NAME_ENTRY_get_object)  GetProcAddress(__libeay_DLL, "X509_NAME_ENTRY_get_object") ;
            __openssl_x509_name_entry_get_data      = (DLL_OPENSSL_X509_NAME_ENTRY_get_data)    GetProcAddress(__libeay_DLL, "X509_NAME_ENTRY_get_data") ;
            __openssl_x509_get_serialnumber         = (DLL_OPENSSL_X509_get_serialNumber)       GetProcAddress(__libeay_DLL, "X509_get_serialNumber") ;
            __openssl_asn1_integer_get              = (DLL_OPENSSL_ASN1_INTEGER_get)            GetProcAddress(__libeay_DLL, "ASN1_INTEGER_get") ;
            __openssl_i2c_asn1_integer              = (DLL_OPENSSL_i2c_ASN1_INTEGER)            GetProcAddress(__libeay_DLL, "i2c_ASN1_INTEGER") ;
            __openssl_x509_get_issuer_name          = (DLL_OPENSSL_X509_get_issuer_name)        GetProcAddress(__libeay_DLL, "X509_get_issuer_name") ;
            __openssl_x509_get_subject_name         = (DLL_OPENSSL_X509_get_subject_name)       GetProcAddress(__libeay_DLL, "X509_get_subject_name") ;
            __openssl_x509_digest                   = (DLL_OPENSSL_X509_digest)                 GetProcAddress(__libeay_DLL, "X509_digest") ;
            __openssl_asn1_time_to_generalizedtime  = (DLL_OPENSSL_ASN1_TIME_to_generalizedtime) GetProcAddress(__libeay_DLL, "ASN1_TIME_to_generalizedtime") ;
            __openssl_hmac_init_ex                  = (DLL_OPENSSL_HMAC_Init_ex)                GetProcAddress(__libeay_DLL, "HMAC_Init_ex") ;
            __openssl_hmac_ctx_init                 = (DLL_OPENSSL_HMAC_CTX_init)               GetProcAddress(__libeay_DLL, "HMAC_CTX_init") ;
            __openssl_hmac_update                   = (DLL_OPENSSL_HMAC_Update)                 GetProcAddress(__libeay_DLL, "HMAC_Update") ;
            __openssl_hmac_final                    = (DLL_OPENSSL_HMAC_Final)                  GetProcAddress(__libeay_DLL, "HMAC_Final") ;
            __openssl_rand_add                      = (DLL_OPENSSL_RAND_add)                    GetProcAddress(__libeay_DLL, "RAND_add") ;
            __openssl_evp_cipherinit                = (DLL_OPENSSL_EVP_CipherInit)              GetProcAddress(__libeay_DLL, "EVP_CipherInit") ;
            __openssl_evp_cipher_ctx_set_padding    = (DLL_OPENSSL_EVP_CIPHER_CTX_set_padding)  GetProcAddress(__libeay_DLL, "EVP_CIPHER_CTX_set_padding") ;
            __openssl_evp_cipherfinal               = (DLL_OPENSSL_EVP_CipherFinal)             GetProcAddress(__libeay_DLL, "EVP_CipherFinal") ;
            __openssl_evp_cipher_block_size         = (DLL_OPENSSL_EVP_CIPHER_block_size)       GetProcAddress(__libeay_DLL, "EVP_CIPHER_block_size") ;
            __openssl_evp_md_size                   = (DLL_OPENSSL_EVP_MD_size)                 GetProcAddress(__libeay_DLL, "EVP_MD_size") ;
            __openssl_evp_get_cipherbyname          = (DLL_OPENSSL_EVP_get_cipherbyname)        GetProcAddress(__libeay_DLL, "EVP_get_cipherbyname") ;
            __openssl_pkcs5_pbkdf2_hmac_sha1        = (DLL_OPENSSL_PKCS5_PBKDF2_HMAC_SHA1)      GetProcAddress(__libeay_DLL, "PKCS5_PBKDF2_HMAC_SHA1") ;
            __openssl_hmac_ctx_cleanup              = (DLL_OPENSSL_HMAC_CTX_cleanup)            GetProcAddress(__libeay_DLL, "HMAC_CTX_cleanup") ;
            __openssl_evp_cleanup                   = (DLL_OPENSSL_EVP_cleanup)                 GetProcAddress(__libeay_DLL, "EVP_cleanup") ;
            __openssl_obj_nid2sn                    = (DLL_OPENSSL_OBJ_nid2sn)                  GetProcAddress(__libeay_DLL, "OBJ_nid2sn") ;
            __openssl_evp_cipher_nid                = (DLL_OPENSSL_EVP_CIPHER_nid)              GetProcAddress(__libeay_DLL, "EVP_CIPHER_nid") ;
            __openssl_asn1_integer_to_bn            = (DLL_OPENSSL_ASN1_INTEGER_to_BN)          GetProcAddress(__libeay_DLL, "ASN1_INTEGER_to_BN") ;
            __openssl_bn_bn2hex                     = (DLL_OPENSSL_BN_bn2hex)                   GetProcAddress(__libeay_DLL, "BN_bn2hex") ;

            
            if(! __openssl_add_all_algorithms) //depends on a #define in openssl include
            {
                __openssl_add_all_algorithms        = (DLL_OPENSSL_add_all_algorithms)          GetProcAddress(__openssl_add_all_algorithms, "OPENSSL_add_all_algorithms_conf") ;
            }
            
            if (!(__openssl_err_load_crypto_strings &&
                  __openssl_err_error_string_n &&
                  __openssl_err_get_error &&
                  __openssl_rand_bytes &&
                  __openssl_evp_bytestokey &&
                  __openssl_evp_cipher_ctx_init &&
                  __openssl_evp_cipherinit_ex &&
                  __openssl_evp_cipherupdate &&
                  __openssl_evp_cipherfinal_ex &&
                  __openssl_evp_cipher_ctx_cleanup &&
                  __openssl_rsa_generate_key &&
                  __openssl_pem_read_bio_rsa_pubkey &&
                  __openssl_pem_read_bio_rsaprivatekey &&
                  __openssl_rsa_public_encrypt &&
                  __openssl_rsa_private_decrypt &&
                  __openssl_pem_write_bio_rsaprivatekey &&
                  __openssl_pem_write_bio_rsa_pubkey &&
                  __openssl_rsa_free &&
                  __openssl_bio_new &&
                  __openssl_bio_new_mem_buf &&
                  __openssl_bio_s_mem &&
                  __openssl_bio_ctrl_pending &&
                  __openssl_bio_read &&
                  __openssl_bio_free_all &&
                  __openssl_bio_free &&
                  __openssl_evp_cipher_key_length &&
                  __openssl_evp_cipher_iv_length &&
                  __openssl_evp_aes_256_cbc &&
                  __openssl_evp_aes_192_cbc &&
                  __openssl_evp_aes_128_cbc &&
                  __openssl_evp_bf_cbc &&
                  __openssl_evp_bf_cfb64 &&
                  __openssl_evp_bf_ofb &&
                  __openssl_rsa_size &&
                  __openssl_evp_cipher_ctx_new &&
                  __openssl_evp_cipher_ctx_free &&
                  __openssl_evp_md5 &&
                  __openssl_evp_sha1 &&
                  __openssl_evp_sha256 &&
                  __openssl_evp_sha512 &&
                  __openssl_evp_dss1 &&
                  __openssl_evp_mdc2 &&
                  __openssl_evp_ripemd160 &&
                  __openssl_evp_md_ctx_init &&
                  __openssl_evp_digestinit_ex &&
                  __openssl_evp_digestupdate &&
                  __openssl_evp_digestfinal_ex &&
                  __openssl_evp_md_ctx_cleanup &&
                  __openssl_bio_f_base64 &&
                  __openssl_bio_push &&
                  __openssl_bio_write &&
                  __openssl_bio_ctrl &&
                  __openssl_bio_set_flags &&
                  __openssl_add_all_algorithms &&
                  __openssl_err_print_errors_fp &&
                  __openssl_crypto_malloc &&
                  __openssl_crypto_num_locks &&
                  __openssl_crypto_threadid_set_numeric &&
                  __openssl_crypto_threadid_set_callback &&
                  __openssl_crypto_set_locking_callback &&
                  __openssl_crypto_free &&
                  __openssl_crypto_set_mem_functions &&
                  __openssl_x509_free &&
                  __openssl_pem_read_bio_x509 &&
                  __openssl_d2i_x509_bio &&
                  __openssl_obj_obj2txt &&
                  __openssl_asn1_string_to_utf8 &&
                  __openssl_x509_name_entry_count &&
                  __openssl_x509_name_get_entry &&
                  __openssl_x509_name_entry_get_object &&
                  __openssl_x509_name_entry_get_data &&
                  __openssl_x509_get_serialnumber &&
                  __openssl_asn1_integer_get &&
                  __openssl_i2c_asn1_integer &&
                  __openssl_x509_get_issuer_name &&
                  __openssl_x509_get_subject_name &&
                  __openssl_x509_digest &&
                  __openssl_hmac_init_ex &&
                  __openssl_hmac_ctx_init &&
                  __openssl_hmac_update &&
                  __openssl_hmac_final &&
                  __openssl_rand_add &&
                  __openssl_evp_cipherinit &&
                  __openssl_evp_cipher_ctx_set_padding &&
                  __openssl_evp_cipherfinal &&
                  __openssl_evp_cipher_block_size &&
                  __openssl_evp_md_size &&
                  __openssl_evp_get_cipherbyname &&
                  __openssl_pkcs5_pbkdf2_hmac_sha1 &&
                  __openssl_hmac_ctx_cleanup &&
                  __openssl_evp_cleanup &&
                  __openssl_obj_nid2sn &&
                  __openssl_evp_cipher_nid &&
                  __openssl_asn1_time_to_generalizedtime &&
                  __openssl_asn1_integer_to_bn &&
                  __openssl_bn_bn2hex
                  ))
            {
                if(!__openssl_err_load_crypto_strings)		NSLog(@"__openssl_err_load_crypto_strings NULL");
                if(!__openssl_err_error_string_n)			NSLog(@"__openssl_err_error_string_n NULL");
                if(!__openssl_err_get_error)				NSLog(@"__openssl_err_get_error NULL");
                if(!__openssl_rand_bytes)                   NSLog(@"__openssl_rand_bytes NULL");
                if(!__openssl_evp_bytestokey)               NSLog(@"__openssl_evp_bytestokey NULL");
                if(!__openssl_evp_cipher_ctx_init)			NSLog(@"__openssl_evp_cipher_ctx_init NULL");
                if(!__openssl_evp_cipherinit_ex)            NSLog(@"__openssl_evp_cipherinit_ex NULL");
                if(!__openssl_evp_cipherupdate)             NSLog(@"__openssl_evp_cipherupdate NULL");
                if(!__openssl_evp_cipherfinal_ex)           NSLog(@"__openssl_evp_cipherfinal_ex NULL");
                if(!__openssl_evp_cipher_ctx_cleanup)       NSLog(@"__openssl_evp_cipher_ctx_cleanup NULL");
                if(!__openssl_rsa_generate_key)             NSLog(@"__openssl_rsa_generate_key NULL");
                if(!__openssl_pem_read_bio_rsa_pubkey)      NSLog(@"__openssl_pem_read_bio_rsa_pubkey NULL");
                if(!__openssl_pem_read_bio_rsaprivatekey)	NSLog(@"__openssl_pem_read_bio_rsaprivatekey NULL");
                if(!__openssl_rsa_public_encrypt)           NSLog(@"__openssl_rsa_public_encrypt NULL");
                if(!__openssl_rsa_private_decrypt)          NSLog(@"__openssl_rsa_private_decrypt NULL");
                if(!__openssl_rsa_sign)                     NSLog(@"__openssl_rsa_sign NULL");
                if(!__openssl_rsa_verify)                   NSLog(@"__openssl_rsa_verify NULL");
                if(!__openssl_pem_write_bio_rsaprivatekey)	NSLog(@"__openssl_pem_write_bio_rsaprivatekey NULL");
                if(!__openssl_pem_write_bio_rsa_pubkey)     NSLog(@"__openssl_pem_write_bio_rsa_pubkey NULL");
                if(!__openssl_rsa_free)                     NSLog(@"__openssl_rsa_free NULL");
                if(!__openssl_bio_new)                      NSLog(@"__openssl_bio_new NULL");
                if(!__openssl_bio_new_mem_buf)              NSLog(@"__openssl_bio_new_mem_buf NULL");
                if(!__openssl_bio_s_mem)                    NSLog(@"__openssl_bio_s_mem NULL");
                if(!__openssl_bio_ctrl_pending)             NSLog(@"__openssl_bio_ctrl_pending NULL");
                if(!__openssl_bio_read)                     NSLog(@"__openssl_bio_read NULL");
                if(!__openssl_bio_free_all)                 NSLog(@"__openssl_bio_free_all NULL");
                if(!__openssl_bio_free)                     NSLog(@"__openssl_bio_free NULL");
                if(!__openssl_evp_cipher_key_length)		NSLog(@"__openssl_evp_cipher_key_length NULL");
                if(!__openssl_evp_cipher_iv_length)			NSLog(@"__openssl_evp_cipher_iv_length NULL");
                if(!__openssl_evp_aes_256_cbc)				NSLog(@"__openssl_evp_aes_256_cbc NULL");
                if(!__openssl_evp_aes_192_cbc)              NSLog(@"__openssl_evp_aes_192_cbc NULL");
                if(!__openssl_evp_aes_128_cbc)				NSLog(@"__openssl_evp_aes_128_cbc NULL");
                if(!__openssl_evp_bf_cbc)                   NSLog(@"__openssl_evp_bf_cbc NULL");
                if(!__openssl_evp_bf_cfb64)                 NSLog(@"__openssl_evp_bf_cfb64 NULL");
                if(!__openssl_evp_bf_ofb)                   NSLog(@"__openssl_evp_bf_ofb NULL");
                if(!__openssl_rsa_size)                     NSLog(@"__openssl_rsa_size NULL");
                if(!__openssl_evp_cipher_ctx_new)			NSLog(@"__openssl_evp_cipher_ctx_new NULL");
                if(!__openssl_evp_cipher_ctx_free)          NSLog(@"__openssl_evp_cipher_ctx_free NULL");
                if(!__openssl_evp_md5)                      NSLog(@"__openssl_evp_md5 NULL");
                if(!__openssl_evp_sha1)                     NSLog(@"__openssl_evp_sha1 NULL");
                if(!__openssl_evp_sha256)                   NSLog(@"__openssl_evp_sha256 NULL");
                if(!__openssl_evp_sha512)                   NSLog(@"__openssl_evp_sha512 NULL");
                if(!__openssl_evp_dss1)                     NSLog(@"__openssl_evp_dss1 NULL");
                if(!__openssl_evp_mdc2)                     NSLog(@"__openssl_evp_mdc2 NULL");
                if(!__openssl_evp_ripemd160)                NSLog(@"__openssl_evp_ripemd160 NULL");
                if(!__openssl_evp_md_ctx_init)              NSLog(@"__openssl_evp_md_ctx_init NULL");
                if(!__openssl_evp_digestinit_ex)			NSLog(@"__openssl_evp_digestinit_ex NULL");
                if(!__openssl_evp_digestupdate)             NSLog(@"__openssl_evp_digestupdate NULL");
                if(!__openssl_evp_digestfinal_ex)           NSLog(@"__openssl_evp_digestfinal_ex NULL");
                if(!__openssl_evp_md_ctx_cleanup)           NSLog(@"__openssl_evp_md_ctx_cleanup NULL");
                if(!__openssl_bio_f_base64)                 NSLog(@"__openssl_bio_f_base64 NULL");
                if(!__openssl_bio_push)                     NSLog(@"__openssl_bio_push NULL");
                if(!__openssl_bio_write)                    NSLog(@"__openssl_bio_write NULL");
                if(!__openssl_bio_ctrl)                     NSLog(@"__openssl_bio_ctrl NULL");
                if(!__openssl_bio_set_flags)                NSLog(@"__openssl_bio_set_flags NULL");
                if(!__openssl_add_all_algorithms)           NSLog(@"__openssl_add_all_algorithms NULL");
                if(!__openssl_err_print_errors_fp)          NSLog(@"__openssl_err_print_errors_fp NULL");
                if(!__openssl_crypto_malloc)                NSLog(@"__openssl_crypto_malloc NULL");
                if(!__openssl_crypto_num_locks)             NSLog(@"__openssl_crypto_num_locks NULL");
                if(!__openssl_crypto_threadid_set_numeric)  NSLog(@"__openssl_crypto_threadid_set_numeric NULL");
                if(!__openssl_crypto_threadid_set_callback) NSLog(@"__openssl_crypto_threadid_set_callback NULL");
                if(!__openssl_crypto_set_locking_callback)  NSLog(@"__openssl_crypto_set_locking_callback NULL");
                if(!__openssl_crypto_free)                  NSLog(@"__openssl_crypto_free NULL");
                if(!__openssl_crypto_set_mem_functions)     NSLog(@"__openssl_crypto_set_mem_functions NULL");
                if(!__openssl_x509_free)                    NSLog(@"__openssl_x509_free NULL");
                if(!__openssl_pem_read_bio_x509)            NSLog(@"__openssl_pem_read_bio_x509 NULL");
                if(!__openssl_d2i_x509_bio)                 NSLog(@"__openssl_d2i_x509_bio NULL");
                if(!__openssl_obj_obj2txt)                  NSLog(@"__openssl_obj_obj2txt NULL");
                if(!__openssl_asn1_string_to_utf8)          NSLog(@"__openssl_asn1_string_to_utf8 NULL");
                if(!__openssl_x509_name_entry_count)        NSLog(@"__openssl_x509_name_entry_count NULL");
                if(!__openssl_x509_name_get_entry)          NSLog(@"__openssl_x509_name_get_entry NULL");
                if(!__openssl_x509_name_entry_get_object)   NSLog(@"__openssl_x509_name_entry_get_object NULL");
                if(!__openssl_x509_name_entry_get_data)     NSLog(@"__openssl_x509_name_entry_get_data NULL");
                if(!__openssl_x509_get_serialnumber)        NSLog(@"__openssl_x509_get_serialnumber NULL");
                if(!__openssl_asn1_integer_get)             NSLog(@"__openssl_asn1_integer_get NULL");
                if(!__openssl_i2c_asn1_integer)             NSLog(@"__openssl_i2c_asn1_integer NULL");
                if(!__openssl_x509_get_issuer_name)         NSLog(@"__openssl_x509_get_issuer_name NULL");
                if(!__openssl_x509_get_subject_name)        NSLog(@"__openssl_x509_get_subject_name NULL");
                if(!__openssl_x509_digest)                  NSLog(@"__openssl_x509_digest NULL");
                if(!__openssl_asn1_time_to_generalizedtime) NSLog(@"__openssl_asn1_time_to_generalizedtime NULL");  
                if(!__openssl_hmac_init_ex)                 NSLog(@"__openssl_hmac_init_ex NULL");
                if(!__openssl_hmac_ctx_init)                NSLog(@"__openssl_hmac_ctx_init NULL");
                if(!__openssl_hmac_update)                  NSLog(@"__openssl_hmac_update NULL");
                if(!__openssl_hmac_final)                   NSLog(@"__openssl_hmac_final NULL");
                if(!__openssl_rand_add)                     NSLog(@"__openssl_rand_add NULL");
                if(!__openssl_evp_cipherinit)               NSLog(@"__openssl_evp_cipherinit NULL");
                if(!__openssl_evp_cipher_ctx_set_padding)   NSLog(@"__openssl_evp_cipher_ctx_set_padding NULL");
                if(!__openssl_evp_cipherfinal)              NSLog(@"__openssl_evp_cipherfinal NULL");
                if(!__openssl_evp_cipher_block_size)        NSLog(@"__openssl_evp_cipher_block_size NULL");
                if(!__openssl_evp_md_size)                  NSLog(@"__openssl_evp_md_size NULL");
                if(!__openssl_evp_get_cipherbyname)         NSLog(@"__openssl_evp_get_cipherbyname NULL");
                if(!__openssl_pkcs5_pbkdf2_hmac_sha1)       NSLog(@"__openssl_pkcs5_pbkdf2_hmac_sha1 NULL");
                if(!__openssl_hmac_ctx_cleanup)             NSLog(@"__openssl_hmac_ctx_cleanup NULL");
                if(!__openssl_evp_cleanup)                  NSLog(@"__openssl_evp_cleanup NULL");
                if(!__openssl_obj_nid2sn)                   NSLog(@"__openssl_obj_nid2sn NULL");
                if(!__openssl_evp_cipher_nid)               NSLog(@"__openssl_evp_cipher_nid NULL");
                if(!__openssl_asn1_integer_to_bn)           NSLog(@"__openssl_asn1_integer_to_bn NULL");
                if(!__openssl_bn_bn2hex)                    NSLog(@"__openssl_bn_bn2hex NULL");

                MSRaise(NSGenericException, @"Error while loading libeay32 library") ;
            }
        }
        else {
            MSRaise(NSGenericException, @"Error while loading libeay32.dll") ;
        }
    }
    
    if(!__libssl_DLL)
    {
        __libssl_DLL = MSLoadDLL(@"libssl32.dll") ;
   
        if (__libssl_DLL != NULL) {
            __openssl_ssl_library_init              = (DLL_OPENSSL_SSL_library_init)            GetProcAddress(__libssl_DLL, "SSL_library_init") ;
            __openssl_sslv23_method                 = (DLL_OPENSSL_SSLv23_method)               GetProcAddress(__libssl_DLL, "SSLv23_method") ;
            __openssl_sslv2_method                  = (DLL_OPENSSL_SSLv2_method)                GetProcAddress(__libssl_DLL, "SSLv2_method") ;
            __openssl_sslv3_method                  = (DLL_OPENSSL_SSLv3_method)                GetProcAddress(__libssl_DLL, "SSLv3_method") ;
            __openssl_tlsv1_method                  = (DLL_OPENSSL_TLSv1_method)                GetProcAddress(__libssl_DLL, "TLSv1_method") ;
            __openssl_tlsv1_1_method                = (DLL_OPENSSL_TLSv1_1_method)              GetProcAddress(__libssl_DLL, "TLSv1_1_method") ;
            __openssl_ssl_load_error_strings        = (DLL_OPENSSL_SSL_load_error_strings)      GetProcAddress(__libssl_DLL, "SSL_load_error_strings") ;
            __openssl_ssl_new                       = (DLL_OPENSSL_SSL_new)                     GetProcAddress(__libssl_DLL, "SSL_new") ;
            __openssl_ssl_ctx_new                   = (DLL_OPENSSL_SSL_CTX_new)                 GetProcAddress(__libssl_DLL, "SSL_CTX_new") ;
            __openssl_ssl_ctx_free                  = (DLL_OPENSSL_SSL_CTX_free)                GetProcAddress(__libssl_DLL, "SSL_CTX_free") ;
            __openssl_ssl_ctx_use_certificate_file  = (DLL_OPENSSL_SSL_CTX_use_certificate_file)GetProcAddress(__libssl_DLL, "SSL_CTX_use_certificate_file") ;
            __openssl_ssl_ctx_use_PrivateKey_file   = (DLL_OPENSSL_SSL_CTX_use_PrivateKey_file) GetProcAddress(__libssl_DLL, "SSL_CTX_use_PrivateKey_file") ;
            __openssl_ssl_ctx_check_private_key     = (DLL_OPENSSL_SSL_CTX_check_private_key)   GetProcAddress(__libssl_DLL, "SSL_CTX_check_private_key") ;
            __openssl_ssl_ctx_ctrl                  = (DLL_OPENSSL_SSL_CTX_ctrl)                GetProcAddress(__libssl_DLL, "SSL_CTX_ctrl") ;
            __openssl_ssl_accept                    = (DLL_OPENSSL_SSL_accept)                  GetProcAddress(__libssl_DLL, "SSL_accept") ;
            __openssl_ssl_read                      = (DLL_OPENSSL_SSL_read)                    GetProcAddress(__libssl_DLL, "SSL_read") ;
            __openssl_ssl_write                     = (DLL_OPENSSL_SSL_write)                   GetProcAddress(__libssl_DLL, "SSL_write") ;
            __openssl_ssl_get_fd                    = (DLL_OPENSSL_SSL_get_fd)                  GetProcAddress(__libssl_DLL, "SSL_get_fd") ;
            __openssl_ssl_set_fd                    = (DLL_OPENSSL_SSL_set_fd)                  GetProcAddress(__libssl_DLL, "SSL_set_fd") ;
            __openssl_ssl_free                      = (DLL_OPENSSL_SSL_free)                    GetProcAddress(__libssl_DLL, "SSL_free") ;
            __openssl_ssl_get_ssl_ctx               = (DLL_OPENSSL_SSL_get_SSL_CTX)             GetProcAddress(__libssl_DLL, "SSL_get_SSL_CTX") ;
            __openssl_ssl_connect                   = (DLL_OPENSSL_SSL_connect)                 GetProcAddress(__libssl_DLL, "SSL_connect") ;
            __openssl_ssl_get_error                 = (DLL_OPENSSL_SSL_get_error)               GetProcAddress(__libssl_DLL, "SSL_get_error") ;
            __openssl_ssl_shutdown                  = (DLL_OPENSSL_SSL_shutdown)                GetProcAddress(__libssl_DLL, "SSL_shutdown") ;
            __openssl_ssl_get_shutdown              = (DLL_OPENSSL_SSL_get_shutdown)            GetProcAddress(__libssl_DLL, "SSL_get_shutdown") ;
            __openssl_ssl_ctx_set_verify            = (DLL_OPENSSL_SSL_CTX_set_verify)          GetProcAddress(__libssl_DLL, "SSL_CTX_set_verify") ;
            __openssl_ssl_set_verify                = (DLL_OPENSSL_SSL_set_verify)              GetProcAddress(__libssl_DLL, "SSL_set_verify") ;
            __openssl_ssl_get_peer_certificate      = (DLL_OPENSSL_SSL_get_peer_certificate)     GetProcAddress(__libssl_DLL, "SSL_get_peer_certificate") ;
            __openssl_ssl_ctx_set_session_id_context    = (DLL_OPENSSL_SSL_CTX_set_session_id_context)  GetProcAddress(__libssl_DLL, "SSL_CTX_set_session_id_context") ;
            __openssl_ssl_ctx_load_verify_locations     = (DLL_OPENSSL_SSL_CTX_load_verify_locations)   GetProcAddress(__libssl_DLL, "SSL_CTX_load_verify_locations") ;
            __openssl_ssl_ctx_set_verify_depth          = (DLL_OPENSSL_SSL_CTX_set_verify_depth)    GetProcAddress(__libssl_DLL, "SSL_CTX_set_verify_depth") ;
            __openssl_ssl_set_verify_depth          = (DLL_OPENSSL_SSL_set_verify_depth)        GetProcAddress(__libssl_DLL, "SSL_set_verify_depth") ;
            __openssl_ssl_renegotiate               = (DLL_OPENSSL_SSL_renegotiate)             GetProcAddress(__libssl_DLL, "SSL_renegotiate") ;
            __openssl_ssl_do_handshake              = (DLL_OPENSSL_SSL_do_handshake)            GetProcAddress(__libssl_DLL, "SSL_do_handshake") ;
            

            if (!(	__openssl_ssl_library_init &&
                  __openssl_sslv23_method &&
                  __openssl_sslv2_method &&
                  __openssl_sslv3_method &&
                  __openssl_tlsv1_method &&
                  __openssl_tlsv1_1_method &&
                  __openssl_ssl_load_error_strings &&
                  __openssl_ssl_new &&
                  __openssl_ssl_ctx_new &&
                  __openssl_ssl_ctx_free &&
                  __openssl_ssl_ctx_use_certificate_file &&
                  __openssl_ssl_ctx_use_PrivateKey_file &&
                  __openssl_ssl_ctx_check_private_key &&
                  __openssl_ssl_ctx_ctrl &&
                  __openssl_ssl_accept &&
                  __openssl_ssl_read &&
                  __openssl_ssl_write &&
                  __openssl_ssl_get_fd &&
                  __openssl_ssl_set_fd &&
                  __openssl_ssl_free &&
                  __openssl_ssl_get_ssl_ctx &&
                  __openssl_ssl_connect &&
                  __openssl_ssl_get_error &&
                  __openssl_ssl_shutdown &&
                  __openssl_ssl_get_shutdown &&
                  __openssl_ssl_ctx_set_verify &&
                  __openssl_ssl_set_verify &&
                  __openssl_ssl_get_peer_certificate &&
                  __openssl_ssl_ctx_set_session_id_context &&
                  __openssl_ssl_ctx_load_verify_locations &&
                  __openssl_ssl_ctx_set_verify_depth &&
                  __openssl_ssl_set_verify_depth &&
                  __openssl_ssl_renegotiate &&
                  __openssl_ssl_do_handshake
                  ))
            {                
                if(!__openssl_ssl_library_init)             NSLog(@"__openssl_ssl_library_init NULL");
                if(!__openssl_sslv23_method)                NSLog(@"__openssl_sslv23_method NULL");
                if(!__openssl_sslv2_method)                 NSLog(@"__openssl_sslv2_method NULL");
                if(!__openssl_sslv3_method)                 NSLog(@"__openssl_sslv3_method NULL");
                if(!__openssl_tlsv1_method)                 NSLog(@"__openssl_tlsv1_method NULL");
                if(!__openssl_tlsv1_1_method)               NSLog(@"__openssl_tlsv1_1_method NULL");
                if(!__openssl_ssl_load_error_strings)       NSLog(@"__openssl_ssl_load_error_strings NULL");
                if(!__openssl_ssl_new)                      NSLog(@"__openssl_ssl_new NULL");
                if(!__openssl_ssl_ctx_new)                  NSLog(@"__openssl_ssl_ctx_new NULL");
                if(!__openssl_ssl_ctx_free)                 NSLog(@"__openssl_ssl_ctx_free NULL");
                if(!__openssl_ssl_ctx_use_certificate_file) NSLog(@"__openssl_ssl_ctx_use_certificate_file NULL");
                if(!__openssl_ssl_ctx_use_PrivateKey_file)  NSLog(@"__openssl_ssl_ctx_use_PrivateKey_file NULL");
                if(!__openssl_ssl_ctx_check_private_key)    NSLog(@"__openssl_ssl_ctx_check_private_key NULL");
                if(!__openssl_ssl_get_ssl_ctx)              NSLog(@"__openssl_ssl_get_ssl_ctx NULL");
                if(!__openssl_ssl_accept)                   NSLog(@"__openssl_ssl_accept NULL");
                if(!__openssl_ssl_read)                     NSLog(@"__openssl_ssl_read NULL");
                if(!__openssl_ssl_write)                    NSLog(@"__openssl_ssl_write NULL");
                if(!__openssl_ssl_get_fd)                   NSLog(@"__openssl_ssl_get_fd NULL");
                if(!__openssl_ssl_set_fd)                   NSLog(@"__openssl_ssl_set_fd NULL");
                if(!__openssl_ssl_free)                     NSLog(@"__openssl_ssl_free NULL");
                if(!__openssl_ssl_get_ssl_ctx)              NSLog(@"__openssl_ssl_get_ssl_ctx NULL");
                if(!__openssl_ssl_connect)                  NSLog(@"__openssl_ssl_connect NULL");
                if(!__openssl_ssl_get_error)                NSLog(@"__openssl_ssl_get_error NULL");
                if(!__openssl_ssl_shutdown)                 NSLog(@"__openssl_ssl_shutdown NULL");
                if(!__openssl_ssl_get_shutdown)             NSLog(@"__openssl_ssl_get_shutdown NULL");
                if(!__openssl_ssl_ctx_set_verify)           NSLog(@"__openssl_ssl_ctx_set_verify NULL");
                if(!__openssl_ssl_set_verify)               NSLog(@"__openssl_ssl_set_verify NULL");
                if(!__openssl_ssl_get_peer_certificate)      NSLog(@"__openssl_ssl_get_peer_certificate NULL");
                if(!__openssl_ssl_ctx_set_session_id_context)   NSLog(@"__openssl_ssl_ctx_set_session_id_context NULL");
                if(!__openssl_ssl_ctx_load_verify_locations)    NSLog(@"__openssl_ssl_ctx_load_verify_locations NULL");
                if(!__openssl_ssl_ctx_set_verify_depth)         NSLog(@"__openssl_ssl_ctx_set_verify_depth NULL");
                if(!__openssl_ssl_set_verify_depth)         NSLog(@"__openssl_ssl_set_verify_depth NULL");
                if(!__openssl_ssl_renegotiate)              NSLog(@"__openssl_ssl_renegotiate NULL");
                if(!__openssl_ssl_do_handshake)             NSLog(@"__openssl_ssl_do_handshake NULL");
            
                MSRaise(NSGenericException, @"Error while loading libssl32 library") ;
            }
            
        }
        else {
            MSRaise(NSGenericException, @"Error while loading libssl32.dll") ;
        }
    }
    
    
    //must be called prior openssl calls
    OPENSSL_CRYPTO_set_mem_functions(malloc, realloc, free) ; // == OPENSSL_CRYPTO_malloc_init()
    
    OPENSSL_SSL_library_init() ; //initializes open ssl
    OPENSSL__add_all_algorithms();  /* load & register all cryptos, etc. */
    OPENSSL_SSL_load_error_strings();   /* load all error messages */
    OPENSSL_initialize_done = 1;
}

#else

static int OPENSSL_initialize_done = 0;
void OPENSSL_initialize()
{
    if(OPENSSL_initialize_done)
        return;
    OPENSSL_SSL_library_init() ; //initializes open ssl
    OPENSSL__add_all_algorithms();  /* load & register all cryptos, etc. */
    OPENSSL_SSL_load_error_strings();   /* load all error messages */
    OPENSSL_initialize_done = 1;
}

#define __openssl_err_load_crypto_strings() ERR_load_crypto_strings()
#define __openssl_err_error_string_n(X,Y,Z) ERR_error_string_n(X, Y, Z)
#define __openssl_err_get_error() ERR_get_error()
#define __openssl_rand_bytes(X, Y) RAND_bytes(X, Y)
#define __openssl_evp_bytestokey(X, Y, Z, A, B, C, D, E) EVP_BytesToKey(X, Y, Z, A, B, C, D, E)
#define __openssl_evp_cipher_ctx_init(X) EVP_CIPHER_CTX_init(X)
#define __openssl_evp_cipherinit_ex(X, Y, Z, A, B, C) EVP_CipherInit_ex(X, Y, Z, A, B, C)
#define __openssl_evp_cipherupdate(X, Y, Z, A, B) EVP_CipherUpdate(X, Y, Z, A, B)
#define __openssl_evp_cipherfinal_ex(X, Y, Z) EVP_CipherFinal_ex(X, Y, Z)
#define __openssl_evp_cipher_ctx_cleanup(X) EVP_CIPHER_CTX_cleanup(X)
#define __openssl_rsa_generate_key(X, Y, Z, A) RSA_generate_key(X, Y, Z, A)
#define __openssl_pem_read_bio_rsa_pubkey(X, Y, Z, A) PEM_read_bio_RSA_PUBKEY(X, Y, Z, A)
#define __openssl_pem_read_bio_rsaprivatekey(X, Y, Z, A) PEM_read_bio_RSAPrivateKey(X, Y, Z, A)
#define __openssl_rsa_public_encrypt(X, Y, Z, A, B) RSA_public_encrypt(X, Y, Z, A, B)
#define __openssl_rsa_private_decrypt(X, Y, Z, A, B) RSA_private_decrypt(X, Y, Z, A, B)
#define __openssl_rsa_sign(X, Y, Z, A, B, C) RSA_sign(X, Y, Z, A, B, C)
#define __openssl_rsa_verify(X, Y, Z, A, B, C) RSA_verify(X, Y, Z, A, B, C)
#define __openssl_pem_write_bio_rsaprivatekey(X, Y, Z, A, B, C, D) PEM_write_bio_RSAPrivateKey(X, Y, Z, A, B, C, D)
#define __openssl_pem_write_bio_rsa_pubkey(X, Y) PEM_write_bio_RSA_PUBKEY(X, Y)
#define __openssl_rsa_free(X) RSA_free(X)
#define __openssl_bio_new(X) BIO_new(X)
#define __openssl_bio_new_mem_buf(X, Y) BIO_new_mem_buf(X, Y)
#define __openssl_bio_s_mem() BIO_s_mem()
#define __openssl_bio_ctrl_pending(X) BIO_ctrl_pending(X);
#define __openssl_bio_read(X, Y, Z) BIO_read(X, Y, Z)
#define __openssl_bio_free_all(X) BIO_free_all(X)
#define __openssl_bio_free(X) BIO_free(X)
#define __openssl_evp_cipher_key_length(X) EVP_CIPHER_key_length(X)
#define __openssl_evp_cipher_iv_length(X) EVP_CIPHER_iv_length(X)
#define __openssl_evp_aes_256_cbc() EVP_aes_256_cbc()
#define __openssl_evp_aes_192_cbc() EVP_aes_192_cbc()
#define __openssl_evp_aes_128_cbc() EVP_aes_128_cbc()
#define __openssl_evp_bf_cbc() EVP_bf_cbc()
#define __openssl_evp_bf_cfb64() EVP_bf_cfb64()
#define __openssl_evp_bf_ofb() EVP_bf_ofb()
#define __openssl_rsa_size(X) RSA_size(X)
#define __openssl_evp_cipher_ctx_new() EVP_CIPHER_CTX_new()
#define __openssl_evp_cipher_ctx_free(X) EVP_CIPHER_CTX_free(X)
#define __openssl_evp_md5() EVP_md5()
#define __openssl_evp_sha1() EVP_sha1()
#define __openssl_evp_sha256() EVP_sha256()
#define __openssl_evp_sha512() EVP_sha512()
#define __openssl_evp_dss1() EVP_dss1()
#define __openssl_evp_mdc2() EVP_mdc2()
#define __openssl_evp_ripemd160() EVP_ripemd160()
#define __openssl_evp_md_ctx_init(X) EVP_MD_CTX_init(X)
#define __openssl_evp_digestinit_ex(X, Y, Z) EVP_DigestInit_ex(X, Y, Z)
#define __openssl_evp_digestupdate(X, Y, Z) EVP_DigestUpdate(X, Y, Z)
#define __openssl_evp_digestfinal_ex(X, Y, Z) EVP_DigestFinal_ex(X, Y, Z)
#define __openssl_evp_md_ctx_cleanup(X) EVP_MD_CTX_cleanup(X)
#define __openssl_bio_f_base64() BIO_f_base64()
#define __openssl_bio_push(X, Y) BIO_push(X, Y)
#define __openssl_bio_write(X, Y, Z) BIO_write(X, Y, Z)
#define __openssl_bio_ctrl(X, Y, Z, A) BIO_ctrl(X, Y, Z, A)
#define __openssl_bio_set_flags(X, Y) BIO_set_flags(X, Y)
#define __openssl_add_all_algorithms() OpenSSL_add_all_algorithms()
#define __openssl_err_print_errors_fp(X) ERR_print_errors_fp(X)
#define __openssl_ssl_library_init() (int) SSL_library_init()
#define __openssl_sslv23_method() SSLv23_method()
#define __openssl_sslv2_method() SSLv2_method()
#define __openssl_sslv3_method() SSLv3_method()
#define __openssl_tlsv1_method() TLSv1_method()
#define __openssl_tlsv1_1_method() TLSv1_1_method()
#define __openssl_ssl_load_error_strings() SSL_load_error_strings()
#define __openssl_ssl_new(X) SSL_new(X)
#define __openssl_ssl_ctx_new(X) SSL_CTX_new(X)
#define __openssl_ssl_ctx_free(X) SSL_CTX_free(X)
#define __openssl_ssl_ctx_use_certificate_file(X,Y,Z) SSL_CTX_use_certificate_file(X,Y,Z)
#define __openssl_ssl_ctx_use_PrivateKey_file(X,Y,Z) SSL_CTX_use_PrivateKey_file(X,Y,Z) 
#define __openssl_ssl_ctx_check_private_key(X) SSL_CTX_check_private_key(X)
#define __openssl_ssl_ctx_ctrl(X,Y,Z,A) SSL_CTX_ctrl(X,Y,Z,A)
#define __openssl_ssl_accept(X) SSL_accept(X)
#define __openssl_ssl_read(X,Y,Z) SSL_read(X,Y,Z)
#define __openssl_ssl_write(X,Y,Z) SSL_write(X,Y,Z)
#define __openssl_ssl_get_fd(X) SSL_get_fd(X)
#define __openssl_ssl_set_fd(X,Y) SSL_set_fd(X,Y)
#define __openssl_ssl_free(X) SSL_free(X)
#define __openssl_crypto_malloc(X,Y,Z) CRYPTO_malloc(X,Y,Z)
#define __openssl_crypto_num_locks CRYPTO_num_locks
#define __openssl_crypto_threadid_set_numeric(X,Y) CRYPTO_THREADID_set_numeric(X,Y)
#define __openssl_crypto_threadid_set_callback(X) CRYPTO_THREADID_set_callback(X)
#define __openssl_crypto_set_locking_callback(X) CRYPTO_set_locking_callback(X)
#define __openssl_crypto_free(X) CRYPTO_free(X)
#define __openssl_ssl_get_ssl_ctx(X) SSL_get_SSL_CTX(X)
#define __openssl_ssl_connect(X) SSL_connect(X)
#define __openssl_crypto_set_mem_functions(X,Y,Z) CRYPTO_set_mem_functions(X,Y,Z)
#define __openssl_ssl_get_error(X,Y) SSL_get_error(X,Y)
#define __openssl_ssl_shutdown(X) SSL_shutdown(X)
#define __openssl_ssl_get_shutdown(X) SSL_get_shutdown(X)
#define __openssl_ssl_ctx_set_verify(X,Y,Z) SSL_CTX_set_verify(X,Y,Z)
#define __openssl_ssl_set_verify(X,Y,Z) SSL_set_verify(X,Y,Z)
#define __openssl_ssl_get_peer_certificate(X) SSL_get_peer_certificate(X)
#define __openssl_ssl_ctx_set_session_id_context(X,Y,Z) SSL_CTX_set_session_id_context(X,Y,Z)
#define __openssl_ssl_ctx_load_verify_locations(X,Y,Z) SSL_CTX_load_verify_locations(X,Y,Z)
#define __openssl_ssl_ctx_set_verify_depth(X,Y) SSL_CTX_set_verify_depth(X,Y)
#define __openssl_ssl_set_verify_depth(X,Y) SSL_set_verify_depth(X,Y)
#define __openssl_ssl_renegotiate(X) SSL_renegotiate(X)
#define __openssl_ssl_do_handshake(X) SSL_do_handshake(X) ;
#define __openssl_x509_free(X) X509_free(X)
#define __openssl_pem_read_bio_x509(X,Y,Z,A) PEM_read_bio_X509(X,Y,Z,A)
#define __openssl_d2i_x509_bio(X,Y) d2i_X509_bio(X,Y)
#define __openssl_obj_obj2txt(X,Y,Z,A) OBJ_obj2txt(X,Y,Z,A)
#define __openssl_asn1_string_to_utf8(X,Y) ASN1_STRING_to_UTF8(X,Y)
#define __openssl_x509_name_entry_count(X) X509_NAME_entry_count(X)
#define __openssl_x509_name_get_entry(X,Y) X509_NAME_get_entry(X,Y)
#define __openssl_x509_name_entry_get_object(X) X509_NAME_ENTRY_get_object(X)
#define __openssl_x509_name_entry_get_data(X) X509_NAME_ENTRY_get_data(X)
#define __openssl_x509_get_serialnumber(X) X509_get_serialNumber(X)
#define __openssl_asn1_integer_get(X) ASN1_INTEGER_get(X)
#define __openssl_i2c_asn1_integer(X,Y) i2c_ASN1_INTEGER(X,Y)
#define __openssl_x509_get_issuer_name(X) X509_get_issuer_name(X)
#define __openssl_x509_get_subject_name(X) X509_get_subject_name(X)
#define __openssl_x509_digest(X,Y,Z,A) X509_digest(X,Y,Z,A)
#define __openssl_asn1_time_to_generalizedtime(X,Y) ASN1_TIME_to_generalizedtime(X,Y)
#define __openssl_hmac_init_ex(X,Y,Z,A,B) HMAC_Init_ex(X,Y,Z,A,B)
#define __openssl_hmac_ctx_init(X) HMAC_CTX_init(X)
#define __openssl_hmac_update(X,Y,Z) HMAC_Update(X,Y,Z)
#define __openssl_hmac_final(X,Y,Z) HMAC_Final(X,Y,Z)
#define __openssl_rand_add(X,Y,Z) RAND_add(X,Y,Z)
#define __openssl_evp_cipherinit(X,Y,Z,A,B) EVP_CipherInit(X,Y,Z,A,B)
#define __openssl_evp_cipher_ctx_set_padding(X,Y) EVP_CIPHER_CTX_set_padding(X,Y)
#define __openssl_evp_cipherfinal(X,Y,Z) EVP_CipherFinal(X,Y,Z)
#define __openssl_evp_cipher_block_size(X) EVP_CIPHER_block_size(X)
#define __openssl_evp_md_size(X) EVP_MD_size(X)
#define __openssl_evp_get_cipherbyname(X) EVP_get_cipherbyname(X)
#define __openssl_pkcs5_pbkdf2_hmac_sha1(X,Y,Z,A,B,C,D) PKCS5_PBKDF2_HMAC_SHA1(X,Y,Z,A,B,C,D)
#define __openssl_hmac_ctx_cleanup(X) HMAC_CTX_cleanup(X)
#define __openssl_evp_cleanup() EVP_cleanup()
#define __openssl_obj_nid2sn(X) OBJ_nid2sn(X)
#define __openssl_evp_cipher_nid(X) EVP_CIPHER_nid(X)
#define __openssl_asn1_integer_to_bn(X,Y) ASN1_INTEGER_to_BN(X,Y)
#define __openssl_bn_bn2hex(X) BN_bn2hex(X)

#endif

void			OPENSSL_ERR_load_crypto_strings() { __openssl_err_load_crypto_strings() ; }
void			OPENSSL_ERR_error_string_n(unsigned long e, char *buf, size_t len) { __openssl_err_error_string_n(e, buf, len) ; }
unsigned long	OPENSSL_ERR_get_error() { return __openssl_err_get_error() ; }
int				OPENSSL_RAND_bytes(unsigned char *buf, int num) { return __openssl_rand_bytes(buf, num) ; }
int				OPENSSL_EVP_BytesToKey(const void *type,const void *md, const unsigned char *salt, const unsigned char *data, int datal, int count, unsigned char *key,unsigned char *iv) { return __openssl_evp_bytestokey((const EVP_CIPHER *)type, (const EVP_MD *)md, salt, data, datal, count, key, iv) ; }
void			OPENSSL_EVP_CIPHER_CTX_init(void *a) { __openssl_evp_cipher_ctx_init(a) ; }
int				OPENSSL_EVP_CipherInit_ex(void *ctx, const void *type, void *impl, unsigned char *key, unsigned char *iv, int enc) { return __openssl_evp_cipherinit_ex((EVP_CIPHER_CTX *)ctx, (const EVP_CIPHER *)type, (ENGINE *)impl, key, iv, enc) ; }
int				OPENSSL_EVP_CipherUpdate(void *ctx, unsigned char *out, int *outl, unsigned char *in, int inl) { return __openssl_evp_cipherupdate( (EVP_CIPHER_CTX *)ctx, out, outl, in, inl) ; }
int				OPENSSL_EVP_CipherFinal_ex(void *ctx, unsigned char *outm, int *outl) { return __openssl_evp_cipherfinal_ex( (EVP_CIPHER_CTX *)ctx, outm, outl) ; }
int				OPENSSL_EVP_CIPHER_CTX_cleanup(void *a) { return __openssl_evp_cipher_ctx_cleanup(a) ; }
void *			OPENSSL_RSA_generate_key(int num, unsigned long e, void (*callback)(int,int,void *), void *cb_arg) { return (void *)__openssl_rsa_generate_key(num, e, callback, cb_arg) ; }
void *			OPENSSL_PEM_read_bio_RSA_PUBKEY(void *bp, void **x, void *cb, void *u) { return (void *)__openssl_pem_read_bio_rsa_pubkey((BIO *)bp, (RSA **)x, (pem_password_cb *)cb, u) ; }
void *			OPENSSL_PEM_read_bio_RSAPrivateKey(void *bp, void **x, void *cb, void *u) { return (void *)__openssl_pem_read_bio_rsaprivatekey((BIO *)bp, (RSA **)x, (pem_password_cb *)cb, u) ; }
int				OPENSSL_RSA_public_encrypt(int flen, unsigned char *from, unsigned char *to, void *rsa, int padding) { return __openssl_rsa_public_encrypt(flen, from, to, (RSA *)rsa, padding) ; }
int				OPENSSL_RSA_private_decrypt(int flen, unsigned char *from, unsigned char *to, void *rsa, int padding) { return __openssl_rsa_private_decrypt(flen, from, to, (RSA *)rsa, padding) ; }
int             OPENSSL_RSA_sign(int type, const unsigned char *m, unsigned int m_len, unsigned char *sigret, unsigned int *siglen, void *rsa) { return __openssl_rsa_sign(type, m, m_len, sigret, siglen, (RSA *)rsa) ; }
int             OPENSSL_RSA_verify(int type, const unsigned char *m, unsigned int m_len, unsigned char *sigbuf, unsigned int siglen, void *rsa) { return __openssl_rsa_verify(type, m, m_len, sigbuf, siglen, (RSA *)rsa) ; }
int				OPENSSL_PEM_write_bio_RSAPrivateKey(void *bp, void *x, const void *enc, unsigned char *kstr, int klen, void *cb, void *u) { return __openssl_pem_write_bio_rsaprivatekey((BIO *)bp, (RSA *)x, (const EVP_CIPHER *)enc, kstr, klen, (pem_password_cb *)cb, u) ; }
int				OPENSSL_PEM_write_bio_RSA_PUBKEY(void *bp, void *x) { return __openssl_pem_write_bio_rsa_pubkey((BIO *)bp, (RSA *)x) ; }
void			OPENSSL_RSA_free(void *rsa) { __openssl_rsa_free((RSA *)rsa) ; }
void *			OPENSSL_BIO_new(void *type) { return (void *)__openssl_bio_new((BIO_METHOD *)type) ; }
void *			OPENSSL_BIO_new_mem_buf(void *buf, int len) { return (void *)__openssl_bio_new_mem_buf(buf,len) ; }
void *			OPENSSL_BIO_s_mem() { return (void *)__openssl_bio_s_mem() ; }
size_t			OPENSSL_BIO_ctrl_pending(void *b) { return __openssl_bio_ctrl_pending((BIO *)b) ; }
int				OPENSSL_BIO_read(void *b, void *buf, int len) { return __openssl_bio_read((BIO *)b,buf,len) ; }
void			OPENSSL_BIO_free_all(void *a) { __openssl_bio_free_all((BIO *)a) ; }
int				OPENSSL_BIO_free(void *a) { return __openssl_bio_free((BIO *)a) ; }
int				OPENSSL_EVP_CIPHER_key_length(const void *cipher) { return __openssl_evp_cipher_key_length((const EVP_CIPHER *)cipher) ; }
int				OPENSSL_EVP_CIPHER_iv_length(const void *cipher) { return __openssl_evp_cipher_iv_length((const EVP_CIPHER *)cipher) ; }
const void *	OPENSSL_EVP_aes_256_cbc() { return (const void *) __openssl_evp_aes_256_cbc() ; }
const void *	OPENSSL_EVP_aes_192_cbc() { return (const void *) __openssl_evp_aes_192_cbc() ; }
const void *	OPENSSL_EVP_aes_128_cbc() { return (const void *) __openssl_evp_aes_128_cbc() ; }
const void *	OPENSSL_EVP_bf_cbc() { return (const void *) __openssl_evp_bf_cbc() ; }
const void *	OPENSSL_EVP_bf_cfb64() { return (const void *) __openssl_evp_bf_cfb64() ; }
const void *	OPENSSL_EVP_bf_ofb() { return (const void *) __openssl_evp_bf_ofb() ; }
int				OPENSSL_RSA_size(const void *x) { return __openssl_rsa_size((const RSA *)x) ; }
void *			OPENSSL_EVP_CIPHER_CTX_new() { return (void *)__openssl_evp_cipher_ctx_new() ; }
void			OPENSSL_EVP_CIPHER_CTX_free(void *a) { __openssl_evp_cipher_ctx_free((EVP_CIPHER_CTX *)a) ; }
const void *	OPENSSL_EVP_md5() { return (const void *) __openssl_evp_md5() ; }
const void *	OPENSSL_EVP_sha1() { return (const void *) __openssl_evp_sha1() ; }
const void *	OPENSSL_EVP_sha256() { return (const void *) __openssl_evp_sha256() ; }
const void *	OPENSSL_EVP_sha512() { return (const void *) __openssl_evp_sha512() ; }
const void *	OPENSSL_EVP_dss1() { return (const void *) __openssl_evp_dss1() ; }
const void *	OPENSSL_EVP_mdc2() { return (const void *) __openssl_evp_mdc2() ; }
const void *	OPENSSL_EVP_ripemd160() { return (const void *) __openssl_evp_ripemd160() ; }
void			OPENSSL_EVP_MD_CTX_init(void *ctx) { __openssl_evp_md_ctx_init((EVP_MD_CTX *)ctx) ; }
int				OPENSSL_EVP_DigestInit_ex(void *ctx, const void *type, void *impl) { return __openssl_evp_digestinit_ex((EVP_MD_CTX *)ctx, (const EVP_MD *)type, (ENGINE *)impl) ; }
int				OPENSSL_EVP_DigestUpdate(void *ctx, const void *d, size_t cnt) { return __openssl_evp_digestupdate((EVP_MD_CTX *)ctx, (const void *)d, cnt) ; }
int				OPENSSL_EVP_DigestFinal_ex(void *ctx, void *md, void *s) { return __openssl_evp_digestfinal_ex((EVP_MD_CTX *)ctx, (unsigned char *)md, (unsigned int *)s) ; }
int				OPENSSL_EVP_MD_CTX_cleanup(void *ctx) { return __openssl_evp_md_ctx_cleanup((EVP_MD_CTX *)ctx) ; }
void *          OPENSSL_BIO_f_base64() { return (void * )__openssl_bio_f_base64() ; }
void *          OPENSSL_BIO_push (void *b,void *append) { return (void *)__openssl_bio_push((BIO *)b, (BIO *)append) ; }
int             OPENSSL_BIO_write (void *b, const void *data, int len) { return __openssl_bio_write((BIO *)b, data, len) ; }
long            OPENSSL_BIO_ctrl(void *bp,int cmd,long larg,void *parg) { return __openssl_bio_ctrl((BIO *)bp, cmd, larg, parg) ; }
void            OPENSSL_BIO_set_flags(void *b, int flags) { __openssl_bio_set_flags((BIO *)b, flags) ; }
void            OPENSSL__add_all_algorithms() { __openssl_add_all_algorithms() ; }
void            OPENSSL_ERR_print_errors_fp(void *fp) { __openssl_err_print_errors_fp((FILE *) fp) ; }
int             OPENSSL_SSL_library_init() { return __openssl_ssl_library_init() ; }
const void *    OPENSSL_SSLv23_method() { return (SSL_METHOD *) __openssl_sslv23_method() ; }
const void *    OPENSSL_SSLv2_method() { return (SSL_METHOD *) __openssl_sslv2_method() ; }
const void *    OPENSSL_SSLv3_method() { return (SSL_METHOD *) __openssl_sslv3_method() ; }
const void *    OPENSSL_TLSv1_method() { return (SSL_METHOD *) __openssl_tlsv1_method() ; }
const void *    OPENSSL_TLSv1_1_method() { return (SSL_METHOD *) __openssl_tlsv1_1_method() ; }
void            OPENSSL_SSL_load_error_strings() { __openssl_ssl_load_error_strings() ; }
void *          OPENSSL_SSL_new (void *ctx) { return (SSL *) __openssl_ssl_new((SSL_CTX *)ctx) ; }
void *          OPENSSL_SSL_CTX_new(const void *meth) { return (SSL_CTX *) __openssl_ssl_ctx_new((SSL_METHOD *)meth) ;}
void            OPENSSL_SSL_CTX_free(void *ctx) { __openssl_ssl_ctx_free((SSL_CTX *) ctx) ; }
int             OPENSSL_SSL_CTX_use_certificate_file(void *ctx, const char *file, int type) { return __openssl_ssl_ctx_use_certificate_file((SSL_CTX *)ctx, file, type) ; }
int             OPENSSL_SSL_CTX_use_PrivateKey_file(void *ctx, const char *file, int type) { return __openssl_ssl_ctx_use_PrivateKey_file((SSL_CTX *)ctx, file, type) ; }
int             OPENSSL_SSL_CTX_check_private_key(const void *ctx) { return __openssl_ssl_ctx_check_private_key((const SSL_CTX *)ctx) ;}
long            OPENSSL_SSL_CTX_set_mode(void *ctx, long mode) { return __openssl_ssl_ctx_ctrl((ctx),SSL_CTRL_MODE,(mode),NULL) ; }
long            OPENSSL_SSL_CTX_set_options(void *ctx, long options) { return __openssl_ssl_ctx_ctrl((ctx),SSL_CTRL_OPTIONS,(options),NULL) ; }
int             OPENSSL_SSL_accept(void *ssl) { return __openssl_ssl_accept((SSL *)ssl) ; }
int             OPENSSL_SSL_read(void *ssl,void *buf,int num) { return __openssl_ssl_read((SSL *)ssl, buf, num) ; }
int             OPENSSL_SSL_write(void *ssl,const void *buf,int num) { return __openssl_ssl_write((SSL *)ssl, buf, num) ; }
int             OPENSSL_SSL_get_fd(const void *s) { return __openssl_ssl_get_fd((const SSL *)s) ; }
int             OPENSSL_SSL_set_fd(void *s, int fd) { return __openssl_ssl_set_fd((SSL *)s, fd) ;}
void            OPENSSL_SSL_free(void *ssl) { __openssl_ssl_free((SSL *)ssl) ; }
void *          OPENSSL_CRYPTO_malloc(int num, const char *file, int line) { return __openssl_crypto_malloc(num, file, line) ; }
int             OPENSSL_CRYPTO_num_locks() { return __openssl_crypto_num_locks() ; }
void            OPENSSL_CRYPTO_THREADID_set_numeric(void *id, unsigned long val) { __openssl_crypto_threadid_set_numeric((CRYPTO_THREADID *)id, val) ; }
int             OPENSSL_CRYPTO_THREADID_set_callback(void (*threadid_func)(void *)) { return __openssl_crypto_threadid_set_callback((void (*)(CRYPTO_THREADID *))threadid_func) ; }
void            OPENSSL_CRYPTO_set_locking_callback(void (*func)(int mode,int type, const char *file,int line)) { __openssl_crypto_set_locking_callback(func) ; }
void            OPENSSL_CRYPTO_free(void *crypt) { __openssl_crypto_free(crypt) ; }
void *          OPENSSL_SSL_get_SSL_CTX(const void *ssl) { return __openssl_ssl_get_ssl_ctx((SSL*) ssl) ; }
int             OPENSSL_SSL_connect(void *ssl) { return __openssl_ssl_connect((SSL*) ssl) ; }
int             OPENSSL_CRYPTO_set_mem_functions(void *(*m)(size_t),void *(*r)(void *,size_t), void (*f)(void *)) { return __openssl_crypto_set_mem_functions(m,r,f) ; }
int             OPENSSL_SSL_get_error(const void *s,int ret) { return __openssl_ssl_get_error(s, ret) ; }
int             OPENSSL_SSL_shutdown(void *ssl) { return __openssl_ssl_shutdown((SSL*) ssl) ; }
int             OPENSSL_SSL_get_shutdown(void *ssl) { return __openssl_ssl_get_shutdown((SSL*) ssl) ; }
typedef int (*openssl_ssl_verify_callback)(int, X509_STORE_CTX *) ;
void            OPENSSL_SSL_CTX_set_verify(void *ctx,int mode, int (*callback)(int, void *)) { __openssl_ssl_ctx_set_verify(ctx, mode, (openssl_ssl_verify_callback)callback) ; }
void            OPENSSL_SSL_set_verify(void *s, int mode, int (*callback)(int, void *)) { __openssl_ssl_set_verify(s, mode, (openssl_ssl_verify_callback)callback) ; }
void *          OPENSSL_SSL_get_peer_certificate(const void *s) { return __openssl_ssl_get_peer_certificate(s) ; }
int             OPENSSL_SSL_CTX_set_session_id_context(void *ctx,const unsigned char *sid_ctx, unsigned int sid_ctx_len) { return __openssl_ssl_ctx_set_session_id_context(ctx, sid_ctx, sid_ctx_len) ; }
int             OPENSSL_SSL_CTX_load_verify_locations(void *ctx, const char *CAfile, const char *CApath) { return __openssl_ssl_ctx_load_verify_locations(ctx, CAfile, CApath) ; }
void            OPENSSL_SSL_CTX_set_verify_depth(void *s, int depth) { __openssl_ssl_ctx_set_verify_depth(s, depth) ; }
void            OPENSSL_SSL_set_verify_depth(void *s, int depth) { __openssl_ssl_set_verify_depth(s, depth) ; }
int             OPENSSL_SSL_renegotiate(void *s) { return __openssl_ssl_renegotiate(s) ; }
int             OPENSSL_SSL_do_handshake(void *s) { return __openssl_ssl_do_handshake(s) ; }
void            OPENSSL_X509_free(void *a) { __openssl_x509_free(a) ; }
void *          OPENSSL_PEM_read_bio_X509(void *bp, void **x, void *cb, void *u) { return (X509 *)__openssl_pem_read_bio_x509((BIO *)bp, (X509 **)x, cb, u) ; }
void *          OPENSSL_d2i_X509_bio(void *bp,void **x509) { return (X509 *)__openssl_d2i_x509_bio((BIO *)bp, (X509 **)x509) ; }
int             OPENSSL_OBJ_obj2txt(char *buf, int buf_len, const void *a, int no_name) { return __openssl_obj_obj2txt(buf, buf_len, (const ASN1_OBJECT *)a, no_name) ; }
int             OPENSSL_ASN1_STRING_to_UTF8(unsigned char **out, void *in) { return __openssl_asn1_string_to_utf8(out, (ASN1_STRING *)in) ; }
int             OPENSSL_X509_NAME_entry_count(void *name) { return __openssl_x509_name_entry_count((X509_NAME *)name) ; }
void *          OPENSSL_X509_NAME_get_entry(void *name, int loc) { return (X509_NAME_ENTRY *)__openssl_x509_name_get_entry((X509_NAME *)name, loc) ; }
void *          OPENSSL_X509_NAME_ENTRY_get_object(void *ne) { return (ASN1_OBJECT *)__openssl_x509_name_entry_get_object((X509_NAME_ENTRY *)ne) ; }
void *          OPENSSL_X509_NAME_ENTRY_get_data(void *ne) { return (ASN1_STRING *)__openssl_x509_name_entry_get_data((X509_NAME_ENTRY *)ne) ; }
void *          OPENSSL_X509_get_serialNumber(void *x) { return (ASN1_INTEGER *)__openssl_x509_get_serialnumber((X509 *)x) ; }
long            OPENSSL_ASN1_INTEGER_get(const void *a) { return __openssl_asn1_integer_get((ASN1_INTEGER *)a) ; }
int             OPENSSL_i2c_ASN1_INTEGER(void *a,unsigned char **pp) { return __openssl_i2c_asn1_integer((ASN1_INTEGER *)a, pp) ; }
void *          OPENSSL_X509_get_issuer_name(void *a) { return (X509_NAME *)__openssl_x509_get_issuer_name((X509 *)a) ; }
void *          OPENSSL_X509_get_subject_name(void *a) { return (X509_NAME *)__openssl_x509_get_subject_name((X509 *)a) ; }
int             OPENSSL_X509_digest(const void *data,const void *type,unsigned char *md, unsigned int *len) { return __openssl_x509_digest((const X509 *)data, (const EVP_MD *)type, md, len) ; }
int             OPENSSL_HMAC_Init_ex(void *ctx, const void *key, int len, const void *md, void *impl) { return __openssl_hmac_init_ex((HMAC_CTX *)ctx, key, len, (const EVP_MD *)md, (ENGINE *)impl) ; }
void            OPENSSL_HMAC_CTX_init(void *ctx){__openssl_hmac_ctx_init((HMAC_CTX *)ctx); }
int             OPENSSL_HMAC_Update(void *ctx, const unsigned char *data, size_t len){return __openssl_hmac_update((HMAC_CTX *)ctx,data,len);}
int             OPENSSL_HMAC_Final(void *ctx, unsigned char *md, unsigned int *len){return __openssl_hmac_final((HMAC_CTX *)ctx,md,len);}
void            OPENSSL_RAND_add(const void *buf,int num,double entropy){__openssl_rand_add(buf,num,entropy);}
int             OPENSSL_EVP_CipherInit(void *ctx,const void *cipher, const unsigned char *key,const unsigned char *iv, int enc){return __openssl_evp_cipherinit((EVP_CIPHER_CTX *)ctx,(const EVP_CIPHER *)cipher,key,iv,enc);}
int             OPENSSL_EVP_CIPHER_CTX_set_padding(void *c, int pad){return __openssl_evp_cipher_ctx_set_padding((EVP_CIPHER_CTX *)c,pad);}
int             OPENSSL_EVP_CipherFinal(void *ctx, unsigned char *outm, int *outl){return __openssl_evp_cipherfinal((EVP_CIPHER_CTX *)ctx,outm,outl);}
int             OPENSSL_EVP_CIPHER_block_size(const void *cipher){return __openssl_evp_cipher_block_size((const EVP_CIPHER *)cipher);}
int             OPENSSL_EVP_MD_size(const void *md){return __openssl_evp_md_size((const EVP_MD *)md);}
const void *    OPENSSL_EVP_get_cipherbyname(const char *name){return(const EVP_CIPHER *)__openssl_evp_get_cipherbyname(name);}
int             OPENSSL_PKCS5_PBKDF2_HMAC_SHA1(const char *pass, int passlen, const unsigned char *salt, int saltlen, int iter, int keylen, unsigned char * out){return __openssl_pkcs5_pbkdf2_hmac_sha1(pass,passlen,salt,saltlen,iter,keylen,out);}
void            OPENSSL_HMAC_CTX_cleanup(void *ctx){__openssl_hmac_ctx_cleanup((HMAC_CTX *)ctx);}
void            OPENSSL_EVP_cleanup(){__openssl_evp_cleanup();}
const char *    OPENSSL_OBJ_nid2sn(int n){return __openssl_obj_nid2sn(n);}
int             OPENSSL_EVP_CIPHER_nid(const void *cipher){return __openssl_evp_cipher_nid((const EVP_CIPHER*)cipher);}
void *          OPENSSL_ASN1_TIME_to_generalizedtime(void *t, void **out) { return __openssl_asn1_time_to_generalizedtime((ASN1_TIME *)t, (ASN1_GENERALIZEDTIME **)out) ; }
void *          OPENSSL_X509_get_notBefore(void *a) { return X509_get_notBefore((X509*)a) ; }
void *          OPENSSL_X509_get_notAfter(void *a) { return X509_get_notAfter((X509*)a) ; }
void *          OPENSSL_ASN1_INTEGER_to_BN(const void *ai,void *bn) { return __openssl_asn1_integer_to_bn((const ASN1_INTEGER *)ai, (BIGNUM *)bn) ; }
char *          OPENSSL_BN_bn2hex(const void *a) { return __openssl_bn_bn2hex((const BIGNUM *)a) ; }
