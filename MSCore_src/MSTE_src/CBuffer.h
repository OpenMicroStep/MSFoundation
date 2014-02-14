/* TODO move to MSCore/MSCBuffer */


/*
 * bfr		a buffer containing an error
 * idx		the index of the error
 * fmt		printf format string
 * vaLst	printf arguments
 */
void					CBuffer_verrAt(
	CBuffer*			bfr,
	int				idx,
	const char*			fmt,
	va_list*			vaLst);


/*
 * bfr		a buffer containing an error
 * idx		the index of the error
 * ret		the error to return
 * fmt		printf format string
 * vaLst	printf arguments
 *
 * returns:	value of ret
 */
int					CBuffer_verrAtReturn(
	CBuffer*			bfr,
	int				idx,
	int				ret,
	const char*			fmt,
	va_list*			vaLst);


/*
 * bfr		a buffer containing an error
 * idx		the index of the error
 * fmt		printf format string
 * ...		printf arguments
 */
void					CBuffer_errAt(
	CBuffer*			bfr,
	int				idx,
	const char*			fmt,
					...);


/*
 * bfr		a buffer containing an error
 * idx		the index of the error
 * ret		the error to return
 * fmt		printf format string
 * ...		printf arguments
 *
 * returns:	value of ret
 */
int					CBuffer_errAtReturn(
	CBuffer*			bfr,
	int				idx,
	int				ret,
	const char*			fmt,
					...);


/*
 * self		a buffer
 * bgnIdx	begin index
 * dst		destination buffer
 *
 * returns
 *	0	ok
 *	else	failed
 */
int					CBuffer_nbrRead(
	CBuffer*			self,
	int				bgnIdx,
	CBuffer*			dst);
