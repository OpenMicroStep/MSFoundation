/*
 
 MSCurlHandler.m
 
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
//#import "MSBuffer.h"
//#import "MSStringAdditions.h"

typedef struct ReadBufferStruct {
    const void *buff ;
    NSUInteger length ;
} ReadBuffer ;

struct upload_context {
    int lines_read;
    MSCurlSendMail *aMSCurlSendMail ;
};


NSArray *payload_text_plain_text(MSCurlSendMail *aMSCurlSendMail);
NSArray *payload_text_html_format(MSCurlSendMail *aMSCurlSendMail);

NSArray *payload_text_plain_text(MSCurlSendMail *aMSCurlSendMail) {
    NSMutableArray *array = [NSMutableArray array] ;
    NSUInteger i;
    NSMutableString *recipient = [NSMutableString string];
    for (i=0; i<[[aMSCurlSendMail to] count];i++){
        NSString *mail = [[aMSCurlSendMail to] objectAtIndex:i];
        [recipient stringByAppendingString:mail];
    }
    [array addObject:[NSString stringWithFormat:@"To: %@\r\n", recipient]] ;
    [array addObject:[NSString stringWithFormat:@"From: %@\r\n", [aMSCurlSendMail from]]] ;
    [array addObject:[NSString stringWithFormat:@"Subject: %@\r\n", [aMSCurlSendMail subject]]] ;
    [array addObject:@"Content-Type: text; charset=\"iso-8859-1\";\r\n"] ;
    [array addObject:@"\r\n"] ;
    [array addObject:[aMSCurlSendMail body]] ;
    return array ;
}

NSArray *payload_text_html_format(MSCurlSendMail *aMSCurlSendMail) {
    NSMutableArray *array = [NSMutableArray array] ;
    NSUInteger i;
    NSMutableString *recipient = [NSMutableString string];
    for (i=0; i<[[aMSCurlSendMail to] count];i++){        
        NSString *mail = [[aMSCurlSendMail to] objectAtIndex:i];
        [recipient stringByAppendingString:mail];        
    }
    [array addObject:[NSString stringWithFormat:@"To: %@\r\n", recipient]] ;       
    [array addObject:[NSString stringWithFormat:@"From: %@\r\n", [aMSCurlSendMail from]]] ;
    [array addObject:[NSString stringWithFormat:@"Subject: %@\r\n", [aMSCurlSendMail subject]]] ;
    [array addObject:@"Mime-Version: 1.0;\r\n"] ;
    [array addObject:@"Content-Type: text/html; charset=\"utf-8\";\r\n"] ;
    [array addObject:@"Content-Transfer-Encoding: 7bit;\r\n"] ;
    [array addObject:@"\r\n"] ;
    [array addObject:@"<html><body>\n"] ;
    [array addObject:[[[aMSCurlSendMail body] htmlRepresentation] replaceOccurrencesOfString:@"\n" withString:@"<br/>"]] ;
    [array addObject:@"</body></html>\n"] ;
    return array ;
}

static size_t payload_source(void *ptr, size_t size, size_t nmemb, void *userp)
{
    struct upload_context *upload_ctx = (struct upload_context *)userp;
    NSData *data = nil;
    NSArray *messageLines = nil ;
    MSCurlSendMail *aMSCurlSendMail = nil ;
    
    if((size == 0) || (nmemb == 0) || ((size*nmemb) < 1)) {
        return 0;
    }
    
    aMSCurlSendMail = upload_ctx->aMSCurlSendMail ;
    if ([aMSCurlSendMail htmlFormat]) {
        messageLines = payload_text_html_format(aMSCurlSendMail);
    }
    else {
        messageLines = payload_text_plain_text(aMSCurlSendMail);
    }
    
    if ((NSUInteger)upload_ctx->lines_read<[messageLines count]) {
        data = [[messageLines objectAtIndex:(NSUInteger)upload_ctx->lines_read] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] ;
    }
    
    if([data length]) {
        size_t len = [data length];
        memcpy(ptr, [data bytes], len);
        upload_ctx->lines_read++;
        
        return len;
    }
    return 0;
}


@implementation MSCurlSendMail

- (void)setUserName:(NSString*)userName andPassword:(NSString*)password
{
    ASSIGN(_userName, userName);
    ASSIGN(_password, password);  
}
- (void)setCaInfo:(NSString*)caInfo { ASSIGN(_caInfo, caInfo) ; }
- (void)setFrom:(NSString *)from { ASSIGN(_from, from) ; }
- (void)setTo:(NSArray *)to { ASSIGN(_to, to) ; }
- (void)setCc:(NSString *)cc { ASSIGN(_cc, cc) ; }
- (void)setSubject:(NSString *)subject { ASSIGN(_subject, subject) ; }
- (void)setBody:(NSString *)body { ASSIGN(_body, body) ; }
- (void)setHtmlFormat:(BOOL)aBool { _htmlFormat = aBool ; }
- (NSString *)from {return _from ; }
- (NSArray *)to {return _to ; }
- (NSString *)subject {return _subject ; }
- (NSString *)body {return _body ; }
- (BOOL)htmlFormat { return _htmlFormat ; }

- (BOOL)sendMail{
    
    NSString *url = [NSString stringWithFormat:@"%@://%@%@", ([self useSSL] ? @"smtps" : @"smtp"), [self server], ( [self port] ? [NSString stringWithFormat:@":%u", [self port]] : @"")];
    CURLcode res = CURLE_OK;
    NSUInteger i;
    struct curl_slist *recipients = NULL;
    struct upload_context upload_ctx;
    
    upload_ctx.lines_read = 0;
    upload_ctx.aMSCurlSendMail = self ;
    
    if([self curl]) {
        MS_curl_easy_setopt_pntr([self curl], CURLOPT_USERNAME, (void *)[_userName cStringUsingEncoding:NSASCIIStringEncoding]);
        MS_curl_easy_setopt_pntr([self curl], CURLOPT_PASSWORD, (void *)[_password cStringUsingEncoding:NSASCIIStringEncoding]);
        MS_curl_easy_setopt_pntr([self curl], CURLOPT_URL, (void *)[url cStringUsingEncoding:NSASCIIStringEncoding]);
        if([self useSSL]) {
#ifdef WIN32
            //WARNING: only works after v7.34 of libCurl under Win32
            MS_curl_easy_setopt_long([self curl], CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1_0) ;
            if (_caInfo) {
                MS_curl_easy_setopt_pntr([self curl], CURLOPT_CAINFO, (void *)[_caInfo cStringUsingEncoding:NSWindowsCP1252StringEncoding]);
            }
            else {
                MSRaise(NSGenericException, @"CURLOPT_CAINFO (string naming a file holding one or more certificates to verify the peer with) is missing!");
            }
#else
//            MS_curl_easy_setopt_long([self curl], CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1) ;
#endif
            MS_curl_easy_setopt_long([self curl], CURLOPT_USE_SSL, CURLUSESSL_TRY) ;
        }
        MS_curl_easy_setopt_pntr([self curl], CURLOPT_MAIL_FROM, (void *)[_from cStringUsingEncoding:NSASCIIStringEncoding]);
        for (i=0; i<[_to count];i++){
            recipients = MS_curl_slist_append(recipients,  [[_to objectAtIndex:i] cStringUsingEncoding:NSASCIIStringEncoding]);
        }
        MS_curl_easy_setopt_pntr([self curl], CURLOPT_MAIL_RCPT, recipients);
        MS_curl_easy_setopt_pntr([self curl], CURLOPT_READFUNCTION, payload_source);
        MS_curl_easy_setopt_pntr([self curl], CURLOPT_READDATA, &upload_ctx);
        MS_curl_easy_setopt_long([self curl], CURLOPT_UPLOAD, 1L);
        //MS_curl_easy_setopt_long([self curl], CURLOPT_VERBOSE, 1L);

        res = MS_curl_easy_perform([self curl]);
        
        if(res != CURLE_OK)
            fprintf(stderr, "curl_easy_perform() failed: %s\n",
                    MS_curl_easy_strerror(res));
        
        MS_curl_slist_free_all(recipients);
    }
    //system("pause");
    return (res == CURLE_OK);
    
}

- (void)dealloc
{
    RELEASE(_from) ;
    RELEASE(_to) ;
    RELEASE(_cc) ;
    RELEASE(_userName);
    RELEASE(_password);
    RELEASE(_caInfo);
    RELEASE(_subject);
    RELEASE(_body);

    [super dealloc];
}


@end
