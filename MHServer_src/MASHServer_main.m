/*
 
 MASHServer_main.m
 
 This file is is a part of the MicroStep Application Server over Http Application.
 
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
 
 A Special homage to Steve Jobs who permits the Objective-C technology
 to meet the world. Without him, this years-long work should not have
 been existing at all. Thank you Steve and rest in peace.
 
 */

#import <MSNode/MSNode.h>

static id apps;
static void MASHServerInit(void *arg)
{
  NSString *error= nil;
  CDictionary* d= (CDictionary*)arg;
  NSDictionary *parameters= CDictionaryObjectForKey(d, @"parameters");
  NSString *path= CDictionaryObjectForKey(d, @"path");
  apps= [[MSHttpApplication applicationsWithParameters:parameters withPath:path error:&error] retain];
  if (error) {
    NSLog(@"Error while starting: %@", error);}
  RELEASE(d);
}
int main(int argc, const char * argv[])
{ 
  NEW_POOL;
  NSDictionary *parameters= nil; NSString *parametersPath= nil; int ret= 1;
  if (argc > 1) {
    parametersPath = [NSString stringWithUTF8String:argv[1]];}
  else {
    NSLog(@"Configuration path is expected at the first argument"); }
  if (parametersPath) {
    parameters= [NSDictionary dictionaryWithContentsOfFile:parametersPath];}
  if (parameters) {
    CDictionary* d= CCreateDictionary(0);
    CDictionarySetObjectForKey(d, parameters, @"parameters");
    CDictionarySetObjectForKey(d, [parametersPath stringByDeletingLastPathComponent], @"path");
    ret= MSNodeStart(MASHServerInit, d);
    RELEASE(apps);}
  else {
    NSLog(@"Unable to load configuration at path: %s", argv[1]); }
  KILL_POOL;
  return ret;
}
