enum					JsonLexTk
{
	JsonLexTk_eof			= 0,
	JsonLexTk_err			= 1,
	JsonLexTk_nbr			= 2,
	JsonLexTk_str			= 3,
	JsonLexTk_objBgn		= 4,
	JsonLexTk_objEnd		= 5,
	JsonLexTk_arrayBgn		= 6,
	JsonLexTk_arrayEnd		= 7,
	JsonLexTk_sep			= 8,
	JsonLexTk_kvSep			= 9
};


int					JsonLexTk_charGet(
	enum JsonLexTk			me,
	char*				dst);
