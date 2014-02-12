struct					MSTReader;
struct					MSTWriter;


struct					MSTHeader
{
	CBuffer*			ver;
	int				cnt;
	CBuffer*			crc;
};


void					MSTHeader_initNull(
	struct MSTHeader*		self);


int					MSTHeader_init(
	struct MSTHeader*		self,
	const char*			version,
	int				cnt,
	const char*			crc);


int					MSTHeader_initFromReader(
	struct MSTHeader*		self,
	struct MSTReader*		reader);


void					MSTHeader_halt(
	struct MSTHeader*		self);


int					MSTHeader_toWriter(
	struct MSTHeader*		self,
	struct MSTWriter*		reader);


int					MSTHeader_cntGet(
	struct MSTHeader*		self);
