//
//  _MHPostProcessingDelegate.m
//  MSFoundation
//
//  Created by Geoffrey Guilbon on 21/01/13.
//
//

#import "MSNet_Private.h"
//#import <MSFoundation/MSSystemLayer.h>

#define STR2UTF8BUF(X,Y) MSBAddData(X, [Y dataUsingEncoding:NSUTF8StringEncoding])

#ifdef WIN32
#define STR2INIBUF(X,Y) MSBAddData(X, [Y dataUsingEncoding:NSISOLatin1StringEncoding])
#else
#define STR2INIBUF(X,Y) STR2UTF8BUF(X,Y)
#endif

@implementation MHPostProcessingDelegate


- (BOOL)_launchExternalExecutable:(NSString *)executable withArgs:(NSArray *)args successValue:(int)successValue
{
    NSTask *task;
    int status ;
    
    NS_DURING
    task = [[NSTask alloc] init] ;
    [task setLaunchPath:executable] ;
    [task setArguments:args] ;
    
    [task launch] ;
    [task waitUntilExit] ;
    
    status = [task terminationStatus] ;
    NS_HANDLER
    return NO ;
    NS_ENDHANDLER
    
    return (status == successValue) ;
}

- (void)_writeHTMLHeaderFromPostProc:(NSDictionary *)postProc
               usingFieldsDefinition:(NSDictionary *)fieldsDefinition
                           andValues:(NSDictionary *)values
                      forApplication:(MHApplication *)app
                               toBuf:(MSBuffer *)buf
{
    NSString *formTitle , *head, *formAction ;
    
    formAction = [app postProcessingURL] ;
    formTitle = [postProc objectForKey:@"formTitle"] ;
    head = [NSString stringWithFormat:@"<html>\n <body>\n  <form action=/%@>\n   <h1>%@</h1>\n",
            formAction,
            [formTitle length] ? formTitle : @""
            ] ;
    
    STR2UTF8BUF(buf, head) ;
}

- (void)_writeHTMLFooterFromPostProc:(MHResource *)postProc
                            andInput:(MHResource *)input
                           andOutput:(MHResource **)output
               usingFieldsDefinition:(NSDictionary *)fieldsDefinition
                           andValues:(NSDictionary *)values
                               toBuf:(MSBuffer *)buf
{
    NSString *field ;
    
    //input field
    field = [NSString stringWithFormat:@"   <input type=\"hidden\" id=\"input\" name=\"input\" value=\"%@\">\n",
                   [input url]] ;
    STR2UTF8BUF(buf, field) ;
    
    
    //input field
    field = [NSString stringWithFormat:@"   <input type=\"hidden\" id=\"postproc\" name=\"postproc\" value=\"%@\">\n",
             [postProc url]] ;
    STR2UTF8BUF(buf, field) ;
    
    //submit button
    field = @"   <p align=\"left\"><input type=\"submit\" value=\"Ok\"></p>\n" ;
    STR2UTF8BUF(buf, field) ;
    
    field = @"  </form>\n </body>\n</html>\n" ;
    STR2UTF8BUF(buf, field) ;
    
    //javascript to open file
    field = [NSString stringWithFormat:@"  <script language=\"javascript\">window.open('/%@','_blank','',true);</script>\n",
             [*output url]
             ] ;
    STR2UTF8BUF(buf, field) ;
}

- (void)_writeHTMLCheckBoxField:(NSDictionary *)field usingFieldDefinition:(NSDictionary *)fieldDef andValues:(NSDictionary *)values toBuf:(MSBuffer *)buf
{
    NSString *fieldID, *htmlField, *fieldLabel ;
    BOOL checked = NO ;
        
    //get html field name
    fieldID = [field objectForKey:@"fieldID"] ;
    if(![fieldID length]) fieldID = @"" ;
    
    fieldLabel = [fieldDef objectForKey:@"label"] ;
    fieldLabel = ([fieldLabel length]) ? [fieldLabel htmlRepresentation] : @"" ;
    
    //get value by priority : (high priority) 1:post 2:postproc default 3:configfile default (less priority)
    if([values objectForKey:fieldID])
    {
        checked = MSStringIsTrue([values objectForKey:fieldID]) ;
    }
    else if([field objectForKey:@"default"])
    {
        checked = MSStringIsTrue([field objectForKey:@"default"]) ;
    }
    else if([fieldDef objectForKey:@"default"])
    {
        checked = MSStringIsTrue([fieldDef objectForKey:@"default"]) ;
    }
    
    htmlField = [NSString stringWithFormat:@"    <input type=\"hidden\" name=\"%@\" value=\"0\"/><input type=\"checkbox\" name=\"%@\" value=\"1\" %@/> <label>%@</label><br />\n",
                 fieldID,
                 fieldID,
                 checked ? @"checked" : @"",
                 fieldLabel
                 ] ;
    
    /*htmlField = [NSString stringWithFormat:@"    <input type=\"checkbox\" name=\"%@\" id=\"%@\" %@ /> <label>%@</label><br />\n",
                 fieldID,
                 fieldID,
                 checked ? @"checked" : @"",
                 fieldLabel
                 ] ;
     */
    
    STR2UTF8BUF(buf, htmlField) ;
}

