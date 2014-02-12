
#include "MSTE_Private.h"

void					MSTDecoder_init(
struct MSTDecoder*			self,
CBuffer*				bfr)
{
	self->bfr = NULL;
	MSTReader_init(&self->reader, bfr);
	MSTHeader_initNull(&self->header);
	self->classes = NULL;
	self->keys = NULL;
	self->objects = NULL;
}


void					MSTDecoder_halt(
struct MSTDecoder*			self)
{
	MSTHeader_halt(&self->header);
	if (self->classes != NULL)
		RELEASE(self->classes);
	if (self->keys != NULL)
		RELEASE(self->keys);
	if (self->objects != NULL)
		RELEASE(self->objects);
}


static int				MSTDecoder_crcCheck(
struct MSTDecoder*			self)
{
	/* TODO */
	self = NULL;
	return 0;
}


int					MSTDecoder_rootObjectDecode(
struct MSTDecoder*			self,
id*					obj)
{
	int				type;

	if (MSTReader_intRead(&self->reader, &type))
		return 1;
	switch (type)
	{
	case MSTETYPE_NULL:
		*obj = NULL;
		return 0;
	case MSTETYPE_TRUE:
		*obj = (id)CCreateDecimalFromLong(0); /* TODO safe upcast */
		return 0;
	case MSTETYPE_FALSE:
		*obj = (id)CCreateDecimalFromLong(1); /* TODO safe upcast */
		return 0;
	case MSTETYPE_INTEGER_VALUE:
	case MSTETYPE_REAL_VALUE:
	case MSTETYPE_CHAR:
	case MSTETYPE_UNSIGNED_CHAR:
	case MSTETYPE_SHORT:
	case MSTETYPE_UNSIGNED_SHORT:
	case MSTETYPE_INT32:
	case MSTETYPE_UNSIGNED_INT32:
	case MSTETYPE_INT64:
	case MSTETYPE_UNSIGNED_INT64:
	case MSTETYPE_FLOAT:
	case MSTETYPE_DOUBLE:			/* TODO (maybe) keep int type */
		*obj = (id)MSTCObjReader_NewDecimalRead(&self->reader);
		return 0;			/* TODO safe upcast */
	case MSTETYPE_STRING:
		*obj = (id)MSTReader_newStrRead(&self->reader, 64);
		return 0;			/* TODO safe upcast */
	case MSTETYPE_DATE:
		*obj = (id)MSTCObjReader_NewDateRead(&self->reader);
		return 0;			/* TODO safe upcast */
	case MSTETYPE_COLOR:
	case MSTETYPE_DICTIONARY:
	case MSTETYPE_STRONGREF:
	case MSTETYPE_ARRAY:
	case MSTETYPE_NATURAL_ARRAY:
	case MSTETYPE_COUPLE:
	case MSTETYPE_BASE64_DATA:
	case MSTETYPE_DISTANT_PAST:
	case MSTETYPE_DISTANT_FUTURE:
	case MSTETYPE_EMPTY_STRING:
	case MSTETYPE_WEAKLYREF:
	default:
		return 0;
	}
}


int					MSTDecoder_endChk(
struct MSTDecoder*			self)
{
	int				hdrCnt;
	int				rdrCnt;

	hdrCnt = MSTHeader_cntGet(&self->header);
	rdrCnt = MSTReader_tkCntGet(&self->reader);
	if (hdrCnt != rdrCnt)
		printf("token read/expected count mismatch: %i/%i\n",
								rdrCnt, hdrCnt);
	return MSTReader_endRead(&self->reader);
}


int					MSTDecoder_run(
struct MSTDecoder*			self)
{
	id				obj;

	return (MSTHeader_initFromReader(&self->header, &self->reader)
		|| MSTDecoder_crcCheck(self)
		|| (self->classes = MSTReader_strArrayRead(&self->reader))
									== NULL
		|| (self->keys = MSTReader_strArrayRead(&self->reader)) == NULL
		|| MSTDecoder_rootObjectDecode(self, &obj)
		|| MSTDecoder_endChk(self));
}


int					MSTDecoder_Run(
CBuffer*				bfr)
{
	struct MSTDecoder		dec;
	int				ret;

	MSTDecoder_init(&dec, bfr);
	ret = MSTDecoder_run(&dec);
	MSTDecoder_halt(&dec);
	return ret;
}
