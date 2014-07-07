/*
 
 _MSStringParsingPrivate.h
 
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
 
 WARNING : a great part of content of this file comes from the Unicode fundation,
 you are invited to check what licence really covers this file
 */

//
//   _MSPListParsing_private.h
//
//  Copyright (c) 1998-2005 Herve MALAINGRE. All rights reserved.
//

static NSDictionary *__privateClassCorrespondances = nil ;

// liste des etats de l'automate de reconnaissance des PLIST
#define NORMAL				0
#define STRING_NORM			1
#define ESCAPE				2
#define STRING_QUOT			3
#define PRECOMMENTARY			4
#define COMMENTARY			5
#define ESCAPE_DIGIT1			6
#define ESCAPE_DIGIT2			7
#define MCOMMENTARY				8
#define MCOMMENTARY2			9
#define CLASS_DEFINITION_START	10
#define CLASS_DEFINITION		11
#define UNICODE_DIGITS			12

static char *_states[13] = {
    "inter-token corpus",
    "simple string",
    "escape sequence in string",
    "quoted string",
    "beginning of commentary",
    "single-line commentary",
    "octal escape",
    "end of octal escape",
    "multi-line commentary",
    "end of multi-line commentary",
    "class name",
    "class definition",
    "unicode escape"
} ;

@interface _MSPlistContext : NSObject
{
@public
    Class futureClass ;
    id object ;
    id key ;
    unsigned phase ;
    BOOL dico ;
    BOOL isNatural ;
	BOOL isCouple ;	// OK : we did make the couple a standard class
}
@end

static inline _MSPlistContext *_MSCreatePListContextWithRetainedObject(id o)
{
    _MSPlistContext *ctx = [_MSPlistContext new] ;
    ctx->object = o ; // deja retenu
    ctx->dico = [o isKindOfClass:[NSDictionary class]] ;
    if (!ctx->dico) {
		ctx->isNatural = NO; //ecb [o isKindOfClass:[MSNaturalArray class]] ;
		if (!ctx->isNatural) ctx->isCouple = [o isKindOfClass:[MSMutableCouple class]] ;
	}
    return ctx ;
}

#define ACCEPTS_FIRST(X)        (!context && (mask & (X)))
#define PHASE(X)	(!context || !context->dico || (context->dico && context->phase == (X)))
#define SPHASE(X)	(context && context->dico && context->phase == (X))
#define APHASE(X)	(context && !context->dico && context->phase == (X))
#define ANATURAL	(context && context->isNatural)
#define ACOUPLE		(context && context->isCouple && context->phase == 1)

#define OBJECT_NOT_KEY          ((!context || SPHASE(2) || APHASE(0)) && !ANATURAL)


#define PUSH(X)		{ id o = NEW(X) ; context = _MSCreatePListContextWithRetainedObject(o) ; [array addObject:context] ; pool ++ ; }



static inline char *_MSDealWithRetainedObject(_MSPlistContext *context, id *objectptr, unsigned short *stateptr)
{
	char *err = NULL ;
	//NS?Log(@"Deal with retained object : '%@'", *objectptr) ;
	if (SPHASE(0)) { context->key = *objectptr ; }
    else if (SPHASE(2)) {
        [(NSMutableDictionary*)context->object setObject:*objectptr forKey:context->key] ;
        RELEASE(*objectptr) ;
        RELEASE(context->key) ; context->key = nil ;
    }
    else {
		if (context->isCouple && [context->object secondMember]) {
			err =  "impossible to add more than two objects in a couple" ;
		}
		else {
			[context->object addObject:*objectptr] ;
		}
        RELEASE(*objectptr) ;
    }
    context->phase ++ ;
    *stateptr = NORMAL ;
    *objectptr = nil ;
	return err ;
}

static inline char *_MSDealWithNotKeyObject(_MSPlistContext *context, id object, unsigned short *stateptr)
{
	char *err = NULL ;
    if (SPHASE(2)) {
        [(NSMutableDictionary*)context->object setObject:object forKey:context->key] ;
        RELEASE(context->key) ; context->key = nil ;
    }
    else {
		if (context->isCouple && [context->object secondMember]) {
			err =  "impossible to add more than two objects in a couple" ;
		}
		else {
			[context->object addObject:object] ;
		}
    }
    context->phase ++ ;
    *stateptr = NORMAL ;
	return err ;
}

static id __nulParseValue = nil ;

static inline BOOL _MSGetNumber(NSString *s, SES initialSES, NSUInteger position, NSUInteger length, BOOL acceptsNegative, long long stopValue,
								long long *result, NSUInteger *endPosition)
{
    if (s && length) {
        MSLong a ;
		SES ses = initialSES, ret ;
		ses.start = position ;
		ses.length = length ;
        
		ret = SESExtractInteger(ses, (acceptsNegative ? -stopValue : 0), stopValue, (CUnicharChecker)CUnicharIsSpace, &a) ;
		if (SESOK(ret)) {
            //NS?Log(@"interpretation on range %lld-%lld", (long long)ret.start, (long long)ret.length) ;
            //NS?Log(@"result = %lld", a) ;
            if (result) *result = (long long)a ;
			if (endPosition) { *endPosition = ret.start + ret.length ; }
			return YES ;
		}
		//else { NSLog(@"Impossible to interpret %@ value as a number", s) ; }
	}
	return NO ;
}



