
#include "MSTE_Private.h"


static int				MSTDecoder_objectDecode(
	struct MSTDecoder*		self,
	id*				obj,
	int*				isWeakRef);


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


static id				MSTDecoder_IndexGetFromArray(
CArray*					array,
unsigned int				idx,
const char*				name)
{
	id				val;

	if ((val = CArrayObjectAtIndex(array, idx)) == NULL)
	{
		printf("%s index out of range: %u\n", name, idx);
		return NULL;
	}
	return val;
}


static id				MSTDecoder_indexReadAndGetFromArray(
struct MSTDecoder*			self,
CArray*					array,
const char*				name)
{
	unsigned int			valRef;

	if (MSTReader_uIntRead(&self->reader, &valRef))
		return NULL;
	return MSTDecoder_IndexGetFromArray(array, valRef, name);
}


/*
static id				MSTDecoder_classReadAndGet(
struct MSTDecoder*			self)
{
	return MSTDecoder_indexReadAndGetFromArray(self, self->classes,
								"class");
}
*/


static id				MSTDecoder_classGet(
struct MSTDecoder*			self,
unsigned int				idx)
{
	return MSTDecoder_IndexGetFromArray(self->classes, idx, "class");
}


static id				MSTDecoder_keyReadAndGet(
struct MSTDecoder*			self)
{
	return MSTDecoder_indexReadAndGetFromArray(self, self->keys, "key");
}


static id				MSTDecoder_objRefReadAndGetObj(
struct MSTDecoder*			self)
{
	return MSTDecoder_indexReadAndGetFromArray(self, self->objects,
								"object");
}


static void				MSTDecoder_decodedObjetAdd(
struct MSTDecoder*			self,
id					obj)
{
	CArrayAddObject(self->objects, obj);
}


static int				MSTDecoder_crcCheck(
struct MSTDecoder*			self)
{
	/* TODO */
	self = NULL;
	return 0;
}


static int				MSTDecoder_BooleanDecode(
int					val,
id*					obj)
{
	id				dec;

	/* TODO typesafe cast */
	if ((dec = (id)MSTObjBuilder_NewDecimalFromLong(val)) == NULL)
		return 1;
	*obj = dec;
	return 0;
}


static int				MSTDecoder_nbrDecode(
struct MSTDecoder*			self,
id*					obj)
{
	CBuffer*			bfr;
	id				dec;

	if ((bfr = MSTReader_newNbrRead(&self->reader, 16)) == NULL)
		return 1;
	CBufferAppendByte(bfr, 0);
	/* TODO typesafe cast */
	if ((dec = (id)MSTObjBuilder_NewDecimal(bfr)) == NULL)
		return 1;
	*obj = dec;
	RELEASE(bfr);
	return 0;
}


static int				MSTDecoder_strDecode(
struct MSTDecoder*			self,
id*					obj)
{
	CBuffer*			bfr;
	id				str;

	if ((bfr = MSTReader_newStrRead(&self->reader, 64)) == NULL)
		return 1;
	CBufferAppendByte(bfr, 0);
	/* TODO typesafe cast */
	str = (id)MSTObjBuilder_NewStr(bfr);
	RELEASE(bfr);
	if (str == NULL)
		return 1;
	*obj = str;
	return 0;
}


static int				MSTDecoder_dateDecode(
struct MSTDecoder*			self,
id*					obj)
{
	int				sse;
	id				date;

	if (MSTReader_intRead(&self->reader, &sse))
		return 1;
	/* TODO typesafe cast */
	if ((date = (id)MSTObjBuilder_NewDate(sse)) == NULL)
		return 1;
	*obj = date;
	return 0;
}


static int				MSTDecoder_colorDecode(
struct MSTDecoder*			self,
id*					obj)
{
	long long			rgb;
	id				date;

	if (MSTReader_longLongRead(&self->reader, &rgb))
		return 1;
	/* TODO typesafe cast */
	if ((date = (id)MSTObjBuilder_NewColor(rgb)) == NULL)
		return 1;
	*obj = date;
	return 0;
}


static int				MSTDecoder_dictionaryEntryDecode(
struct MSTDecoder*			self,
id					dic)
{
	id				key;
	id				obj;

	if ((key = MSTDecoder_keyReadAndGet(self)) == NULL
		|| MSTDecoder_objectDecode(self, &obj, NULL))
		return 1;
	if (MSTObjBuilder_NewDictionaryKeyVal(dic, key, obj))
	{
		RELEASE(obj);
		return 1;
	}
	return 0;
}


