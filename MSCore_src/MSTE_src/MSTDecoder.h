struct					MSTDecoder
{
	CBuffer*			bfr;
	struct MSTReader		reader;
	struct MSTHeader		header;
	CArray*				classes;
	CArray*				keys;
	CArray*				objects;
};


void					MSTDecoder_init(
	struct MSTDecoder*		self,
	CBuffer*			bfr);


void					MSTDecoder_halt(
	struct MSTDecoder*		self);


int					MSTDecoder_run(
	struct MSTDecoder*		self);


int					MSTDecoder_Run(
	CBuffer*			self);
