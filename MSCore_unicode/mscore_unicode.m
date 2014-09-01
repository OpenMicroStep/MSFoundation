// mscore_unicode.m, ecb, 131002

#import <Foundation/Foundation.h>
#import "MSCore_Private.h"
#import "UnicodeData.c.h"

/*
static inline void u16Tou8(const char *cIn, char *ret)
  {
  char x; int i;
  unichar c= 0;
  if (cIn) for (i= 0; i<4; i++) {
    x= cIn[i];
    c= 16*c + (unichar)('0'<=x && x<='9'?x-'0':'A'<=x && x<='F'?10+x-'A':0);}
  if (c == 0x0000) {
    ret[0]= 0x00;}
  else if (c <= 0x007F) {
    ret[0]= (char)c; ret[1]= 0x00;}
  else if (c <= 0x07FF) {
    ret[0]= (char)(0xC0 | (((char)(c >> 6)) & 0x1F));
    ret[1]= (char)(0x80 | (((char)(c >> 0)) & 0x3F));
    ret[2]= 0x00;}
  else if (c <= 0xFFFF) {
    ret[0]= (char)(0xE0 | (((char)(c >> 12)) & 0x0F));
    ret[1]= (char)(0x80 | (((char)(c >>  6)) & 0x3F));
    ret[2]= (char)(0x80 | (((char)(c >>  0)) & 0x3F));
    ret[3]= 0x00;}
  else {
    ret[0]= 0x00;}
  if (ret[0]==';' && ret[1]==0x00) {ret[0]= '"'; ret[1]= ';'; ret[2]= '"'; ret[3]= 0x00;}
  }
*/

// byNames= {
//   name= code;
//   }
// byCodes= { OLD
//   "0021"= {
//     "code"= "0021"; str= "!"; "name"= EXCLAMATION MARK; "gc"= Po;
//     "ascii"= 0041 030A;
//     "mac"= code mac (NSNumber) | absent
//     "substitute"= a sub; "substitutionRule"= a rule [NOT another rule];};
//   }
// byCodes= { NEW
//   "0021"= {"a rule"= a substitute;};
//   }
// 1/ prendre les substitutions les plus longues
// 2/ trier les substitutions qui donnent la même chose des autres (et donner leurs résultats)
// 3/ Vérifier que la substitution proposée existe ! (quand elle vient de unicode)

static inline NSString *hexToString(NSString *s) // @"0021" -> @"!"
  {
  unichar c= 0;
  if (s) {
    char x;
    const char *cIn= [s cStringUsingEncoding:NSASCIIStringEncoding];
    if (cIn) while ((x= *cIn++)) {
      c= 16*c + (unichar)('0'<=x && x<='9'?x-'0':'A'<=x && x<='F'?10+x-'A':0);}}
  if (c==0 || c==0xFFFD) return @"";
  else if (c==';') return @";";
  else return [NSString stringWithCharacters:&c length:1];
  }
static inline unichar hexToUnichar(NSString *s) // @"0021" -> 33
  {
  unichar c= 0;
  if (s) {
    char x;
    const char *cIn= [s cStringUsingEncoding:NSASCIIStringEncoding];
    if (cIn) while ((x= *cIn++)) {
      c= 16*c + (unichar)('0'<=x && x<='9'?x-'0':'A'<=x && x<='F'?10+x-'A':0);}}
  return c;
  }

static void setSubstitute(NSMutableDictionary *byCode, id c, id sub, id rule)
// Enregistre un substitut 'sub' selon la règle 'rule' pour le code 'c'
  {
  NSMutableDictionary *d; id r;
  d= [byCode objectForKey:c];
  if (![d objectForKey:@"substitute"]) {
    [d setObject:sub forKey:@"substitute"];
    [d setObject:rule forKey:@"substitutionRule"];}
  else {
    r= [d objectForKey:@"substitutionRule"];
    r= [r stringByAppendingFormat:@" [NOT %@]",rule];
    [d setObject:r forKey:@"substitutionRule"];}
  }

