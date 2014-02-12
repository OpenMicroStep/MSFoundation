
#include "MSTE_Private.h"

CDecimal*				MSTCObjReader_NewDecimalRead(
struct MSTReader*			reader)
{
	CBuffer*			bfr;
	CDecimal*			dec;

	if ((bfr = MSTReader_newNbrRead(reader, 16)) == NULL)
		return NULL;
	CBufferAppendByte(bfr, 0);
	if ((dec = CCreateDecimalFromUTF8String((char*)CBufferCString(bfr))) == NULL)
		printf("failed to create MSCDecimal\n");
	RELEASE(bfr);
	return dec;
}


CDate*					MSTCObjReader_NewDateRead(
struct MSTReader*			reader)
{
	int				sse;
	CDate*				date;

	if (MSTReader_intRead(reader, &sse))
		return NULL;
	/* TODO create date from int */
	if ((date = CCreateDateNow(/* sse */)) == NULL)
		printf("failed to create MSCDate\n");
	return date;
}


CColor*					MSTCObjReader_NewColorRead(
struct MSTReader*			reader)
{
	int				rgb;
	CColor*				col;

	if (MSTReader_intRead(reader, &rgb))
		return NULL;
	/* TODO */
	if ((col = CCreateColor(0, 0, 0, 0)) == NULL)
		printf("failed to create MSCDate\n");
	return col;
}
