struct					MSTDecoder
{
	CBuffer*			bfr;
	struct MSTReader		reader;
	struct MSTHeader		header;
	CArray*				classes;
	CArray*				keys;
	CArray*				objects;
};


/*
 * bfr		MSTE buffer to decode
 */
void					MSTDecoder_init(
	struct MSTDecoder*		self,
	CBuffer*			bfr);


void					MSTDecoder_halt(
	struct MSTDecoder*		self);


/*
 * returns:
 *	0	ok
 *	else	failed
 */
int					MSTDecoder_run(
	struct MSTDecoder*		self);


/*
 * returns:
 *	0	ok
 *	else	failed
 */
int					MSTDecoder_Run(
	CBuffer*			self);
