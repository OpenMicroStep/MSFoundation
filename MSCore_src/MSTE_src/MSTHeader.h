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


/*
 * version	string holding a MSTE version
 * cnt		MSTE header token count
 * crc		string holding a MSTR crc
 *
 * returns
 *	0	ok
 *	else	failed
 */
int					MSTHeader_init(
	struct MSTHeader*		self,
	const char*			version,
	int				cnt,
	const char*			crc);


/*
 * reader	the MSTEReader to read tokens from
 * 
 * returns:
 *	0	ok
 *	1	failed
 */
int					MSTHeader_initFromReader(
	struct MSTHeader*		self,
	struct MSTReader*		reader);


void					MSTHeader_halt(
	struct MSTHeader*		self);


/*
 * writer	the MSTWriter to write to
 *
 * returns
 *	0	ok
 *	1	failed
 */
int					MSTHeader_toWriter(
	struct MSTHeader*		self,
	struct MSTWriter*		writer);


/*
 * returns
 *	token count from this header
 */
int					MSTHeader_cntGet(
	struct MSTHeader*		self);
