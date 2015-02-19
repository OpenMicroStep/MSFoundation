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
BOOL MSEqualStrings(NSString *s1, NSString *s2)
{
  if (s1 != s2) {
    if (s1 && s2) {
      SES ses1= [s1 stringEnumeratorStructure] ;
      SES ses2= [s2 stringEnumeratorStructure] ;
      NSUInteger len1= ses1.length ;
      // TODO: a revoir, les length n'ont pas à être égales mais simplement à la
      // fin i==iend et j==jend
      if (len1 == ses2.length) {
        NSUInteger i,iend,j,jend ;
        i= SESStart(ses1); iend= SESEnd(ses1);
        j= SESStart(ses2); jend= SESEnd(ses2);
        while (i < iend && j < jend)
          if (SESIndexN(ses1, &i) != SESIndexN(ses2, &j)) return NO ;
        return YES ;}}
    return NO ;}
  return YES ;
}
BOOL MSInsensitiveEqualStrings(NSString *s1, NSString *s2)
{
  if (s1 != s2) {
    if (s1 && s2) {
      SES ses1 = [s1 stringEnumeratorStructure];
      SES ses2 = [s2 stringEnumeratorStructure];
      NSUInteger len1 = ses1.length ;
      if (len1 == ses2.length) {
        NSUInteger i,iend,j,jend ;
        i= SESStart(ses1); iend= SESEnd(ses1);
        j= SESStart(ses2); jend= SESEnd(ses2);
        while (i < iend && j < jend)
          if (!CUnicharInsensitiveEquals(SESIndexN(ses1,&i),SESIndexN(ses2,&j)))
            return NO ;
        return YES ;}}
    return NO ;}
  return YES ;
}

@implementation NSString (MSAddendum)
static inline NSString *_createStringWithContentsOfUTF8File(NSString *file)
{
	NSMutableData *data = [ALLOC(NSMutableData) initWithContentsOfFile:file] ;
	NSUInteger len = [data length] ;
	MSByte *bytes = (MSByte *)[data bytes] ;
	MSString *ret = nil ;
	
	if (len >= 3 && bytes[0] == 0xef && bytes[1] == 0xbb && bytes[2] == 0xbf) {
		len -= 3 ;
		bytes += 3 ;
	}
	if (len) {
		
		ret = (MSString*)CCreateString(len) ;
		if (!CStringAppendSupposedEncodingBytes((CString *)ret, bytes, len, NSUTF8StringEncoding, NULL)) {
			DESTROY(ret) ;
		}
	}
	
	RELEASE(data) ;
	
	return ret ;
}
+ (NSString *)stringWithContentsOfUTF8File:(NSString *)file { return AUTORELEASE(_createStringWithContentsOfUTF8File(file)) ; }

- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)allowLossyConversion
{
  MSBuffer *buf= nil;
  if (allowLossyConversion || [self canBeConvertedToEncoding:encoding]) {
    NSData *data= [self dataUsingEncoding:encoding allowLossyConversion:YES];
    buf= [MSBuffer bufferWithBytes:[data bytes] length:[data length]];}
  return (const char *)[buf cString];
}
static unichar _slowChai(const void *self, NSUInteger *pos)
{
  return [(NSString*)self characterAtIndex:(*pos)++];
}
- (SES)stringEnumeratorStructure
{
  return MSMakeSES((const void*)self, _slowChai, 0,[self length], 0);
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
    return [self stringWithURLEncoding:NSISOLatin1StringEncoding] ;
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
  return strtof([self UTF8String], NULL);
}

