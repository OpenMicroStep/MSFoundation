//#include <limits.h>
//#include <stdarg.h>
//#include <string.h>
//#include <stdlib.h>
//#include <stdio.h>

//#define MSCORE_STANDALONE

#include "MSCore_Private.h"

#include "JsonLexTk.h"
#include "JsonLex.h"
#include "MSTReaderTk.h"
#include "MSTReader.h"
#include "MSTHeader.h"
#include "MSTDecoder.h"


static int				test_LexTokenDump(
enum JsonLexTk				tk,
CBuffer*				bfr)
{
	char				chr;

	switch (tk)
	{
	case JsonLexTk_eof:
	case JsonLexTk_err:	printf("%i\n", tk);
				return 0;
	case JsonLexTk_nbr:
	case JsonLexTk_str:	printf("%i:%.*s\n", tk,
					(int)CBufferLength(bfr),
					CBufferCString(bfr));
				return 0;
	default:		if (JsonLexTk_charGet(tk, &chr))
					return 1;
				printf("%i:%c\n", tk, chr);
				return 0;
	}
}


static enum JsonLexTk			test_LexTokenRead(
struct JsonLex*				lex)
{
	enum JsonLexTk			tk;
	CBuffer*			bfr;

	bfr = CCreateBuffer(42);
	tk = JsonLex_tokenRead(lex, bfr);
	test_LexTokenDump(tk, bfr);
	RELEASE(bfr);
	return tk;
}


static int				test_LexTokensLoop(
char*					str)
{
	struct JsonLex			lex;
	enum JsonLexTk			tk;
	CBuffer*			bfr;

	bfr = CCreateBufferWithBytes(str, strlen(str));
	JsonLex_init(&lex, bfr);
	while ((tk = JsonLex_tokenPeek(&lex)) != JsonLexTk_eof
							&& tk != JsonLexTk_err)
	{
		if ((tk = test_LexTokenRead(&lex)) == JsonLexTk_err)
			break;
	}
	RELEASE(bfr);
	return (tk != JsonLexTk_eof);
}


static int				test_Lex(
int					argc,
char**					argv)
{
	int				idx;

	for (idx = 0; idx < argc; idx ++)
		printf("lex[%i]: %i\n", idx, test_LexTokensLoop(argv[idx]));
	return 0;
}


static enum MSTReaderTk			test_MstTokenRead(
struct MSTReader*			mst)
{
	enum MSTReaderTk		tk;
	CBuffer*			bfr;

	bfr = CCreateBuffer(42);
	if ((tk = MSTReader_tokenRead(mst, bfr)) != MSTReaderTk_eof
						&& tk != MSTReaderTk_err)
	{
		printf("%i:%.*s\n", tk, (int)CBufferLength(bfr),
							CBufferCString(bfr));
	}
	RELEASE(bfr);
	return tk;
}


static int				test_MstTokensLoop(
char*					str)
{
	struct MSTReader		mst;
	enum MSTReaderTk		tk;
	CBuffer*			bfr;

	bfr = CCreateBufferWithBytes(str, strlen(str));
	MSTReader_init(&mst, bfr);
	while ((tk = test_MstTokenRead(&mst)) != JsonLexTk_eof
							&& tk != JsonLexTk_err)
		;
	RELEASE(bfr);
	return (tk != JsonLexTk_eof);
}


static int				test_Mst(
int					argc,
char**					argv)
{
	int				idx;

	for (idx = 0; idx < argc; idx ++)
		printf("MST[%i]: %i\n", idx, test_MstTokensLoop(argv[idx]));
	return 0;
}


static int				test_MstDec(
char*					str)
{
	int				ret;
	CBuffer*			bfr;

	if ((str = strdup(str)) == NULL)
	{
		printf("failed to duplicate string\n");
		return 1;
	}
	bfr = CCreateBufferWithBytes(str, strlen(str));
	ret = MSTDecoder_Run(bfr);
	RELEASE(bfr);
	free(str);
	return ret;
}


static int				test_MstDecs(
int					argc,
char**					argv)
{
	int				idx;

	for (idx = 0; idx < argc; idx ++)
		printf("MST[%i]: %i\n", idx, test_MstDec(argv[idx]));
	return 0;
}


