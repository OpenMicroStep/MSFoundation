/*
 
 MSStringParsing.m
 
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

//#import "MSBool.h"
//#import "MSStringAdditions.h"
//#import "MSStringEnumeration.h"
//#import "MSUnicodeString.h"
//#import "MSArray.h"
//#import "MSCouple.h"
//#import "MSNaturalArray.h"
//#import "MSStringParsing.h"
//#import "_MSStringParsingPrivate.h"

id MSCreatePropertyListFromString(NSString *str,
								  unsigned mask,
								  NSDictionary *classCorrespondances,
								  unichar (*escapeTransformationFn)(MSByte),
								  id (*analyseFn)(MSString *, unsigned, void *),
								  void *analyseContext
								  )
{
	SES sourceSES = SESFromString(str) ;
	//NS?Log(@"entering MSCreatePropertyListFromString()") ;
    if (SESOK(sourceSES)) {
		NSUInteger len = sourceSES.length;
		
        NEW_POOL ;
        unsigned int pool = 0 ;
        NSUInteger count, pos = 0, ppos, unicodeLength = 0 ;
        unsigned short state, lastState ;
        unichar c, delimitor = 0, c1 = 0, c2 = 0 ;
        MSString *buf = nil ;
        MSMutableArray *array = [[MSMutableArray alloc]initWithCapacity:32 noRetainRelease:YES nilItems:NO] ;
        char *error = NULL ;
        BOOL startingCommentaryWasTested = NO ;
        NSString *futureClassName = nil ;
        _MSPlistContext *context = nil ;
		id retour ;
        
//        if (!escapeTransformationFn) escapeTransformationFn = MSNextstepToUnicode ;
        
        if (!__nulParseValue) { __nulParseValue = RETAIN([NSNull null]) ; }
		
		//NS?Log(@"MSCreatePropertyListFromString() == initialisation done") ;
        //NS?Log(@"source SES.start = %lu", sourceSES.start) ;
        //NS?Log(@"source SES.length = %lu", len) ;
		
        state = lastState = NORMAL ;
        
        while (pos < len) {
            ppos= pos; c = SESIndexN(sourceSES, &ppos) ;
            /*NSLog(@"%08d:==> ppl phase is %d %s Entering state = %s , character is %d ('%@')",
			 (int)pos,
			 (context ? context->phase : 999),
			 (context ? (context->dico ? "[dictionary]" : (context->isNatural ? "[naturals]" : "[array]")) : ""),
			 _states[state],
			 c,
			 [NSString stringWithCharacters:&c length:1]) ;*/
            
            switch (state) {
                case NORMAL:
                    switch (c) {
                        case (unichar)'@':
                            if (ACCEPTS_FIRST(MSPPLParseUserClass /* | MSPPLParseCouple*/) || OBJECT_NOT_KEY) {
                                buf = (MSString*)CCreateString(4) ;
                                if (buf) { state = CLASS_DEFINITION_START ; }
								else STOP_BUF ;
                            }
                            else INVALID_CHARACTER(1) ;
                            break ;
                        case (unichar)'{':
                            if (ACCEPTS_FIRST(MSPPLParseDict) || OBJECT_NOT_KEY) PUSH(NSMutableDictionary)
							else INVALID_CHARACTER(2) ;
                            break ;
                        case (unichar)'(':
                            if (ACCEPTS_FIRST(MSPPLParseArray) || OBJECT_NOT_KEY) PUSH(NSMutableArray)
							else INVALID_CHARACTER(3) ;
                            break ;
                        case (unichar)'[':
							if (ACCEPTS_FIRST(MSPPLParseNaturals) || OBJECT_NOT_KEY) PUSH(MSMutableNaturalArray)
							else INVALID_CHARACTER(4) ;
                            break ;
                        case (unichar)'}':
                            if (SPHASE(0)) PULL
							else INVALID_CHARACTER(5) ;
                            break ;
                        case (unichar)')':
                            if ((APHASE(1) || (APHASE(0) && [context->object count] == 0) || ACOUPLE) && !ANATURAL) PULL
							else INVALID_CHARACTER(6) ;
                            break ;
                        case (unichar)']':
                            if ((APHASE(1) || (APHASE(0) && [context->object count] == 0)) && ANATURAL) PULL
							else INVALID_CHARACTER(7) ;
                            break ;
                        case (unichar)',':
                            if (APHASE(1)) { context->phase = 0 ; }
							else INVALID_CHARACTER(8) ;
                            break ;
                        case (unichar)';':
                            if (SPHASE(3)) { context->phase = 0 ; }
							else INVALID_CHARACTER(9) ;
                            break ;
                        case (unichar)'=':
                            if (SPHASE(1)) { context->phase = 2 ; }
							else INVALID_CHARACTER(10) ;
                            break ;
                        case (unichar)'"': case (unichar)'\'':
                            delimitor = c ;
                            buf = (MSString*)CCreateString(4) ;
							if (buf) { state = STRING_QUOT ; }
							else STOP_BUF ;
                            break ;
                        case (unichar)'/':
                            if (!startingCommentaryWasTested) {
                                lastState = state ; state = PRECOMMENTARY ;
                                break ;
                            }
                            // on va passer en defaut si on venait de tester la presence de commentaire
                        default:
                            if (CUnicharIsSpace(c) || CUnicharIsEOL(c)) { break ; } // les espaces ne comptent pas en regime normal de meme que les fins de ligne
                            if (SPHASE(0) || SPHASE(2) || APHASE(0)) {
                                // lecture d'une chaine de caracteres sans double quote (ni simple quote) autour
                                state = STRING_NORM ;
                                buf = (MSString*)CCreateString(4) ;
								if (buf) { MSSAddUnichar(buf, c) ; }
								else STOP_BUF ;
                            }
                            else INVALID_CHARACTER(11) ;
                            break ;
                    }
                    startingCommentaryWasTested = NO ;
                    break ;
                case PRECOMMENTARY:
                    if (c == (unichar)'/') { state = COMMENTARY ; }
                    else if (c == (unichar)'*') { state = MCOMMENTARY ; }
                    else {
                        // c'etait la continuation d'un etat precedent normal
                        startingCommentaryWasTested = YES ;
                        pos -= 2 ; // on depile pour revenir a l'etat precedent
                        state = lastState ;
                    }
                    break ;
                case MCOMMENTARY:
                    if (c == (unichar)'*') { state = MCOMMENTARY2 ; }
                    break ;
                case MCOMMENTARY2:
                    if (c == (unichar)'/') { state = lastState ; startingCommentaryWasTested = NO ; }
                    else { state = MCOMMENTARY ; }
                    break ;
                case COMMENTARY:
                    if (CUnicharIsEOL(c)) { pos-- ; state = lastState ; startingCommentaryWasTested = NO ; }
                    break ;
                case STRING_QUOT:
                    if (c == (unichar)'\\') { state = ESCAPE ; }
                    else if (c == delimitor) {
						error = _MSDealWithRetainedObject(context, &buf, &state) ;
						if (error) STOP(error)
					}
                    else { MSSAddUnichar(buf, c) ; }
                    break ;
                case ESCAPE:
                    switch (c) {
                        case (unichar)'0': case (unichar)'1': case (unichar)'2': case (unichar)'3':
                            c1 = c ;
                            state = ESCAPE_DIGIT1 ;
                            break ;
                        case (unichar)'n':
                            MSSAddUnichar(buf, (unichar)'\n') ;
                            state = STRING_QUOT ;
                            break ;
                        case (unichar)'t' :
                            MSSAddUnichar(buf, (unichar)'\t') ;
                            state = STRING_QUOT ;
                            break ;
                        case (unichar)'r':
                            MSSAddUnichar(buf, (unichar)'\r') ;
                            state = STRING_QUOT ;
                            break ;
                        case  (unichar)'U':
                            // on va aller decoder de l'unicode
                            unicodeLength = 0 ;
                            c1 = 0 ;
                            state = UNICODE_DIGITS ;
                            break ;
                        default:
                            MSSAddUnichar(buf, c) ;
                            state = STRING_QUOT ;
                            break ;
                    }
                    break ;
                case UNICODE_DIGITS:
                    if      (c >= (unichar)'0' && c <= (unichar)'9') { c1 = (unichar)( (c1 << 3) + c - (unichar)'0'      ); unicodeLength++ ; }
                    else if (c >= (unichar)'A' && c <= (unichar)'F') { c1 = (unichar)( (c1 << 3) + c - (unichar)'A' + 10 ); unicodeLength++ ; }
                    else if (c >= (unichar)'a' && c <= (unichar)'f') { c1 = (unichar)( (c1 << 3) + c - (unichar)'a' + 10 ); unicodeLength++ ; }
                    else {
                        // si on a un pb, on insere juste le grand U puisqu'il y avait un antislash devant
                        MSSAddUnichar(buf, (unichar)'U') ;
                        pos -= unicodeLength ; // et on revient en arriere de ce qu'on avait decode
                        state = STRING_QUOT ;
                        break ;
                    }
                    if (unicodeLength == 4) {
                        MSSAddUnichar(buf, c1) ;
                        state = STRING_QUOT ;
                    }
                    break ;
                case ESCAPE_DIGIT1:
                    if (c >= (unichar)'0' && c <= (unichar)'7') { c2 = c ; state = ESCAPE_DIGIT2 ;}
                    else {
                        MSSAddUnichar(buf, (c1 == (unichar)'0' ? (unichar)0 : c1)) ; ;
                        pos -- ;
                        state = STRING_QUOT ;
                    }
                    break ;
                case ESCAPE_DIGIT2:
                    if (c >= (unichar)'0' && c <= (unichar)'7') {
                        MSSAddUnichar(buf, escapeTransformationFn((((c1-(unichar)'0') << 6) + ((c2-(unichar)'0') << 3) + (c-(unichar)'0')) & 0xff)) ;
                    }
                    else {
                        MSSAddUnichar(buf, c1) ;
                        MSSAddUnichar(buf, c2) ;
                        pos -- ;
                    }
                    state = STRING_QUOT ;
                    break ;
                case STRING_NORM:
                    switch (c) {
                        case (unichar)'(': case (unichar)'{': case (unichar)'[': case (unichar)'@':
                        case (unichar)']': // on ne peut pas trouver de chaines dans un tableau de naturals
                        case (unichar) '"': case (unichar)'\'':
                            STOP("Invalid p-list control character found in string") ;
                            break ;
                        case (unichar)')': case (unichar)'}': case (unichar)',': case (unichar)';': case (unichar)'=':
                            error = _MSDealWithNormalString(context, mask, &buf, &state, analyseFn, analyseContext) ;
                            if (error) STOP(error)
							else { pos -- ; }
                            break ;
                        case (unichar)'/':
                            if (!startingCommentaryWasTested) { lastState = state ; state = PRECOMMENTARY ; break ; }
                            // on continue sur le case suivant car on venait deja de tester la presence d'un commentaire
                        default:
                            if (CUnicharIsSpace(c) || CUnicharIsEOL(c)) {
                                error = _MSDealWithNormalString(context, mask, &buf, &state, analyseFn, analyseContext) ;
                                if (error) STOP(error) ;
                            }
                            else { MSSAddUnichar(buf, c) ; }
                            break ;
                    }
                    startingCommentaryWasTested = NO ;
                    break ;
                case CLASS_DEFINITION_START:
                    if (CUnicharIsLetter(c) || c == (unichar)'_') {
                        if (ACCEPTS_FIRST(MSPPLParseUserClass) || OBJECT_NOT_KEY) {
                            MSSAddUnichar(buf, c) ;
                            state = CLASS_DEFINITION ;
                        }
                        else STOP("Tryng to make a non-accepted class parsing") ;
                    }
                    else if (c == (unichar)'(') {
						// a thing like @(x, y) is a couple
						if (ACCEPTS_FIRST(MSPPLParseCouple) || OBJECT_NOT_KEY) {
							PUSH(MSMutableCouple)
							state = NORMAL ;
							DESTROY(buf) ;
						}
						else STOP("Tryng to make a non-accepted couple parsing")
                    }
                    else STOP("Invalid character found at start of class name")
					break ;
                case CLASS_DEFINITION:
                    if (CUnicharIsLetter(c) || c == (unichar)'_' || CUnicharIsIsoDigit(c)) { MSSAddUnichar(buf, c) ; }
                    else if (c == (unichar)'{' || c == (unichar)'(') {
                        if (c == (unichar)'{') PUSH(NSMutableDictionary) else PUSH(NSMutableArray) ;
                        
                        futureClassName = [__privateClassCorrespondances objectForKey:buf] ;
                        if (!futureClassName) futureClassName = [classCorrespondances objectForKey:buf] ;
                        
                        if (futureClassName) context->futureClass = ([futureClassName length] ? NSClassFromString(buf) : Nil) ;
                        else context->futureClass = NSClassFromString(buf) ;
                        
                        state = NORMAL ;
                        DESTROY(buf) ;
                    }
                    else STOP("Invalid character found in class name") ;
                    break ;
                    
            }
            pos ++ ;
        }
 		//NS?Log(@"MSCreatePropertyListFromString() == analysis done") ;
       
        if (state != NORMAL || pool != 0) STOP("Non terminated p-list") ;
        retour = RETAIN(context->object) ;
        DESTROY(array) ;
		KILL_POOL ;
        return retour ;
		/*******************
		 HM remark: the new compiler is vicious.
		 in the precedent version we did return context->object 
		 and it crashes randomly (about half of the time).
		 By using an intermediary var, it works. I don't know why !!!!!!!!
		 *******************/
    }
    return nil ;
}



