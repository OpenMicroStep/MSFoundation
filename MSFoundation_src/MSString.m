/*   MSString.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 
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
#import "MSStringBooleanAdditions_Private.i"

static char *__htmlTags[256] = {
    /* 00*/	"\001\000", "\001\001", "\001\002", "\001\003", "\001\004", "\001\005", "\001\006", "\001\007",
    /* 08*/	"\001\010", "\001\011", "\001\012", "\001\013", "\001\014", "\001\015", "\001\016", "\001\017",
    /* 10*/	"\001\020", "\001\021", "\001\022", "\001\023", "\001\024", "\001\025", "\001\026", "\001\027",
    /* 18*/	"\001\030", "\001\031", "\001\032", "\001\033", "\001\034", "\001\035", "\001\036", "\001\037",
    /* 20*/	"\001\040", "\001!", "\001\"", "\001#", "\001$", "\001%", "\001&", "\001\047",
    /* 28*/	"\001(", "\001)", "\001*", "\001+", "\001,", "\001-", "\001.", "\001/",
    /* 30*/	"\0010", "\0011", "\0012", "\0013", "\0014", "\0015", "\0016", "\0017",
    /* 38*/	"\0018", "\0019", "\001:", "\001;", "\001<", "\001=", "\001>", "\001?",
    /* 40*/	"\001@", "\001A", "\001B", "\001C", "\001D", "\001E", "\001F", "\001G",
    /* 48*/	"\001H", "\001I", "\001J", "\001K", "\001L", "\001M", "\001N", "\001O",
    /* 50*/	"\001P", "\001Q", "\001R", "\001S", "\001T", "\001U", "\001V", "\001W",
    /* 58*/	"\001X", "\001Y", "\001Z", "\001[", "\001\\", "\001]", "\001^", "\001_",
    /* 60*/	"\001`", "\001a", "\001b", "\001c", "\001d", "\001e", "\001f", "\001g",
    /* 68*/	"\001h", "\001i", "\001j", "\001k", "\001l", "\001m", "\001n", "\001o",
    /* 70*/	"\001p", "\001q", "\001r", "\001s", "\001t", "\001u", "\001v", "\001w",
    /* 78*/	"\001x", "\001y", "\001z", "\001{", "\001|", "\001}", "\001~", "\000",
    /* 80*/	"\000", "\000", "\000", "\000", "\000", "\000", "\000", "\000",
    /* 88*/	"\000", "\000", "\000", "\000", "\000", "\000", "\000", "\000",
    /* 90*/	"\000", "\000", "\000", "\000", "\000", "\000", "\000", "\000",
    /* 98*/	"\000", "\000", "\000", "\000", "\000", "\000", "\000", "\000",
    /* A0*/	"\006&nbsp;", "\007&iexcl;", "\006&cent;", "\007&pound;", "\010&curren;", "\005&yen;", "\010&brvbar;", "\006&sect;",
    /* A8*/	"\005&uml;", "\006&copy;", "\006&ordf;", "\007&laquo;", "\005&not;", "\005&shy;", "\005&reg;", "\006&macr;",
    /* B0 */	"\005&deg;", "\010&plusmn;", "\006&sup2;", "\006&sup3;", "\007&acute;", "\007&micro;", "\006&para;", "\010&middot;",
    /* B8 */	"\007&cedil;", "\006&sup1;", "\006&ordm;", "\007&raquo;", "\010&frac14;", "\010&frac12;", "\010&frac34;", "\010&iquest;",
    /* C0 */	"\010&Agrave;", "\010&Aacute;", "\007&Acirc;", "\010&Atilde;", "\006&Auml;", "\007&Aring;", "\007&AElig;", "\010&Ccedil;",
    /* C8 */ 	"\010&Egrave;", "\010&Eacute;", "\007&Ecirc;", "\006&Euml;", "\010&Igrave;", "\010&Iacute;", "\007&Icirc;", "\006&Iuml;",
    /* D0 */ 	"\005&ETH;", "\010&Ntilde;", "\010&Ograve;", "\010&Oacute;", "\007&Ocirc;", "\010&Otilde;", "\006&Ouml;", "\007&times;",
    /* D8 */ 	"\010&Oslash;", "\010&Ugrave;", "\010&Uacute;", "\007&Ucirc;", "\006&Uuml;", "\010&Yacute;", "\007&THORN;", "\007&szlig;",
    /* E0 */	"\010&agrave;", "\010&aacute;", "\007&acirc;", "\010&atilde;", "\006&auml;", "\007&aring;", "\007&aelig;", "\010&ccedil;",
    /* E8 */ 	"\010&egrave;", "\010&eacute;", "\007&ecirc;", "\006&euml;", "\010&igrave;", "\010&iacute;", "\007&icirc;", "\006&iuml;",
    /* F0 */ 	"\005&eth;", "\010&ntilde;", "\010&ograve;", "\010&oacute;", "\007&ocirc;", "\010&otilde;", "\006&ouml;", "\010&divide;",
    /* F8 */ 	"\010&oslash;", "\010&ugrave;", "\010&uacute;", "\007&ucirc;", "\006&uuml;", "\010&yacute;", "\007&thorn;", "\006&yuml;"
} ;

static char *__fullHtmlTags[256] = {
    /* 00*/	"\001\000", "\001\001", "\001\002", "\001\003", "\001\004", "\001\005", "\001\006", "\001\007",
    /* 08*/	"\001\010", "\001\011", "\001\012", "\001\013", "\001\014", "\001\015", "\001\016", "\001\017",
    /* 10*/	"\001\020", "\001\021", "\001\022", "\001\023", "\001\024", "\001\025", "\001\026", "\001\027",
    /* 18*/	"\001\030", "\001\031", "\001\032", "\001\033", "\001\034", "\001\035", "\001\036", "\001\037",
    /* 20*/	"\001\040", "\001!", "\006&quot;", "\001#", "\001$", "\001%", "\005&amp;", "\001\047",
    /* 28*/	"\001(", "\001)", "\001*", "\001+", "\001,", "\001-", "\001.", "\001/",
    /* 30*/	"\0010", "\0011", "\0012", "\0013", "\0014", "\0015", "\0016", "\0017",
    /* 38*/	"\0018", "\0019", "\001:", "\001;", "\004&lt;", "\001=", "\004&gt;", "\001?",
    /* 40*/	"\001@", "\001A", "\001B", "\001C", "\001D", "\001E", "\001F", "\001G",
    /* 48*/	"\001H", "\001I", "\001J", "\001K", "\001L", "\001M", "\001N", "\001O",
    /* 50*/	"\001P", "\001Q", "\001R", "\001S", "\001T", "\001U", "\001V", "\001W",
    /* 58*/	"\001X", "\001Y", "\001Z", "\001[", "\001\\", "\001]", "\001^", "\001_",
    /* 60*/	"\001`", "\001a", "\001b", "\001c", "\001d", "\001e", "\001f", "\001g",
    /* 68*/	"\001h", "\001i", "\001j", "\001k", "\001l", "\001m", "\001n", "\001o",
    /* 70*/	"\001p", "\001q", "\001r", "\001s", "\001t", "\001u", "\001v", "\001w",
    /* 78*/	"\001x", "\001y", "\001z", "\001{", "\001|", "\001}", "\001~", "\000",
    /* 80*/	"\000", "\000", "\000", "\000", "\000", "\000", "\000", "\000",
    /* 88*/	"\000", "\000", "\000", "\000", "\000", "\000", "\000", "\000",
    /* 90*/	"\000", "\000", "\000", "\000", "\000", "\000", "\000", "\000",
    /* 98*/	"\000", "\000", "\000", "\000", "\000", "\000", "\000", "\000",
    /* A0*/	"\006&nbsp;", "\007&iexcl;", "\006&cent;", "\007&pound;", "\010&curren;", "\005&yen;", "\010&brvbar;", "\006&sect;",
    /* A8*/	"\005&uml;", "\006&copy;", "\006&ordf;", "\007&laquo;", "\005&not;", "\005&shy;", "\005&reg;", "\006&macr;",
    /* B0 */	"\005&deg;", "\010&plusmn;", "\006&sup2;", "\006&sup3;", "\007&acute;", "\007&micro;", "\006&para;", "\010&middot;",
    /* B8 */	"\007&cedil;", "\006&sup1;", "\006&ordm;", "\007&raquo;", "\010&frac14;", "\010&frac12;", "\010&frac34;", "\010&iquest;",
    /* C0 */	"\010&Agrave;", "\010&Aacute;", "\007&Acirc;", "\010&Atilde;", "\006&Auml;", "\007&Aring;", "\007&AElig;", "\010&Ccedil;",
    /* C8 */ 	"\010&Egrave;", "\010&Eacute;", "\007&Ecirc;", "\006&Euml;", "\010&Igrave;", "\010&Iacute;", "\007&Icirc;", "\006&Iuml;",
    /* D0 */ 	"\005&ETH;", "\010&Ntilde;", "\010&Ograve;", "\010&Oacute;", "\007&Ocirc;", "\010&Otilde;", "\006&Ouml;", "\007&times;",
    /* D8 */ 	"\010&Oslash;", "\010&Ugrave;", "\010&Uacute;", "\007&Ucirc;", "\006&Uuml;", "\010&Yacute;", "\007&THORN;", "\007&szlig;",
    /* E0 */	"\010&agrave;", "\010&aacute;", "\007&acirc;", "\010&atilde;", "\006&auml;", "\007&aring;", "\007&aelig;", "\010&ccedil;",
    /* E8 */ 	"\010&egrave;", "\010&eacute;", "\007&ecirc;", "\006&euml;", "\010&igrave;", "\010&iacute;", "\007&icirc;", "\006&iuml;",
    /* F0 */ 	"\005&eth;", "\010&ntilde;", "\010&ograve;", "\010&oacute;", "\007&ocirc;", "\010&otilde;", "\006&ouml;", "\010&divide;",
    /* F8 */ 	"\010&oslash;", "\010&ugrave;", "\010&uacute;", "\007&ucirc;", "\006&uuml;", "\010&yacute;", "\007&thorn;", "\006&yuml;"
} ;

