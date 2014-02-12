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


void					MSTReader_init(
	struct MSTReader*		self,
	CBuffer*			bfr);


int					MSTReader_tkCntGet(
	struct MSTReader*		self);


int					MSTReader_endRead(
	struct MSTReader*		self);


enum MSTReaderTk			MSTReader_tokenRead(
	struct MSTReader*		self,
	CBuffer*			bfr);


int					MSTReader_nbrRead(
	struct MSTReader*		self,
	CBuffer*			bfr);


int					MSTReader_strRead(
	struct MSTReader*		self,
	CBuffer*			bfr);


CBuffer*				MSTReader_newNbrRead(
	struct MSTReader*		self,
	int				expectedLen);


CBuffer*				MSTReader_newStrRead(
	struct MSTReader*		self,
	int				expectedLen);


int					MSTReader_intRead(
	struct MSTReader*		self,
	int*				dst);


CArray*					MSTReader_strArrayRead(
	struct MSTReader*		self);
