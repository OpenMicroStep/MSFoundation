/*
 
 MSCSSLInterface.h
 
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

//OpenSSL cross-plateform functions

MSNetExtern NSString *MSGetOpenSSLErrStr(void);
MSNetExtern NSString *MSGetOpenSSL_SSLErrStr(void *ssl, int ret);
MSNetExtern void MSRaiseCryptoOpenSSLException(void);

MSNetExtern void			OPENSSL_initialize(void) ;

//Errors section
MSNetExtern unsigned long	OPENSSL_ERR_get_error(void) ;
MSNetExtern void			OPENSSL_ERR_error_string_n(unsigned long e, char *buf, size_t len) ;
MSNetExtern void			OPENSSL_ERR_load_crypto_strings(void) ;
MSNetExtern void           OPENSSL_ERR_print_errors_fp(void *fp) ;

//BIO section
MSNetExtern long           OPENSSL_BIO_ctrl(void *bp,int cmd,long larg,void *parg) ;
MSNetExtern size_t			OPENSSL_BIO_ctrl_pending(void *b) ;
MSNetExtern void *         OPENSSL_BIO_f_base64(void) ;
MSNetExtern int			OPENSSL_BIO_free(void *a) ;
MSNetExtern void			OPENSSL_BIO_free_all(void *a) ;
MSNetExtern void *			OPENSSL_BIO_new(void *type) ;
MSNetExtern void *			OPENSSL_BIO_new_mem_buf(void *buf, int len) ;
MSNetExtern void *         OPENSSL_BIO_push (void *b,void *append) ;
MSNetExtern int			OPENSSL_BIO_read(void *b, void *buf, int len) ;
MSNetExtern void *			OPENSSL_BIO_s_mem(void) ;
MSNetExtern void           OPENSSL_BIO_set_flags(void *b, int flags);
MSNetExtern int            OPENSSL_BIO_write (void *b, const void *data, int len) ;

#define                 OPENSSL_BIO_flush(b) (int)OPENSSL_BIO_ctrl(b,BIO_CTRL_FLUSH,0,NULL)
#define                 OPENSSL_BIO_get_mem_data(b,pp) OPENSSL_BIO_ctrl(b,BIO_CTRL_INFO,0,(char *)pp)
#define                 OPENSSL_BIO_set_close(b,c) (int)OPENSSL_BIO_ctrl(b,BIO_CTRL_SET_CLOSE,(c),NULL)
#define                 OPENSSL_BIO_reset(b) (int)OPENSSL_BIO_ctrl(b,BIO_CTRL_RESET,0,NULL)
#define                 OPENSSL_EVP_CIPHER_name(e)		OPENSSL_OBJ_nid2sn(OPENSSL_EVP_CIPHER_nid(e))                 

//EVP section
MSNetExtern int			OPENSSL_EVP_BytesToKey(const void *type,const void *md, const unsigned char *salt, const unsigned char *data, int datal, int count, unsigned char *key,unsigned char *iv) ;
MSNetExtern void			OPENSSL_EVP_CIPHER_CTX_init(void *a) ;
MSNetExtern int			OPENSSL_EVP_CipherInit_ex(void *ctx, const void *type, void *impl, unsigned char *key, unsigned char *iv, int enc) ;
MSNetExtern int			OPENSSL_EVP_CipherUpdate(void *ctx, unsigned char *out, int *outl, unsigned char *in, int inl) ;
MSNetExtern int			OPENSSL_EVP_CipherFinal_ex(void *ctx, unsigned char *outm, int *outl) ;
MSNetExtern int			OPENSSL_EVP_CIPHER_CTX_cleanup(void *a) ;
MSNetExtern int			OPENSSL_EVP_CIPHER_key_length(const void *cipher) ;
MSNetExtern int			OPENSSL_EVP_CIPHER_iv_length(const void *cipher) ;
MSNetExtern const void *	OPENSSL_EVP_aes_256_cbc(void) ;
MSNetExtern const void *	OPENSSL_EVP_aes_192_cbc(void) ;
MSNetExtern const void *	OPENSSL_EVP_aes_128_cbc(void) ;
MSNetExtern const void *	OPENSSL_EVP_bf_cbc(void) ;
MSNetExtern const void *	OPENSSL_EVP_bf_cfb64(void) ;
MSNetExtern const void *	OPENSSL_EVP_bf_ofb(void) ;
MSNetExtern void *			OPENSSL_EVP_CIPHER_CTX_new(void) ;
MSNetExtern void			OPENSSL_EVP_CIPHER_CTX_free(void *a) ;
MSNetExtern const void *	OPENSSL_EVP_md5(void) ;
MSNetExtern const void *	OPENSSL_EVP_sha1(void) ;
MSNetExtern const void *	OPENSSL_EVP_sha256(void) ;
MSNetExtern const void *	OPENSSL_EVP_sha512(void) ;
MSNetExtern const void *	OPENSSL_EVP_dss1(void) ;
MSNetExtern const void *	OPENSSL_EVP_mdc2(void) ;
MSNetExtern const void *	OPENSSL_EVP_ripemd160(void) ;
MSNetExtern void			OPENSSL_EVP_MD_CTX_init(void *ctx) ;
MSNetExtern int			OPENSSL_EVP_DigestInit_ex(void *ctx, const void *type, void *impl) ;
MSNetExtern int			OPENSSL_EVP_DigestUpdate(void *ctx, const void *d, size_t cnt) ;
MSNetExtern int			OPENSSL_EVP_DigestFinal_ex(void *ctx, void *md, void *s) ;
MSNetExtern int			OPENSSL_EVP_MD_CTX_cleanup(void *ctx) ;
MSNetExtern int            OPENSSL_EVP_CipherInit(void *ctx,const void *cipher,
                                    const unsigned char *key,const unsigned char *iv,
                                    int enc);
MSNetExtern int            OPENSSL_EVP_CIPHER_CTX_set_padding(void *c, int pad);
MSNetExtern int            OPENSSL_EVP_CipherFinal(void *ctx, unsigned char *outm, int *outl);
MSNetExtern int            OPENSSL_EVP_CIPHER_block_size(const void *cipher);
MSNetExtern int            OPENSSL_EVP_MD_size(const void *md);
MSNetExtern void           OPENSSL_EVP_cleanup(void);
MSNetExtern const void *   OPENSSL_EVP_get_cipherbyname(const char *name);
MSNetExtern int            OPENSSL_EVP_CIPHER_nid(const void *cipher);

//PEM section
MSNetExtern void *			OPENSSL_PEM_read_bio_RSA_PUBKEY(void *bp, void **x, void *cb, void *u) ;
MSNetExtern void *			OPENSSL_PEM_read_bio_RSAPrivateKey(void *bp, void **x, void *cb, void *u) ;
MSNetExtern int			OPENSSL_PEM_write_bio_RSAPrivateKey(void *bp, void *x, const void *enc, unsigned char *kstr, int klen, void *cb, void *u) ;
MSNetExtern int			OPENSSL_PEM_write_bio_RSA_PUBKEY(void *bp, void *x) ;
MSNetExtern void *         OPENSSL_PEM_read_bio_X509(void *bp, void **x, void *cb, void *u) ;

//RAND section
MSNetExtern int			OPENSSL_RAND_bytes(unsigned char *buf, int num) ;
MSNetExtern void           OPENSSL_RAND_add(const void *buf,int num,double entropy);

//RSA Section
MSNetExtern void *			OPENSSL_RSA_generate_key(int num, unsigned long e, void (*callback)(int,int,void *), void *cb_arg) ;
MSNetExtern int			OPENSSL_RSA_size(const void *x) ;
MSNetExtern int			OPENSSL_RSA_public_encrypt(int flen, unsigned char *from, unsigned char *to, void *rsa, int padding) ;
MSNetExtern int			OPENSSL_RSA_private_decrypt(int flen, unsigned char *from, unsigned char *to, void *rsa, int padding) ;
MSNetExtern int          OPENSSL_RSA_sign(int type, const unsigned char *m, unsigned int m_len, unsigned char *sigret, unsigned int *siglen, void *rsa);
MSNetExtern int          OPENSSL_RSA_verify(int type, const unsigned char *m, unsigned int m_len, unsigned char *sigbuf, unsigned int siglen, void *rsa);
MSNetExtern void			OPENSSL_RSA_free(void *rsa) ;

//SSL sections
#define OPENSSL_SSL_OP_NO_SSLv2     0x01000000L
#define OPENSSL_SSL_OP_NO_SSLv3     0x02000000L
#define OPENSSL_SSL_OP_NO_TLSv1     0x04000000L
#define OPENSSL_SSL_OP_NO_TLSv1_2   0x08000000L
#define OPENSSL_SSL_OP_NO_TLSv1_1   0x10000000L

MSNetExtern void           OPENSSL__add_all_algorithms(void) ;
MSNetExtern int            OPENSSL_SSL_library_init(void) ;
MSNetExtern const void *   OPENSSL_SSLv23_method(void) ;
MSNetExtern const void *   OPENSSL_SSLv2_method(void) ;
MSNetExtern const void *   OPENSSL_SSLv3_method(void) ;
MSNetExtern const void *   OPENSSL_TLSv1_method(void) ;
MSNetExtern const void *   OPENSSL_TLSv1_1_method(void) ;
MSNetExtern void           OPENSSL_SSL_load_error_strings(void) ;
MSNetExtern void *         OPENSSL_SSL_new (void *ctx) ;
MSNetExtern void *         OPENSSL_SSL_CTX_new(const void *meth) ;
MSNetExtern void           OPENSSL_SSL_CTX_free(void *ctx) ;
MSNetExtern int            OPENSSL_SSL_CTX_use_certificate_file(void *ctx, const char *file, int type) ;
MSNetExtern int            OPENSSL_SSL_CTX_use_PrivateKey_file(void *ctx, const char *file, int type) ;
MSNetExtern int            OPENSSL_SSL_CTX_check_private_key(const void *ctx) ;
MSNetExtern long           OPENSSL_SSL_CTX_set_mode(void *ctx, long mode) ;
MSNetExtern long           OPENSSL_SSL_CTX_set_options(void *ctx, long options);
MSNetExtern void           OPENSSL_SSL_CTX_set_verify(void *ctx,int mode, int (*callback)(int, void *)) ;
MSNetExtern int            OPENSSL_SSL_CTX_set_session_id_context(void *ctx,const unsigned char *sid_ctx, unsigned int sid_ctx_len) ;
MSNetExtern int            OPENSSL_SSL_CTX_load_verify_locations(void *ctx, const char *CAfile, const char *CApath) ;
MSNetExtern void           OPENSSL_SSL_CTX_set_verify_depth(void *ctx,int depth);
MSNetExtern int            OPENSSL_SSL_accept(void *ssl) ;
MSNetExtern int            OPENSSL_SSL_read(void *ssl,void *buf,int num) ;
MSNetExtern int            OPENSSL_SSL_write(void *ssl,const void *buf,int num) ;
MSNetExtern int            OPENSSL_SSL_get_fd(const void *s) ;
MSNetExtern int            OPENSSL_SSL_set_fd(void *s, int fd) ;
MSNetExtern void           OPENSSL_SSL_free(void *ssl) ;
MSNetExtern void *         OPENSSL_SSL_get_SSL_CTX(const void *ssl) ;
MSNetExtern int            OPENSSL_SSL_connect(void *ssl) ;
MSNetExtern int            OPENSSL_SSL_get_error(const void *ssl, int ret) ;
MSNetExtern int            OPENSSL_SSL_shutdown(void *ssl) ;
MSNetExtern int            OPENSSL_SSL_get_shutdown(void *ssl) ;
MSNetExtern void *         OPENSSL_SSL_get_peer_certificate(const void *s) ;
MSNetExtern void           OPENSSL_SSL_set_verify(void *s, int mode, int (*callback)(int, void *)) ;
MSNetExtern void           OPENSSL_SSL_set_verify_depth(void *s, int depth) ;
MSNetExtern int            OPENSSL_SSL_renegotiate(void *s) ;
MSNetExtern int            OPENSSL_SSL_do_handshake(void *s) ;

//Crypto
MSNetExtern void *         OPENSSL_CRYPTO_malloc(int num, const char *file, int line) ;
MSNetExtern void           OPENSSL_CRYPTO_free(void *);
MSNetExtern int            OPENSSL_CRYPTO_num_locks(void) ;
MSNetExtern void           OPENSSL_CRYPTO_THREADID_set_numeric(void *id, unsigned long val) ;
MSNetExtern int            OPENSSL_CRYPTO_THREADID_set_callback(void (*threadid_func)(void *)) ;
MSNetExtern void           OPENSSL_CRYPTO_set_locking_callback(void (*func)(int mode,int type, const char *file,int line)) ;
MSNetExtern int            OPENSSL_CRYPTO_set_mem_functions(void *(*m)(size_t),void *(*r)(void *,size_t), void (*f)(void *)) ;

//X509
MSNetExtern void           OPENSSL_X509_free(void *a) ;
MSNetExtern int            OPENSSL_X509_NAME_entry_count(void *name) ;
MSNetExtern void *         OPENSSL_X509_NAME_get_entry(void *name, int loc) ;
MSNetExtern void *         OPENSSL_X509_NAME_ENTRY_get_object(void *ne) ;
MSNetExtern void *         OPENSSL_X509_NAME_ENTRY_get_data(void *ne) ;
MSNetExtern void *         OPENSSL_X509_get_serialNumber(void *x) ;
MSNetExtern long           OPENSSL_ASN1_INTEGER_get(const void *a) ;
MSNetExtern void *         OPENSSL_X509_get_issuer_name(void *a);
MSNetExtern void *         OPENSSL_X509_get_subject_name(void *a);
MSNetExtern int            OPENSSL_X509_digest(const void *data,const void *type,unsigned char *md, unsigned int *len);
MSNetExtern int            OPENSSL_ASN1_STRING_to_UTF8(unsigned char **out, void *in) ;
MSNetExtern void *         OPENSSL_d2i_X509_bio(void *bp,void **x509) ;
MSNetExtern int            OPENSSL_OBJ_obj2txt(char *buf, int buf_len, const void *a, int no_name) ;
MSNetExtern int            OPENSSL_i2c_ASN1_INTEGER(void *a,unsigned char **pp) ;
MSNetExtern const char *   OPENSSL_OBJ_nid2sn(int n);
MSNetExtern void *         OPENSSL_ASN1_TIME_to_generalizedtime(void *t, void **out) ;
MSNetExtern void  *        OPENSSL_ASN1_INTEGER_to_BN(const void *ai, void *bn) ;
MSNetExtern void *         OPENSSL_X509_get_notBefore(void *a) ;
MSNetExtern void *         OPENSSL_X509_get_notAfter(void *a) ;
MSNetExtern char *         OPENSSL_BN_bn2hex(const void *a) ;

//HMAC
MSNetExtern int            OPENSSL_HMAC_Init_ex(void *ctx, const void *key, int len, const void *md, void *impl);
MSNetExtern void           OPENSSL_HMAC_CTX_init(void *ctx);
MSNetExtern int            OPENSSL_HMAC_Update(void *ctx, const unsigned char *data, size_t len);
MSNetExtern int            OPENSSL_HMAC_Final(void *ctx, unsigned char *md, unsigned int *len);
MSNetExtern void           OPENSSL_HMAC_CTX_cleanup(void *ctx);

//PKCS5
MSNetExtern int            OPENSSL_PKCS5_PBKDF2_HMAC_SHA1(const char *pass, int passlen, const unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out);

#ifdef WO451
MSNetExtern void ** _OPENSSL_Applink(void) ;
#endif
