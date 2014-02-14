
#include "MSTE_Private.h"

void					MSTReader_init(
struct MSTReader*			self,
CBuffer*				bfr)
{
	JsonLex_init(&self->JsonLex, bfr);
	self->state = MSTReader_stateBgn;
	self->tkCnt = 0;
}


int					MSTReader_tkCntGet(
struct MSTReader*			self)
{
	return self->tkCnt;
}


int					MSTReader_endRead(
struct MSTReader*			self)
{
	if (self->state == MSTReader_stateEnd)
		return 0;
	if (JsonLex_tokenRead(&self->JsonLex, NULL) != JsonLexTk_arrayEnd
			|| JsonLex_tokenPeek(&self->JsonLex) != JsonLexTk_eof)
	{
		self->state = MSTReader_stateErr;
		JsonLex_err(&self->JsonLex, "extraneous data");
		return 1;
	}
	self->state = MSTReader_stateEnd;
	return 0;
}


static int				MSTReader_expectedTerminalRead(
struct MSTReader*			self,
enum JsonLexTk				xpt)
{
	enum JsonLexTk			tk;

	if ((tk = JsonLex_tokenPeek(&self->JsonLex)) == JsonLexTk_arrayEnd)
		return MSTReader_endRead(self) ? 1 : -1;
	if (tk != xpt)
	{
		self->state = MSTReader_stateErr;
		JsonLex_err(&self->JsonLex, "unexpected token %i"
						" while expecting %i", tk, xpt);
		return 1;
	}
	return (JsonLex_tokenRead(&self->JsonLex, NULL) == xpt) ? 0 : 1;
}


static enum MSTReaderTk			MSTReader_nonTerminalRead(
struct MSTReader*			self,
CBuffer*				bfr)
{
	enum JsonLexTk			tk;

	switch ((tk = JsonLex_tokenRead(&self->JsonLex, bfr)))
	{
	case JsonLexTk_eof:	JsonLex_err(&self->JsonLex, "unexpected eof");
				return MSTReaderTk_err;
	case JsonLexTk_err:	return MSTReaderTk_err;
	case JsonLexTk_nbr:	self->tkCnt ++;
				return MSTReaderTk_nbr;
	case JsonLexTk_str:	self->tkCnt ++;
				return MSTReaderTk_str;
	default:		self->state = MSTReader_stateErr;
				JsonLex_err(&self->JsonLex, "unexpected token");
				return MSTReaderTk_err;
	}
}


static enum MSTReaderTk			MSTReader_tokenWithPrefixTerminalRead(
struct MSTReader*			self,
enum JsonLexTk				xptPfx,
CBuffer*				bfr)
{
	int				ret;

	if ((ret = MSTReader_expectedTerminalRead(self, xptPfx)) != 0)
		return (ret == -1) ? MSTReaderTk_eof : MSTReaderTk_err;
	return MSTReader_nonTerminalRead(self, bfr);
}


static enum MSTReaderTk			MSTReader_tokenFirstRead(
struct MSTReader*			self,
CBuffer*				bfr)
{
	self->state = MSTReader_stateSep;
	return MSTReader_tokenWithPrefixTerminalRead(self, JsonLexTk_arrayBgn,
									bfr);
}


static enum MSTReaderTk			MSTReader_tokenNextRead(
struct MSTReader*			self,
CBuffer*				bfr)
{
	return MSTReader_tokenWithPrefixTerminalRead(self, JsonLexTk_sep, bfr);
}


enum MSTReaderTk			MSTReader_tokenRead(
struct MSTReader*			self,
CBuffer*				bfr)
{
	switch (self->state)
	{
	case MSTReader_stateErr:
		return MSTReaderTk_err;
	case MSTReader_stateBgn:
		return MSTReader_tokenFirstRead(self, bfr);
	case MSTReader_stateSep:
		return MSTReader_tokenNextRead(self, bfr);
	case MSTReader_stateTkn:
		return MSTReader_nonTerminalRead(self, bfr);
	case MSTReader_stateEnd:
		return MSTReaderTk_eof;
	};
}


enum MSTReaderTk			MSTReader_newTokenRead(
struct MSTReader*			self,
CBuffer**				pBfr,
int					expectedLen) /* TODO(maybe) NSUInteger*/
{
	CBuffer*			bfr;
	enum MSTReaderTk		tk;

	if ((bfr = CCreateBuffer((unsigned int)expectedLen)) == NULL)
		return MSTReaderTk_err;
	if ((tk = MSTReader_tokenRead(self, bfr)) == MSTReaderTk_err
					|| tk == MSTReaderTk_eof)
	{
		RELEASE(bfr);
		return tk;
	}
	*pBfr = bfr;
	return tk;
}


int					MSTReader_nbrRead(
struct MSTReader*			self,
CBuffer*				bfr)
{
	enum MSTReaderTk		tk;

	switch ((tk = MSTReader_tokenRead(self, bfr)))
	{
	case MSTReaderTk_nbr:	return 0;
	case MSTReaderTk_err:	return 1;
	case MSTReaderTk_eof:	JsonLex_err(&self->JsonLex,
						"eof while expecting number");
			return 1;
	default:	self->state = MSTReader_stateErr;
			JsonLex_err(&self->JsonLex, "unexpected token"
					" while expecting number \"%.*s\"",
				(int)CBufferLength(bfr), CBufferCString(bfr));
			return 1;
	}
}


