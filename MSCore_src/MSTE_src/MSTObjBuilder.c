
#include "MSTE_Private.h"


CDecimal*				MSTObjBuilder_NewDecimalFromLong(
long					val)
{
	return CCreateDecimalFromLong(val);
}


CDecimal*				MSTObjBuilder_NewDecimal(
CBuffer*				bfr)
{
	CDecimal*			dec;

	if ((dec = CCreateDecimalFromUTF8String((char*)CBufferCString(bfr))) == NULL)
		printf("failed to create MSCDecimal\n");
	return dec;
}


CBuffer*				MSTObjBuilder_NewStr(
CBuffer*				bfr)
{
	CBuffer*			str;	/* TODO replace by CString */

	if ((str = CCreateBuffer(CBufferLength(bfr))) == NULL)
		return NULL;
	CBufferAppendBuffer(str, bfr);
	return str;
}


CDate*					MSTObjBuilder_NewDate(
int					sse)
{
	CDate*				date;

	/* TODO create date from int */
	if ((date = CCreateDateNow(/* sse */)) == NULL)
		printf("failed to create MSCDate\n");
	return date;
}


CColor*					MSTObjBuilder_NewColor(
long long				rgb)
{
	CColor*				col;

	/* TODO */
	if ((col = CCreateColor(0, 0, 0, 0)) == NULL)
		printf("failed to create MSCColor\n");
	return col;
}


CDictionary*				MSTObjBuilder_NewDictionary(
unsigned int				cnt)
{
	CDictionary*			dic;

	if ((dic = CCreateDictionary(cnt)) == NULL)
		printf("failed to create MSCDictionary\n");
	return dic;
}


int					MSTObjBuilder_NewDictionaryKeyVal(
id					dic,
id					key,
id					val)
{
	/* TODO typesafe cast */
	CDictionarySetObjectForKey((CDictionary*)dic, val, key);
	return 0;
}


CArray*					MSTObjBuilder_NewArray(
unsigned int				cnt)
{
	CArray*				array;

	if ((array = CCreateArray(cnt)) == NULL)
		printf("failed to create MSCArray\n");
	return array;
}


int					MSTObjBuilder_NewArrayVal(
id					array,
id					val)
{
	/* TODO typesafe cast */
	CArrayAddObject((CArray*)array, val);
	return 0;
}


CCouple*				MSTObjBuilder_NewCouple(
id					first,
id					second)
{
	return CCreateCouple(first, second);
}


CBuffer*				MSTObjBuilder_NewBuffer(
CBuffer*				bfr)
{
	CBuffer*			str;

	if ((str = CCreateBuffer(CBufferLength(bfr))) == NULL)
		return NULL;
	CBufferAppendBuffer(str, bfr);
	return str;
}


CBuffer*				MSTObjBuilder_NewEmptyString(void)
{
	/* TODO create empty string */
	return CCreateBuffer(0);
}


CDictionary*				MSTObjBuilder_NewObj(
unsigned int				cnt,
id					classId)
{
	CDictionary*			dic;

	if ((dic = CCreateDictionary(cnt)) == NULL)
		printf("failed to create MSCDictionary/object\n");
	/* TODO add a field to identify this dictionary as a class */
	classId = NULL;
	return dic;
}


int					MSTObjBuilder_NewObjKeyVal(
id					dic,
id					key,
id					val)
{
	/* TODO typesafe cast */
	CDictionarySetObjectForKey((CDictionary*)dic, val, key);
	return 0;
}
