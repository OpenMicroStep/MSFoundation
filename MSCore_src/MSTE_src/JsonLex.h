struct					JsonLex
{
	CBuffer*			bfr;
	int				idx;
};


/*
 * bfr		buffer to parse
 */
void					JsonLex_init(
	struct JsonLex*			self,
	CBuffer*			bfr);


/*
 * fmt		printf format string
 * ...		printf arguments
 *
 * returns:	JsonLexTk_err
 */
enum JsonLexTk				JsonLex_err(
	struct JsonLex*			self,
	const char*			fmt,
					...);


enum JsonLexTk				JsonLex_tokenPeek(
	struct JsonLex*			self);


/*
 * bfr		the destination buffer to store the token to
 *
 * returns:	the type of the read token
 */
enum JsonLexTk				JsonLex_tokenRead(
	struct JsonLex*			self,
	CBuffer*			bfr);
