/*
 
 _MSStringBooleanAdditionsPrivate.h
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 Frederic Olivi : fred.olivi@free.fr
 
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
 
 WARNING : this header file IS PRIVATE, please direclty
 include <MSFoundation/MSFoundation.h>
 */
//#import "MSStringAdditions.h"
//#import "MSStringEnumeration.h"

#define _BOOLEAN_START_		0
#define _BOOLEAN_END_		1
#define _BOOLEAN_S_			2
#define _BOOLEAN_Y_			3
#define _BOOLEAN_YES_		4
#define _BOOLEAN_O_			5
#define _BOOLEAN_OUI_		6
#define _BOOLEAN_T_			7
#define _BOOLEAN_TRU_		8
#define _BOOLEAN_TRUE_		9
#define _BOOLEAN_V_			10
#define _BOOLEAN_VRA_		11
#define _BOOLEAN_VRAI_		12
#define _BOOLEAN_0DIGIT_	13
#define _BOOLEAN_NDIGIT_	14
#define _BBN_     			15

// blank characters make us stay on initial state
#define _BDG_				_BOOLEAN_NDIGIT_
#define _BLK_				_BOOLEAN_START_

static BOOL __booleanFinals[16] = { NO, YES, NO, YES, NO, YES, NO, NO, NO, NO, NO, NO, NO, NO, YES, NO } ;

// avoid a switch and much more faster
static unsigned char __booleanStart[256] = {
    /* 00 */ _BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BLK_,_BLK_,_BBN_,_BBN_,_BLK_,_BBN_,_BBN_,
    /* 10 */ _BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,
    /* 20 */ _BLK_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,
    /* 30 */ _BOOLEAN_0DIGIT_,_BDG_,_BDG_,_BDG_,_BDG_,_BDG_,_BDG_,_BDG_,_BDG_,_BDG_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,
    /* 40 */ _BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BOOLEAN_O_,
    /* 50 */ _BBN_,_BBN_,_BBN_,_BOOLEAN_S_,_BOOLEAN_T_,_BBN_,_BOOLEAN_V_,_BBN_,_BBN_,_BOOLEAN_Y_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,
    /* 60 */ _BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BOOLEAN_O_,
    /* 70 */ _BBN_,_BBN_,_BBN_,_BOOLEAN_S_,_BOOLEAN_T_,_BBN_,_BOOLEAN_V_,_BBN_,_BBN_,_BOOLEAN_Y_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,
    /* 80 */ _BLK_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,
    /* 90 */ _BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,
    /* A0 */ _BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,
    /* B0 */ _BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,
    /* C0 */ _BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,
    /* D0 */ _BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,
    /* E0 */ _BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,
    /* F0 */ _BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_,_BBN_
} ;

/*
 TO DO : a _MSScanBoolean string which also recognize NO, FALSE, FAUX, FALSH, ....
 */

static inline BOOL _MSStringIsTrue(NSString *self, SES ses, CUnicharChecker stopAtCharacter, NSUInteger *endPosition)
{
    unsigned char state = _BOOLEAN_START_ ;
	NSUInteger i = ses.start, j, len = ses.length ; unichar c ;

    while (i < len) {
        j= i; c = SESIndexN(ses, &j) ;

        switch (state) {
            case _BOOLEAN_START_:
                if (c <= 256) { 
					state = __booleanStart[c] ; 
					if (state == _BBN_) {
						if (endPosition) *endPosition = i ;
						return NO ; 
					}
				}
                else if (!stopAtCharacter(c)) { 
					if (endPosition) *endPosition = i ;
					return NO ; 
				}
                break ;
            case _BOOLEAN_0DIGIT_:
                // POTENTIAL FINAL STATE
                if (c == 0x0030) { break ; } // leading zeros don't count here 
                else if (c > 0x0030 && c <= 0x0039) { state = _BOOLEAN_NDIGIT_ ; break ; }
				if (endPosition) *endPosition = i ;
                return NO ;
            case _BOOLEAN_NDIGIT_:
                if (c >= 0x0030 && c <= 0x0039) { break ; }
                else if (stopAtCharacter(c)) { state = _BOOLEAN_END_ ; break ; }
				if (endPosition) *endPosition = i ;
                return NO ;
            case _BOOLEAN_END_:
                // POTENTIAL FINAL STATE
                if (!stopAtCharacter(c)) { 
					if (endPosition) *endPosition = i ;
					return NO ; 
				}
                break ;
            case _BOOLEAN_S_:
                if ((c & 0x00df) == 'I') { state = _BOOLEAN_END_ ; break ; }
				if (endPosition) *endPosition = i ;
                return NO ;
            case _BOOLEAN_Y_:
                // POTENTIAL FINAL STATE
                if ((c & 0x00df) == 'A') { state = _BOOLEAN_END_ ; break ; }
                else if ((c & 0x00df) == 'E') { state = _BOOLEAN_YES_ ; break ; }
                else if (stopAtCharacter(c)) { state = _BOOLEAN_END_ ; break ;}
				if (endPosition) *endPosition = i ;
                return NO ;
            case _BOOLEAN_YES_:
                if ((c & 0x00df) == 'S') { state = _BOOLEAN_END_ ; break ; }
				if (endPosition) *endPosition = i ;
                return NO ;
            case _BOOLEAN_O_:
                // POTENTIAL FINAL STATE
                if ((c & 0x00df) == 'U') { state = _BOOLEAN_OUI_ ; break ; }
                else if ((c & 0x00df) == 'K') { state = _BOOLEAN_END_ ; break ; }
                else if (stopAtCharacter(c)) { state = _BOOLEAN_END_ ; break ; }
				if (endPosition) *endPosition = i ;
                return NO ;
            case _BOOLEAN_OUI_:
                if ((c & 0x00df) ==  'I') { state = _BOOLEAN_END_ ; break ; }
				if (endPosition) *endPosition = i ;
                return NO ;
            case _BOOLEAN_T_:
                if ((c & 0x00df) == 'R') { state = _BOOLEAN_TRU_ ; break ; }
				if (endPosition) *endPosition = i ;
                return NO ;
            case _BOOLEAN_TRU_:
                if ((c & 0x00df) == 'U') { state = _BOOLEAN_TRUE_ ; break ; }
				if (endPosition) *endPosition = i ;
                return NO ;
            case _BOOLEAN_TRUE_:
                if ((c & 0x00df) == 'E') { state = _BOOLEAN_END_ ; break ; }
				if (endPosition) *endPosition = i ;
                return NO ;
            case _BOOLEAN_V_:
                if ((c & 0x00df) == 'R') { state = _BOOLEAN_VRA_ ; break ; }
				if (endPosition) *endPosition = i ;
                return NO ;
            case _BOOLEAN_VRA_:
                if ((c & 0x00df) == 'A') { state = _BOOLEAN_VRAI_ ; break ; }
				if (endPosition) *endPosition = i ;
                return NO ;
            case _BOOLEAN_VRAI_:
                if ((c & 0x00df) == 'I') { state = _BOOLEAN_END_ ; break ; }
				if (endPosition) *endPosition = i ;
                return NO ;
        }
        i= j ;
    }
	if (endPosition) *endPosition = i ;
    return __booleanFinals[state] ;
}

