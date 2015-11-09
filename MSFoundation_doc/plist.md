# plist parser

See `MSStringParsing.h`

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