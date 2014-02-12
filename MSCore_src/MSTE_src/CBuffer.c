/* TODO move to MSCore/MSCBuffer */

#include "MSTE_Private.h"

/* TODO: use functions from MSCORE */
#define CBUFFER_ISDIGIT(chr)		(chr >=  '0' && chr <= '9')


void					CBuffer_verrAt(
CBuffer*				bfr,
int					idx,
const char*				fmt,
va_list*				vaLst)
{
	const char*			ptr;
	int				len;
	int				endLen;

	vprintf(fmt, *vaLst);
	ptr = (char*)CBufferCString(bfr);
	len = CBufferLength(bfr);
	endLen = len - idx;
	printf("\n\tin: %.*s\n\tat %i: %.*s%s\n", len, ptr, idx,
					(endLen > 64) ? 64 : endLen,
					ptr + idx, (endLen > 20) ? "..." : "");
}


int					CBuffer_verrAtReturn(
CBuffer*				self,
int					idx,
int					ret,
const char*				fmt,
va_list*				vaLst)
{
	CBuffer_verrAt(self, idx, fmt, vaLst);
	return ret;
}


void					CBuffer_errAt(
CBuffer*				self,
int					idx,
const char*				fmt,
					...)
{
	va_list				vaLst;

	va_start(vaLst, fmt);
	CBuffer_verrAt(self, idx, fmt, &vaLst);
        va_end(vaLst);
}


int					CBuffer_errAtReturn(
CBuffer*				self,
int					idx,
int					ret,
const char*				fmt,
					...)
{
	va_list				vaLst;

	va_start(vaLst, fmt);
	CBuffer_verrAt(self, idx, fmt, &vaLst);
        va_end(vaLst);
	return ret;
}


#define CBUFFER_NBRMINUS		'-'
#define CBUFFER_NBRPLUS			'+'
#define CBUFFER_NBRDOT			'.'
#define CBUFFER_NBRLEXP			'e'
#define CBUFFER_NBRUEXP			'E'


static int				CBuffer_nbrSignRead(
CBuffer*				self,
CBuffer*				dst,
int*					idx)
{
	char				chr;

	if (CBufferLength(self) < 1)
		return 1;
	chr = CBufferByteAtIndex(self, *idx);
	if (chr != CBUFFER_NBRMINUS)
		return 0;
	CBufferAppendByte(dst, chr);
	(*idx) ++;
	return 0;
}


static int				CBuffer_nbrIntBgnRead(
CBuffer*				self,
CBuffer*				dst,
int*					idx)
{
	char				chr;

	if (CBufferLength(self) < 1)
		return 1;
	chr = CBufferByteAtIndex(self, *idx);
	if (!CBUFFER_ISDIGIT(chr))
		return CBuffer_errAtReturn(self, *idx, 1,
							"bad digit in number");
	CBufferAppendByte(dst, chr);
	(*idx) ++;
	return (chr == '0') ? 0 : -1;
}


static int				CBuffer_nbrDigitsRead(
CBuffer*				self,
CBuffer*				dst,
int*					pIdx)
{
	char*				bfr;
	int				len;
	int				idx;
	char				chr;

	len = CBufferLength(self);
	bfr = (char*)CBufferCString(self);
	for (idx = *pIdx; idx < len; idx ++)
	{
		chr = bfr[idx];
		if (!CBUFFER_ISDIGIT(chr))
			break ;
		CBufferAppendByte(dst, chr);
	}
	*pIdx = idx;
	return 0;
}


static int				CBuffer_nbrIntRead(
CBuffer*				self,
CBuffer*				dst,
int*					pIdx)
{
	int				ret;

	if ((ret = CBuffer_nbrIntBgnRead(self, dst, pIdx)) != -1)
		return ret;
	return CBuffer_nbrDigitsRead(self, dst, pIdx);
}


static int				CBuffer_nbrDecBgnRead(
CBuffer*				self,
CBuffer*				dst,
int*					idx)
{
	char				chr;

	if (CBufferLength(self) < 1)
		return 1;
	chr = CBufferByteAtIndex(self, *idx);
	if (chr != CBUFFER_NBRDOT)
		return 0;
	CBufferAppendByte(dst, chr);
	(*idx) ++;
	return -1;
}


static int				CBuffer_nbrDecRead(
CBuffer*				self,
CBuffer*				dst,
int*					pIdx)
{
	int				idx;
	int				ret;

	if ((ret = CBuffer_nbrDecBgnRead(self, dst, pIdx)) != -1)
		return ret;
	idx = *pIdx;
	if (CBuffer_nbrDigitsRead(self, dst, pIdx))
		return 1;
	if (idx == *pIdx)
		return CBuffer_errAtReturn(self, idx, 1, "bad digit after '.'");
	return 0;
}


static int				CBuffer_nbrExpBgnRead(
CBuffer*				self,
CBuffer*				dst,
int*					idx)
{
	char				chr;

	if (CBufferLength(self) < 1)
		return 1;
	chr = CBufferByteAtIndex(self, *idx);
	if (chr != CBUFFER_NBRLEXP && chr != CBUFFER_NBRUEXP)
		return 0;
	CBufferAppendByte(dst, chr);
	(*idx) ++;
	return -1;
}