static int				MSTDecoder_dictionaryDecode(
struct MSTDecoder*			self,
id*					obj)
{
	unsigned int			cnt;
	unsigned int			idx;
	id				dic;

	if (MSTReader_uIntRead(&self->reader, &cnt))
		return 1;
	/* TODO typesafe cast */
	if ((dic = (id)MSTObjBuilder_NewDictionary(cnt)) == NULL)
		return 1;
	MSTDecoder_decodedObjetAdd(self, dic);
	for (idx = 0; idx < cnt; idx ++)
		if (MSTDecoder_dictionaryEntryDecode(self, dic))
		{
			RELEASE(dic);	/* TODO check that content is freed */
			return 1;
		}
	*obj = dic;
	return 0;
}


static int				MSTDecoder_strongRefDecode(
struct MSTDecoder*			self,
id*					obj)
{
	id				ref;

	/* TODO handle strong/weak ref */
	if ((ref = MSTDecoder_objRefReadAndGetObj(self)) == NULL)
		return 1;
	*obj = ref;
	return 0;
}


static int				MSTDecoder_arrayEntryDecode(
struct MSTDecoder*			self,
id					dic)
{
	id				obj;

	if (MSTDecoder_objectDecode(self, &obj, NULL))
		return 1;
	if (MSTObjBuilder_NewArrayVal(dic, obj))
	{
		RELEASE(obj);
		return 1;
	}
	return 0;
}


static int				MSTDecoder_arrayDecode(
struct MSTDecoder*			self,
id*					obj)
{
	unsigned int			cnt;
	unsigned int			idx;
	id				array;

	if (MSTReader_uIntRead(&self->reader, &cnt))
		return 1;
	/* TODO typesafe cast */
	if ((array = (id)MSTObjBuilder_NewArray(cnt)) == NULL)
		return 1;
	MSTDecoder_decodedObjetAdd(self, array);
	for (idx = 0; idx < cnt; idx ++)
		if (MSTDecoder_arrayEntryDecode(self, array))
		{
			RELEASE(array);	/* TODO check that content is freed */
			return 1;
		}
	*obj = array;
	return 0;
}


static int				MSTDecoder_naturalArrayEntryDecode(
struct MSTDecoder*			self,
id					dic)
{
	id				obj;

	/* TODO check boundaries (unsigned 32bits) */
	if (MSTDecoder_nbrDecode(self, &obj))
		return 1;
	if (MSTObjBuilder_NewArrayVal(dic, obj))
	{
		RELEASE(obj);
		return 1;
	}
	return 0;
}


static int				MSTDecoder_naturalArrayDecode(
struct MSTDecoder*			self,
id*					obj)
{
	unsigned int			cnt;
	unsigned int			idx;
	id				array;

	if (MSTReader_uIntRead(&self->reader, &cnt))
		return 1;
	/* TODO typesafe cast */
	if ((array = (id)MSTObjBuilder_NewArray(cnt)) == NULL)
		return 1;
	MSTDecoder_decodedObjetAdd(self, array);
	for (idx = 0; idx < cnt; idx ++)
		if (MSTDecoder_naturalArrayEntryDecode(self, array))
		{
			RELEASE(array);	/* TODO check that content is freed */
			return 1;
		}
	*obj = array;
	return 0;
}


static int				MSTDecoder_coupleObjsDecode(
struct MSTDecoder*			self,
id*					first,
id*					second)
{
	id				lFirst;
	id				lSecond;

	if (MSTDecoder_objectDecode(self, &lFirst, NULL))
		return 1;
	if (MSTDecoder_objectDecode(self, &lSecond, NULL))
	{
		RELEASE(first);
		return 1;
	}
	*first = lFirst;
	*second = lSecond;
	return 0;
}


static int				MSTDecoder_coupleDecode(
struct MSTDecoder*			self,
id*					obj)
{
	id				first;
	id				second;
	id				couple;

	if (MSTDecoder_coupleObjsDecode(self, &first, &second))
		return 1;
	/* TODO typesafe cast */
	if ((couple = (id)MSTObjBuilder_NewCouple(first, second)) == NULL)
	{
		RELEASE(second);
		RELEASE(first);
		return 1;
	}
	MSTDecoder_decodedObjetAdd(self, couple);
	*obj = couple;
	return 0;
}


/*
 * TODO(maybe) move to a MSCBuffer constructor
 */
static CBuffer*				MSTDecoder_Base64DoDecode(
CBuffer*				src)
{
	CBuffer*			dst;

	if ((dst = CCreateBuffer(CBufferLength(src))) == NULL)
		return NULL;
	if (CBufferBase64DecodeAndAppendBytes(dst, CBufferCString(src),
						CBufferLength(src)) == NO)
	{
		printf("Invalid base64 data: %.*s\n", (int)CBufferLength(src),
							CBufferCString(src));
		RELEASE(dst);
		return NULL;
	}
	return dst;
}