static char *__greekHtmlTags[70] = {
    "\007&Alpha;", /*913 */
    "\006&Beta;",
    "\007&Gamma;",
    "\007&Delta;",
    "\011&Epsilon;",
    "\006&Zeta;",
    "\005&Eta;",
    "\007&Theta;",
    "\006&Iota;",
    "\007&Kappa;",
    "\010&Lambda;",
    "\004&Mu;",
    "\004&Nu;",
    "\004&Xi;",
    "\011&Omicron;",
    "\004&Pi;",
    "\005&Rho;",
    "\006&#930;",
    "\007&Sigma;",
    "\005&Tau;",
    "\011&Upsilon;",
    "\005&Phi;",
    "\005&Chi;",
    "\005&Psi;",
    "\007&Omega;",
    "\006&#938;",
    "\006&#939;",
    "\006&#940;",
    "\006&#941;",
    "\006&#942;",
    "\006&#943;",
    "\006&#944;",
    "\007&alpha;", /*945 */
    "\006&beta;",
    "\007&gamma;",
    "\007&delta;",
    "\011&epsilon;",
    "\006&zeta;",
    "\005&eta;",
    "\007&theta;",
    "\006&iota;",
    "\007&kappa;",
    "\010&lambda;",
    "\004&mu;",
    "\004&nu;",
    "\004&xi;",
    "\011&omicron;",
    "\004&pi;",
    "\005&rho;",
    "\010&sigmaf;",
    "\007&sigma;",
    "\005&tau;",
    "\011&upsilon;",
    "\005&phi;",
    "\005&chi;",
    "\005&psi;",
    "\007&omega;",
    "\006&#970;",
    "\006&#971;",
    "\006&#972;",
    "\006&#973;",
    "\006&#974;",
    "\006&#975;",
    "\006&#976;",
    "\012&thetasym;",
    "\007&upsih;",
    "\006&#979;",
    "\006&#980;",
    "\006&#981;",
    "\005&piv;"
} ;

static char *__symbolHtmlTags[61] = {
    "\007&#8200;",
    "\010&thinsp;",
    "\007&#8202;",
    "\007&#8203;",
    "\006&zwnj;",
    "\005&zwj;",
    "\005&lrm;",
    "\005&rlm;",
    "\007&#8208;",
    "\007&#8209;",
    "\007&#8210;",
    "\007&ndash;",
    "\007&mdash;",
    "\007&#8213;",
    "\007&#8214;",
    "\007&#8215;",
    "\007&lsquo;",
    "\007&rsquo;",
    "\007&sbquo;",
    "\007&#8219;",
    "\007&ldquo;",
    "\007&rdquo;",
    "\007&bdquo;",
    "\007&#8223;",
    "\010&dagger;",
    "\010&Dagger;",
    "\006&bull;",
    "\007&#8227;",
    "\007&#8228;",
    "\007&#8229;",
    "\010&hellip;",
    "\007&#8231;",
    "\007&#8232;",
    "\007&#8233;",
    "\007&#8234;",
    "\007&#8235;",
    "\007&#8236;",
    "\007&#8237;",
    "\007&#8238;",
    "\007&#8239;",
    "\010&permil;",
    "\007&#8241;",
    "\007&prime;",
    "\007&#8243;",
    "\007&#8244;",
    "\007&#8245;",
    "\007&#8246;",
    "\007&#8247;",
    "\007&#8248;",
    "\010&lsaquo;",
    "\010&rsaquo;",
    "\007&#8251;",
    "\007&#8252;",
    "\007&#8253;",
    "\007&oline;",
    "\007&#8255;",
    "\007&#8256;",
    "\007&#8257;",
    "\007&#8258;",
    "\007&#8259;",
    "\007&frasl;"
} ;

//static char *__romanCentaines[10] = { "", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM" } ;
//static char *__romanDizaines[10] = { "", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC" } ;
//static char *__romanUnites[10] = { "", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX" } ;

BOOL MSStringIsTrue(NSString *s)
{ 
	SES ses = SESFromString(s) ;
	if (SESOK(ses)) {
		return _MSStringIsTrue(ses, CUnicharIsSpace, NULL) ;
	}
	return NO ;
}

static inline BOOL _MSEqualsStrings(NSString *s1, NSString *s2, BOOL insensitive)
{
  if (s1 != s2) {
    if (s1 && s2) {
      SES ses1= [s1 stringEnumeratorStructure] ;
      SES ses2= [s2 stringEnumeratorStructure] ;
      return insensitive ? SESEquals(ses1, ses2) : SESInsensitiveEquals(ses1, ses2) ;}
    return NO ;}
  return YES ; 
}
BOOL MSEqualStrings(NSString *s1, NSString *s2)
{ return _MSEqualsStrings(s1, s2, NO); }
BOOL MSInsensitiveEqualStrings(NSString *s1, NSString *s2)
{ return _MSEqualsStrings(s1, s2, YES); }

@implementation NSString (MSAddendum)
static inline NSString *_createStringWithContentsOfUTF8File(NSString *file)
{
  MSString *ret= nil; CBuffer* buf; NSUInteger len; const MSByte *bytes;
  buf= CCreateBuffer(0);
  if (CBufferAppendContentsOfFile(buf, SESFromString(file))) {
    len= CBufferLength(buf);
    bytes= CBufferBytes(buf);

    if (len >= 3 && bytes[0] == 0xef && bytes[1] == 0xbb && bytes[2] == 0xbf) {
      len-= 3;
      bytes+= 3;}
    if (len) {
      ret= (MSString*)CCreateString(len);
      if (!CStringAppendSupposedEncodingBytes((CString *)ret, bytes, len, NSUTF8StringEncoding, NULL)) {
        RELEAZEN(ret);}}
  }
  RELEASE(buf);
	return ret;
}
+ (NSString *)stringWithContentsOfUTF8File:(NSString *)file { return AUTORELEASE(_createStringWithContentsOfUTF8File(file)) ; }