static int				CBuffer_nbrExpSignRead(
CBuffer*				self,
CBuffer*				dst,
int*					idx)
{
	char				chr;

	if (CBufferLength(self) < 1)
		return 1;
	chr = CBufferByteAtIndex(self, *idx);
	if (chr != CBUFFER_NBRMINUS && chr != CBUFFER_NBRPLUS)
		return 0;
	CBufferAppendByte(dst, chr);
	(*idx) ++;
	return 0;
}


static int				CBuffer_nbrExpRead(
CBuffer*				self,
CBuffer*				dst,
int*					pIdx)
{
	int				idx;
	int				ret;

	if ((ret = CBuffer_nbrExpBgnRead(self, dst, pIdx)) != -1)
		return ret;
	if (CBuffer_nbrExpSignRead(self, dst, pIdx))
		return 1;
	idx = *pIdx;
	if (CBuffer_nbrDigitsRead(self, dst, pIdx))
		return 1;
	if (idx == *pIdx)
		return CBuffer_errAtReturn(self, idx, 1, "bad digit in exp");
	return 0;
}


int					CBuffer_nbrRead(
CBuffer*				self,
int					bgnIdx,
CBuffer*				dst)
{
	int				idx;

	idx = bgnIdx;
	if (CBuffer_nbrSignRead(self, dst, &idx)
			|| CBuffer_nbrIntRead(self, dst, &idx)
			|| CBuffer_nbrDecRead(self, dst, &idx)
			|| CBuffer_nbrExpRead(self, dst, &idx))
		return -1;
	return idx;
}


enum					CBufferNbrState
{
	CBufferNbrState_bgn		= 1,
	CBufferNbrState_intBgn		= 2,
	CBufferNbrState_int		= 3,
	CBufferNbrState_decBgn		= 4,
	CBufferNbrState_dec		= 5,
	CBufferNbrState_expBgn		= 6,
	CBufferNbrState_expSgn		= 7,
	CBufferNbrState_exp		= 8,
	CBufferNbrState_end		= 9
};


int					CBuffer_nbrReadOld(
CBuffer*				self,
int					bgnIdx,
CBuffer*				dst)
{
	enum CBufferNbrState		state;
	char*				bfr;
	int				len;
	int				idx;
	char				chr;

	len = CBufferLength(self);
	bfr = (char*)CBufferCString(self);
	state = CBufferNbrState_bgn;
	for (idx = bgnIdx; idx < len && state != CBufferNbrState_end; )
	{
		chr = bfr[idx];
/*printf("DB nbr %i: %c\n", state, chr);*/
		switch (state)
		{
		case CBufferNbrState_bgn:
			if (chr == CBUFFER_NBRMINUS)
			{
				CBufferAppendByte(dst, chr);
				idx ++;
			}
			state = CBufferNbrState_intBgn;
			break ;
		case CBufferNbrState_intBgn:
			if (!CBUFFER_ISDIGIT(chr))
				return CBuffer_errAtReturn(self, idx, -1,
							"bad digit in number");
			CBufferAppendByte(dst, chr);
			idx ++;
			state = (idx == len) 
				? CBufferNbrState_end
				: (chr == '0') ? CBufferNbrState_decBgn
						: CBufferNbrState_int;
			break ;
		case CBufferNbrState_int:
			if (CBUFFER_ISDIGIT(chr))
			{
				CBufferAppendByte(dst, chr);
				idx ++;
				if (idx == len)
					state = CBufferNbrState_end;
			}
			else
				state = CBufferNbrState_decBgn;
			break ;
		case CBufferNbrState_decBgn:
			if (chr == CBUFFER_NBRDOT)
			{
				CBufferAppendByte(dst, chr);
				idx ++;
				state = CBufferNbrState_dec;
			}
			else
				state = CBufferNbrState_expBgn;
			break ;
		case CBufferNbrState_dec:
			if (CBUFFER_ISDIGIT(chr))
			{
				CBufferAppendByte(dst, chr);
				idx ++;
				if (idx == len)
					state = CBufferNbrState_end;
			}
			else
				state = CBufferNbrState_expBgn;
			break ;
		case CBufferNbrState_expBgn:
			if (chr == CBUFFER_NBRLEXP || chr == CBUFFER_NBRUEXP)
			{
				CBufferAppendByte(dst, chr);
				idx ++;
				state = CBufferNbrState_expSgn;
			}
			else
				state = CBufferNbrState_end;
			break ;
		case CBufferNbrState_expSgn:
			if (chr == CBUFFER_NBRMINUS || chr == CBUFFER_NBRPLUS)
			{
				CBufferAppendByte(dst, chr);
				idx ++;
			}
			state = CBufferNbrState_exp;
			break ;
		case CBufferNbrState_exp:
			if (CBUFFER_ISDIGIT(chr))
			{
				CBufferAppendByte(dst, chr);
				idx ++;
				if (idx == len)
					state = CBufferNbrState_end;
			}
			else
				state = CBufferNbrState_end;
			break ;
		case CBufferNbrState_end:	break;
		}
	}
	if (state != CBufferNbrState_end)
		return CBuffer_errAtReturn(self, idx, -1, "eof in number");
	return idx;
}