static inline char *_MSDealWithNormalString(_MSPlistContext *context,
                                            unsigned mask,
                                            MSString **bufptr,
                                            unsigned short *stateptr,
                                            id (*analyseFn)(MSString *, unsigned, void *),
                                            void *analyseContext)
{
    MSString *buf = *bufptr ;
    char *err = NULL ;
	SES initialSES = SESFromString(buf) ;
	NSUInteger blen = initialSES.length ;
	
#define MSGetNumber(STR, POS, LEN, AN, SV, RES, ENP) _MSGetNumber(STR, initialSES, POS, LEN, AN, SV, RES, ENP)
    
    if (ANATURAL) {
        long long n = 0 ;
		//NS?Log(@"Want to scan natural in buffer : <%@>", buf) ;
        if (MSGetNumber(buf, 0, 0xffffffff, NO, (long long)0xffffffff, &n, NULL)) {
			[context->object addNatural:(NSUInteger)n] ;
        }
        else { err = "Impossible to scan the unsigned value intended to be inserted in a natural array" ; }
		context->phase ++ ;
		*stateptr = NORMAL ;
        RELEASE(buf) ; *bufptr = nil ;
    }
    else if (!SPHASE(0)) {
        // TO DO : transformer les chaines que l'on a a comparer en buffer unicode et comparer directement de buffer a buffer ...
        // TO DO : ajouter le decodage des NSData a partir d'une sous classe de NSData (MSBuffer)
        // TO DO : ajouter le decodage des floats et/ou des doubles des qu'on aura une methode du type scanFloat: ou scanDouble:
        // on est dans le cas ou l'on est pas la clef d'un dictionnaire
        id value = nil ;
        long long number = 0 ;
		NSUInteger endPos = 0 ;
        //NS?Log(@"Want to decode : '%@'", buf) ;
        if ((mask & MSPPLDecodeNull) &&
			(MSInsensitiveEqualStrings(buf, @"*NULL*") || MSInsensitiveEqualStrings(buf, @"NULL") || MSInsensitiveEqualStrings(buf, @"NIL") || MSInsensitiveEqualStrings(buf, @"*NIL*"))) {
            err = _MSDealWithNotKeyObject(context, __nulParseValue, stateptr) ;
        }
        else if ((mask & MSPPLDecodeBoolean) &&
				 (MSInsensitiveEqualStrings(buf, @"Y") || MSInsensitiveEqualStrings(buf, @"YES") || MSInsensitiveEqualStrings(buf, @"TRUE"))) {
            err = _MSDealWithNotKeyObject(context, MSTrue, stateptr) ;
            RELEASE(buf) ; *bufptr = nil ;
        }
        else if ((mask & MSPPLDecodeBoolean) &&
                 (MSInsensitiveEqualStrings(buf, @"N") || MSInsensitiveEqualStrings(buf, @"NO") || MSInsensitiveEqualStrings(buf, @"FALSE"))) {
            err = _MSDealWithNotKeyObject(context, MSFalse, stateptr) ;
            RELEASE(buf) ; *bufptr = nil ;
        }
        else if ((mask & MSPPLDecodeUnsigned) && MSGetNumber(buf, 0, 0xffffffff, NO, (long long)0xffffffff, &number, &endPos) && (endPos == blen || CUnicharIsSpace(MSSIndex(buf, endPos)))) {
			//NS?Log(@"Parsed unsigned number : %u", (unsigned int)number) ;
            err = _MSDealWithNotKeyObject(context, [NSNumber numberWithUnsignedInt:(unsigned int)number], stateptr) ;
            RELEASE(buf) ; *bufptr = nil ;
        }
        else if ((mask & MSPPLDecodeInteger) && MSGetNumber(buf, 0, 0xffffffff, YES, (long long)0x7fffffff, &number, &endPos) && (endPos == blen || CUnicharIsSpace(MSSIndex(buf, endPos)))) {
			//NS?Log(@"Parsed integer number : %d", (int)number) ;
            err = _MSDealWithNotKeyObject(context, [NSNumber numberWithInt:(int)number], stateptr) ;
            RELEASE(buf) ; *bufptr = nil ;
        }
        else if (analyseFn && (mask & MSPPLDecodeOthers) && (value = analyseFn(buf, mask, analyseContext))) {
            // avec ca on pourra essayer de reconnaitre tout ce que l'on veut de plus, il suffit de passer un pointeur sur fonction
            err = _MSDealWithNotKeyObject(context, value, stateptr) ;
            RELEASE(buf) ; *bufptr = nil ;
        }
        else {
			err = _MSDealWithRetainedObject(context, bufptr, stateptr) ;
		}
    }
    else {
        long long number = 0 ;
		NSUInteger endPos = 0 ;
        id localBuf = nil ;
        if ((mask & MSPPLDecodeUnsigned) && MSGetNumber(buf, 0, 0xffffffff, NO, (long long)0xffffffff, &number, &endPos) && (endPos == blen || CUnicharIsSpace(MSSIndex(buf, endPos)))) {
			//NS?Log(@"Parsed unsigned number key : %u", (unsigned int)number) ;
            localBuf = [NSNumber numberWithUnsignedInt:(unsigned int)number] ;
            RELEASE(buf) ;
        }
        else if ((mask & MSPPLDecodeInteger) && MSGetNumber(buf, 0, 0xffffffff, YES, (long long)0x7fffffff, &number, &endPos) && (endPos == blen || CUnicharIsSpace(MSSIndex(buf, endPos)))) {
			//NS?Log(@"Parsed integer number key : %d", (int)number) ;
            localBuf = [NSNumber numberWithInt:(int)number] ;
            RELEASE(buf) ;
        }
        //else { NS?Log(@"Parsed key %@ with mask 0x%08x, %d, %d, %lld, %lld", buf, mask & MSPPLDecodeUnsigned, MSGetNumber(buf, 0, 0xffffffff, NO, (long long)0xffffffff, &number, NULL), number & 0xffff, (long long)endPos, (long long)blen) ; }
        context->key = (localBuf ? [localBuf retain] : *bufptr) ;
        context->phase ++ ;
        *stateptr = NORMAL ;
        *bufptr = nil ;
        err = NULL ;

	}
    
    return err ;
}

