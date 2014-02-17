enum					MSTReader_state
{
	MSTReader_stateErr		= 0,
	MSTReader_stateBgn		= 1,
	MSTReader_stateSep		= 2,
	MSTReader_stateTkn		= 3,
	MSTReader_stateEnd		= 4
};


struct					MSTReader
{
	struct JsonLex			JsonLex;
	enum MSTReader_state		state;
	int				tkCnt;
};


/*
 * bfr		MSTE buffer to decode
 */
void					MSTReader_init(
	struct MSTReader*		self,
	CBuffer*			bfr);



/*
 * fmt		printf format string
 * ...		printf arguments
 *
 * returns 1
 */
int					MSTReader_err(
	struct MSTReader*		self,
	const char*			fmt,
					...);


/*
 * returns current position in buffer
 */
int					MSTReader_idxGet(
	struct MSTReader*		self);

/*
 * returns
 *	count of tokens previously read
 */
int					MSTReader_tkCntGet(
	struct MSTReader*		self);


/*
 * returns
 *	0	ok
 *	else	failed
 */
int					MSTReader_endRead(
	struct MSTReader*		self);


/*
 * bfr		destination buffer to store next token to
 * returns
 *	the type of the token that was read
 */
enum MSTReaderTk			MSTReader_tokenRead(
	struct MSTReader*		self,
	CBuffer*			bfr);


/*
 * pBfr		pointer to the pointer where store the newly allocated buffer
 *		pointer
 * expectedLen	the initial length of the buffer
 *
 * returns
 *	the type of the token that was read
 */
enum MSTReaderTk			MSTReader_newTokenRead(
	struct MSTReader*		self,
	CBuffer**			pBfr,
	int				expectedLen);


/*
 * bfr		buffer to store the number to
 *		(bytes as they were in the input stream)
 *
 * returns:
 *	0	ok
 *	else	failed
 */
int					MSTReader_nbrRead(
	struct MSTReader*		self,
	CBuffer*			bfr);


/*
 * bfr		buffer to store the string to
 *		(quotes and escape sequences removed)
 *
 * returns:
 *	0	ok
 *	else	failed
 */
int					MSTReader_strRead(
	struct MSTReader*		self,
	CBuffer*			bfr);


/*
 * expectedLen	expected length of the number to read
 *
 * returns:
 *	NULL	failed
 *	else	a pointer to a newly allocated CBuffer holding the number
 *		(bytes as they were in the input stream)
 */
CBuffer*				MSTReader_newNbrRead(
	struct MSTReader*		self,
	int				expectedLen);


/*
 * expectedLen	expected length of the string to read
 *
 * returns:
 *	NULL	failed
 *	else	a pointer to a newly allocated CBuffer holding the string
 *		(quotes and escape sequences removed)
 */
CBuffer*				MSTReader_newStrRead(
	struct MSTReader*		self,
	int				expectedLen);


/*
 * dst		pointer to the destination long long
 *
 * returns:
 *	0	ok
 *	else	failed
 */
int					MSTReader_longLongRead(
	struct MSTReader*		self,
	long long*			dst);


/*
 * dst		pointer to the destination unsigned long long
 *
 * returns:
 *	0	ok
 *	else	failed
 */
int					MSTReader_uLongLongRead(
	struct MSTReader*		self,
	unsigned long long*		dst);


/*
 * dst		pointer to the destination long long
 * min		minimum value
 * max		maximum value
 *
 * returns:
 *	0	ok
 *	else	failed
 */
int					MSTReader_rangeLongLongRead(
	struct MSTReader*		self,
	long long*			dst,
	int				min,
	int				max);


/*
 * dst		pointer to the destination unsigned long long
 * min		minimum value
 * max		maximum value
 *
 * returns:
 *	0	ok
 *	else	failed
 */
int					MSTReader_rangeULongLongRead(
	struct MSTReader*		self,
	unsigned long long*		dst,
	unsigned int			min,
	unsigned int			max);


/*
 * dst		pointer to the destination int
 *
 * returns:
 *	0	ok
 *	else	failed
 */
int					MSTReader_intRead(
	struct MSTReader*		self,
	int*				dst);


/*
 * dst		pointer to the destination unsigned int
 *
 * returns:
 *	0	ok
 *	else	failed
 */
int					MSTReader_uIntRead(
	struct MSTReader*		self,
	unsigned int*			dst);


/*
 * returns:
 *	NULL	failed
 *	else	pointer to the newly allocated string array
 */
CArray*					MSTReader_strArrayRead(
	struct MSTReader*		self);