#ifdef WO451
- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)allowLossyConversion
{
  MSBuffer *buf= nil;
  if (allowLossyConversion || [self canBeConvertedToEncoding:encoding]) {
    NSData *data= [self dataUsingEncoding:encoding allowLossyConversion:YES];
    buf= [MSBuffer bufferWithBytes:[data bytes] length:[data length]];}
  return (const char *)[buf cString];
}
- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding
{
  CBuffer *b= CCreateBuffer(0);
  CBufferAppendSES(b, SESFromString(self), encoding);
  AUTORELEASE((MSBuffer*)b);
  return (const char *)CBufferCString(b);
}
#endif

static unichar _slowChaiN(const void *self, NSUInteger *pos)
{
  return [(NSString*)self characterAtIndex:(*pos)++];
}
static unichar _slowChaiP(const void *self, NSUInteger *pos)
{
  return [(NSString*)self characterAtIndex:--(*pos)];
}
- (SES)stringEnumeratorStructure
{
  return MSMakeSES((const void*)self, _slowChaiN, _slowChaiP, 0,[self length], 0);
}

- (NSMutableString *)replaceOccurrencesOfString:(NSString *)tag withString:(NSString *)replace
{
    NSArray *subStrings = [self componentsSeparatedByString:tag] ;
    return [[[subStrings componentsJoinedByString:replace] mutableCopy] autorelease] ;
}

NSRange MSStringFind(NSString *source, NSString *searched)
{
	NSRange ret = {NSNotFound,0} ;
	if (source && searched) {
		SES ses = SESFromString(source) ;
		if (SESOK(ses)) {
			ses = SESFind(ses, SESFromString(searched)) ;
			if (SESOK(ses)) { ret = (NSRange){ses.start, ses.length} ; }
		}
	}
	return ret ;
}

- (BOOL)isTrue
{
	return MSStringIsTrue(self);
}
- (NSString *)mid:(NSUInteger)position
{
	NSUInteger selfLen = (NSUInteger)[self length] ;
	if (position < selfLen) {
		return [self substringWithRange: NSMakeRange(position, selfLen - position)] ;		
	}
	return @"" ;
}
- (NSString *)mid:(NSUInteger)position :(NSUInteger)length
{
	if (length) {
		NSUInteger selfLen = (NSUInteger)[self length] ;
		if (position < selfLen) {
			return [self substringWithRange: NSMakeRange(position , (length == NSUIntegerMax || position+length > selfLen ? selfLen - position : length))] ;
		}
	}
	return @"" ;
}
- (NSString *)left:(NSUInteger)length
{
	if (length) {
		NSUInteger selfLen = [self length] ;
		if (length > selfLen) length = selfLen ;
		if (length) return [self substringWithRange: NSMakeRange(0 , length)] ;
	}
	return @"" ;
}
- (NSString *)right:(NSUInteger)length
{
	if (length) {
    NSUInteger selfLen = [self length] ;
		if (length > selfLen) length = selfLen ;
		if (length) return [self substringWithRange: NSMakeRange(selfLen - length , length)] ;
	}
	return @"" ;
}

- (NSString *)substringBeforeString:(NSString *)string
{
    NSUInteger p = MSStringFind(self, string).location ;
    return (p == NSNotFound ? (id)nil : (id)[self left:p]) ; 
}
- (NSString *)substringAfterString:(NSString *)string
{
    NSRange r = MSStringFind(self, string) ;
    return (r.location == NSNotFound ? (id)nil : [self mid: r.location+r.length]) ;
}

static inline NSString *_MSTrimAt(NSString *source, NSUInteger position, NSUInteger length, CUnicharChecker matchingChar)
{
	if (source && matchingChar) {
		if (length) {
			SES ses = SESFromString(source) ;
			if (SESOK(ses) && position < ses.length) {
				ses.start = position ;
				if (length == NSUIntegerMax || position + length > ses.length) ses.length -= position ;
				else ses.length = length ;
				ses = SESExtractPart(ses, matchingChar) ;
				if (SESOK(ses)) { return [source substringWithRange:NSMakeRange(ses.start, ses.length)] ; }
			}
		}
		return @"" ;
	}
	return nil ;
}
NSString *MSTrimAt(NSString *self, NSUInteger position, NSUInteger length, CUnicharChecker checker)
{
  return _MSTrimAt(self, position, length, (checker ? (CUnicharChecker)checker : CUnicharIsSolid)) ;
}

- (NSString *)trim { return _MSTrimAt(self,0, NSUIntegerMax, (CUnicharChecker)CUnicharIsSolid) ; }

- (BOOL)containsString:(NSString *)anotherString
{
    if (anotherString) {
        if ([anotherString length]) {
            NSRange r = [self rangeOfString:anotherString] ;
            return r.location == NSNotFound ? NO : YES ;
        }
        return YES ;
    }
    return NO ;
}

- (const char *)asciiCString { return _MSUnicodeToASCIICString(self) ; }

- (BOOL)hasExtension:(NSString *)ext
{
    return (ext ? MSEqualStrings([self pathExtension], ext) : ([[self pathExtension] length] ? NO : YES)) ;
}

- (NSString *)stringWithURLEncoding:(NSStringEncoding)conversionEncoding
{
    if ([self length]) {
        NSData *conversion = [self dataUsingEncoding:conversionEncoding allowLossyConversion:YES] ;
        NSUInteger len = [conversion length] ;
        char *s = (char *)[conversion bytes] ;
        if (len && s) {
            NSString *ret ;
            MSBuffer *buffer = MSURLFromBytes(s, len) ;
            len = [buffer length] ;
#ifdef WO451
            if (len) ret = [NSString stringWithCString:[buffer bytes] length:len] ;
#else
            CBufferAppendByte((CBuffer *)buffer, 0) ;
            if (len) ret = [NSString stringWithUTF8String:[buffer bytes]] ;
#endif
            else ret = [NSString string] ;
            return ret ;
        }
    }
    return self ;
}
- (NSString *)stringWithURLEncoding
{
    return [self stringWithURLEncoding:NSUTF8StringEncoding] ;
}

- (NSString *)stringByAppendingURLComponent:(NSString *)urlComponent
{
    if ([urlComponent length]) {
        if ([self characterAtIndex:([self length]-1)] == (unichar)'/') return [self stringByAppendingFormat:@"%@", urlComponent];
        else return [self stringByAppendingFormat:@"/%@", urlComponent];
    }
    else return self ;
}

- (NSString *)stringByDeletingLastURLComponent
{
    NSRange range = [self rangeOfString:@"/" options:NSBackwardsSearch range:NSMakeRange(0, ([self length]-1))] ;
    if(range.length && range.location)
    {
        return [self substringWithRange:NSMakeRange(0, range.location)] ;
    }
    else return self ;
}

- (NSString*)decodedURLString
{
	char *s = (char *)[self UTF8String] ; // on retourne à use form de buffer (!?!)
	if (s && *s) {
		NSUInteger len = (NSUInteger)strlen(s) ;
		MSString *ret = (MSString*)CCreateString(len) ;
		
		if (CStringAppendURLBytes((CString*)ret, (void *)s, len, NSUTF8StringEncoding, NULL)) {
			return AUTORELEASE(ret) ;
		}
		RELEASE(ret) ;
	}
	return [NSString string] ;
}

// TODO: If mutable, returns an immutable copy ?
- (NSString *)toString { return self ; }

