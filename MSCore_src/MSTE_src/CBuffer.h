/* TODO move to MSCore/MSCBuffer */


void					CBuffer_verrAt(
	CBuffer*			bfr,
	int				idx,
	const char*			fmt,
	va_list*			vaLst);


int					CBuffer_verrAtReturn(
	CBuffer*			bfr,
	int				idx,
	int				ret,
	const char*			fmt,
	va_list*			vaLst);


void					CBuffer_errAt(
	CBuffer*			bfr,
	int				idx,
	const char*			fmt,
					...);


int					CBuffer_errAtReturn(
	CBuffer*			bfr,
	int				idx,
	int				ret,
	const char*			fmt,
					...);


int					CBuffer_nbrRead(
	CBuffer*			self,
	int				bgnIdx,
	CBuffer*			dst);
