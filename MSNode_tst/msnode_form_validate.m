#import "msnode_validate.h"


static BOOL _test_formFieldHandler_reject(MSHttpFormParser *parser, int idx, NSString *name, NSString *value, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT(test, NO, "formField event should not had been fired");
  return YES;
}
static BOOL _test_formFileHeaderHandler_reject(MSHttpFormParser *parser, int idx, NSString *name, NSString *value, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT(test, NO, "formFileHeader event should not had been fired");
  return YES;
}
static BOOL _test_formFileChunkHandler_reject(MSHttpFormParser *parser, int idx, const MSByte *bytes, NSUInteger length, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT(test, NO, "formFileChunk event should not had been fired");
  return YES;
}

static NSString *convertUncFromUrl(NSString *url)
{
    NSData *s= [url dataUsingEncoding:NSUTF8StringEncoding];
    SES ses= MSMakeSES([s bytes], utf8URIStringChaiN, utf8URIStringChaiP, 0, [s length], 0);
    return AUTORELEASE(CCreateStringWithSES(ses));
}

static BOOL _test_formFieldHandler(MSHttpFormParser *parser, int idx, NSString *name, NSString *value, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  if (*args[1].i1Ptr == 0) {
    TASSERT_EQUALS_LLD(test, idx, 0);
    TASSERT_EQUALS_OBJ(test, name, @"Name");
    TASSERT_EQUALS_OBJ(test, value, @"Gareth Wylie");
  }
  else if (*args[1].i1Ptr == 1) {
    TASSERT_EQUALS_LLD(test, idx, 1);
    TASSERT_EQUALS_OBJ(test, name, @"Age");
    TASSERT_EQUALS_OBJ(test, value, @"24");
  }
  else if (*args[1].i1Ptr == 2) {
    TASSERT_EQUALS_LLD(test, idx, 2);
    TASSERT_EQUALS_OBJ(test, name, @"!For mula!");
    TASSERT_EQUALS_OBJ(test, value, @"a + b == 13%!");
  }
  else {
    TASSERT(test, NO, "formField event should not had been fired more than 3 times");
  }
  ++(*args[1].i1Ptr);
  return YES;
}
static void form_urlencoded(test_t *test)
{
  NEW_POOL;
  MSHttpFormParser *parser; char pass;

  TASSERT_EQUALS_OBJ(test, convertUncFromUrl(@"%C3%A9C%3A%5CUsers%5CPublic%5CPictures%5CSample%20Pictures%5CD%C3%A9sert.jpg"), @"éC:\\Users\\Public\\Pictures\\Sample Pictures\\Désert.jpg");

  parser= [ALLOC(MSHttpFormParser) initWithUrlEncoded];
  pass= 0;
  [parser addOnFieldHandler:_test_formFieldHandler args:2, MSMakeHandlerArg(test), MSMakeHandlerArg(&pass)];
  [parser addOnFileHeaderHandler:_test_formFileHeaderHandler_reject args:1, MSMakeHandlerArg(test)];
  [parser addOnFileChunkHandler:_test_formFileChunkHandler_reject args:1, MSMakeHandlerArg(test)];
  TASSERT_EQUALS_LLD(test, pass, 0);
  [parser writeData:[MSBuffer bufferWithCString:"Name=Gareth+Wylie&Age=24&%21For%20mula%21=a+%2B+b+%3D%3D+13%25%21"]];
  [parser writeEnd];
  TASSERT_EQUALS_LLD(test, pass, 3);
  RELEASE(parser);

  parser= [ALLOC(MSHttpFormParser) initWithUrlEncoded];
  pass= 0;
  [parser addOnFieldHandler:_test_formFieldHandler args:2, MSMakeHandlerArg(test), MSMakeHandlerArg(&pass)];
  [parser addOnFileHeaderHandler:_test_formFileHeaderHandler_reject args:1, MSMakeHandlerArg(test)];
  [parser addOnFileChunkHandler:_test_formFileChunkHandler_reject args:1, MSMakeHandlerArg(test)];
  TASSERT_EQUALS_LLD(test, pass, 0);
  [parser writeData:[MSBuffer bufferWithCString:"Name=Gareth+Wylie"]];
  [parser writeData:[MSBuffer bufferWithCString:"&Age=24&%2"]];
  [parser writeData:[MSBuffer bufferWithCString:"1For%20mu"]];
  [parser writeData:[MSBuffer bufferWithCString:"la%21=a+%2B+b+%3"]];
  [parser writeData:[MSBuffer bufferWithCString:"D%3D+13%25%2"]];
  [parser writeData:[MSBuffer bufferWithCString:"1"]];
  [parser writeEnd];
  TASSERT_EQUALS_LLD(test, pass, 3);
  RELEASE(parser);

  KILL_POOL;
}