static inline NSString *_HTMLFromString(NSString *self, char **tagStrings, SEL sourceMethod)
{
 	SES ses = SESFromString(self) ;
    if (SESOK(ses)) {
		NSUInteger sourceLen = ses.length ;
        NSUInteger i, end, len = 0, size = MAX(sourceLen+16, (NSUInteger)(sourceLen*1.25)) ;
        unichar c ;
        char *buf = (char *)MSMalloc(size,"_HTMLFromString()") ;
        char *tag = NULL, clen = 0 ;
        char sharp[16] ;
        
        if (!buf) MSRaiseFrom(NSMallocException,self, sourceMethod, @"string of %lu characters cannot be allocated", (unsigned long)size) ;
		
        //for (i = 0 ; i < sourceLen ; i++) {
        for (i= SESStart(ses), end= SESEnd(ses); i < end;) {
            c = SESIndexN(ses, &i) ;
            if (c < 256) {
                tag = tagStrings[c] ;
                clen = *tag++ ;
            }
            else if (c >= 913 && c <= 982) {
                tag = __greekHtmlTags[c-913] ;
                clen = *tag++ ;
            }
            else if (c >= 8200 && c <= 8260) {
                tag = __symbolHtmlTags[c-8200] ;
                clen = *tag++ ;
            }
            else if (c == 0x0152) { tag = "&OElig;" ; clen = 7 ; } 	// don't forget our french ...
            else if (c == 0x0153) { tag = "&oelig;" ; clen = 7 ; }		// in our source code
            else if (c == 8364) { tag = "&euro;" ; clen = 6 ; }
            else if (c == 8482) { tag = "&trade;" ; clen = 7 ; }
            else {
                clen = (char)sprintf(sharp, "&#%d;", c) ;
                tag = sharp ;
                //clen = strlen(sharp) ;
            }
            if (clen) {
                if (len + (NSUInteger)clen > size) {
                    NSUInteger newSize = MAX(len+(NSUInteger)clen+16, (sourceLen*((NSUInteger)clen+len)/i)) ; // i will never be null because we allocate 16 at least
                    buf = (char *)MSRealloc(buf, newSize, "_HTMLFromString()") ;
                    if (!buf) MSRaiseFrom(NSMallocException, self, sourceMethod, @"string of %lu characters cannot be allocated", (unsigned long)newSize) ;
                    size = newSize ;
                }
                memcpy(buf+len, tag, clen) ;
                len += (NSUInteger)clen ;
            }
        }
        if (len) { return AUTORELEASE(MSCreateASCIIStringWithBytes((void *)buf, len, NO, YES)) ; }
        MSFree(buf, "_HTMLFromString()");
    }
    return @"" ;
}

- (NSString *)htmlRepresentation { return _HTMLFromString(self, __fullHtmlTags, _cmd) ; }
- (NSString *)htmlRepresentation:(BOOL)convertsHTMLMarks { return _HTMLFromString(self, (convertsHTMLMarks ? __fullHtmlTags: __htmlTags), _cmd) ; }

- (float)floatValue
{
  return [[MSDecimal decimalWithString:self] floatValue];
}

- (double)doubleValue
{
  return [[MSDecimal decimalWithString:self] doubleValue];
}

-(BOOL)boolValue
{
  BOOL ret= NO;
  SES ses;
  ses= SESFromString(self);
  if(SESOK(ses)) {
    NSUInteger i,end; unichar u = 0; BOOL c= YES;
    for (i= SESStart(ses), end= SESEnd(ses); c && i < end;) {
      u= SESIndexN(ses, &i);
      c= (u == 0x0020 || u == 0x0009); }
    if(i <= end) {
      if(u=='Y' || u=='y' || u=='T' || u=='t')
        ret= YES;
      else {
        if(u=='-' || u=='+')
          u= SESIndexN(ses, &i);
        while(u == '0' && i < end){
          u= SESIndexN(ses, &i);}
        ret= (i <= end && '1' <= 'u' && u <= '9');}
    }
  }
  return ret;
}

- (int)intValue {
  CDecimal *decimal = CCreateDecimalWithSES(SESFromString(self),NO,NULL,NULL);
  int value = CDecimalIntValue(decimal);
  RELEASE((id)decimal);
  return value;
}
- (NSInteger)integerValue {
  CDecimal *decimal = CCreateDecimalWithSES(SESFromString(self),NO,NULL,NULL);
  NSInteger value = CDecimalIntegerValue(decimal);
  RELEASE((id)decimal);
  return value;
}
- (long long)longLongValue {
  CDecimal *decimal = CCreateDecimalWithSES(SESFromString(self),NO,NULL,NULL);
  long long value = CDecimalLongValue(decimal);
  RELEASE((id)decimal);
  return value;
}

- (NSUInteger)hash:(unsigned)depth
{ return SESHash(SESFromString(self)); }
@end

#define MS_STRING_LAST_VERSION 101

@implementation MSString
+ (void)load          {MSFinishLoadingDec();}
+ (void)initialize {[MSDictionary setVersion:MS_STRING_LAST_VERSION];}

#pragma mark Alloc / Init

+ (id)new    { return ALLOC(self); }

static inline id _string(Class cl, id a, BOOL m)
{
  if (!a) a= AUTORELEASE(ALLOC(cl));
  if (!m) CGrowSetForeverImmutable(a);
  return a;
}
static inline id _stringWithBytes(Class cl, id a, BOOL m, NSStringEncoding encoding, const void *s, NSUInteger length)
{
  if (!a) a= AUTORELEASE(ALLOC(cl));
  CStringAppendBytes((CString*)a, encoding, s, length);
  if (!m) CGrowSetForeverImmutable(a);
  return a;
}
static inline id _stringWithSES(Class cl, id a, BOOL m, SES ses)
{
  if (!a) a= AUTORELEASE(ALLOC(cl));
  CStringAppendSES((CString*)a, ses);
  if (!m) CGrowSetForeverImmutable(a);
  return a;
}
static inline id _stringWithFormatv(Class cl, id a, BOOL m, const char *fmt, va_list ap)
{
  if (!a) a= AUTORELEASE(ALLOC(cl));
  CStringAppendFormatv((CString*)a, fmt, ap);
  if (!m) CGrowSetForeverImmutable(a);
  return a;
}
#define _stringWithFormats(CL,A,M,LA,FMT) ({\
  id ret; \
  va_list ap; \
  va_start(ap, LA); \
  ret= _stringWithFormatv(CL,A,M, FMT,ap); \
  va_end(ap); \
  ret; })
static inline id _stringWithContentsOfFile(Class cl, id a, BOOL m, NSString *path, NSStringEncoding inEnc, NSStringEncoding *outEnc, NSError **error)
{
  CBuffer* buf= CCreateBuffer(0);
  if (!CBufferAppendContentsOfFile(buf, SESFromString(path)))
    DESTROY(a);
  else if (outEnc)
    DESTROY(a); // TODO
  else
    a= _stringWithBytes(cl, a, m, inEnc, CBufferBytes(buf), CBufferLength(buf));
  RELEASE(buf);
  return a;
}

+ (instancetype)string        {return _string(self, nil,  NO);}
- (instancetype)init          {return _string(nil ,self,  NO);}
+ (instancetype)mutableString {return _string(self, nil, YES);}
- (instancetype)mutableInit   {return _string(nil ,self, YES);}

- (id)mutableInitWithCapacity:(NSUInteger)capacity
  {
  CGrowGrow(self, capacity);
  return self;
  }

+ (instancetype)stringWithCharacters:(const unichar *)characters length:(NSUInteger)length
{ return _stringWithBytes(nil ,self, NO, NSUnicodeStringEncoding, characters,length);}
- (instancetype)initWithCharacters:(const unichar *)characters length:(NSUInteger)length
{ return _stringWithBytes(nil ,self, NO, NSUnicodeStringEncoding, characters,length);}
- (instancetype)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer
{ id str=_stringWithBytes(nil ,self, NO, NSUnicodeStringEncoding, characters,length); if(freeBuffer) free(characters); return str;}
+ (instancetype)mutableStringWithCharacters:(const unichar *)characters length:(NSUInteger)length
{ return _stringWithBytes(nil ,self,YES, NSUnicodeStringEncoding, characters,length);}
- (instancetype)mutableInitWithCharacters:(const unichar *)characters length:(NSUInteger)length
{ return _stringWithBytes(nil ,self,YES, NSUnicodeStringEncoding, characters,length);}
- (instancetype)mutableInitWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer
{ id str=_stringWithBytes(nil ,self,YES, NSUnicodeStringEncoding, characters,length); if(freeBuffer) free(characters); return str;}