static int					test(
int					argc,
char**					argv /*,
char**					arge */)
{
	char*				subCmd;
	if (argc < 2)
	{
		printf("requires sub command name\n");
		return 0;
	}
	subCmd = argv[1];
	argc -= 2;
	argv += 2;
	if (!strcmp(subCmd, "lex"))
		return test_Lex(argc, argv);
	if (!strcmp(subCmd, "mst"))
		return test_Mst(argc, argv);
	if (!strcmp(subCmd, "mstDec"))
		return test_MstDecs(argc, argv);
	printf("unhandled sub command: %s\n", subCmd);
	return 1;
}

/*
static char * tst1= "[\"MSTE0101\",45,\"CRC00000000\",1,\"MSTETest\",7,"
  "\"Arraaaayy\",\"blabla\",\"Array\",\"color\",\"datatau0042\",\"date\","
  "\"string\",50,6,0,20,2,7,2200083711,8,1,1,6,1351586383,2,20,3,14,12,1,9,2,"
  "3,9,2,4,23,\"bcOpbG9kaWU=\",5,9,4,6,5,\"SomeTu00E9ext\"]";
*/

static char * tst2= "[\"MSTE0101\",45,\"CRC00000000\",1,\"MSTETest\",7,"
  "\"Arraaaayy\",\"blabla\",\"Array\",\"color\",\"datatau0042\",\"date\","
  "\"string\",50,6,0,20,2,7,2200083711,8,1,1,6,1351586383,2,20,3,14,12,1,9,2,"
  "3,9,2,4,23,\"bcOpbG9kaWU=\",5,9,4,6,5,\"SomeTu00E9ext\""
  ",0,0e1234567890,0e-1234567890,0e+1234567890,0E1234567890"
  ",0E-1234567890,0E+1234567890,0.1023456789,0.1023456789e1234567890"
  ",0.1023456789e-1234567890,0.1023456789e+1234567890"
  ",0.1023456789E1234567890,0.1023456789E-1234567890"
  ",0.1023456789E+1234567890,1023456789,1023456789e1234567890"
  ",1023456789e-1234567890,1023456789e+1234567890,1023456789E1234567890"
  ",1023456789E-1234567890,1023456789E+1234567890,1023456789.1023456789"
  ",1023456789.1023456789e1234567890,1023456789.1023456789e-1234567890"
  ",1023456789.1023456789e+1234567890,1023456789.1023456789E1234567890"
  ",1023456789.1023456789E-1234567890,1023456789.1023456789E+1234567890"
  ",-0,-0e1234567890,-0e-1234567890,-0e+1234567890,-0E1234567890"
  ",-0E-1234567890,-0E+1234567890,-0.1023456789,-0.1023456789e1234567890"
  ",-0.1023456789e-1234567890,-0.1023456789e+1234567890"
  ",-0.1023456789E1234567890,-0.1023456789E-1234567890"
  ",-0.1023456789E+1234567890,-1023456789,-1023456789e1234567890"
  ",-1023456789e-1234567890,-1023456789e+1234567890"
  ",-1023456789E1234567890,-1023456789E-1234567890,-1023456789E+1234567890"
  ",-1023456789.1023456789,-1023456789.1023456789e1234567890"
  ",-1023456789.1023456789e-1234567890,-1023456789.1023456789e+1234567890"
  ",-1023456789.1023456789E1234567890,-1023456789.1023456789E-1234567890"
  ",-1023456789.1023456789E+1234567890]";

int mste_validate()
{
  int err= 0; clock_t t0= clock(), t1; double seconds;
  int argc;
  char* argv[3];

  argc= 3;
  argv[0]= NULL;
  argv[1]= "lex";
  argv[2]= tst2;
  err+= test(argc, argv);

  argv[1]= "mst";
  argv[2]= tst2;
  err+= test(argc, argv);

  argv[1]= "mstDec";
  argv[2]= tst2;
  err+= test(argc, argv);

  t1= clock(); seconds= (double)(t1-t0)/CLOCKS_PER_SEC;
  fprintf(stdout, "=> %-14s validate: %s (%.3f s)\n","MSTE",(err?"FAIL":"PASS"),seconds);
  return err;
}
