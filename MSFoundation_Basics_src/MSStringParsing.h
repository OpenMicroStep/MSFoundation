/*
 
 MSStringParsing.h
 
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
 
 WARNING : this header file cannot be included alone, please direclty
 include <MSFoundation/MSFoundation.h>
 */

#define MSPPLParseArray       0x00000001
#define MSPPLParseDict        0x00000002
#define MSPPLParseUserClass   0x00000004
#define MSPPLParseNaturals    0x00000008
#define MSPPLParseCouple      0x00000010
#define MSPPLParseData        0x00000020
#define MSPPLParseAll         0x00000fff

#define MSPPLDecodeNull       0x00010000
#define MSPPLDecodeInteger    0x00020000
#define MSPPLDecodeUnsigned   0x00040000
#define MSPPLDecodeBoolean    0x00080000
#define MSPPLDecodeOthers     0x00100000
#define MSPPLDecodeAll        0x00fff000

#define MSPPLStrictMode       0x01000000
#define MSPPLOptionsAll       0xff000000

#define MSPPLApplePlist       MSPPLParseArray | MSPPLParseDict | MSPPLParseData | MSPPLStrictMode

/**
 # plist parser
 
 ## Classic plist format
 
 ### Array
 
 () // empty array
 (value1, value2) // simple array
 (value1, value2, value3,) // simple array with ',' at the end is still acceptable
 
 In a plist array, a value can be any plist type (ie. array, dictionary, data, string, ...)
 
 ### Dictionary
 
 {} // empty dictionary
 { key1 = value1; key2 = value2; } // simple dictionary
 
 In a plist dictionary, keys must follow the plist string format.
 A value can be any plist type (ie. array, dictionary, data, string, ...)
 
 ### Data
 
 <0a 2b 3C4D5e6F> // simple data
 
 In a plist data, the binary value is encoded in hexadecimal.
 The hexadecimal value is case insensitive and spaces are allowed.
 
 ### String
 
 asciistringvalue // string value without quotes
 "My String Value" // quoted string value
 "\"My quoted string value\"" // quoted string value with quotes in it
 "\r\n\t\u0064 \U0068" // string value with some specific chars (CR, LF, TAB, unicode)
 
 A plist string can be declared using two different format
 - without quotes, then only digits (0-9), letters (A-Z, a-z) and '_' characters are allowed
 - with quotes, then much complex strings are possible.
 The following sequences of characters allow to define complex values
 - `\r` is replaced by a CR character
 - `\n` is replaced by a LF character
 - `\t` is replaced by a TAB character
 - `\uXXXX` or `\UXXXX` is replaced by the UTF16 characters with the XXXX value
 
 ## Extensions to the standard plist format
 
 ### String
 
 '''This extension should be removed or simplified'''
 
 String values without quotes can contains a wider range of characters.
 Any character that is not one of the following is accepted :
 (){}[]@',;=/ \r\n
 
 ### User class
 
 @classname { key1 = value1; key2 = value2; } // user class initialized with a dictionary
 @classname (value1, value2) // user class initialised with an array
 
 This allow object decoded in the plist to be directly in a usefull type.
 Once parsed, the message `initWithPPLParsedObject:` is sent to a newly allocated object of class `classname`.
 
 ### Couple
 
 @(value1, value2) // couple
 
 ### Natural array
 
 [] // empty natural array
 [1, 2, 3, 4, 5] // simple natural array
 [1, 2, 3, 4, 5,6,] // natural array with ',' at the end is still valid
 

 **/

@interface NSString (MSPPPLParsing)

- (NSMutableDictionary *)dictionaryValue ;
- (NSMutableArray *)arrayValue ;
- (NSMutableDictionary *)stringsDictionaryValue ;
- (NSMutableArray *)stringsArrayValue ;

@end
