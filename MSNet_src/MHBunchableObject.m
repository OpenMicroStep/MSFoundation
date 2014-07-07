/*
 
 MHBunchableObject.m
 
 This file is is a part of the MicroStep Application Server over Http Framework.
 
 Initial copyright LOGITUD Solutions (logitud@logitud.fr) since 2012
 
 Herve Malaingre : herve@malaingre.com
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 
 
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
#import "MSNet_Private.h"

#define  DEFAULT_BUNCH_SIZE 64

@implementation MHBunchableObject

- (id)allocWithZone:(NSZone *)zone
{
    //an instance of MHBunchableObject can not be directly allocated -> use the appropriate function ie. CNotificationCreate CHTTPMessageCreate
	return [self notImplemented:_cmd] ;
}

- (id)new
{
    //an instance of MHBunchableObject can not be directly allocated -> use the appropriate function ie. CNotificationCreate CHTTPMessageCreate
	return [self notImplemented:_cmd] ;
}

- (id)autorelease
{
    //an instance of MHBunchableObject can not be autoreleased
	return self ;
}

- (id)retain {
    _localRetainCount++ ;
    return self ; 
}

#ifdef WIN32
- (MSUInt)retainCount { return _localRetainCount ; }
#else
- (NSUInteger)retainCount { return (NSUInteger)_localRetainCount ; }
#endif

- (oneway void)release
{
    if(_localRetainCount) _localRetainCount-- ;
     
    if (!_localRetainCount) {
        //when releasing an instance of MHBunchableObject, we advertise its bunch that it can forget the instance
        //in order to free the bunch when all its objects will be released
        removeObjectFromBunch(((CBunch *)_private), self) ;
    }
    /* Warning! No call to [super release] */
}

- (void)dealloc {if (0) [super dealloc];} // No warning. Deallocation will be done by the bunch of this instance

+ (MSUShort)defaultBunchSize
{
    return DEFAULT_BUNCH_SIZE ;
}

@end