static const char _formData[]=
"--AaB03x\r\n"
"Content-Disposition: form-data; name=\"submit-name\"\r\n"
"\r\n"
"Larry\r\n"
"--AaB03x\r\n"
"Content-Disposition: form-data; name=\"files\"\r\n"
"Content-Type: multipart/mixed; boundary=BbC04y\r\n"
"\r\n"
"--BbC04y\r\n"
"Content-Disposition: file; filename=\"file1.txt\"\r\n"
"Content-Type: text/plain\r\n"
"\r\n"
"... contents of file1.txt ...\r\n"
"--BbC04y\r\n"
"Content-Disposition: file; filename=\"file2.gif\"\r\n"
"Content-Type: image/gif\r\n"
"Content-Transfer-Encoding: binary\r\n"
"\r\n"
"...contents of file2.gif...\r\n"
"--BbC04y--\r\n"
"--AaB03x--\r\n";
static const char _formDataPart2[] =
"--BbC04y\r\n"
"Content-Disposition: file; filename=\"file1.txt\"\r\n"
"Content-Type: text/plain\r\n"
"\r\n"
"... contents of file1.txt ...\r\n"
"--BbC04y\r\n"
"Content-Disposition: file; filename=\"file2.gif\"\r\n"
"Content-Type: image/gif\r\n"
"Content-Transfer-Encoding: binary\r\n"
"\r\n"
"...contents of file2.gif...\r\n"
"--BbC04y--";

static const char _formDataBug[] =
"------WebKitFormBoundarysauI3YTQ2M7RKKUu\r\n"
"Content-Disposition: form-data; name=\"textfield-1135-inputEl\"\r\n"
"\r\n"
"\r\n"
"------WebKitFormBoundarysauI3YTQ2M7RKKUu\r\n"
"Content-Disposition: form-data; name=\"wibfilefield-1133-inputEl\"; filename=\"tarif MEYLAN.csv\"\r\n"
"Content-Type: text/csv\r\n"
"\r\n"
"CodeTarif;Commentaires;Poids;D?finition;Tarif\r\n"
"8FOOTSTABA;foot stab dt A;;heure, quart-heure;10,15 \x80\r\n"
"\r\n"
"------WebKitFormBoundarysauI3YTQ2M7RKKUu--\r\n";

static int _formDataSplits[10]= {1,10,20,40,50,60,70,100,200,400};