static id readUnicode()
  {
  NSMutableDictionary *dByCode, *dByName, *dc; NSMutableArray *codes;
  id s,a,ae,l,b,code,name,gc,ascii,str,firstCode;
  long iCode,i,ui; id iCodes[0xFFFF];
  dByCode= [NSMutableDictionary new];
  dByName= [NSMutableDictionary new];
  codes= [NSMutableArray new];
  s= [NSString stringWithContentsOfFile:@"/tmp/UnicodeData.txt"
    encoding:NSASCIIStringEncoding error:NULL];
  a= [s componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  for (ae= [a objectEnumerator]; (l= [ae nextObject]);) {
    b= [l componentsSeparatedByString:@";"];
    if ([b count]==15) {
      code= [b objectAtIndex:0];
      gc= [b objectAtIndex:2];
      ascii= [b objectAtIndex:5];
      if ([gc characterAtIndex:0]=='C') str= @"";
      else str= hexToString(code);
      iCode= hexToUnichar(code);
      if ([code length]<5) { // && [code isLessThan:@"DA00"]
        [codes addObject:code];
        dc= [NSMutableDictionary dictionaryWithObjectsAndKeys:
          code,@"code",
          (name= [b objectAtIndex:1]),@"name",
          gc,@"gc", // general category
          ascii,@"ascii",
          str,@"str",
          nil];
        [dByCode setObject:dc forKey:code];
        iCodes[iCode]= dc;
        if ((firstCode= [dByName objectForKey:name])) { // <control>
//NSLog(@"%@ %@ %@",code,firstCode,name);
          setSubstitute(dByCode, code, firstCode, @"Name already found");
          }
        else [dByName setObject:code forKey:name];}}
    else if ([b count]>1) NSLog(@"line %lu",[b count]);}
NSLog(@"%lu codes, %lu codes before 10000, %lu differents codes.",[a count],[dByCode count],[dByName count]);
  for (i=0; i<256; i++) {
    MSByte c= (MSByte)i;
    SES ses= MSMakeSESWithBytes(&c, 1, NSMacOSRomanStringEncoding);
    NSUInteger index= 0;
    ui= (long)SESIndexN(ses, &index);
    [(NSMutableDictionary*)iCodes[ui] setObject:[NSNumber numberWithInt:(int)i] forKey:@"mac"];
    }

  return [NSDictionary dictionaryWithObjectsAndKeys:
    dByCode,@"ByCode",dByName,@"ByName",codes,@"Codes",nil];
  }

static inline NSString *l2s(NSString *s)
// AB -> 0041 0042
  {
  static char l[16]= {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
  char txt[20]; NSUInteger i,n,ti; unichar u;
  for (n= [s length], ti=0, i=0; i<n; i++) {
    u= [s characterAtIndex:i];
    if (i) txt[ti++]= ' ';
    txt[ti++]= l[(u/(16*16*16))%16];
    txt[ti++]= l[(u/(16*16   ))%16];
    txt[ti++]= l[(u/(16      ))%16];
    txt[ti++]= l[(u           )%16];}
  txt[ti++]= 0x00;
  return [NSString stringWithCString:txt encoding:NSASCIIStringEncoding];
  }

static void substitute(NSMutableDictionary *byCode, id c, id sub)
  {
  setSubstitute(byCode, l2s(c), l2s(sub), @"Manual");
  }
static void substituteSome(NSMutableDictionary *byCode)
  {
  substitute(byCode,@"¦",@"|"  ); // ¦ -> |
  substitute(byCode,@"©",@"(c)"); // © -> (c)
  substitute(byCode,@"®",@"(r)"); // ® -> (r)
  substitute(byCode,@"±",@"+-" ); // ± -> +-
  substitute(byCode,@"·",@"."  );
  substitute(byCode,@"Æ",@"AE" );
  substitute(byCode,@"Ð",@"D"  );
  substitute(byCode,@"×",@"x"  );
  substitute(byCode,@"æ",@"ae" );
  substitute(byCode,@"÷",@"/"  );
  substitute(byCode,@"ı",@"i"  );
  substitute(byCode,@"ĸ",@"k"  );
  substitute(byCode,@"Œ",@"OE" );
  substitute(byCode,@"œ",@"oe" );
  substitute(byCode,@"Ƣ",@"OI");
  substitute(byCode,@"ƣ",@"oi");
  substitute(byCode,@"ǈ",@"Lj" );
  substitute(byCode,@"ǋ",@"Nj" );
  substitute(byCode,@"ǲ",@"Dz" );
  substitute(byCode,@"ȷ",@"j"  );
  substitute(byCode,@"ȸ",@"db" );
  substitute(byCode,@"ȸ",@"db" );
  substitute(byCode,@"ȹ",@"qp" );
  substitute(byCode,@"ɢ",@"G"  );
  substitute(byCode,@"ɴ",@"N"  );
  substitute(byCode,@"ɵ",@"o"  );
  substitute(byCode,@"ɶ",@"OE" );
  substitute(byCode,@"Ɖ",@"D"  );
  substitute(byCode,@"ʀ",@"R"  );
  substitute(byCode,@"ʉ",@"u"  );
  substitute(byCode,@"ʏ",@"Y"  );
  substitute(byCode,@"ʗ",@"C"  );
  substitute(byCode,@"ʙ",@"B"  );
  substitute(byCode,@"ʜ",@"H"  );
  substitute(byCode,@"ʟ",@"L"  );
  substitute(byCode,@"ʣ",@"dz" );
  substitute(byCode,@"ʦ",@"ts" );
  substitute(byCode,@"ʨ",@"tc");
  substitute(byCode,@"ʪ",@"ls" );
  substitute(byCode,@"ʫ",@"lz" );
  substitute(byCode,@"ʫ",@"lz" );
  substitute(byCode,@"˂",@"<"  );
  substitute(byCode,@"˃",@">"  );
  substitute(byCode,@"⓫",@"-11");
  substitute(byCode,@"⓬",@"-12");
  substitute(byCode,@"⓭",@"-13");
  substitute(byCode,@"⓮",@"-14");
  substitute(byCode,@"⓯",@"-15");
  substitute(byCode,@"⓰",@"-16");
  substitute(byCode,@"⓱",@"-17");
  substitute(byCode,@"⓲",@"-18");
  substitute(byCode,@"⓳",@"-19");
  substitute(byCode,@"⓴",@"-20");
  substitute(byCode,@"⓿",@"-0" );
  substitute(byCode,@"❶",@"-1" );
  substitute(byCode,@"❷",@"-2" );
  substitute(byCode,@"❸",@"-3" );
  substitute(byCode,@"❹",@"-4" );
  substitute(byCode,@"❺",@"-5" );
  substitute(byCode,@"❻",@"-6" );
  substitute(byCode,@"❼",@"-7" );
  substitute(byCode,@"❽",@"-8" );
  substitute(byCode,@"❾",@"-9" );
  substitute(byCode,@"❿",@"-10");
  substitute(byCode,@"➊",@"-1" );
  substitute(byCode,@"➋",@"-2" );
  substitute(byCode,@"➌",@"-3" );
  substitute(byCode,@"➍",@"-4" );
  substitute(byCode,@"➎",@"-5" );
  substitute(byCode,@"➏",@"-6" );
  substitute(byCode,@"➐",@"-7" );
  substitute(byCode,@"➑",@"-8" );
  substitute(byCode,@"➒",@"-9" );
  substitute(byCode,@"➓",@"-10");
  substitute(byCode,@"⫀",@"⊃+" );
  substitute(byCode,@"⫀",@"⊃+" );
  }

static void findSubstitute(NSMutableDictionary *byCode, NSDictionary *byName)
  {
  NSMutableDictionary *d; id ke,c,n,ns,lookw,looka,substituteCode;
  NSRange rg,rgw,rga; NSUInteger e,ew,ea,l,nsn,nc,nf,i; BOOL fd;
  ns= [NSMutableArray array]; nc= 0; nf= 0;
  for (ke= [byCode keyEnumerator]; (c= [ke nextObject]);) {
    d= [byCode objectForKey:c];
    n= [d objectForKey:@"name"]; l= [n length]; e= 0;
    [ns removeAllObjects];
    lookw= @" WITH "; looka= @" AND ";
    for (fd= YES; fd;) {
      ew= (rgw= [n rangeOfString:lookw options:0 range:NSMakeRange(e, l-e)]).location;
      ea= (rga= [n rangeOfString:looka options:0 range:NSMakeRange(e, l-e)]).location;
      if (ew==NSNotFound && ea==NSNotFound) fd= NO;
      else {
        if      (ew==NSNotFound) {e= ea; rg= rga;}
        else if (ea==NSNotFound) {e= ew; rg= rgw;}
        else {
          if (e) NSLog(@"WITH & AND %@",n);
          if (ew<ea) {e= ew; rg= rgw;}
          else       {e= ea; rg= rga;}}
        [ns addObject:[n substringToIndex:e]];
//if ([ns count]) NSLog(@"%@ %@",n, ns);
        e+= rg.length;}}
//if ([ns count]>1) NSLog(@"%@ %@",n, ns);
    if ((nsn= [ns count])) nc++;
    for (fd= NO, i= 0; !fd && i<nsn; i++) {
      if ((substituteCode= [byName objectForKey:[ns objectAtIndex:nsn-1-i]])) {
        setSubstitute(byCode, c, substituteCode, @"With/And substitution");
        nf++; fd= YES;}}
//if (nsn && !fd) NSLog(@"No substitute for %@ %@ [%@]",c, n, ns);
    }
NSLog(@"%lu substitutes found on %lu possibilities.",nf,nc);
  }

static void substituteRemovableWord(NSString *look, NSMutableDictionary *byCode, NSDictionary *byName)
  {
  NSMutableDictionary *d; id ke,c,n,ns,substituteCode;
  NSRange rgs; NSUInteger e,es,l,nf;
  nf= 0;
  for (ke= [byCode keyEnumerator]; (c= [ke nextObject]);) {
    d= [byCode objectForKey:c];
    if (![d objectForKey:@"sustitute"]) {
      n= [d objectForKey:@"name"]; l= [n length]; e= 0;
      es= (rgs= [n rangeOfString:look options:0 range:NSMakeRange(e, l-e)]).location;
      if (es!=NSNotFound) {
        ns= [n stringByReplacingCharactersInRange:rgs withString:@""];
        if ((substituteCode= [byName objectForKey:ns])) {
          setSubstitute(byCode, c, substituteCode, [look stringByAppendingString:@"removed substitution"]);
          nf++;}
        }}}
NSLog(@"%lu %@substitutions.\n",nf,look);
  }

static void findAscii(NSMutableDictionary *byCode)
  {
  NSMutableDictionary *d; id ke,c,ascii,cs;
  for (ke= [byCode keyEnumerator]; (c= [ke nextObject]);) {
    d= [byCode objectForKey:c];
    ascii= [d objectForKey:@"ascii"];
    if (ascii && ![ascii isEqual:@""]) {
      cs= [ascii componentsSeparatedByString:@" "];
      if ([cs count]>=1 && [[cs objectAtIndex:0] length] &&
          [[cs objectAtIndex:0] characterAtIndex:0]=='<') {
        cs= [cs subarrayWithRange:NSMakeRange(1, [cs count]-1)];}
      if ([cs count]>=1) {
        cs= [cs componentsJoinedByString:@" "];
        setSubstitute(byCode, c, cs, @"Ascii substitution");}}}
  }

static void find(id name, NSMutableDictionary *byCode, NSDictionary *byName)
  {
  NSMutableDictionary *d; id nameCode,ke,c,n; NSUInteger nspc; NSRange rg;
  nameCode= [byName objectForKey:name]; nspc= 0;
  for (ke= [byCode keyEnumerator]; (c= [ke nextObject]);) {
    if (![c isLessThan:@"009F"] && ![c isEqual:nameCode]) {
      d= [byCode objectForKey:c];
      n= [d objectForKey:@"name"];
      if ((rg= [n rangeOfString:name]).location!=NSNotFound &&
          ((rg.location==0 || [n characterAtIndex:rg.location-1]==' ')&&
           (NSMaxRange(rg)==[n length] || [n characterAtIndex:NSMaxRange(rg)]==' '))) {
        if (![d objectForKey:@"substitute"]) {
          NSLog(@"%@ %@ %@",c,[d objectForKey:@"str"],n);
          nspc++;}
        setSubstitute(byCode, c, nameCode, [name stringByAppendingString:@" substitution"]);}}}
if (nspc) NSLog(@"%lu %@ substitutes found.\n\n",nspc,name);
  }
static inline NSString *wStrEscape(NSString *code, NSDictionary *byCode, BOOL escape)
// le str du code, éventuellement escapé
// 0041 -> A - 0022 -> \" - 005C -> '\\'
  {
  id x= [(NSDictionary*)[byCode objectForKey:code] objectForKey:@"str"];
  if (escape) {
    if ([x isEqualToString:@"\\"]) x= @"\\\\";
    else if ([x isEqualToString:@"\""]) x= @"\\\"";
    }
  return x;
  }
static inline NSString *wSubs(NSString *substitute, NSDictionary *byCode, BOOL escape)
// la représentation d'une suite d'unichar hexa
// 0041 0022 005C -> 'A"\' ou 'A\"\\'
  {
  id ss,se,s,a; NSUInteger n;
  ss= [substitute componentsSeparatedByString:@" "];
  if (!(n= [ss count])) return nil;
  else if (n==1) return wStrEscape(substitute, byCode, escape);
  else {
    NSMutableString *r= [NSMutableString string];
    for (se= [ss objectEnumerator]; (s= [se nextObject]);) {
      if ((a= wStrEscape(s, byCode, escape))) {
        [r appendString:a];}}
    return r;}
  }
static void writeCodes(NSArray *codes, NSDictionary *byCode)
  {
  NSMutableDictionary *d; NSMutableString *s;
  id sep,ke,c,n,glyph,substitute,substituteName;
  unichar u; long i,codeMac; id ss,sss,sus,suse,x,ws; NSUInteger susn;
  s= [NSMutableString string]; sep=@"\t";
  [s appendFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@\n",
    @"code",sep,@"name",sep,@"glyph",sep,
    @"s_glyphs",sep,@"s_name",sep,@"s_code",sep,
    @"ascii",sep,@"gc",
    sep,@"rules"];
  [s writeToFile:@"/tmp/UnicodeData.csv" atomically:YES encoding:NSUTF8StringEncoding error:NULL];
  for (ke= [codes objectEnumerator]; (c= [ke nextObject]);) {
    d= [byCode objectForKey:c];
    n= [d objectForKey:@"name"];
    glyph= [d objectForKey:@"str"];
    substitute= [d objectForKey:@"substitute"];
    substituteName= [(NSDictionary*)[byCode objectForKey:substitute] objectForKey:@"name"];
//NSLog(@"%@%@%@%@%@%@%@%@%@%@%@\n",
//      c,sep,hexToString(c),sep,n,sep,substitute,sep,hexToString(substitute),sep,substituteName);
//NSLog(@"%@",s);
    [s appendFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@\n",
      c,sep,n,sep,glyph,sep,
      wSubs(substitute,byCode,0),sep,substituteName,sep,substitute,sep,
      [d objectForKey:@"ascii"],sep,[d objectForKey:@"gc"],
      sep,[d objectForKey:@"substitutionRule"]];}
  [s writeToFile:@"/tmp/UnicodeData.csv" atomically:YES encoding:NSUTF8StringEncoding error:NULL];
NSLog(@"%lu",[codes count]);
//NSLog(@"%@",s);
  // Fabrication du fichier UnicodeData.c.h
  i= -1;
  s= [NSMutableString string];   // les unichar-s
  ss= [NSMutableString string];  // les unicharInfo-s
  sss= [NSMutableString string]; // le tableau final
  [s appendString:@"// NULL: le caractère n’existe pas\n"];
  [s appendString:@"// {NULL, ...}: le caractère ne se substitue pas\n"];
  [s appendString:@"// {caractère(s) de substitution, codeMacRoman, ...}\n"];
  [s appendString:@"\n"];
  [s appendString:@"typedef struct unicharInfoStruct {\n"];
  [s appendString:@"  unichar *substitution;\n"];
  [s appendString:@"  unsigned char mac;}\n"];
  [s appendString:@"unicharInfo;\n"];
  [s appendString:@"\n"];
  [s appendString:@"unichar\n"];
  for (ke= [codes objectEnumerator]; (c= [ke nextObject]);) {
    u= hexToUnichar(c);
    while (++i<(long)u) [sss appendFormat:@"NULL, // %ld\n",i];
    d= [byCode objectForKey:c];
    glyph= [d objectForKey:@"str"];
    substitute= [d objectForKey:@"substitute"];
    codeMac= [d objectForKey:@"mac"]?[[d objectForKey:@"mac"] intValue]:0;
    sus= [substitute componentsSeparatedByString:@" "];
    susn= [sus count];
    if (!susn && !codeMac) [sss appendString:@"&xEmpty"];
    else {
      [sss appendFormat:@"&x%@",c];
      if (!susn) [ss appendFormat:@"x%@= {NULL, %ld},\n",c,codeMac];
      else {
        [ss appendFormat:@"x%@= {u%@, %ld},\n",c,c,codeMac];
        [s appendFormat:@"u%@[]= {%ld",c,susn];
        for (suse= [sus objectEnumerator]; (x= [suse nextObject]);) {
          [s appendFormat:@", %u", hexToUnichar(x)];}
        [s appendString:@"},\n"];}}
    ws= wSubs(substitute,byCode,0);
    if (i==8232 || i==8233) glyph=@"";
    [sss appendFormat:@", // %ld-%@-%@-\n",i,glyph,ws?ws:@""];
    }
  [s appendString:@"*uEmpty= NULL;\n"];
  [s appendString:@"unicharInfo\n"];
  [s appendString:ss];
  [s appendString:@"xEmpty= {NULL, 0};\n"];
  [s appendString:@"unicharInfo *__x[]= {\n"];
  [s appendString:sss];
  [s appendString:@"NULL, // 65534\n"];
  [s appendString:@"NULL  // 65535\n"];
  [s appendString:@"};\n"];
  [s writeToFile:@"/tmp/UnicodeData.c.h" atomically:YES encoding:NSUTF8StringEncoding error:NULL];
  }
static void substituteUnichar(unichar u, unsigned char *outStr)
  {
  unicharInfo *y; NSUInteger i,n; unichar *us;
  y= __x[u];
  if (y) {
    if (y->mac) {
      n= strlen((char*)outStr);
      outStr[n]= y->mac; outStr[n+1]= 0;}
    else if ((us= y->substitution) && (n= us[0])) {
      for (i= 0; i<n; i++) substituteUnichar(us[i+1],outStr);}}
  }
static inline NSString *substitution(NSString *s)
  {
  unsigned char outString[1024];
  outString[0]= 0;
  NSUInteger i,n;
  n= [s length];
  for (i=0; i<n; i++) {
    substituteUnichar([s characterAtIndex:i],outString);}
  return [NSString stringWithCString:(char*)outString encoding:NSMacOSRomanStringEncoding];
  }

int main(int argc, const char *argv[])
  {
  static NSString *fs[]={
    @"SPACE",
    @"EXCLAMATION MARK",
    @"QUOTATION MARK",
    @"NUMBER SIGN",
    @"DOLLAR SIGN",
    @"PERCENT SIGN",
    @"AMPERSAND",
    @"APOSTROPHE",
    @"LEFT PARENTHESIS" ,
    @"RIGHT PARENTHESIS",
    @"ASTERISK",
    @"PLUS SIGN",
    @"TURNED COMMA",
    @"COMMA",
    @"HYPHEN-MINUS",
    @"FULL STOP",
    @"REVERSE SOLIDUS",
    @"SOLIDUS",
    @"DIGIT ZERO",
    @"DIGIT ONE",
    @"DIGIT TWO",
    @"DIGIT THREE",
    @"DIGIT FOUR",
    @"DIGIT FIVE",
    @"DIGIT SIX",
    @"DIGIT SEVEN",
    @"DIGIT EIGHT",
    @"DIGIT NINE",
    @"SEMICOLON",
    @"LESS-THAN SIGN",
    @"EQUALS SIGN",
    @"GREATER-THAN SIGN",
    @"QUESTION MARK",
    @"COMMERCIAL AT",
    @"LEFT SQUARE BRACKET",
    @"RIGHT SQUARE BRACKET",
    @"CIRCUMFLEX ACCENT",
    @"LOW LINE",
    @"GRAVE ACCENT",
    @"LEFT CURLY BRACKET",
    @"RIGHT CURLY BRACKET",
    @"DOUBLE VERTICAL LINE",
    @"VERTICAL LINE",
    @"NOT TILDE",
    @"TILDE",
    @"DOUBLE PRIME",
    @"PRIME",
    @"DOUBLE ACUTE ACCENT",
    @"ACUTE ACCENT",
    @"LOGICAL OR",
    @"LOGICAL AND",
    NULL};
  
  NSAutoreleasePool *pool= [NSAutoreleasePool new];
  NSMutableDictionary *code= nil, *byCode, *byName, *d;
  id ke, c,name,*f;
  int err= 0,i;
  MSByte *s; NSUInteger index,l,lu; SES ses; unichar u[10]; id o;
  argc= 0;
  argv= NULL;
  code= readUnicode();
  byCode= [code objectForKey:@"ByCode"];
  byName= [code objectForKey:@"ByName"];
  substituteSome(byCode);
  findSubstitute(byCode,byName);
  findAscii(byCode);
  for (f= fs; *f; f++) {
    find(*f,byCode,byName);
    c= [byName objectForKey:*f];
    d= [byCode objectForKey:c];
    [d setObject:@"DONE" forKey:@"find"];
    }
  substituteRemovableWord(@"SMALL ", byCode,byName);
  substituteRemovableWord(@"DOUBLE ", byCode,byName);
  for (i= 0, ke= [byCode keyEnumerator]; NO && (c= [ke nextObject]);) {
    d= [byCode objectForKey:c];
    name= [d objectForKey:@"name"];
    if (![d objectForKey:@"find"] &&
        [[d objectForKey:@"gc"] characterAtIndex:0]!='C' &&
        [[d objectForKey:@"gc"] characterAtIndex:0]!='L' &&
        [name rangeOfString:@"BRAILLE"].location==NSNotFound) {
      i++;
      find(name ,byCode,byName);}}
  writeCodes([code objectForKey:@"Codes"],[code objectForKey:@"ByCode"]);
  NSLog(@"%@ -> %@",@"toto",substitution(@"toto"));
  NSLog(@"%@ -> %@",@"tœtæ",substitution(@"tœtæ"));
  NSLog(@"%@ -> %@",@"ö¼Ðü",substitution(@"ö¼Ðü"));
  NSLog(@"%@ -> %@",@"00A0  ",substitution(@"00A0  "));
  NSLog(@"%@ -> %@",@"00A1 ¡",substitution(@"00A1 ¡"));
  s= (MSByte*)"¡±ĀϿḀ⓿⣿㊿﹫"; // a1 b1 100 3ff 1e00 24ff 28ff 32bf fe6b
  l= (NSUInteger)strlen((char*)s);
  ses= MSMakeSESWithBytes(s, l, NSUTF8StringEncoding);
  NSLog(@"%lu",l);
  for (lu= index= 0; index<l;) {
    NSLog(@"%lu %hu",index,(u[lu++]= SESIndexN(ses, &index)));}
  o= [NSString stringWithCharacters:u length:lu];
  NSLog(@"%lu %@",lu,o);
  [pool release];
  return err;
  }