+ (instancetype)stringWithUTF8String:(const char *)nullTerminatedCString
{ return _stringWithBytes(self, nil, NO, NSUTF8StringEncoding, nullTerminatedCString, strlen(nullTerminatedCString));}
- (instancetype)initWithUTF8String:(const char *)nullTerminatedCString
{ return _stringWithBytes(nil ,self, NO, NSUTF8StringEncoding, nullTerminatedCString, strlen(nullTerminatedCString));}
+ (instancetype)mutableStringWithUTF8String:(const char *)nullTerminatedCString
{ return _stringWithBytes(self, nil,YES, NSUTF8StringEncoding, nullTerminatedCString, strlen(nullTerminatedCString));}
- (instancetype)mutableInitWithUTF8String:(const char *)nullTerminatedCString
{ return _stringWithBytes(nil ,self,YES, NSUTF8StringEncoding, nullTerminatedCString, strlen(nullTerminatedCString));}

+ (instancetype)stringWithString:(NSString *)string
{ return _stringWithSES(self, nil, NO, SESFromString(string));}
- (instancetype)initWithString:(NSString *)string
{ return _stringWithSES(nil ,self, NO, SESFromString(string));}
+ (instancetype)mutableStringWithString:(NSString *)string
{ return _stringWithSES(self, nil,YES, SESFromString(string));}
- (instancetype)mutableInitWithString:(NSString *)string
{ return _stringWithSES(nil ,self,YES, SESFromString(string));}

/* TODO: Locale support */
+ (instancetype)stringWithFormat:(NSString *)format, ...
{ return _stringWithFormats(self, nil, NO, format, [format UTF8String]); }
- (instancetype)initWithFormat:(NSString *)format, ...
{ return _stringWithFormats(nil ,self, NO, format, [format UTF8String]); }
- (instancetype)initWithFormat:(NSString *)format arguments:(va_list)argList
{ return _stringWithFormatv(nil ,self, NO, [format UTF8String], argList);}
- (instancetype)initWithFormat:(NSString *)format locale:(id)locale, ...
{ return _stringWithFormats(nil ,self, NO, locale, [format UTF8String]);}
- (instancetype)initWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList
{ return _stringWithFormatv(nil ,self, NO, [format UTF8String], argList);}
+ (instancetype)localizedStringWithFormat:(NSString *)format, ...
{ return _stringWithFormats(self, nil, NO, format, [format UTF8String]); }
+ (instancetype)mutableStringWithFormat:(NSString *)format, ...
{ return _stringWithFormats(self, nil,YES, format, [format UTF8String]); }
- (instancetype)mutableInistWithFormat:(NSString *)format, ...
{ return _stringWithFormats(nil ,self,YES, format, [format UTF8String]); }
- (instancetype)mutableInitWithFormat:(NSString *)format arguments:(va_list)argList
{ return _stringWithFormatv(nil ,self,YES, [format UTF8String], argList);}
- (instancetype)mutableInitWithFormat:(NSString *)format locale:(id)locale, ...
{ return _stringWithFormats(nil ,self,YES, locale, [format UTF8String]);}
- (instancetype)mutableInitWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList
{ return _stringWithFormatv(nil ,self,YES, [format UTF8String], argList);}

- (instancetype)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{ return _stringWithBytes(nil, self, NO, encoding, [data bytes], [data length]);}
- (instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding
{ return _stringWithBytes(nil, self, NO, encoding, bytes, len);}
- (instancetype)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer
{ id str=_stringWithBytes(nil, self, NO, encoding, bytes, len); if(freeBuffer) free(bytes); return str;}
- (instancetype)mutableInitWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{ return _stringWithBytes(nil, self,YES, encoding, [data bytes], [data length]);}
- (instancetype)mutableInitWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding
{ return _stringWithBytes(nil, self,YES, encoding, bytes, len);}
- (instancetype)mutableInitWithBytesNoCopy:(void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer
{ id str=_stringWithBytes(nil, self,YES, encoding, bytes, len); if(freeBuffer) free(bytes); return str;}

+ (instancetype)stringWithCString:(const char *)cstr encoding:(NSStringEncoding)enc
{ return _stringWithBytes(self, nil, NO, NSUTF8StringEncoding, cstr, strlen(cstr));}
- (instancetype)initWithCString:(const char *)cstr encoding:(NSStringEncoding)encoding
{ return _stringWithBytes(nil ,self, NO, NSUTF8StringEncoding, cstr, strlen(cstr));}
+ (instancetype)mutableStringWithCString:(const char *)cstr encoding:(NSStringEncoding)enc
{ return _stringWithBytes(self, nil,YES, NSUTF8StringEncoding, cstr, strlen(cstr));}
- (instancetype)mutableInitWithCString:(const char *)cstr encoding:(NSStringEncoding)encoding
{ return _stringWithBytes(nil ,self,YES, NSUTF8StringEncoding, cstr, strlen(cstr));}

+ (instancetype)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error
{ return _stringWithContentsOfFile(self, nil, NO, path, enc, 0,error);}
- (instancetype)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error
{ return _stringWithContentsOfFile(nil ,self, NO, path, enc, 0, error);}
+ (instancetype)stringWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{ return _stringWithContentsOfFile(self, nil, NO, path, 0, enc, error);}
- (instancetype)initWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{ return _stringWithContentsOfFile(nil ,self, NO, path, 0, enc, error);}
+ (instancetype)mutableStringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error
{ return _stringWithContentsOfFile(self, nil,YES, path, enc, 0,error);}
- (instancetype)mutableInitWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error
{ return _stringWithContentsOfFile(nil ,self,YES, path, enc, 0,error);}
+ (instancetype)mutableStringWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{ return _stringWithContentsOfFile(self, nil,YES, path, 0, enc, error);}
- (instancetype)mutableInitWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{ return _stringWithContentsOfFile(nil ,self,YES, path, 0, enc, error);}


+ (instancetype)UUIDString
{
  return AUTORELEASE(CCreateStringWithGeneratedUUID());
}

- (void)dealloc
{
  CStringFreeInside(self);
  [super dealloc];
}

#pragma mark Mutability

- (BOOL)isMutable    {return CGrowIsForeverMutable(self);}
- (void)setImmutable {CGrowSetForeverImmutable(self);}

#pragma mark Primitives

- (NSUInteger)length
{
  return _length;
}
- (unichar)characterAtIndex:(NSUInteger)index
//The index value must not lie outside the bounds of the receiver.
{
  return _buf[index];
}

- (void)getCharacters:(unichar*)buffer range:(NSRange)rg
{
  NSUInteger i,n; unichar *p;
  p= _buf+rg.location;
  for (n= rg.length, i=0; i<n; i++) {*buffer++= *p++;}
}
- (SES)stringEnumeratorStructure
{
  return CStringSES((CString*)self);
}

#pragma mark Mutable primitives

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString
{
  CStringReplaceInRangeWithSES((CString *)self, range, SESFromString(aString));
}

- (void)insertString:(NSString *)aString atIndex:(NSUInteger)loc
{
  CStringReplaceInRangeWithSES((CString *)self, NSMakeRange(loc, 0), SESFromString(aString));
}

- (void)deleteCharactersInRange:(NSRange)range
{
  CStringReplaceInRangeWithSES((CString *)self, range, MSInvalidSES);
}

- (void)appendString:(NSString *)aString
{
  CStringAppendSES((CString*)self, SESFromString(aString));
}
- (void)appendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
  va_list ap;
  va_start(ap, format);
  CStringAppendFormatv((CString*)self, [format UTF8String], ap);
  va_end(ap);
}
- (void)setString:(NSString *)aString
{
  CStringReplaceInRangeWithSES((CString *)self, NSMakeRange(0, CStringLength((CString *)self)), SESFromString(aString));
}
// TODO: - (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange

#pragma mark Global methods

- (NSUInteger)hash:(unsigned)depth {return CStringHash(self, depth);}

#pragma mark Copying

- (id)copyWithZone:(NSZone*)z
{return MSGrowCopyWithZone(z,self, NO,(MSGrowInitCopyMethod)CStringInitCopyWithMutability);}
- (id)mutableCopyWithZone:(NSZone*)z
{return MSGrowCopyWithZone(z,self,YES,(MSGrowInitCopyMethod)CStringInitCopyWithMutability);}

- (void)describeIn:(id)result level:(int)level context:(MSDictionary*)ctx
{
  CStringDescribe(self, result, level, (CDictionary*)ctx);
}

- (BOOL)isEqualToString:(NSString*)s
  {
  return SESEquals(SESFromString(self), SESFromString(s));
  }

- (BOOL)isEqual:(id)object
  {
  if (object == (id)self) return YES;
  if (!object) return NO;
  if ([object isKindOfClass:[MSString class]]) {
    return CStringEquals((CString*)self, (CString*)object);}
  else if ([object isKindOfClass:[NSString class]]) {
    return SESEquals(SESFromString(self), SESFromString(object));}
  return NO;
  }

#pragma mark description

static inline unichar _noopTransform(unichar ch)
{ return ch; }
static inline NSString* _caseTransformedString(NSString* self, unichar (*firstChar)(unichar ch), unichar (*otherChars)(unichar ch))
{
  SES ses; NSUInteger i= 0; CString *s;
  ses= [self stringEnumeratorStructure];
  s= CCreateString([self length]);
  if (i < SESEnd(ses)) {
    CStringAppendCharacter(s, firstChar(SESIndexN(ses, &i)));}
  while (i < SESEnd(ses)) {
    CStringAppendCharacter(s, otherChars(SESIndexN(ses, &i)));}
  return AUTORELEASE((id)s);
}
- (NSString *)uppercaseString
{ return _caseTransformedString(self, CUnicharToUpper, CUnicharToUpper);}
- (NSString *)lowercaseString
{ return _caseTransformedString(self, CUnicharToLower, CUnicharToLower);}
- (NSString *)capitalizedString
{ return _caseTransformedString(self, CUnicharToUpper, _noopTransform);}

- (NSString*)description
{ return self; }

#pragma mark encoding

static inline CBuffer* _dataUsingEncoding(NSString *self, NSStringEncoding encoding) {
  CBuffer *ret= CCreateBuffer(0);
  CBufferAppendSES(ret, SESFromString(self), encoding);
  return ret;
} 
- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding
{ return [self cStringUsingEncoding:encoding allowLossyConversion:YES]; }
- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)flag
{
  CBuffer *b= _dataUsingEncoding(self, encoding);
  AUTORELEASE((MSBuffer*)b);
  return (const char *)CBufferCString(b);
}
- (const char *)UTF8String
{
  CBuffer *b= _dataUsingEncoding(self, NSUTF8StringEncoding);
  AUTORELEASE((MSBuffer*)b);
  return (const char *)CBufferCString(b);
}
- (const unichar *)UTF16String
{
  CGrowGrow((id)self, 1); // Même si pas mutable
  self->_buf[self->_length]= 0x0000;
  return self->_buf;
}

- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding
{ return [self dataUsingEncoding:encoding allowLossyConversion:YES]; }
- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)flag
{ return AUTORELEASE(_dataUsingEncoding(self, encoding)); }
/* DEBUG

#define WHO super // [NSString stringWithString:self] // super
#define _logAndDo(M)    {NSLog(@#M); return [WHO M];}
#define _logAndDoA(M,A) {NSLog(@#M); return [WHO M:A];}


+ (const NSStringEncoding *)availableStringEncodings _logAndDo(availableStringEncodings)
+ (NSStringEncoding)defaultCStringEncoding           _logAndDo(defaultCStringEncoding)
- (NSStringEncoding)fastestEncoding                  _logAndDo(fastestEncoding)
- (NSStringEncoding)smallestEncoding                 _logAndDo(smallestEncoding)
- (const char *)cString                              _logAndDo(cString)       // deprecated
- (NSUInteger)cStringLength                          _logAndDo(cStringLength) // deprecated
- (const char *)lossyCString                         _logAndDo(lossyCString)  // deprecated
- (void)getCString:(char *)buffer                               _logAndDoA(getCString,buffer) // deprecated
+ (NSString *)localizedNameOfStringEncoding:(NSStringEncoding)e _logAndDoA(localizedNameOfStringEncoding,e)
- (BOOL)canBeConvertedToEncoding:(NSStringEncoding)e            _logAndDoA(canBeConvertedToEncoding,e)
- (NSData *)dataUsingEncoding:(NSStringEncoding)e               _logAndDoA(dataUsingEncoding,e)
- (void)getCharacters:(unichar *)buffer                         _logAndDoA(getCharacters,buffer) // deprecated
- (NSData *)dataUsingEncoding:(NSStringEncoding)e allowLossyConversion:(BOOL)flag
{
  NSLog(@"dataUsingEncoding:allowLossyConversion:");
  return [WHO dataUsingEncoding:e allowLossyConversion:flag];
}
- (BOOL)getCString:(char *)buffer maxLength:(NSUInteger)maxBufferCount encoding:(NSStringEncoding)encoding
{
  NSLog(@"getCString");
  return [WHO getCString:buffer maxLength:maxBufferCount encoding:encoding];
}
- (BOOL)getBytes:(void *)buffer maxLength:(NSUInteger)maxBufferCount usedLength:(NSUInteger *)usedBufferCount
  encoding:(NSStringEncoding)encoding options:(NSStringEncodingConversionOptions)options range:(NSRange)range
  remainingRange:(NSRangePointer)leftover
{
  NSLog(@"getBytes");
  return [WHO getBytes:buffer maxLength:maxBufferCount usedLength:usedBufferCount encoding:encoding options:options range:range remainingRange:leftover];
}
- (void)getCString:(char *)buffer maxLength:(NSUInteger)maxLength // deprecated
{
  NSLog(@"getCString");
  return [WHO getCString:buffer maxLength:maxLength];
}
- (void)getCString:(char *)buffer maxLength:(NSUInteger)maxLength range:(NSRange)aRange
  remainingRange:(NSRangePointer)leftoverRange // deprecated
{
  NSLog(@"getCString:...");
  return [WHO getCString:buffer maxLength:maxLength range:aRange remainingRange:leftoverRange];
}
- (id)initWithCStringNoCopy:(char *)cString length:(NSUInteger)length freeWhenDone:(BOOL)flag
{
  NSLog(@"initWithCStringNoCopy:");
  return [WHO initWithCStringNoCopy:cString length:length freeWhenDone:flag];
}
*/
#pragma mark Finding characters and substrings

SES _SESFind(SES src, SES searched, BOOL insensitive, BOOL backward, BOOL anchored, NSRange *range);

- (NSRange)rangeOfString:(NSString *)aString
{
  NSRange r;
  _SESFind(SESFromString(self), SESFromString(aString), NO, NO, NO, &r);
  return r;
}

- (NSRange)rangeOfString:(NSString *)aString options:(NSStringCompareOptions)mask
{
  NSRange r;
  _SESFind(SESFromString(self), SESFromString(aString), (mask & NSCaseInsensitiveSearch) > 0, (mask & NSBackwardsSearch) > 0, (mask & NSAnchoredSearch) > 0, &r);
  return r;
}

#pragma mark Determining line ranges