@implementation _MSPlistContext
- (void)dealloc { DESTROY(object) ; DESTROY(key) ; [super dealloc] ; }
@end

@implementation NSObject (MSPPLParsing)
- (id)initWithPPLParsedObject:(id)anObject { NSLog(@"*** ERROR *** : want to init with PPL parsed object '%@'", anObject) ; RELEASE(self) ; return nil ; }
@end


@implementation NSString (MSPPPLParsing)

- (NSMutableDictionary *)dictionaryValue
{ return AUTORELEASE(MSCreatePropertyListFromString(self, MSPPLParseDict | MSPPLDecodeAll, nil, NULL, NULL, NULL)) ; }

- (NSMutableArray *)arrayValue
{ return AUTORELEASE(MSCreatePropertyListFromString(self, MSPPLParseArray | MSPPLDecodeAll, nil, NULL, NULL, NULL)) ; }

- (NSMutableDictionary *)stringsDictionaryValue
{ return AUTORELEASE(MSCreatePropertyListFromString(self, MSPPLParseDict, nil, NULL, NULL, NULL)) ; }

- (NSMutableArray *)stringsArrayValue
{ return AUTORELEASE(MSCreatePropertyListFromString(self, MSPPLParseArray, nil, NULL, NULL, NULL)) ; }

@end

