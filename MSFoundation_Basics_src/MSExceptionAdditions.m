/* MSExceptionAdditions.m
 
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

#import "MSFoundationPrivate_.h"

@implementation NSException (MSAdditions)

+ (void)raise:(NSString *)exceptionName from:(id)object in:(SEL)selector format:(NSString *)format arguments:(va_list)argList
{ MSRaiseFromV(exceptionName, object, selector, format, argList) ; }

+ (void)raise:(NSString *)exceptionName from:(id)object in:(SEL)selector format:(NSString *)format, ...
{
    va_list ap;
    va_start (ap, format);
    MSRaiseFromV(exceptionName, object, selector, format, ap) ;
    va_end(ap) ;
}

@end

void MSRaise(NSString *name, NSString *format, ...)
{
    va_list ap ;
    va_start (ap, format) ;
    MSRaiseV(name, format, ap) ;
    va_end(ap) ;
}

void MSRaiseV(NSString *name, NSString *format, va_list argList)
{ [NSException raise:name format:format arguments:argList] ; }

void MSRaiseFrom(NSString *name, id object, SEL selector, NSString *format, ...)
{
    va_list ap ;
    va_start (ap, format) ;
    MSRaiseFromV(name, object, selector, format, ap) ;
    va_end(ap) ;
}

void MSRaiseFromV(NSString *name, id object, SEL selector, NSString *format, va_list argList)
{
    Class cls = [object class] ;
    format = [NSString stringWithFormat:@"%c [%@ (0x%p) %@] : %@",
        //(ISMETA(cls) ? '+' : '-'), TODO: CLS_META undefined on Win32
        '-',
        NSStringFromClass(cls),
        object,
        NSStringFromSelector(selector),
        format] ;
    MSRaiseV(name, format, argList) ;
}