#define STOP_BUF	{ \
	printf("Plist parsing error due to unicode buffer allocation error in state %s\n", _states[state]) ; fflush(stdout) ;\
	DESTROY(array) ; \
	KILL_POOL ; \
	return nil ; \
}

//
#define STOP(X)		{ \
	const char *converted ; \
	NSUInteger p = pos, pc , ppi ; \
	printf("Plist parsing error in %s : %s\n", _states[state], (X)) ; \
	while (p-- > 0) { ppi= p; if (CUnicharIsEOL(SESIndexN(sourceSES, &ppi))) { p++ ; break ; } } \
	pc = p ; \
	while (pc < pos) {\
    ppi= pc;\
		if (SESIndexN(sourceSES, &ppi) == (unichar)'\t') { printf("\t") ; } else { printf(" ") ; }\
		pc++ ;\
	} ;\
	printf("v---- error is here\n") ; \
	converted = [[str mid:p :256] asciiCString]; \
	printf("%s\n", converted) ; fflush(stdout) ; \
	DESTROY(array) ; DESTROY(buf) ; \
	KILL_POOL ; \
	return nil ; \
}
/*
static inline void STOP(char *msg, unsigned int pos, char **states, int state,SES sourceSES,id str)		{
	const char *converted ;
	NSUInteger p = pos, pc , ppi ;
	printf("Plist parsing error in %s : %s\n", states[state], msg) ;
	while (p-- > 0) { ppi= p; if (CUnicharIsEOL(SESIndexN(sourceSES, &ppi))) { p++ ; break ; } }
	pc = p ;
	while (pc < pos) {
    ppi= pc;
		if (SESIndexN(sourceSES, &ppi) == (unichar)'\t') { printf("\t") ; } else { printf(" ") ; }
		pc++ ;
	} ;
	printf("v---- error is here\n") ;
	converted = [[str mid:p :256] asciiCString];
	printf("%s\n", converted) ; fflush(stdout) ;
	DESTROY(array) ; DESTROY(buf) ;
	KILL_POOL ;
	return nil ;
}
*/
#define INVALID_CHARACTER(NB)   { char msg[64] ; sprintf(msg, "Invalid character 0x%04x ('%c') found - #%d", c, (CUnicharIsPrintable(c) && c <= 255 ? (char)c : (char)'_'), NB) ; STOP(msg) ; }
//STOP(msg,pos,_states, state,sourceSES)
// dans le pull on retire le dernier objet de l'array en mettant uniquement sont pointeur a nil
// et en changeant le count. Dans les faits, la variable fin se retrouve avec ce dernier objet en retain
#define PULL {\
	pool -- ; \
	if ((count = MSACount(array)) > 1) { \
		_MSPlistContext *fin = MSAIndex(array, count - 1) ;\
		id cls = (id)(fin->futureClass) ; \
		id toAdd =  nil ; \
		((CArray*)array)->pointers[count - 1] = nil ; \
		((CArray*)array)->count -- ; \
		context = MSAIndex(array, count - 2) ; \
		context->phase ++ ; \
		if (cls) { toAdd = [ALLOC(cls) initWithPPLParsedObject:fin->object] ; } \
		else { toAdd = fin->object ; fin->object = nil ; } \
		if (toAdd) { \
			if (context->dico) { [(NSMutableDictionary*)context->object setObject:toAdd forKey:context->key] ; } \
			else { [context->object addObject:toAdd] ; }\
			DESTROY(toAdd) ; \
		} \
		DESTROY(fin) ;\
	}\
}