- (double)doubleValue
{
  return strtod([self UTF8String], NULL);
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
+ (void)load          {MSFinishLoadingAddClass(self);}
+ (void)finishLoading {[MSDictionary setVersion:MS_STRING_LAST_VERSION];}

#pragma mark alloc / init

+ (id)new    { return ALLOC(self);}

- (id)init   { return self; }

+ (id)UUIDString
  {
  // TODO: Reimplement
  //CString *x= CCreateStringWithSES([[[NSUUID UUID] UUIDString] stringEnumeratorStructure]);
  //return AUTORELEASE((id)x);
  return nil;
  }
- (void)dealloc
  {
  CStringFreeInside(self);
  [super dealloc];
  }

#pragma mark init

// NEEDED
+ (id)string { return AUTORELEASE(ALLOC(self));}
+ (instancetype)stringWithString:(NSString *)string
{ return AUTORELEASE([ALLOC(self) initWithString:string]); }
+ (instancetype)stringWithCharacters:(const unichar *)characters length:(NSUInteger)length
{ return AUTORELEASE([ALLOC(self) initWithCharacters:characters length:length]); }
+ (instancetype)stringWithUTF8String:(const char *)cstr
{ return AUTORELEASE([ALLOC(self) initWithUTF8String:cstr]); }
+ (instancetype)stringWithCString:(const char *)cstr encoding:(NSStringEncoding)enc
{ return AUTORELEASE([ALLOC(self) initWithCString:cstr encoding:enc]); }

+ (instancetype)stringWithFormat:(NSString *)fmt, ...
{
  MSString *s; va_list vp;
  va_start(vp, fmt);
  s= AUTORELEASE([ALLOC(self) initWithFormat:fmt locale:nil arguments:vp]);
  va_end(vp);
  return s;
}
+ (instancetype)localizedStringWithFormat:(NSString *)fmt, ...
{
  MSString *s; va_list vp;
  va_start(vp, fmt);
  s= AUTORELEASE([ALLOC(self) initWithFormat:fmt locale:nil/* TODO*/ arguments:vp]);
  va_end(vp);
  return s;
}

- (instancetype)initWithString:(NSString *)string
{
  CStringAppendSES((CString*)self, SESFromString(string));
  return self;
}

- (instancetype)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
  CStringAppendBytes((CString*)self, encoding, [data bytes], [data length]/CStringSizeOfCharacterForEncoding(encoding));
  return self;
}
- (instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding
{
  CStringAppendBytes((CString*)self, encoding, bytes, len/CStringSizeOfCharacterForEncoding(encoding));
  return self;
}
- (instancetype)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)flag
{
  CStringAppendBytes((CString*)self, encoding, bytes, len/CStringSizeOfCharacterForEncoding(encoding));
  if (flag) free(bytes);
  return self;
}
- (instancetype)initWithCharacters:(const unichar *)characters length:(NSUInteger)length
{
  CStringAppendBytes((CString*)self, NSUnicodeStringEncoding, characters, length);
  return self;
}
- (instancetype)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)flag
{
  CStringAppendBytes((CString*)self, NSUnicodeStringEncoding, characters, length);
  if (flag) free(characters);
  return self;
}
- (instancetype)initWithCString:(const char *)cstr encoding:(NSStringEncoding)encoding
{
  CStringAppendBytes((CString*)self, encoding, cstr, strlen(cstr));
  return self;
}

- (instancetype)initWithFormat:(NSString *)fmt, ...
{
  va_list args;
  va_start(args, fmt);
  self= [self initWithFormat:fmt locale:nil arguments:args];
  va_end(args);
  return self;
}
- (instancetype)initWithFormat:(NSString *)fmt locale:(id)locale, ...
{
  va_list args;
  va_start(args, locale);
  self= [self initWithFormat:fmt locale:locale arguments:args];
  va_end(args);
  return self;
}
- (instancetype)initWithFormat:(NSString *)fmt arguments:(va_list)args
{ return [self initWithFormat:fmt locale:nil arguments:args]; }
- (instancetype)initWithFormat:(NSString *)fmt locale:(id)locale arguments:(va_list)args
{
  CStringAppendFormatv((CString*)self, [fmt UTF8String], args);
  return self;
}

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

- (NSString *)substringWithRange:(NSRange)range
{
  return AUTORELEASE((id)CCreateStringWithBytes(NSUnicodeStringEncoding, _buf + range.location, range.length));
}

#pragma mark Global methods

- (NSUInteger)hash:(unsigned)depth {return CStringHash(self, depth);}

- (id)copyWithZone:(NSZone*)z // La copie n'est pas mutable TODO: à revoir ? just retain ?
  {
  CString *s= (CString*)MSAllocateObject([MSString class], 0, z);
  CStringAppendString(s, (const CString*)self);
  return (id)s;
  }
- (id)mutableCopyWithZone:(NSZone*)z
  {
  CString *s= (CString*)MSAllocateObject([MSMutableString class], 0, z);
  CStringAppendString(s, (const CString*)self);
  return (id)s;
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
  if (i < SESLength(ses)) {
    CStringAppendCharacter(s, firstChar(SESIndexN(ses, &i)));}
  while (i < SESLength(ses)) {
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

- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding
{
  CBuffer *b= CCreateBufferWithString((CString*)self, encoding);
  AUTORELEASE((MSBuffer*)b);
//NSLog(@"cStringUsingEncoding %lu",encoding);
  return (const char *)CBufferCString(b);
}

- (const char *)UTF8String
{
  return [self cStringUsingEncoding:NSUTF8StringEncoding];
}

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
#pragma mark Path

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

@implementation MSMutableString

+ (id)stringWithCapacity:(NSUInteger)capacity
  {
  id d= MSAllocateObject(self, 0, NULL);
  CStringGrow((CString*)d, capacity);
  return AUTORELEASE(d);
  }

- (id)initWithCapacity:(NSUInteger)capacity
  {
  CStringGrow((CString*)self, capacity);
  return self;
  }

@end
