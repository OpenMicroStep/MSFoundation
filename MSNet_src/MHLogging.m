/*
 
 MHLogging.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Geoffrey Guilbon : gguilbon@gmail.com
 
 
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

#define LOG_HEADER_SIZE 128
#define MAX_APPNAME_LENGTH 16

#import "_MASHPrivate.h"

@implementation MHLogging

+ (id)loggingWithFile:(NSString *)path
{
    return [[ALLOC(self) initLoggingWithFile:path] autorelease] ;
}

+ (id)newLoggingWithFile:(NSString *)path
{
    return [ALLOC(self) initLoggingWithFile:path] ;
}

- (id)initLoggingWithFile:(NSString *)path
{
    if ((self = [super init]))
    {
        //open log file
        _logFile = [NSFileHandle fileHandleForUpdatingAtPath:path] ;
        if(!_logFile)
        {
#ifdef WO451
            [@"" writeToFile:path atomically:YES] ;
#else
            [@"" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil] ;
#endif
            _logFile = [NSFileHandle fileHandleForUpdatingAtPath:path] ;
        }
        
        [_logFile retain] ;
        
        if (_logFile == nil)
        {
            NSLog(@"Logging : Failed to open file at path '%@'", path);
            return nil ;
        }
        
        // put the file pointer at the end of the file
        NS_DURING
        [_logFile seekToEndOfFile] ;
        NS_HANDLER
        if (_logFile == nil)
        {
            NSLog(@"Logging : Failed to seek end of file at path '%@'", path);
            return nil ;
        }
        NS_ENDHANDLER
        
        //sets up lock
        mutex_init(_lock) ;
        
        //default mode : outputs in the file
        _mode = (MSUShort)MHFileMode ;
        
        //default log mode
        _logLevel = MHLogWarning ;
        
        //set date format
        ASSIGN(_dateFormat,@"%Y-%m-%d %H:%M:%S.%F");
        
    }
        
    return self ;
}

- (void)dealloc
{
    [_logFile closeFile] ;
    DESTROY(_logFile) ;
    DESTROY(_dateFormat) ;
    mutex_delete(_lock) ;
    [super dealloc] ;
}

- (void)logWithLevel:(MHLogLevel)level application:(NSString *)application log:(NSString *)format args:(va_list)args
{
    NSUInteger appLength = [application length] ;
    NSString *appLogName = nil ;
    
    if((level >= _logLevel) && [format length] && appLength && _mode)
    {
        NSString *log ;
            
        log = [ALLOC(NSString) initWithFormat:format arguments:args] ;
        
        if([log length])
        {
            NSString *finalLog = nil ;
            NSString *dateStr = [[NSCalendarDate date] descriptionWithCalendarFormat:_dateFormat] ;
            NSString *levelStr = NULL;

            switch (level) {
                case MHLogDevel    : levelStr = @"DEVEL   " ; break ;
                case MHLogDebug    : levelStr = @"DEBUG   " ; break ;
                case MHLogInfo     : levelStr = @"INFO    " ; break ;
                case MHLogWarning  : levelStr = @"WARNING " ; break ;
                case MHLogError    : levelStr = @"ERROR   " ; break ;
                case MHLogCritical : levelStr = @"CRITICAL" ; break ;
            }
            
            //format application name
            if(appLength < MAX_APPNAME_LENGTH)
            {
#ifdef WO451
                NSString *padding = @"" ;
                int paddingSize = MAX_APPNAME_LENGTH - appLength ;
                int i ;
                for(i=0; i<paddingSize; i++) padding = [padding stringByAppendingString:@" "] ;
                appLogName = [application stringByAppendingString:padding] ; 
#else
                appLogName = [application stringByPaddingToLength:MAX_APPNAME_LENGTH withString:@" " startingAtIndex:0] ; 
#endif
            }
            else if (appLength > MAX_APPNAME_LENGTH)
            {
                appLogName = [application substringToIndex:MAX_APPNAME_LENGTH] ;
            }
            else
            {
                appLogName = application ;
            }

            //create log string
            finalLog = [NSString stringWithFormat:@"%@ - %@ - %@ - [%10u] - %@\n", dateStr, appLogName, levelStr, thread_id(), log] ;

            //write to stdout and/or file
            mutex_lock(_lock) ;
            if(_mode & (MSByte)MHScreenMode) //print to screen
            {
#ifdef WO451
                fprintf(stdout,"%s",[finalLog cStringUsingEncoding:NSWindowsCP1252StringEncoding allowLossyConversion:YES]) ;
#else
                fprintf(stdout,"%s",[finalLog UTF8String]) ;
#endif
                fflush(stdout);
            }
            if(_mode & (MSByte)MHFileMode)   //print to file
            {
#ifdef WO451
                [_logFile writeData:[finalLog dataUsingEncoding:NSWindowsCP1252StringEncoding allowLossyConversion:YES] ] ;
#else
                [_logFile writeData:[finalLog dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]] ;
#endif
            }
            mutex_unlock(_lock) ;
        }
        RELEASE(log) ;
    }
}

- (void)setLogMode:(MHLogMode)mode enabled:(BOOL)enabled
{
    if(enabled)
    {
        mutex_lock(_lock) ;
        _mode |= (MSByte)mode ;
        mutex_unlock(_lock) ;
    }
    else
    {
        mutex_lock(_lock) ;
        _mode &= ~(MSByte)mode ;
        mutex_unlock(_lock) ;
    }
}

- (void)setLogLevel:(MHLogLevel)level
{
    mutex_lock(_lock) ;
    _logLevel = level ;
    mutex_unlock(_lock) ;
}

- (MHLogLevel)logLevel
{
    return _logLevel ;
}

@end