- (void)_writeHTMLComboField:(NSDictionary *)field usingFieldDefinition:(NSDictionary *)fieldDef andValues:(NSDictionary *)values toBuf:(MSBuffer *)buf
{
    NSString *fieldID, *fieldLabel;
    NSString *fieldValue = @"" ;
    NSString *comboHeader, *comboFooter ;
    NSArray *valuesArray = [fieldDef objectForKey:@"values"] ;
    NSEnumerator *e = [valuesArray objectEnumerator] ;
    NSArray *namesArray = [fieldDef objectForKey:@"names"] ;
    MSUInt namesArrayCount = (MSUInt)[namesArray count] ;
    NSString *currentValue, *currentValueName = nil ;
    NSString *option ;
    BOOL selected ;
    unsigned int i = 0 ;
        
    //get html field name
    fieldID = [field objectForKey:@"fieldID"] ;
    if(![fieldID length]) fieldID = @"" ;
    
    fieldLabel = [fieldDef objectForKey:@"label"] ;
    fieldLabel = ([fieldLabel length]) ? [fieldLabel htmlRepresentation] : @"" ;
    
    //get value by priority : (high priority) 1:post 2:postproc default 3:configfile default (less priority)
    if([[values objectForKey:fieldID] length])
    {
        fieldValue = [values objectForKey:fieldID] ;
    }
    else if([[field objectForKey:@"default"] length])
    {
        fieldValue = [field objectForKey:@"default"] ;
    }
    else if([[fieldDef objectForKey:@"default"] length])
    {
        fieldValue = [fieldDef objectForKey:@"default"] ;
    }
    fieldValue = [fieldValue htmlRepresentation] ;
    
    comboHeader = [NSString stringWithFormat:@"    <label for=\"%@\">%@:</label>\n     <select id=\"%@\" name=\"%@\">\n",
                    fieldLabel, fieldLabel, fieldID, fieldID] ;
    
    comboFooter = @"    </select><br>\n" ;
    
    
    STR2UTF8BUF(buf, comboHeader) ;

    while((currentValue = [[e nextObject] htmlRepresentation]))
    {
        if(namesArrayCount && i<namesArrayCount) //get name option if names specified, else value is used
        {
            currentValueName = [namesArray objectAtIndex:i] ;
        }else
        {
            currentValueName = nil ;
        }
        
        selected = NO ;
        if([currentValue isEqualToString:fieldValue])
        {
            selected = YES ;
        }
        
        option = [NSString stringWithFormat:@"    <option %@ value=\"%@\">%@</option>\n",
                  selected ? @"selected" : @"" ,
                  currentValue,
                  currentValueName ? currentValueName : currentValue
                  ] ;
        STR2UTF8BUF(buf, option) ;
        i++ ;
    }
    
    STR2UTF8BUF(buf, comboFooter) ;
}

- (void)_writeHTMLTextField:(NSDictionary *)field usingFieldDefinition:(NSDictionary *)fieldDef andValues:(NSDictionary *)values hidden:(BOOL)hidden toBuf:(MSBuffer *)buf
{
    NSString *fieldID, *htmlField, *fieldLabel;
    NSString *fieldValue = @"" ;
    
    //get html field name
    fieldID = [field objectForKey:@"fieldID"] ;
    if(![fieldID length]) fieldID = @"" ;
    
    fieldLabel = [fieldDef objectForKey:@"label"] ;
    if([fieldLabel length] && !hidden)
    {
        fieldLabel = [NSString stringWithFormat:@"<label>%@: </label>", [fieldLabel htmlRepresentation]] ;
    }
    else
    {
        fieldLabel = @"" ;
    }
        
    
    //get value by priority : (high priority) 1:post 2:postproc default 3:configfile default (less priority)
    if([[values objectForKey:fieldID] length])
    {
        fieldValue = [values objectForKey:fieldID] ;
    }
    else if([[field objectForKey:@"default"] length])
    {
        fieldValue = [field objectForKey:@"default"] ;
    }
    else if([[fieldDef objectForKey:@"default"] length])
    {
        fieldValue = [fieldDef objectForKey:@"default"] ;
    }
    
    htmlField = [NSString stringWithFormat:@"    %@<input type=\"%@\" id=\"%@\" value=\"%@\">%@\n",
                 fieldLabel,
                 hidden ? @"hidden" : @"text",
                 fieldID,
                 [fieldValue htmlRepresentation],
                 hidden ? @"" : @"<br>"
                 ] ;
    
    STR2UTF8BUF(buf, htmlField) ;
}