static inline NSUInteger SESForwardN(SES ses, NSUInteger idx, NSUInteger amount) {
  while (amount > 0 && idx < SESEnd(ses)) {
    SESIndexN(ses, &idx);
    --amount;}
  return idx;
}

- (void)getLineStart:(NSUInteger *)startIndex end:(NSUInteger *)lineEndIndex contentsEnd:(NSUInteger *)contentsEndIndex forRange:(NSRange)aRange
{
  SES ses; NSUInteger s, si, ci, ei, e;
  ses= SESFromString(self);
  s= SESStart(ses); e= SESEnd(ses);
  si= SESForwardN(ses, s, aRange.location);
  ci= SESForwardN(ses, si, aRange.length);
  while (s < si && !CUnicharIsEOL(SESIndexP(ses, &si)))
      ; // move si backward until EOL is reached
  while (ci < e && !CUnicharIsEOL(SESIndexN(ses, &ci)))
      ; // move ci forward until EOL is reached
  ei= ci;
  while (ei < e && CUnicharIsEOL(SESIndexN(ses, &ei)))
      ; // move ei forward until EOL is over
  if (startIndex)       *startIndex= si;
  if (lineEndIndex)     *lineEndIndex= ei;
  if (contentsEndIndex) *contentsEndIndex= ci;
}
- (NSRange)lineRangeForRange:(NSRange)aRange
{
  NSRange r; NSUInteger s, e;
  [self getLineStart:&r.location end:&e contentsEnd:NULL forRange:aRange];
  r.length= e - r.location;
  return r;
}

#pragma mark Dividing strings

- (NSArray *)componentsSeparatedByString:(NSString *)separator
{
  CArray *arr; CString *cur; SES ses, searched, find, sub;
  arr= CCreateArray(0);
  ses= sub= SESFromString(self);
  searched= SESFromString(separator);
  while(SESOK(find= SESFind(ses, searched))) {
    SESSetEnd(sub, SESStart(find));
    cur= CCreateStringWithSES(sub);
    CArrayAddObject(arr, (id)cur);
    RELEASE(cur);
    SESSetStart(ses, SESEnd(find));
    SESSetStart(sub, SESEnd(find));}
  cur= CCreateStringWithSES(ses);
  CArrayAddObject(arr, (id)cur);
  RELEASE(cur);
  return AUTORELEASE(arr);
}
- (NSString *)substringFromIndex:(NSUInteger)anIndex
{
  SES ses; id ret= self;
  ses= SESFromString(self);
  if (SESOK(ses)) {
    SESSetStart(ses, SESForwardN(ses, SESStart(ses), anIndex));
    ret= AUTORELEASE(CCreateStringWithSES(ses));}
  return ret;
}
- (NSString *)substringToIndex:(NSUInteger)anIndex
{
  SES ses; NSUInteger i, e, n; id ret= self; CString *s;
  ses= SESFromString(self);
  if (SESOK(ses)) {
    s= CCreateString(anIndex);
    i= SESStart(ses); e= SESEnd(ses);
    for (n= 0; i < e && n < anIndex; ++n) {
      CStringAppendCharacter(s, SESIndexN(ses, &i));}
    ret= AUTORELEASE(s);}
  return ret;
}
- (NSString *)substringWithRange:(NSRange)aRange
{
  SES ses; NSUInteger i, e, n; id ret= self; CString *s;
  ses= SESFromString(self);
  if (SESOK(ses)) {
    s= CCreateString(aRange.length);
    e= SESEnd(ses);
    i= SESForwardN(ses, SESStart(ses), aRange.location);
    for (n= 0; i < e && n < aRange.length; ++n) {
      CStringAppendCharacter(s, SESIndexN(ses, &i));}
    ret= AUTORELEASE(s);}
  return ret;
}

#pragma mark Combining strings

- (NSString *)stringByAppendingFormat:(NSString *)format, ...
{
  CString *ret; va_list vp;
  ret= CCreateStringWithSES(SESFromString(self));
  va_start(vp, format);
  CStringAppendFormatv(ret, [format UTF8String], vp);
  va_end(vp);
  CGrowSetForeverImmutable((id)ret);
  return AUTORELEASE(ret);
}
- (NSString *)stringByAppendingString:(NSString *)aString
{
  CString *ret;
  ret= CCreateStringWithSES(SESFromString(self));
  CStringAppendSES(ret, SESFromString(aString));
  CGrowSetForeverImmutable((id)ret);
  return AUTORELEASE(ret);
}
- (NSString *)stringByPaddingToLength:(NSUInteger)newLength withString:(NSString *)padString startingAtIndex:(NSUInteger)padIndex
{
  CString *ret; SES ses; NSUInteger i;
  ret= CCreateStringWithSES(SESFromString(self));
  if(CStringLength(ret) < newLength) {
    ses= SESFromString(padString);
    for(i= SESStart(ses); padIndex > 0; --padIndex) {
      SESIndexN(ses, &i);}
    padIndex= i;
    while(CStringLength(ret) < newLength) {
      if(i == SESEnd(ses)) {
        i= SESStart(ses);}
      CStringAppendCharacter(ret, SESIndexN(ses, &i));}}
  CGrowSetForeverImmutable((id)ret);
  return AUTORELEASE(ret);
}

#pragma mark Identifying and comparing strings

- (NSComparisonResult)caseInsensitiveCompare:(NSString *)aString
{ return SESInsensitiveCompare(SESFromString(self), SESFromString(aString)); }
- (NSComparisonResult)compare:(NSString *)aString
{ return SESCompare(SESFromString(self), SESFromString(aString)); }
- (BOOL)hasPrefix:(NSString *)aString
{ return SESOK(SESCommonPrefix(SESFromString(self), SESFromString(aString))); }
- (BOOL)hasSuffix:(NSString *)aString
{ return SESOK(SESCommonSuffix(SESFromString(self), SESFromString(aString))); }


#pragma mark Path

static inline BOOL _isPathSeparator(unichar u)
{
#ifdef WIN32
  return u == '/' || u == '\\';
#else
  return u == '/';
#endif
}

- (const char *)fileSystemRepresentation
{ return [self UTF8String]; }

+ (NSString *)pathWithComponents:(NSArray *)components
{
  NSUInteger i, len; CString *ret; BOOL sep= NO; NSString *o;
  ret= CCreateString(0);
  for (i= 0, len= [components count]; i < len; ++i) {
    if (sep)
      CStringAppendCharacter(ret, '/');
    o= [components objectAtIndex:i];
    CStringAppendSES(ret, SESFromString(o));
    if (i!= 0 || [o length] != 1 || !_isPathSeparator([o characterAtIndex:0]))
      sep= YES;
  }
  CGrowSetForeverImmutable((id)ret);
  return AUTORELEASE(ret);
}
- (NSArray *)pathComponents
{
  CArray *ret; CString *cur; SES ses; NSUInteger pos; unichar u; BOOL first= YES;
  ret= CCreateArray(0);
  cur= CCreateString(0);
  ses= SESFromString(self);
  for (pos= SESStart(ses); pos < SESEnd(ses);) {
    u= SESIndexN(ses, &pos);
    if (_isPathSeparator(u)) {
      if (first) {
        CArrayAddObject(ret, @"/");}
      else if(CStringLength(cur) > 0){
        CGrowSetForeverImmutable((id)cur);
        CArrayAddObject(ret, (id)cur);
        RELEASE(cur);
        cur= CCreateString(0);}
    }
    else {
      CStringAppendCharacter(cur, u);
    }
    first= NO;
  }
  if(CStringLength(cur) > 0){
    CGrowSetForeverImmutable((id)cur);
    CArrayAddObject(ret, (id)cur);}
  RELEASE(cur);
  CGrowSetForeverImmutable((id)ret);
  return AUTORELEASE(ret);
}

