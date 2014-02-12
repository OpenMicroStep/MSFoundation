struct					JsonLex
{
	CBuffer*			bfr;
	int				idx;
};


void					JsonLex_init(
	struct JsonLex*			self,
	CBuffer*			bfr);


enum JsonLexTk				JsonLex_err(
	struct JsonLex*			self,
	const char*			fmt,
					...);

enum JsonLexTk				JsonLex_tokenPeek(
	struct JsonLex*			self);


enum JsonLexTk				JsonLex_tokenRead(
	struct JsonLex*			self,
	CBuffer*			bfr);
