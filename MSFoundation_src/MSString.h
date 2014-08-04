/*   MSString.h
 
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

#define SESFromString(X)    ({ __typeof__(X) __x = (X) ; (__x ? [__x stringEnumeratorStructure] : MSInvalidSES) ; })
MSExport BOOL MSStringIsTrue(NSString *s);
MSExport BOOL MSEqualStrings(NSString *s1, NSString *s2);
MSExport BOOL MSInsensitiveEqualStrings(NSString *s1, NSString *s2);
MSExport NSRange MSStringFind(NSString *source, NSString *searched) ;
MSExport NSString *MSTrimAt(NSString *source, NSUInteger position, NSUInteger length, CUnicharChecker matchingSolidChar) ;

@interface NSString (MSAddendum)
+ (NSString *)stringWithContentsOfUTF8File:(NSString *)file;
- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)allowLossyConversion;
- (SES)stringEnumeratorStructure;
- (NSMutableString *)replaceOccurrencesOfString:(NSString *)tag withString:(NSString *)replace;
- (BOOL)isTrue;
- (NSString *)mid:(NSUInteger)position;
- (NSString *)mid:(NSUInteger)position :(NSUInteger)length;
- (NSString *)left:(NSUInteger)length ;
- (NSString *)trim;
- (NSString *)substringBeforeString:(NSString *)string ;
- (NSString *)substringAfterString:(NSString *)string;
- (BOOL)containsString:(NSString *)anotherString;
- (const char *)asciiCString;
// In MSString (MSNetAddedum) ?
- (BOOL)hasExtension:(NSString*)ext;
- (NSString *)stringWithURLEncoding:(NSStringEncoding)conversionEncoding;
- (NSString *)stringWithURLEncoding;
- (NSString *)stringByAppendingURLComponent:(NSString *)urlComponent ;
- (NSString *)stringByDeletingLastURLComponent;
- (NSString *)decodedURLString ;

- (NSString *)htmlRepresentation; // also converts HTML marks
- (NSString *)htmlRepresentation:(BOOL)convertsHTMLMarks ;
@end

@interface MSString : NSString
{
@private
  unichar*   _buf;
  NSUInteger _length;
  NSUInteger _size;
}
- (SES)stringEnumeratorStructure;
- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding;
- (const char *)UTF8String;
@end

@interface MSMutableString : MSString
{
@private
}
+ (id)stringWithCapacity:(NSUInteger)capacity;
- (id)initWithCapacity:(NSUInteger)capacity;
@end

#define MSCreateString(S) (MSString*)MCSCreate(S)
