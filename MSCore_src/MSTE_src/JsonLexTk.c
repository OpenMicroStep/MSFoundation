
#include "MSTE_Private.h"

int					JsonLexTk_charGet(
enum JsonLexTk				me,
char*					dst)
{
	switch (me)
	{
	case JsonLexTk_eof:		return 1;
	case JsonLexTk_err:		return 1;
	case JsonLexTk_nbr:		return 1;
	case JsonLexTk_str:		return 1;
	case JsonLexTk_objBgn:		*dst = JSON_OBJBGN;	return 0;
	case JsonLexTk_objEnd:		*dst = JSON_OBJEND;	return 0;
	case JsonLexTk_arrayBgn:	*dst = JSON_ARRAYBGN;	return 0;
	case JsonLexTk_arrayEnd:	*dst = JSON_ARRAYEND;	return 0;
	case JsonLexTk_sep:		*dst = JSON_SEP;	return 0;
	case JsonLexTk_kvSep:		*dst = JSON_KVSEP;	return 0;
	}
}
