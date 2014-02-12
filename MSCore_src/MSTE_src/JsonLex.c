
#include "MSTE_Private.h"

/* TODO: use functions from MSCORE */
#define JSON_ISSPACE(chr)		((chr) == JSON_SPACE \
							|| (chr) == JSON_TAB)

#define JSON_ISDIGIT(chr)		(chr >=  '0' && chr <= '9')


void					JsonLex_init(
struct JsonLex*				self,
CBuffer*				bfr)
{
	self->bfr = bfr;
	self->idx = 0;
}


enum JsonLexTk				JsonLex_err(
struct JsonLex*				self,
const char*				fmt,
					...)
{
	va_list				vaLst;

	va_start(vaLst, fmt);
	CBuffer_verrAt(self->bfr, self->idx, fmt, &vaLst);
        va_end(vaLst);
	return JsonLexTk_err;
}


int					JsonLex_skipSpaces(
struct JsonLex*				self)
{
	char*				bfr;
	int				len;
	int				idx;

	len = CBufferLength(self->bfr);
	bfr = (char*)CBufferCString(self->bfr);
	for (idx = self->idx; idx < len && JSON_ISSPACE(bfr[idx]); idx ++)
		;
	self->idx = idx;
	return (self->idx >= len);
}


enum JsonLexTk				JsonLex_tokenPeek(
struct JsonLex*				self)
{
	char				chr;

	if (JsonLex_skipSpaces(self))
		return JsonLexTk_eof;
	switch ((chr = CBufferByteAtIndex(self->bfr, self->idx)))
	{
	case JSON_MINUS:		return JsonLexTk_nbr;
	case JSON_PLUS:			return JsonLexTk_nbr;
	case JSON_STRBGN:		return JsonLexTk_str;
	case JSON_OBJBGN:		return JsonLexTk_objBgn;
	case JSON_OBJEND:		return JsonLexTk_objEnd;
	case JSON_KVSEP:		return JsonLexTk_kvSep;
	case JSON_ARRAYBGN:		return JsonLexTk_arrayBgn;
	case JSON_ARRAYEND:		return JsonLexTk_arrayEnd;
	case JSON_SEP:			return JsonLexTk_sep;
	}
	if (JSON_ISDIGIT(chr))
		return JsonLexTk_nbr;
	return JsonLex_err(self, "unhandled token");
}


static enum JsonLexTk			JsonLex_nbrRead(
struct JsonLex*				self,
CBuffer*				dst)
{
	int				endIdx;

	if ((endIdx = CBuffer_nbrRead(self->bfr, self->idx, dst)) == -1)
		return JsonLexTk_err;
	self->idx = endIdx;
	return JsonLexTk_nbr;
}


/*
 * TODO JsonLex_Str*: use unicode
 */

static int				JsonLex_StrEscRead(
char*					bfr,
int					len,
char*					dst)
{
	if (len < 2)
		return -1;
	switch (bfr[1])
	{
	case '\"':	*dst = '\"';	return 2;
	case '\\':	*dst = '\\';	return 2;
	case '/':	*dst = '/';	return 2;
	case 'b':	*dst = '\b';	return 2;
	case 'f':	*dst = '\f';	return 2;
	case 'n':	*dst = '\n';	return 2;
	case 'r':	*dst = '\r';	return 2;
	case 't':	*dst = '\t';	return 2;
	case 'u':	if (len < 5)
				return -1;
			*dst = 0;			// TODO
			return 5;	
	}
	return -1;
}


static int				JsonLex_StrChrRead(
char*					bfr,
int					len,
char*					dst)
{
	if (bfr[0] == JSON_STRESC)
		return JsonLex_StrEscRead(bfr, len, dst);
	*dst = bfr[0];
	return 1;
}


static enum JsonLexTk			JsonLex_strRead(
struct JsonLex*				self,
CBuffer*				dst)
{
	char*				bfr;
	int				len;
	int				idx;
	char				chr;
	int				chrLen;

	len = CBufferLength(self->bfr);
	bfr = (char*)CBufferCString(self->bfr);
	for (idx = self->idx + 1; idx < len && bfr[idx] != JSON_STREND;
								idx += chrLen)
	{
		chrLen = JsonLex_StrChrRead(bfr + idx, len - idx, &chr);
		if (chrLen == -1)
			return JsonLex_err(self, "bad char in str at %i", idx);
		CBufferAppendByte(dst, chr);
	}
	if (idx >= len)
		return JsonLex_err(self, "eof in string");
	self->idx = idx + 1;
	return JsonLexTk_str;
}


/*
 * JsonLex_tokenRead - consumes next token
 */
enum JsonLexTk				JsonLex_tokenRead(
struct JsonLex*				self,
CBuffer*				bfr)
{
	enum JsonLexTk			nxt;

	switch ((nxt = JsonLex_tokenPeek(self)))
	{
	case JsonLexTk_nbr:	return JsonLex_nbrRead(self, bfr);
	case JsonLexTk_str:	return JsonLex_strRead(self, bfr);
	default:		self->idx ++;
				return nxt;
	}
}