- (void)_writeHTMLField:(NSDictionary *)field usingFieldsDefinition:(NSDictionary *)fieldsDefinition andValues:(NSDictionary *)values toBuf:(MSBuffer *)buf
{
    NSString *fieldID, *fieldType ;
    NSDictionary *fieldDef ;
    
    fieldID = [field objectForKey:@"fieldID"] ;

    if(fieldID)
    {
        fieldDef = [fieldsDefinition objectForKey:fieldID] ;

        if(fieldDef)
        {
            BOOL isHidden = ([field objectForKey:@"hidden"] || [fieldDef objectForKey:@"hidden"]) ? YES : NO ;
            fieldType = [fieldDef objectForKey:@"type"] ;
            
            if(isHidden)
            {
                [self _writeHTMLTextField:field usingFieldDefinition:fieldDef andValues:values hidden:YES toBuf:buf] ;
            }
            else
            {
                if([@"checkbox" isEqualToString:fieldType])
                {
                    [self _writeHTMLCheckBoxField:field usingFieldDefinition:fieldDef andValues:values toBuf:buf] ;
                }
                else if([@"list" isEqualToString:fieldType])
                {
                    [self _writeHTMLComboField:field usingFieldDefinition:fieldDef andValues:values toBuf:buf] ;
                }
                else if([@"text" isEqualToString:fieldType])
                {
                    [self _writeHTMLTextField:field usingFieldDefinition:fieldDef andValues:values hidden:isHidden toBuf:buf] ;
                }
            }
        }
    }
}

- (void)_writeHTMLFieldSet:(NSDictionary *)fieldSet usingFieldsDefinition:(NSDictionary *)fieldsDefinition andValues:(NSDictionary *)values toBuf:(MSBuffer *)buf
{
    NSString *fieldSetStart, *fieldSetEnd, *fieldSetTitle ;
    NSArray *fields = [fieldSet objectForKey:@"fields"] ;
    NSEnumerator *e = [fields objectEnumerator] ;
    NSDictionary *currentField = nil ;
    
    fieldSetTitle = [fieldSet objectForKey:@"fieldSetTitle"] ;
    fieldSetStart = [NSString stringWithFormat:@"   <fieldset>\n    <legend>%@</legend>\n    <p>\n", [fieldSetTitle length] ? fieldSetTitle : @""] ;
    fieldSetEnd = @"    </p>\n   </fieldset>\n" ;
    
    STR2UTF8BUF(buf, fieldSetStart) ;
    
    while((currentField = [e nextObject]))
    {
        [self _writeHTMLField:currentField usingFieldsDefinition:fieldsDefinition andValues:values toBuf:buf] ;
    }
    
    STR2UTF8BUF(buf, fieldSetEnd) ;
}

- (void) _writeINIHeaderFromPostProc:(NSDictionary *)postProcDic toBuf:(MSBuffer *)buf
{
    NSString *header, *type = [postProcDic objectForKey:@"planningType"] ;
    if(!type) type = @"";
    
    header = [NSString stringWithFormat:@"[%@]\r\n",type] ;
    
    STR2UTF8BUF(buf, header) ;
}