- (BOOL)isAbsolutePath
{
  SES ses; NSUInteger i;
  ses= SESFromString(self);
  i= SESStart(ses);
#ifdef WIN32 // '^[A-Za-z]:'
  return CUnicharIsLetter(SESIndexN(ses, &i)) && SESIndexN(ses, &i) == ':';
#else // '^/'
  return SESIndexN(ses, &i) == '/';
#endif
}

- (NSString *)lastPathComponent
{
  SES ses;  NSUInteger i, s, e; NSString *ret= self;
  ses= SESFromString(self);
  s= SESStart(ses);
  i= e= SESEnd(ses); 
  while (i > SESStart(ses) && _isPathSeparator(SESIndexP(ses, &i)))
    e= i; // skip [/\]*$
  while (i > SESStart(ses) && !_isPathSeparator(SESIndexP(ses, &i)))
    s= i; // skip [^/\]*
  if ((SESStart(ses) != s || SESEnd(ses) != e) && e > s) {
    ses.start= s;
    ses.length= e - s;
    ret= AUTORELEASE(CCreateStringWithSES(ses));
    CGrowSetForeverImmutable(ret);}
  return ret;
}

- (NSString *)pathExtension
{
  SES ses;  NSUInteger i; NSString *ret= @"";
  ses= SESFromString(self);
  i= SESEnd(ses); 
  while (i > SESStart(ses) && SESIndexP(ses, &i) != (unichar)'.')
    ; // skip [^.]*
  if (SESIndexN(ses, &i) == (unichar)'.') {
    ses.length-= i - ses.start;
    ses.start= i;
    ret= AUTORELEASE(CCreateStringWithSES(ses));
    CGrowSetForeverImmutable(ret);}
  return ret;
}

static inline CString *_stringByAppendingPathComponent(NSString *self, NSString *aString)
{
  CString *ret; SES ses, ses2; NSUInteger i, i2;
  ret= CCreateStringWithSES(SESFromString(self));
  i= CStringLength(ret);
  ses2= SESFromString(aString);
  if (SESOK(ses2) && i > 0) {
    while (i > 0 && _isPathSeparator(ret->buf[--i]))
      ;
    if (i > 0) 
      ++i;
    CStringReplaceInRangeWithSES(ret, NSMakeRange(i, ret->length - i), MSMakeSESWithBytes("/", 1, NSUTF8StringEncoding));}
  if (SESOK(ses2)) {
    i2= SESStart(ses2);
    while (i2 < SESEnd(ses2) && _isPathSeparator(SESIndexN(ses2, &i2)))
      ;
    SESIndexP(ses2, &i2);
    ses2.length-= i2 - ses2.start;
    ses2.start= i2;
    CStringAppendSES(ret, ses2);}
  return ret;
}
- (NSString *)stringByAppendingPathComponent:(NSString *)aString
{
  id ret= AUTORELEASE(_stringByAppendingPathComponent(self, aString));
  CGrowSetForeverImmutable(ret);
  return ret;
}

- (NSString *)stringByAppendingPathExtension:(NSString *)ext
{
  CString *ret; SES ses, ses2; NSUInteger i;
  ret= CCreateStringWithSES(SESFromString(self));
  i= CStringLength(ret);
  ses2= SESFromString(ext);
  if (SESOK(ses2) && i > 0) {
    while (i > 0 && _isPathSeparator(ret->buf[--i]))
      ;
    if (!_isPathSeparator(ret->buf[i])) 
      ++i;
    CStringReplaceInRangeWithSES(ret, NSMakeRange(i, ret->length - i), MSMakeSESWithBytes(".", 1, NSUTF8StringEncoding));}
  CStringAppendSES(ret, ses2);
  CGrowSetForeverImmutable((id)ret);
  return AUTORELEASE(ret);
}
- (NSString *)stringByDeletingLastPathComponent 
{
  SES ses;  NSUInteger i, s; id ret;
  ses= SESFromString(self);
  i= SESEnd(ses);
  while (i > SESStart(ses) && _isPathSeparator(SESIndexP(ses, &i)))
    ; // skip [/\]*$
  while (i > SESStart(ses) && !_isPathSeparator(SESIndexP(ses, &i)))
    ; // skip [^/\]*
  ses.length= i - SESStart(ses);
  if(ses.length == 0) {
    i= SESStart(ses);
    if(_isPathSeparator(SESIndexN(ses, &i))) {
      ses.length= i - SESStart(ses);}}
  ret= AUTORELEASE(CCreateStringWithSES(ses));
  CGrowSetForeverImmutable(ret);
  return ret;
}

- (NSString *)stringByDeletingPathExtension
{
  SES ses;  NSUInteger i, e; NSString *ret= self; unichar u;
  ses= SESFromString(self);
  i= e= SESEnd(ses);
  while (i > SESStart(ses) && _isPathSeparator(u= SESIndexP(ses, &i)))
    e= i; // skip [/\]*$
  while (u != (unichar)'.' && i > SESStart(ses))
    u= SESIndexP(ses, &i); // skip [^.]*
  if (u != (unichar)'.' && SESEnd(ses) != e) {
    i= e;} // Remove [/\]* that are at the end of the string
  if (i > SESStart(ses)) {
    ses.length= i - ses.start;
    ret= AUTORELEASE(CCreateStringWithSES(ses));
    CGrowSetForeverImmutable(ret);}
  return ret;
}

- (NSArray *)stringsByAppendingPaths:(NSArray *)paths
{
  NSUInteger i, len; CArray *ret; CString *str;
  len= [paths count];
  ret= CCreateArray(len);
  for (i= 0; i < len; ++i) {
    str= _stringByAppendingPathComponent(self, [paths objectAtIndex:i]);
    CArrayAddObject(ret, (id)str);
    RELEASE(str);
  }
  CGrowSetForeverImmutable((id)ret);
  return AUTORELEASE(ret);
}
/* DEBUG
- (NSArray *)pathComponents                           _logAndDo(pathComponents)
- (const char *)fileSystemRepresentation              _logAndDo(fileSystemRepresentation)
- (BOOL)isAbsolutePath                                _logAndDo(isAbsolutePath)
- (NSString *)lastPathComponent                       _logAndDo(lastPathComponent)
- (NSString *)pathExtension                           _logAndDo(pathExtension)
- (NSString *)stringByAbbreviatingWithTildeInPath     _logAndDo(stringByAbbreviatingWithTildeInPath)
- (NSString *)stringByDeletingLastPathComponent       _logAndDo(stringByDeletingLastPathComponent)
- (NSString *)stringByDeletingPathExtension           _logAndDo(stringByDeletingPathExtension)
- (NSString *)stringByExpandingTildeInPath            _logAndDo(stringByExpandingTildeInPath)
- (NSString *)stringByResolvingSymlinksInPath         _logAndDo(stringByResolvingSymlinksInPath)
- (NSString *)stringByStandardizingPath               _logAndDo(stringByStandardizingPath)
+ (NSString *)pathWithComponents:(NSArray *)a                    _logAndDoA(pathWithComponents,a)
- (NSString *)stringByAppendingPathComponent:(NSString *)aString _logAndDoA(stringByAppendingPathComponent,aString)
- (NSString *)stringByAppendingPathExtension:(NSString *)ext     _logAndDoA(stringByAppendingPathExtension,ext)
- (NSArray *)stringsByAppendingPaths:(NSArray *)paths            _logAndDoA(stringsByAppendingPaths,paths)
- (NSUInteger)completePathIntoString:(NSString **)outputName caseSensitive:(BOOL)flag
  matchesIntoArray:(NSArray **)outputArray filterTypes:(NSArray *)filterTypes
{
  NSLog(@"completePathIntoString");
  return [WHO completePathIntoString:outputName caseSensitive:flag
              matchesIntoArray:outputArray filterTypes:filterTypes];
}
- (BOOL)getFileSystemRepresentation:(char *)buffer maxLength:(NSUInteger)maxLength
{
  NSLog(@"getFileSystemRepresentation");
  return [WHO getFileSystemRepresentation:buffer maxLength:maxLength];
}
*/
@end
