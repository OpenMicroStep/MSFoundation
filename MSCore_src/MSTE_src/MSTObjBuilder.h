/*
 * All functions here are aimed to provide an abstraction of
 * the creation of objects beeing deserealized.
 * The idea beeing that we may build either C, C++, or Objective C objects.
 * We could also leave the possibility to provide implementations
 * that build custom objects.
 *
 * They all take the parsed data and return a pointer to the built object
 * (unless stated otherwise).
 * For now the returned type of objects are MSCore types.
 * So the return type should be changed to ensure abstraction.
 */


CDecimal*				MSTObjBuilder_NewDecimalFromLong(
	long				val);


/*
 * bfr		buffer holding the JSON number
 */
CDecimal*				MSTObjBuilder_NewDecimal(
	CBuffer*			bfr);


/* TODO replace by CString */
CBuffer*				MSTObjBuilder_NewStr(
	CBuffer*			self);


CDate*					MSTObjBuilder_NewDate(
	int				sse);


CColor*					MSTObjBuilder_NewColor(
	long long			rgb);


CDictionary*				MSTObjBuilder_NewDictionary(
	unsigned int			cnt);


int					MSTObjBuilder_NewDictionaryKeyVal(
	id				dic,
	id				key,
	id				val);


CArray*					MSTObjBuilder_NewArray(
	unsigned int			cnt);


int					MSTObjBuilder_NewArrayVal(
	id				array,
	id				val);


CCouple*				MSTObjBuilder_NewCouple(
	id				first,
	id				second);


CBuffer*				MSTObjBuilder_NewBuffer(
	CBuffer*			self);


CBuffer*				MSTObjBuilder_NewEmptyString(void);


CDictionary*				MSTObjBuilder_NewObj(
	unsigned int			cnt,
	id				classId);


int					MSTObjBuilder_NewObjKeyVal(
	id				dic,
	id				key,
	id				val);