- (BOOL)_buildConfigPage:(MHResource **)ini
            fromPostProc:(MHResource *)postProc
                andInput:(MHResource *)input
               andOutput:(MHResource **)output
   usingFieldsdefinition:(NSDictionary *)fieldsDefinition
               andValues:(NSDictionary *)values
          forApplication:(MHApplication *)application
{
    NSDictionary *postProcDic = [NSDictionary dictionaryWithContentsOfFile:[postProc resourcePathOndisk]] ;
    NSArray *fieldSets = [postProcDic objectForKey:@"fieldsets"] ;
    NSEnumerator *fse = [fieldSets objectEnumerator] ;
    NSDictionary *currentFieldSet, *currentField ;
    MSBuffer *buf = AUTORELEASE(MSCreateBuffer(1024));
    
    //create header
    [self _writeINIHeaderFromPostProc:postProcDic toBuf:buf] ;
    
    //iterate fieldsets and generate ini parameters
    while((currentFieldSet = [fse nextObject]))
    {
        NSEnumerator *fe = [[currentFieldSet objectForKey:@"fields" ] objectEnumerator] ;
        NSString *fieldID, *fieldParamName, *iniParam, *fieldValue = nil ;
        NSDictionary *fieldDef ;
        
        while ((currentField = [fe nextObject]))
        {
            fieldID = [currentField objectForKey:@"fieldID"] ;
            
            if([fieldID length])
            {
                fieldDef = [fieldsDefinition objectForKey:fieldID] ;
                fieldParamName = [fieldDef objectForKey:@"paramName"] ;

                if([fieldParamName length])
                {
                    //get value by priority : (high priority) 1:post 2:postproc default 3:configfile default (less priority)
                    
                    if([[values objectForKey:fieldID] isSignificant])
                    {
                        fieldValue = [values objectForKey:fieldID] ;
                    }
                    else if([[currentField objectForKey:@"default"] isSignificant])
                    {
                        fieldValue = [currentField objectForKey:@"default"] ;
                    }
                    else if([[fieldDef objectForKey:@"default"] isSignificant])
                    {
                        fieldValue = [fieldDef objectForKey:@"default"] ;
                    }
                    
                    if([fieldValue isSignificant])
                    {

                        if(MSInsensitiveEqualStrings(fieldValue, @"YES") || MSEqualStrings(fieldValue, @"1") || MSInsensitiveEqualStrings(fieldValue, @"on"))
                        {
                            fieldValue = @"1" ;
                        }
                        else if(MSInsensitiveEqualStrings(fieldValue, @"NO") || MSEqualStrings(fieldValue, @"0"))
                        {
                            fieldValue = @"0" ;
                        }
                        
                        //write in ini file PARAM=VALUE
                        iniParam = [NSString stringWithFormat:@"%@=%@\r\n",fieldParamName, fieldValue] ;
                        STR2INIBUF(buf, iniParam) ;
                    }
                }
            }
        }
    }
    STR2INIBUF(buf, @"\r\n") ;
    
    *ini = [MHDownloadResource resourceWithBuffer:buf
                                      name:@"config.ini"
                                  mimeType:nil
                            forApplication:application] ;
    
    return YES ;
}

- (BOOL)_buildHTMLPage:(MHResource **)html
          fromPostProc:(MHResource *)postProc
              andInput:(MHResource *)input
             andOutput:(MHResource **)output
 usingFieldsdefinition:(NSDictionary *)fieldsDefinition
             andValues:(NSDictionary *)values
        forApplication:(MHApplication *)application
{
    NSDictionary *postProcDic = [NSDictionary dictionaryWithContentsOfFile:[postProc resourcePathOndisk]] ;
    NSArray *fieldSets = [postProcDic objectForKey:@"fieldsets"] ;
    NSEnumerator *e = [fieldSets objectEnumerator] ;
    NSDictionary *currentFieldSet ;
    MSBuffer *buf = AUTORELEASE(MSCreateBuffer(1024));
    
    //create header
    [self _writeHTMLHeaderFromPostProc:postProcDic
                 usingFieldsDefinition:fieldsDefinition
                             andValues:values
                        forApplication:[input application]
                                 toBuf:buf] ;
    
    //iterate fieldsets
    while((currentFieldSet = [e nextObject]))
    {
        [self _writeHTMLFieldSet:currentFieldSet usingFieldsDefinition:fieldsDefinition andValues:values toBuf:buf] ;
    }

    //create footer
    [self _writeHTMLFooterFromPostProc:postProc
                              andInput:input
                             andOutput:output
                 usingFieldsDefinition:fieldsDefinition
                             andValues:values
                                 toBuf:buf] ;
    
    //convert NSString to NSData
    *html = [MHDownloadResource resourceWithBuffer:buf
                                      name:@"configPage.html"
                                  mimeType:@"html"
                            forApplication:application] ;

    return YES ;
}

/*
 * three steps :
 * 1 - postProc + exeDefinitions => ini file
 * 2 - pgm + ini => pdf
 * 2 - postProc + exeDefinitions + pgm + pdf => html
 */
- (BOOL)postProcessInput:(MHDownloadResource *)input
          withParameters:(MHDownloadResource *)parameters //postProc
        toOutputResource:(MHDownloadResource **)output
 andToOutputHTMLResource:(MHDownloadResource **)html
