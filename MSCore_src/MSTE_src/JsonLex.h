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
 * vaLst	printf arguments
 */
enum JsonLexTk				JsonLex_verr(
	struct JsonLex*			self,
	const char*			fmt,
	va_list*			vaLst);


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


/*
 * returns	the type of the next token
 */
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


/*
 * returns current possition in buffer
 */
int					JsonLex_idxGet(
	struct JsonLex*			self);