int					MSTReader_strRead(
struct MSTReader*			self,
CBuffer*				bfr)
{
	enum MSTReaderTk		tk;

	switch ((tk = MSTReader_tokenRead(self, bfr)))
	{
	case MSTReaderTk_str:	return 0;
	case MSTReaderTk_err:	return 1;
	case MSTReaderTk_eof:	JsonLex_err(&self->JsonLex,
						"eof while expecting string");
				return 1;
	default:		self->state = MSTReader_stateErr;
				JsonLex_err(&self->JsonLex, "unexpected token"
					" while expecting string \"%.*s\"",
					(int)CBufferLength(bfr),
					CBufferCString(bfr));
				return 1;
	}
}


CBuffer*				MSTReader_newNbrRead(
struct MSTReader*			self,
int					expectedLen) /* TODO(maybe)NSUInteger */
{
	CBuffer*			bfr;

	if ((bfr = CCreateBuffer((unsigned int)expectedLen)) == NULL)
		return NULL;
	if (MSTReader_nbrRead(self, bfr))
	{
		RELEASE(bfr);
		return NULL;
	}
	return bfr;
}


CBuffer*				MSTReader_newStrRead(
struct MSTReader*			self,
int					expectedLen) /* TODO(maybe)NSUInteger */
{
	CBuffer*			bfr;

	if ((bfr = CCreateBuffer((unsigned int)expectedLen)) == NULL)
		return NULL;
	if (MSTReader_strRead(self, bfr))
	{
		RELEASE(bfr);
		return NULL;
	}
	return bfr;
}


int					MSTReader_longLongRead(
struct MSTReader*			self,
long long*				dst)
{
	CBuffer*			bfr;
	char*				end;
	long long			val;
	int				ret;

	if ((bfr = MSTReader_newNbrRead(self, 8)) == NULL)
		return 1;
	CBufferAppendByte(bfr, 0);
	val = strtoll((char*)CBufferCString(bfr), &end, 10);
	if (*end != 0)
	{
		printf("expected number to be int: \"%s\"\n",
							CBufferCString(bfr));
		ret = 1;
	}
	else
	{
		*dst = val;
		ret = 0;
	}
	RELEASE(bfr);
	return ret;
}


int					MSTReader_uLongLongRead(
struct MSTReader*			self,
unsigned long long*			dst)
{
	CBuffer*			bfr;
	char*				end;
	unsigned long long		val;
	int				ret;

	if ((bfr = MSTReader_newNbrRead(self, 8)) == NULL)
		return 1;
	CBufferAppendByte(bfr, 0);
	val = strtoull((char*)CBufferCString(bfr), &end, 10);
	if (*end != 0)
	{
		printf("expected number to be int: \"%s\"\n",
							CBufferCString(bfr));
		ret = 1;
	}
	else
	{
		*dst = val;
		ret = 0;
	}
	RELEASE(bfr);
	return ret;
}


int					MSTReader_rangeLongLongRead(
struct MSTReader*			self,
long long*				dst,
int					min,
int					max)
{
	long long			val;

	if (MSTReader_longLongRead(self, &val))
		return 1;
	if (val < min || val > max)
	{
		printf("number out of range [%i-%i]: %lli\n", min, max, val);
		return 1;
	}
	*dst = val;
	return 0;
}


int					MSTReader_rangeULongLongRead(
struct MSTReader*			self,
unsigned long long*			dst,
unsigned int				min,
unsigned int				max)
{
	unsigned long long		val;

	if (MSTReader_uLongLongRead(self, &val))
		return 1;
	if (val < min || val > max)
	{
		printf("number out of range [%i-%i]: %lli\n", min, max, val);
		return 1;
	}
	*dst = val;
	return 0;
}


int					MSTReader_intRead(
struct MSTReader*			self,
int*					dst)
{
	long long			val;

	if (MSTReader_rangeLongLongRead(self, &val, INT_MIN, INT_MAX))
		return 1;
	*dst = (int)val;
	return 0;
}


int					MSTReader_uIntRead(
struct MSTReader*			self,
unsigned int*				dst)
{
	unsigned long long		val;

	if (MSTReader_rangeULongLongRead(self, &val, 0, UINT_MAX))
		return 1;
	*dst = (unsigned int)val;
	return 0;
}


CArray*					MSTReader_strArrayRead(
struct MSTReader*			self)
{
	unsigned int			cnt;
	CArray*				array;
	CBuffer*			bfr;
	unsigned int			idx;

	if (MSTReader_uIntRead(self, &cnt)
				|| (array = CCreateArray(cnt)) == NULL)
		return NULL;
	for (idx = 0; idx < cnt; idx ++)
	{
		if ((bfr = MSTReader_newStrRead(self, 16)) == NULL)
		{
			RELEASE(array);	/* TODO check if content is freed */
			return NULL;
		}
		CArrayAddObject(array, (id)bfr); /* TODO typedafe upcast? */
	}
	return array;
}