usingExternalExecutablesDefinitions:(NSDictionary *)exeDefinitions
            postedValues:(NSDictionary *)values
{
    MHDownloadResource *configPage ;
    NSDictionary *postProc = nil ;
    NSDictionary *exeInfo = nil ;
    NSString *exeName = nil ;
    NSString *outputExtension = nil ;
    NSString *outputName = nil ;
    NSString *outputPath = nil ;
    BOOL success = NO ;
    
    if(! [parameters isCachedOnDisk])
    {
        MSRaise(NSInternalInconsistencyException, @"postProcess : parameters resource '%@' not cached on disk", [parameters name]) ;
    }
    
    if(! [input isCachedOnDisk])
    {
        MSRaise(NSInternalInconsistencyException, @"postProcess : input resource '%@' not cached on disk", [input name]) ;
    }
    
    //load and read config file
    postProc = [NSDictionary dictionaryWithContentsOfFile:[parameters resourcePathOndisk]] ;
    if(postProc)
    {
        //get executable informations definition
        exeName = [postProc objectForKey:@"externalExecutable"] ;
        exeInfo = [exeDefinitions objectForKey:exeName] ;
    }else
    {
        MSRaise(NSGenericException, @"postProcess : cannot find reliable information in postproc file") ;
    }
    
    // Step 1
    //generate ini and returns it in 'configPage' parameter
    [self _buildConfigPage:&configPage
              fromPostProc:parameters
                  andInput:input
                 andOutput:output
     usingFieldsdefinition:[exeInfo objectForKey:@"fields"]
                 andValues:values
            forApplication:[input application]] ;
    
    //cache ini file to disk
    MHPrepareAndCacheResource(configPage, nil, YES, MHRESOURCE_SHORT_LIFETIME, YES)  ;
    
    // Step 2
    if(exeInfo)
    {
        NSString *executable = [exeInfo objectForKey:@"path"] ;
        int successValue = [[exeInfo objectForKey:@"successValue"] intValue] ;
        NSDictionary *exeParams = [exeInfo objectForKey:@"parameters"] ;
        MSArray *args = AUTORELEASE(MSCreateArray(1)) ;
        BOOL isDir = NO ;
        
        outputPath = MHMakeTemporaryFileName() ;
        //add parameters to lauch post processing
        if([[exeParams objectForKey:@"inputFile"] length]) MSAAdd(args, [exeParams objectForKey:@"inputFile"]) ;
        MSAAdd(args, [input resourcePathOndisk]) ;
        if([[exeParams objectForKey:@"confFile"] length]) MSAAdd(args, [exeParams objectForKey:@"confFile"]) ;
        MSAAdd(args, [configPage resourcePathOndisk])  ;
        if([[exeParams objectForKey:@"outputFile"] length]) MSAAdd(args, [exeParams objectForKey:@"outputFile"]) ;
        MSAAdd(args, outputPath) ;

#ifdef WIN32
        if (!MSFileExistsAtPath(executable, &isDir) || !isDir) executable = MSFindDLL(executable);
#else 
#warning TODO MSFindDLL under other OS
        isDir = NO ;
#endif
        
        success = [self _launchExternalExecutable:executable withArgs:args successValue:successValue] ;
    }else
    {
        MSRaise(NSGenericException, @"postProcess : cannot find reliable information in configuration file") ;
    }
    
    //Step 3
    if(success)
    {
        outputExtension = [exeInfo objectForKey:@"outputExtension"] ;
        outputName = [[[input name] stringByDeletingPathExtension] stringByAppendingPathExtension:outputExtension] ;
        
        *output = [MHDownloadResource resourceWithContentsOfFile:outputPath
                                                            name:outputName
                                                        mimeType:nil
                                                  forApplication:[input application]
                                               deleteFileOnClean:YES] ;
        //resource loaded to memory, delete file
        if(! MSDeleteFile(outputPath))
        {
            MHServerLogWithLevel(MHLogError, @"postProcess : could not delete temporary output file %@", outputPath) ;
        }
        
        MHPrepareAndCacheResource(*output, nil, YES, MHRESOURCE_SHORT_LIFETIME, NO)  ;
                
        //generate html and returns it in '(MHResource **)html' parameter
        [self _buildHTMLPage:html
                fromPostProc:parameters
                    andInput:input
                   andOutput:output
       usingFieldsdefinition:[exeInfo objectForKey:@"fields"]
                   andValues:values
              forApplication:[input application]] ;
        
        MHPrepareAndCacheResource(*html, nil, YES, MHRESOURCE_SHORT_LIFETIME, NO)  ;
                
    }else
    {
        MSRaise(NSGenericException, @"postProcessInput : external executable failed") ;
    }
    
    return YES;
}

@end