static BOOL _test_formFileHeaderHandler(MSHttpFormParser *parser, int idx, NSString *name, NSString *value, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  if (*args[1].i1Ptr == 0) {
    TASSERT_EQUALS_LLD(test, idx, 0);
    TASSERT_EQUALS_OBJ(test, name, @"Content-Disposition");
    TASSERT_EQUALS_OBJ(test, value, @"form-data; name=\"submit-name\"");
  }
  else if (*args[1].i1Ptr == 1) {
    TASSERT_EQUALS_LLD(test, idx, 1);
    TASSERT_EQUALS_OBJ(test, name, @"Content-Disposition");
    TASSERT_EQUALS_OBJ(test, value, @"form-data; name=\"files\"");
  }
  else if (*args[1].i1Ptr == 2) {
    TASSERT_EQUALS_LLD(test, idx, 1);
    TASSERT_EQUALS_OBJ(test, name, @"Content-Type");
    TASSERT_EQUALS_OBJ(test, value, @"multipart/mixed; boundary=BbC04y");
  }
  else {
    TASSERT(test, NO, "formFileHeader event should not had been fired more than 3 times");
  }
  ++(*args[1].i1Ptr);
  return YES;
}
static BOOL _test_formFileChunkHandler(MSHttpFormParser *parser, int idx, const MSByte *bytes, NSUInteger length, MSHandlerArg *args)
{
  test_t *test= (test_t *)args[0].ptr;
  TASSERT(test, idx < 3, "form-data only contains 3 fields");
  if (idx < 3) {
    //NSLog(@"chunk %d %d %.*s", idx, (int)length, (int)length, bytes);
    [(MSBuffer *)args[1 + idx].id appendBytes:bytes length:length];
  }
  return YES;
}
static void form_formdata(test_t *test)
{
  NEW_POOL;
  MSHttpFormParser *parser; char pass; MSBuffer *b0, *b1, *b2; int i, pos;

  parser= [ALLOC(MSHttpFormParser) initWithFormDataBoundary:@"AaB03x"];
  pass= 0;
  b0= [MSBuffer mutableBuffer];
  b1= [MSBuffer mutableBuffer];
  b2= [MSBuffer mutableBuffer];
  [parser addOnFieldHandler:_test_formFieldHandler_reject args:1, MSMakeHandlerArg(test)];
  [parser addOnFileHeaderHandler:_test_formFileHeaderHandler args:2, MSMakeHandlerArg(test), MSMakeHandlerArg(&pass)];
  [parser addOnFileChunkHandler:_test_formFileChunkHandler args:4, MSMakeHandlerArg(test), MSMakeHandlerArg(b0), MSMakeHandlerArg(b1), MSMakeHandlerArg(b2)];
  TASSERT_EQUALS_LLD(test, pass, 0);
  [parser writeData:[MSBuffer bufferWithCString:_formData]];
  [parser writeEnd];
  TASSERT_EQUALS_OBJ(test, b0, [MSBuffer bufferWithCString:"Larry"]);
  TASSERT_EQUALS_OBJ(test, b1, [MSBuffer bufferWithCString:_formDataPart2]);
  TASSERT_EQUALS_LLD(test, pass, 3);
  RELEASE(parser);

  parser= [ALLOC(MSHttpFormParser) initWithFormDataBoundary:@"AaB03x"];
  pass= 0;
  b0= [MSBuffer mutableBuffer];
  b1= [MSBuffer mutableBuffer];
  b2= [MSBuffer mutableBuffer];
  [parser addOnFieldHandler:_test_formFieldHandler_reject args:1, MSMakeHandlerArg(test)];
  [parser addOnFileHeaderHandler:_test_formFileHeaderHandler args:2, MSMakeHandlerArg(test), MSMakeHandlerArg(&pass)];
  [parser addOnFileChunkHandler:_test_formFileChunkHandler args:4, MSMakeHandlerArg(test), MSMakeHandlerArg(b0), MSMakeHandlerArg(b1), MSMakeHandlerArg(b2)];
  TASSERT_EQUALS_LLD(test, pass, 0);
  for(i= 0, pos= 0; i < 10; ++i) {
    [parser writeData:[MSBuffer bufferWithBytes:_formData + pos length:_formDataSplits[i] - pos]];
    pos= _formDataSplits[i];
  }
  [parser writeData:[MSBuffer bufferWithCString:_formData + pos]];
  [parser writeEnd];
  TASSERT_EQUALS_OBJ(test, b0, [MSBuffer bufferWithCString:"Larry"]);
  TASSERT_EQUALS_OBJ(test, b1, [MSBuffer bufferWithCString:_formDataPart2]);
  TASSERT_EQUALS_LLD(test, pass, 3);
  RELEASE(parser);


  KILL_POOL;
}

testdef_t msnode_form[]= {
  {"urlencoded", NULL, form_urlencoded},
  {"formdata", NULL, form_formdata},
  {NULL}};