/*
 * TODO: choose format
 *	Spec says: original length followed by string.
 * 	Existing implementations have only a string.
 */
static int				MSTDecoder_base64Decode(
struct MSTDecoder*			self,
id*					obj)
{
	CBuffer*			bfr;
	CBuffer*			dec;
	id				dat;

	if ((bfr = MSTReader_newStrRead(&self->reader, 64)) == NULL)
		return 1;
	dec = MSTDecoder_Base64DoDecode(bfr);
	RELEASE(bfr);
	if (dec == NULL)
		return 1;
	/* TODO typesafe cast */
	dat = (id)MSTObjBuilder_NewBuffer(bfr);
	if (dat == NULL)
		return 1;
	*obj = dat;
	return 0;
}


static int				MSTDecoder_EmptyStrDecode(
id*					obj)
{
	id				str;

	/* TODO typesafe cast */
	if ((str = (id)MSTObjBuilder_NewEmptyString()) == NULL)
		return 1;
	*obj = str;
	return 0;
}


static int				MSTDecoder_weakRefDecode(
struct MSTDecoder*			self,
id*					obj)
{
	id				ref;

	/* TODO handle strong/weak ref */
	if ((ref = MSTDecoder_objRefReadAndGetObj(self)) == NULL)
		return 1;
	*obj = ref;
	return 0;
}


static int				MSTDecoder_userObjectDecode(
struct MSTDecoder*			self,
id*					obj,
int					classIdx)
{
	id				classId;
	id				userObj;

	if ((classId = MSTDecoder_classGet(self, (unsigned int)classIdx))
									== NULL)
		return 1;
	/* TODO almost the same as _dictionaryDecode */
	/*MSTDecoder_decodedObjetAdd(self, userObj);*/
	return 0;
}


static int				MSTDecoder_otherTypeDecode(
struct MSTDecoder*			self,
id*					obj,
int					type,
int*					isWeakRef)
{
	int				classIdx;

	if (type < MSTETYPE_USER_CLASS)
	{
		printf("unhandled type: %i\n", type);
		return 1;
	}
	classIdx = (type - MSTETYPE_USER_CLASS) / 2;
	if (MSTDecoder_userObjectDecode(self, obj, classIdx))
		return 1;
	if (isWeakRef != NULL)
		*isWeakRef = type % 2;
	return 0;
}


static int				MSTDecoder_objectDecode(
struct MSTDecoder*			self,
id*					obj,
int*					isWeakRef)
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
		return MSTDecoder_BooleanDecode(0, obj);
	case MSTETYPE_FALSE:
		return MSTDecoder_BooleanDecode(1, obj);
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
	case MSTETYPE_DOUBLE:	/* TODO (maybe) keep int type and check range */
		return MSTDecoder_nbrDecode(self, obj);
	case MSTETYPE_STRING:
		return MSTDecoder_strDecode(self, obj);
	case MSTETYPE_DATE:
		return MSTDecoder_dateDecode(self, obj);
	case MSTETYPE_COLOR:
		return MSTDecoder_colorDecode(self, obj);
	case MSTETYPE_DICTIONARY:
		return MSTDecoder_dictionaryDecode(self, obj);
	case MSTETYPE_STRONGREF:
		return MSTDecoder_strongRefDecode(self, obj);
	case MSTETYPE_ARRAY:
		return MSTDecoder_arrayDecode(self, obj);
	case MSTETYPE_NATURAL_ARRAY:
		return MSTDecoder_naturalArrayDecode(self, obj);
	case MSTETYPE_COUPLE:
		return MSTDecoder_coupleDecode(self, obj);
	case MSTETYPE_BASE64_DATA:
		return MSTDecoder_base64Decode(self, obj);
	case MSTETYPE_DISTANT_PAST:				/* TODO */
		return MSTDecoder_dateDecode(self, obj);
	case MSTETYPE_DISTANT_FUTURE:				/* TODO */
		return MSTDecoder_dateDecode(self, obj);
	case MSTETYPE_EMPTY_STRING:
		return MSTDecoder_EmptyStrDecode(obj);
	case MSTETYPE_WEAKLYREF:
		return MSTDecoder_weakRefDecode(self, obj);
	default:
		return MSTDecoder_otherTypeDecode(self, obj, type, isWeakRef);
	}
}


static int				MSTDecoder_rootObjectDecode(
struct MSTDecoder*			self,
id*					obj)
{
	return MSTDecoder_objectDecode(self, obj, NULL);
}


static int				MSTDecoder_endChk(
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
