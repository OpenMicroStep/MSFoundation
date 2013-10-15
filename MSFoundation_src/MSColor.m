/* MSColor.m
 
 This file is is a part of the MicroStep Framework.
 
 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011
 
 Herve Malaingre : herve@malaingre.com
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr
 
 
 This software is a computer program whose purpose is to [describe
 functionalities and technical features of your software].
 
 This software is governed by the CeCILL-C license under French law and
 abiding by the rules of distribution of free software.  You can  use,
 modify and/ or redistribute the software under the terms of the CeCILL-C
 license as circulated by CEA, CNRS and INRIA at the following URL
 "http://www.cecill.info".
 
 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability.
 
 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or
 data to be ensured and,  more generally, to use and operate it in the
 same conditions as regards security.
 
 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL-C license and that you accept its terms.
 
 */

#import "MSFoundationPrivate_.h"

#define MS_COLOR_LAST_VERSION 201

#define LIGHTER(X)   (float)2.0*(X)*(X)/(float)3.0+(X)/(float)2.0+(float)0.25
#define DARKER(X)    -(X)*(X)/(float)3.0+(float)5.0*(X)/(float)6.0
#define OPAQUE_COLOR ((MSUInt)0xff)

Class __MSColorClass= Nil ;
Class __MSIndexedColorClass= Nil ;

@implementation MSColor

+ (void)initialize
{
  if ([self class] == [MSColor class]) {
    [MSColor setVersion:MS_COLOR_LAST_VERSION] ;
  }
}

#pragma mark Create functions

MSColor *MSCreateColor(MSUInt rgba)
{
  return (MSColor*)CCreateColor(
    (MSByte)((rgba >> 24) & 0xff),
    (MSByte)((rgba >> 16) & 0xff),
    (MSByte)((rgba >>  8) & 0xff),
    (MSByte)((rgba      ) & 0xff));
}

MSColor *MSCreateCSSColor(MSUInt trgb)
{
  return (MSColor*)CCreateColor(
    (MSByte)((trgb >> 16) & 0xff),
    (MSByte)((trgb >>  8) & 0xff),
    (MSByte)((trgb      ) & 0xff),
    (MSByte)(255 - ((trgb >> 24) & 0xff)));
}

static inline MSColor *_MSCreateComponentsColor(float rf, float gf, float bf, float af)
{
  return (MSColor*)CCreateColor(
    (MSByte)(MIN(1.0, rf)*255),
    (MSByte)(MIN(1.0, gf)*255),
    (MSByte)(MIN(1.0, bf)*255),
    (MSByte)(MIN(1.0, af)*255));
}
static inline MSColor *_MSAutoComponentsColor(float rf, float gf, float bf, float af)
{
  return AUTORELEASE(_MSCreateComponentsColor(rf, gf, bf, af));
}

#pragma mark Class methods

+ (MSColor *)colorWithRGBAValue:(MSUInt)color
{ return AUTORELEASE(MSCreateColor(color)) ; }

+ (MSColor *)colorWithCSSValue:(MSUInt)color // TTRRGGBB
{ return AUTORELEASE(MSCreateCSSColor(color)) ; }

+ (MSColor *)colorWithRed:(MSByte)red green:(MSByte)green blue:(MSByte)blue
{ return AUTORELEASE((MSColor*)CCreateColor(red, green, blue, OPAQUE_COLOR)) ; }

+ (MSColor *)colorWithRed:(MSByte)red green:(MSByte)green blue:(MSByte)blue opacity:(MSByte)alpha
{ return AUTORELEASE((MSColor*)CCreateColor(red, green, blue, alpha)) ; }

+ (MSColor *)colorWithRedComponent:(float)red greenComponent:(float)green blueComponent:(float)blue
{ return _MSAutoComponentsColor(red, green, blue, 1.0) ; }

+ (MSColor *)colorWithRedComponent:(float)red greenComponent:(float)green blueComponent:(float)blue alphaComponent:(float)alpha
{ return _MSAutoComponentsColor(red, green, blue, alpha) ; }

#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone
{
  return CColorCopy(self);
  zone= NULL; // unused parameter
}

#pragma mark Standard methods

- (BOOL)isTrue { return ([self opacity] > 0 ? YES : NO) ; }

- (BOOL)isEqual:(id)object
{
  if (object == (id)self) return YES ;
  if (!object || ![object conformsToProtocol:@protocol(MSColor)]) return NO ;
  return [self rgbaValue] == [(id <MSColor>)object rgbaValue] ;
}

- (unsigned int)unsignedIntValue { return (unsigned int)[self rgbaValue] ; }

- (NSString *)toString { return ([self opacity] == OPAQUE_COLOR ? [NSString stringWithFormat:@"#%02x%02x%02x", [self red], [self green], [self blue]] : [NSString stringWithFormat:@"#%02x%02x%02x%02x", [self transparency], [self red], [self green], [self blue]]) ; }
- (NSString *)description { return [NSString stringWithFormat:@"<color #%02x%02x%02x%02x>", [self red], [self green], [self blue], [self opacity]] ; }
- (NSString *)htmlRepresentation { return [NSString stringWithFormat:@"#%02x%02x%02x", [self red], [self green], [self blue]] ; } // html representation does not know about opacity
- (NSString *)jsonRepresentation { return [NSString stringWithFormat:@"\"%@\"", [self toString]] ; }

#pragma mark MSColor protocol

- (float)redComponent   { return ((float)[self red    ])/(float)255.0 ; }
- (float)greenComponent { return ((float)[self green  ])/(float)255.0 ; }
- (float)blueComponent  { return ((float)[self blue   ])/(float)255.0 ; }
- (float)alphaComponent { return ((float)[self opacity])/(float)255.0 ; }
- (float)cyanComponent
{
  float C= (float)1.0 - ((float)[self red  ])/(float)255.0 ;
  float M= (float)1.0 - ((float)[self green])/(float)255.0 ;
  float Y= (float)1.0 - ((float)[self blue ])/(float)255.0 ;
  float K= (float)1.0 ;
  if ( C < K ) K= C ;
  if ( M < K ) K= M ;
  if ( Y < K ) K= Y ;
  if (K >= 1.0) return 0.0 ;
  return (C - K) / (1 - K) ;
  
}
- (float)magentaComponent
{
  float C= (float)1.0 - ((float)[self red  ])/(float)255.0 ;
  float M= (float)1.0 - ((float)[self green])/(float)255.0 ;
  float Y= (float)1.0 - ((float)[self blue ])/(float)255.0 ;
  float K= (float)1.0 ;
  if ( C < K ) K= C ;
  if ( M < K ) K= M ;
  if ( Y < K ) K= Y ;
  if (K >= 1.0) return 0.0 ;
  return (M - K) / (1 - K) ;
}
- (float)yellowComponent
{
  float C= (float)1.0 - ((float)[self red  ])/(float)255.0 ;
  float M= (float)1.0 - ((float)[self green])/(float)255.0 ;
  float Y= (float)1.0 - ((float)[self blue ])/(float)255.0 ;
  float K= (float)1.0 ;
  if ( C < K ) K= C ;
  if ( M < K ) K= M ;
  if ( Y < K ) K= Y ;
  if (K >= 1.0) return 0.0 ;
  return (Y - K) / (1 - K) ;
}
- (float)blackComponent
{
  float C= (float)1.0 - ((float)[self red  ])/(float)255.0 ;
  float M= (float)1.0 - ((float)[self green])/(float)255.0 ;
  float Y= (float)1.0 - ((float)[self blue ])/(float)255.0 ;
  float K= 1.0 ;
  if ( C < K ) K= C ;
  if ( M < K ) K= M ;
  if ( Y < K ) K= Y ;
  return K ;
}

// this 4 methods are considered as internal primitives for MSColor
- (MSByte)red          { return CColorRedValue         ((CColor*)self) ; }
- (MSByte)green        { return CColorGreenValue       ((CColor*)self) ; }
- (MSByte)blue         { return CColorBlueValue        ((CColor*)self) ; }
- (MSByte)opacity      { return CColorOpacityValue     ((CColor*)self) ; }
- (MSByte)transparency { return CColorTransparencyValue((CColor*)self) ; }

- (BOOL)isPaleColor { return CColorIsPale   ((CColor*)self) ; }
- (float)luminance  { return CColorLuminance((CColor*)self) ; }
- (MSUInt)rgbaValue { return CColorRGBAValue((CColor*)self) ; }
- (MSUInt)cssValue  { return CColorCSSValue ((CColor*)self) ; }

- (id <MSColor>)lighterColor
{
  float rf= [self redComponent  ] ;
  float gf= [self greenComponent] ;
  float bf= [self blueComponent ] ;
  return _MSAutoComponentsColor(LIGHTER(rf), LIGHTER(gf), LIGHTER(bf), [self alphaComponent]) ;
}

- (id <MSColor>)darkerColor
{
  float rf= [self redComponent  ] ;
  float gf= [self greenComponent] ;
  float bf= [self blueComponent ] ;
  return _MSAutoComponentsColor(DARKER(rf), DARKER(gf), DARKER(bf), [self alphaComponent]) ;
}

- (id <MSColor>)lightestColor
{
  float rf= [self redComponent  ] ;
  float gf= [self greenComponent] ;
  float bf= [self blueComponent ] ;
  rf= LIGHTER(rf) ;
  gf= LIGHTER(gf) ;
  bf= LIGHTER(bf) ;
  return _MSAutoComponentsColor(LIGHTER(rf), LIGHTER(gf), LIGHTER(bf), [self alphaComponent]) ;
}

- (id <MSColor>)darkestColor
{
  float rf= [self redComponent  ] ;
  float gf= [self greenComponent] ;
  float bf= [self blueComponent ] ;
  rf= DARKER(rf) ;
  gf= DARKER(gf) ;
  bf= DARKER(bf) ;
  return _MSAutoComponentsColor(DARKER(rf), DARKER(gf), DARKER(bf), [self alphaComponent]) ;
}

- (id <MSColor>)matchingVisibleColor { return CColorIsPale((CColor*)self) ? [self darkestColor] : [self lightestColor] ; }

- (id <MSColor>)colorWithAlpha:(MSByte)opacity
{
  return AUTORELEASE((MSColor*)CCreateColor([self red], [self green], [self blue], opacity)) ;
}

- (BOOL)isEqualToColorObject:(id <MSColor>)color
{
  return CColorEquals((CColor*)self, (CColor*)color) ;
}

- (NSComparisonResult)compareToColorObject:(id <MSColor>)color
{
  return CColorsCompare((CColor*)self, (CColor*)color) ;
}

#pragma mark NSCoding

- (Class)classForCoder     { return __MSColorClass ; }
- (Class)classForAchiver   { return [self classForCoder] ; }
- (Class)classForPortCoder { return [self classForCoder] ; }

- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder
{
  if ([encoder isBycopy]) return self;
  return [super replacementObjectForPortCoder:encoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  MSUInt u= [self rgbaValue] ;
  if ([aCoder allowsKeyedCoding]) {
    MSInt i= *((MSInt *)&u) ;
    [aCoder encodeInt32:i forKey:@"color"] ;
  }
  else {
    [aCoder encodeValueOfObjCType:@encode(MSUInt) at:&u] ;
  }
}

- (id)initWithCoder:(NSCoder *)aDecoder
// this class must not be dearchived
{
  ASSIGN(self,nil) ;
  return nil ;
  aDecoder= nil; // unused parameter
}

@end

#pragma mark ********** Clusters classes **********

@interface _MSRGBAColor : MSColor
{ 
@protected
#ifdef __BIG_ENDIAN__
  MSUInt _r:8;
  MSUInt _g:8;
  MSUInt _b:8;
  MSUInt _a:8;
#else
  MSUInt _a:8;
  MSUInt _b:8;
  MSUInt _g:8;
  MSUInt _r:8;
#endif
}
@end
@interface _MSIndexedColor : _MSRGBAColor
{
@private
  NSString *_name ;
  int _colorIndex ;
}
@end
#define MS_RGBACOLOR_LAST_VERSION  301

@implementation _MSRGBAColor : MSColor
+ (void)load { if (!__MSColorClass) {  __MSColorClass= [_MSRGBAColor class] ; }}
+ (void)initialize
{
  if ([self class] == [_MSRGBAColor class]) {
    [_MSRGBAColor setVersion:MS_RGBACOLOR_LAST_VERSION] ;
  }
}

- (NSString *)listItemString { return [self toString] ; }
- (NSString *)displayString  { return [self toString] ; }

- (id)initWithCoder:(NSCoder *)aDecoder
{
  MSUInt value ;
  if ([aDecoder allowsKeyedCoding]) {
    MSInt v= [aDecoder decodeInt32ForKey:@"color"] ;
    value= *((MSUInt *)&v) ;
  }
  else {
    [aDecoder decodeValueOfObjCType:@encode(MSUInt) at:&value] ;
  }
  _r= (MSByte)((value >> 24) & 0xff) ;
  _g= (MSByte)((value >> 16) & 0xff) ;
  _b= (MSByte)((value >>  8) & 0xff) ;
  _a= (MSByte)((value      ) & 0xff) ;
  return self ;
}

@end

#pragma mark Named colors

@implementation MSColor (Naming)
+ (MSColor *)colorWithName:(NSString *)name { return MSColorNamed(name) ; }
@end

static NSMutableDictionary *__namedColors= nil ;
static CArray __colorsList ;
#define COLOR_LIST_COUNT 139

MSColor *MSColorNamed(NSString *name)
{
  MSColor *ret= nil ;
  if (name) {
    ret= [__namedColors objectForKey:name] ;
    if (!ret) ret= [__namedColors objectForKey:[name lowercaseString]] ;
  }
  return ret ;
}

struct _MSColorDefinition {
  char *name ;
  MSUInt value ;
} ;
static const struct _MSColorDefinition __colorTable [COLOR_LIST_COUNT]= {
  {"AliceBlue"           , 0xf0f8ffff},
  {"AntiqueWhite"        , 0xfaebd7ff},
  {"Aqua"                , 0x00ffffff},
  {"Aquamarine"          , 0x7fffd4ff},
  {"Azure"               , 0xf0ffffff},
  {"Beige"               , 0xf5f5dcff},
  {"Bisque"              , 0xffe4c4ff},
  {"Black"               , 0x000000ff},
  {"BlanchedAlmond"      , 0xffebcdff},
  {"Blue"                , 0x0000ffff},
  {"BlueViolet"          , 0x8a2be2ff},
  {"Brown "              , 0xa52a2aff},
  {"BurlyWood"           , 0xdeb887ff},
  {"CadetBlue"           , 0x5f9ea0ff},
  {"Chartreuse"          , 0x7fff00ff},
  {"Chocolate"           , 0xd2691eff},
  {"Coral"               , 0xff7f50ff},
  {"CornflowerBlue"      , 0x6495edff},
  {"Cornsilk"            , 0xfff8dcff},
  {"Crimson"             , 0xdc143cff},
  {"Cyan"                , 0x00ffffff},
  {"DarkBlue"            , 0x00008bff},
  {"DarkCyan"            , 0x008b8bff},
  {"DarkGoldenRod"       , 0xb8860bff},
  {"DarkGray"            , 0xa9a9a9ff},
  {"DarkGreen"           , 0x006400ff},
  {"DarkKhaki"           , 0xbdb76bff},
  {"DarkMagenta"         , 0x8b008bff},
  {"DarkOrange"          , 0xff8c00ff},
  {"DarkOrchid"          , 0x9932ccff},
  {"DarkRed"             , 0x8b0000ff},
  {"DarkSalmon"          , 0xe9967aff},
  {"DarkSeaGreen"        , 0x8fbc8fff},
  {"DarkSlateBlue"       , 0x483d8bff},
  {"DarkSlateGray"       , 0x2f4f4fff},
  {"DarkTurquoise"       , 0x00ced1ff},
  {"DarkViolet"          , 0x9400d3ff},
  {"DeepPink"            , 0xff1493ff},
  {"DeepSkyBlue"         , 0x00bfffff},
  {"DimGray"             , 0x696969ff},
  {"DodgerBlue"          , 0x1e90ffff},
  {"FireBrick"           , 0xb22222ff},
  {"FloralWhite"         , 0xfffaf0ff},
  {"ForestGreen"         , 0x228b22ff},
  {"Fuchsia"             , 0xff00ffff},
  {"Gainsboro"           , 0xdcdcdcff},
  {"GhostWhite"          , 0xf8f8ffff},
  {"Gold"                , 0xffd700ff},
  {"GoldenRod"           , 0xdaa520ff},
  {"Gray"                , 0x808080ff},
  {"Green"               , 0x008000ff},
  {"GreenYellow"         , 0xadff2fff},
  {"HoneyDew"            , 0xf0fff0ff},
  {"HotPink"             , 0xff69b4ff},
  {"IndianRed"           , 0xcd5c5cff},
  {"Indigo"              , 0x4b0082ff},
  {"Ivory"               , 0xfffff0ff},
  {"Khaki"               , 0xf0e68cff},
  {"Lavender"            , 0xe6e6faff},
  {"LavenderBlush"       , 0xfff0f5ff},
  {"LawnGreen"           , 0x7cfc00ff},
  {"LemonChiffon"        , 0xfffacdff},
  {"LightBlue"           , 0xadd8e6ff},
  {"LightCoral"          , 0xf08080ff},
  {"LightCyan"           , 0xe0ffffff},
  {"LightGoldenRodYellow", 0xfafad2ff},
  {"LightGray"           , 0xd3d3d3ff},
  {"LightGreen"          , 0x90ee90ff},
  {"LightPink"           , 0xffb6c1ff},
  {"LightSalmon"         , 0xffa07aff},
  {"LightSeaGreen"       , 0x20b2aaff},
  {"LightSkyBlue"        , 0x87cefaff},
  {"LightSlateGray"      , 0x778899ff},
  {"LightSteelBlue"      , 0xb0c4deff},
  {"LightYellow"         , 0xffffe0ff},
  {"Lime"                , 0x00ff00ff},
  {"LimeGreen"           , 0x32cd32ff},
  {"Linen"               , 0xfaf0e6ff},
  {"Magenta"             , 0xff00ffff},
  {"Maroon"              , 0x800000ff},
  {"MediumAquaMarine"    , 0x66cdaaff},
  {"MediumOrchid"        , 0xba55d3ff},
  {"MediumPurple"        , 0x9370d8ff},
  {"MediumSeaGreen"      , 0x3cb371ff},
  {"MediumStateBlue"     , 0x7b68eeff},
  {"MediumSpringGreen"   , 0x00fa9aff},
  {"MediumTurquoise"     , 0x48d1ccff},
  {"MediumVioletRed"     , 0xc71585ff},
  {"MidnightBlue"        , 0x191970ff},
  {"MintCream"           , 0xf5fffaff},
  {"MistyRose"           , 0xffe4e1ff},
  {"Moccasin"            , 0xffe4b5ff},
  {"NavajoWhite"         , 0xffdeadff},
  {"Navy"                , 0x000080ff},
  {"OldLace"             , 0xfdf5e6ff},
  {"Olive"               , 0x808000ff},
  {"OliveDrab"           , 0x6b8e23ff},
  {"Orange"              , 0xffa500ff},
  {"OrangeRed"           , 0xff4500ff},
  {"Orchid"              , 0xda70d6ff},
  {"PaleGoldenRod"       , 0xeee8aaff},
  {"PaleGreen"           , 0x98fb98ff},
  {"PaleTurquoise"       , 0xafeeeeff},
  {"PaleVioletRed"       , 0xd87093ff},
  {"PapayaWhip"          , 0xffefd5ff},
  {"PeachPuff"           , 0xffdab9ff},
  {"Peru"                , 0xcd853fff},
  {"Pink"                , 0xffc0cbff},
  {"Plum"                , 0xdda0ddff},
  {"PowderBlue"          , 0xb0e0e6ff},
  {"Purple"              , 0x800080ff},
  {"Red"                 , 0xff0000ff},
  {"RosyBrown"           , 0xbc8f8fff},
  {"RoyalBlue"           , 0x4169e1ff},
  {"SaddleBrown"         , 0x8b4513ff},
  {"Salmon"              , 0xfa8072ff},
  {"SandyBrown"          , 0xf4a460ff},
  {"SeaGreen"            , 0x2e8b57ff},
  {"SeaShell"            , 0xfff5eeff},
  {"Sienna"              , 0xa0522dff},
  {"Silver"              , 0xc0c0c0ff},
  {"SkyBlue"             , 0x87ceebff},
  {"SlateBlue"           , 0x6a5acdff},
  {"SlateGray"           , 0x708090ff},
  {"Snow"                , 0xfffafaff},
  {"SpringGreen"         , 0x00ff7fff},
  {"SteelBlue"           , 0x4682b4ff},
  {"Tan"                 , 0xd2b48cff},
  {"Teal"                , 0x008080ff},
  {"Thistle"             , 0xd8bfd8ff},
  {"Tomato"              , 0xff6347ff},
  {"Transparent"         , 0x00000000},
  {"Turquoise"           , 0x40e0d0ff},
  {"Violet"              , 0xee82eeff},
  {"Wheat"               , 0xf5deb3ff},
  {"White"               , 0xffffffff},
  {"WhiteSmoke"          , 0xf5f5f5ff},
  {"Yellow"              , 0xffff00ff},
  {"YellowGreen"         , 0x9acd32ff}} ;

#define MS_INDEXEDCOLOR_LAST_VERSION  401

@implementation _MSIndexedColor
+ (void)load { if (!__MSIndexedColorClass) {  __MSIndexedColorClass= [_MSIndexedColor class] ; }}
+ (void)initialize
{
  if ([self class] == [_MSIndexedColor class]) {
    [_MSIndexedColor setVersion:MS_INDEXEDCOLOR_LAST_VERSION] ;

    if (!__namedColors) {
      struct _MSColorDefinition entry ;
      _MSIndexedColor *c ;
      NSString *s ;
      int i ;
      __namedColors= [ALLOC(NSMutableDictionary) initWithCapacity:COLOR_LIST_COUNT*2] ;
      __colorsList.isa= Nil ;
      __colorsList.pointers= NULL ;
      __colorsList.size= __colorsList.count= 0 ;
      for (i= 0 ; i < COLOR_LIST_COUNT ; i++) {
        entry= __colorTable[i] ;
        s= [NSString stringWithUTF8String:entry.name] ;
        c= (_MSIndexedColor*)MSCreateObject([_MSIndexedColor class]);
		    c->_r= (MSByte)((entry.value >> 24) & 0xff) ;
  		  c->_g= (MSByte)((entry.value >> 16) & 0xff) ;
	  	  c->_b= (MSByte)((entry.value >>  8) & 0xff) ;
		    c->_a= (MSByte)((entry.value      ) & 0xff) ;
		    c->_name= RETAIN(s) ;
		    c->_colorIndex= i ;
        [__namedColors setObject:c forKey:[s lowercaseString]] ;
        [__namedColors setObject:c forKey:s] ;
        CArrayAddObject(&__colorsList, c) ;}}}
}
- (oneway void)release {}
- (id)retain { return self ;}
- (id)autorelease { return self ;}
- (void)dealloc {if (0) [super dealloc];} // No warning
- (Class)classForCoder { return __MSIndexedColorClass ; }
- (id)copyWithZone:(NSZone *)z { return self ; z= nil;}
- (id)copy { return self ; }
- (id)initWithCoder:(NSCoder *)aDecoder
{
  int i= -1 ;
  if ([aDecoder allowsKeyedCoding]) {
    i= [aDecoder decodeIntForKey:@"color-index"] ;
  }
  else {
    [aDecoder decodeValueOfObjCType:@encode(int) at:&i] ;
  }
  RELEASE(self) ;
  if (i >= 0 && i < COLOR_LIST_COUNT) {
    return MSAIndex(&__colorsList, i) ;
  }
  return nil ;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  if ([aCoder allowsKeyedCoding]) {
    [aCoder encodeInt:_colorIndex forKey:@"color-index"] ;
  }
  else {
    [aCoder encodeValueOfObjCType:@encode(int) at:&_colorIndex] ;
  }
}

- (NSString *)htmlRepresentation { return _name ; }

@end

MSColor *MSAliceBlue           (void) { return MSAIndex(&__colorsList, 0) ; } // 0xf0f8ffff
MSColor *MSAntiqueWhite        (void) { return MSAIndex(&__colorsList, 1) ; } // 0xfaebd7ff
MSColor *MSAqua                (void) { return MSAIndex(&__colorsList, 2) ; } // 0x00ffffff
MSColor *MSAquamarine          (void) { return MSAIndex(&__colorsList, 3) ; } // 0x7fffd4ff
MSColor *MSAzure               (void) { return MSAIndex(&__colorsList, 4) ; } // 0xf0ffffff
MSColor *MSBeige               (void) { return MSAIndex(&__colorsList, 5) ; } // 0xf5f5dcff
MSColor *MSBisque              (void) { return MSAIndex(&__colorsList, 6) ; } // 0xffe4c4ff
MSColor *MSBlack               (void) { return MSAIndex(&__colorsList, 7) ; } // 0x000000ff
MSColor *MSBlanchedAlmond      (void) { return MSAIndex(&__colorsList, 8) ; } // 0xffebcdff
MSColor *MSBlue                (void) { return MSAIndex(&__colorsList, 9) ; } // 0x0000ffff
MSColor *MSBlueViolet          (void) { return MSAIndex(&__colorsList, 10) ; } // 0x8a2be2ff
MSColor *MSBrown               (void) { return MSAIndex(&__colorsList, 11) ; } // 0xa52a2aff
MSColor *MSBurlyWood           (void) { return MSAIndex(&__colorsList, 12) ; } // 0xdeb887ff
MSColor *MSCadetBlue           (void) { return MSAIndex(&__colorsList, 13) ; } // 0x5f9ea0ff
MSColor *MSChartreuse          (void) { return MSAIndex(&__colorsList, 14) ; } // 0x7fff00ff
MSColor *MSChocolate           (void) { return MSAIndex(&__colorsList, 15) ; } // 0xd2691eff
MSColor *MSCoral               (void) { return MSAIndex(&__colorsList, 16) ; } // 0xff7f50ff
MSColor *MSCornflowerBlue      (void) { return MSAIndex(&__colorsList, 17) ; } // 0x6495edff
MSColor *MSCornsilk            (void) { return MSAIndex(&__colorsList, 18) ; } // 0xfff8dcff
MSColor *MSCrimson             (void) { return MSAIndex(&__colorsList, 19) ; } // 0xdc143cff
MSColor *MSCyan                (void) { return MSAIndex(&__colorsList, 20) ; } // 0x00ffffff
MSColor *MSDarkBlue            (void) { return MSAIndex(&__colorsList, 21) ; } // 0x00008bff
MSColor *MSDarkCyan            (void) { return MSAIndex(&__colorsList, 22) ; } // 0x008b8bff
MSColor *MSDarkGoldenRod       (void) { return MSAIndex(&__colorsList, 23) ; } // 0xb8860bff
MSColor *MSDarkGray            (void) { return MSAIndex(&__colorsList, 24) ; } // 0xa9a9a9ff
MSColor *MSDarkGreen           (void) { return MSAIndex(&__colorsList, 25) ; } // 0x006400ff
MSColor *MSDarkKhaki           (void) { return MSAIndex(&__colorsList, 26) ; } // 0xbdb76bff
MSColor *MSDarkMagenta         (void) { return MSAIndex(&__colorsList, 27) ; } // 0x8b008bff
MSColor *MSDarkOrange          (void) { return MSAIndex(&__colorsList, 28) ; } // 0xff8c00ff
MSColor *MSDarkOrchid          (void) { return MSAIndex(&__colorsList, 29) ; } // 0x9932ccff
MSColor *MSDarkRed             (void) { return MSAIndex(&__colorsList, 30) ; } // 0x8b0000ff
MSColor *MSDarkSalmon          (void) { return MSAIndex(&__colorsList, 31) ; } // 0xe9967aff
MSColor *MSDarkSeaGreen        (void) { return MSAIndex(&__colorsList, 32) ; } // 0x8fbc8fff
MSColor *MSDarkSlateBlue       (void) { return MSAIndex(&__colorsList, 33) ; } // 0x483d8bff
MSColor *MSDarkSlateGray       (void) { return MSAIndex(&__colorsList, 34) ; } // 0x2f4f4fff
MSColor *MSDarkTurquoise       (void) { return MSAIndex(&__colorsList, 35) ; } // 0x00ced1ff
MSColor *MSDarkViolet          (void) { return MSAIndex(&__colorsList, 36) ; } // 0x9400d3ff
MSColor *MSDeepPink            (void) { return MSAIndex(&__colorsList, 37) ; } // 0xff1493ff
MSColor *MSDeepSkyBlue         (void) { return MSAIndex(&__colorsList, 38) ; } // 0x00bfffff
MSColor *MSDimGray             (void) { return MSAIndex(&__colorsList, 39) ; } // 0x696969ff
MSColor *MSDodgerBlue          (void) { return MSAIndex(&__colorsList, 40) ; } // 0x1e90ffff
MSColor *MSFireBrick           (void) { return MSAIndex(&__colorsList, 41) ; } // 0xb22222ff
MSColor *MSFloralWhite         (void) { return MSAIndex(&__colorsList, 42) ; } // 0xfffaf0ff
MSColor *MSForestGreen         (void) { return MSAIndex(&__colorsList, 43) ; } // 0x228b22ff
MSColor *MSFuchsia             (void) { return MSAIndex(&__colorsList, 44) ; } // 0xff00ffff
MSColor *MSGainsboro           (void) { return MSAIndex(&__colorsList, 45) ; } // 0xdcdcdcff
MSColor *MSGhostWhite          (void) { return MSAIndex(&__colorsList, 46) ; } // 0xf8f8ffff
MSColor *MSGold                (void) { return MSAIndex(&__colorsList, 47) ; } // 0xffd700ff
MSColor *MSGoldenRod           (void) { return MSAIndex(&__colorsList, 48) ; } // 0xdaa520ff
MSColor *MSGray                (void) { return MSAIndex(&__colorsList, 49) ; } // 0x808080ff
MSColor *MSGreen               (void) { return MSAIndex(&__colorsList, 50) ; } // 0x008000ff
MSColor *MSGreenYellow         (void) { return MSAIndex(&__colorsList, 51) ; } // 0xadff2fff
MSColor *MSHoneyDew            (void) { return MSAIndex(&__colorsList, 52) ; } // 0xf0fff0ff
MSColor *MSHotPink             (void) { return MSAIndex(&__colorsList, 53) ; } // 0xff69b4ff
MSColor *MSIndianRed           (void) { return MSAIndex(&__colorsList, 54) ; } // 0xcd5c5cff
MSColor *MSIndigo              (void) { return MSAIndex(&__colorsList, 55) ; } // 0x4b0082ff
MSColor *MSIvory               (void) { return MSAIndex(&__colorsList, 56) ; } // 0xfffff0ff
MSColor *MSKhaki               (void) { return MSAIndex(&__colorsList, 57) ; } // 0xf0e68cff
MSColor *MSLavender            (void) { return MSAIndex(&__colorsList, 58) ; } // 0xe6e6faff
MSColor *MSLavenderBlush       (void) { return MSAIndex(&__colorsList, 59) ; } // 0xfff0f5ff
MSColor *MSLawnGreen           (void) { return MSAIndex(&__colorsList, 60) ; } // 0x7cfc00ff
MSColor *MSLemonChiffon        (void) { return MSAIndex(&__colorsList, 61) ; } // 0xfffacdff
MSColor *MSLightBlue           (void) { return MSAIndex(&__colorsList, 62) ; } // 0xadd8e6ff
MSColor *MSLightCoral          (void) { return MSAIndex(&__colorsList, 63) ; } // 0xf08080ff
MSColor *MSLightCyan           (void) { return MSAIndex(&__colorsList, 64) ; } // 0xe0ffffff
MSColor *MSLightGoldenRodYellow(void) { return MSAIndex(&__colorsList, 65) ; } // 0xfafad2ff
MSColor *MSLightGray           (void) { return MSAIndex(&__colorsList, 66) ; } // 0xd3d3d3ff
MSColor *MSLightGreen          (void) { return MSAIndex(&__colorsList, 67) ; } // 0x90ee90ff
MSColor *MSLightPink           (void) { return MSAIndex(&__colorsList, 68) ; } // 0xffb6c1ff
MSColor *MSLightSalmon         (void) { return MSAIndex(&__colorsList, 69) ; } // 0xffa07aff
MSColor *MSLightSeaGreen       (void) { return MSAIndex(&__colorsList, 70) ; } // 0x20b2aaff
MSColor *MSLightSkyBlue        (void) { return MSAIndex(&__colorsList, 71) ; } // 0x87cefaff
MSColor *MSLightSlateGray      (void) { return MSAIndex(&__colorsList, 72) ; } // 0x778899ff
MSColor *MSLightSteelBlue      (void) { return MSAIndex(&__colorsList, 73) ; } // 0xb0c4deff
MSColor *MSLightYellow         (void) { return MSAIndex(&__colorsList, 74) ; } // 0xffffe0ff
MSColor *MSLime                (void) { return MSAIndex(&__colorsList, 75) ; } // 0x00ff00ff
MSColor *MSLimeGreen           (void) { return MSAIndex(&__colorsList, 76) ; } // 0x32cd32ff
MSColor *MSLinen               (void) { return MSAIndex(&__colorsList, 77) ; } // 0xfaf0e6ff
MSColor *MSMagenta             (void) { return MSAIndex(&__colorsList, 78) ; } // 0xff00ffff
MSColor *MSMaroon              (void) { return MSAIndex(&__colorsList, 79) ; } // 0x800000ff
MSColor *MSMediumAquaMarine    (void) { return MSAIndex(&__colorsList, 80) ; } // 0x66cdaaff
MSColor *MSMediumOrchid        (void) { return MSAIndex(&__colorsList, 81) ; } // 0xba55d3ff
MSColor *MSMediumPurple        (void) { return MSAIndex(&__colorsList, 82) ; } // 0x9370d8ff
MSColor *MSMediumSeaGreen      (void) { return MSAIndex(&__colorsList, 83) ; } // 0x3cb371ff
MSColor *MSMediumStateBlue     (void) { return MSAIndex(&__colorsList, 84) ; } // 0x7b68eeff
MSColor *MSMediumSpringGreen   (void) { return MSAIndex(&__colorsList, 85) ; } // 0x00fa9aff
MSColor *MSMediumTurquoise     (void) { return MSAIndex(&__colorsList, 86) ; } // 0x48d1ccff
MSColor *MSMediumVioletRed     (void) { return MSAIndex(&__colorsList, 87) ; } // 0xc71585ff
MSColor *MSMidnightBlue        (void) { return MSAIndex(&__colorsList, 88) ; } // 0x191970ff
MSColor *MSMintCream           (void) { return MSAIndex(&__colorsList, 89) ; } // 0xf5fffaff
MSColor *MSMistyRose           (void) { return MSAIndex(&__colorsList, 90) ; } // 0xffe4e1ff
MSColor *MSMoccasin            (void) { return MSAIndex(&__colorsList, 91) ; } // 0xffe4b5ff
MSColor *MSNavajoWhite         (void) { return MSAIndex(&__colorsList, 92) ; } // 0xffdeadff
MSColor *MSNavy                (void) { return MSAIndex(&__colorsList, 93) ; } // 0x000080ff
MSColor *MSOldLace             (void) { return MSAIndex(&__colorsList, 94) ; } // 0xfdf5e6ff
MSColor *MSOlive               (void) { return MSAIndex(&__colorsList, 95) ; } // 0x808000ff
MSColor *MSOliveDrab           (void) { return MSAIndex(&__colorsList, 96) ; } // 0x6b8e23ff
MSColor *MSOrange              (void) { return MSAIndex(&__colorsList, 97) ; } // 0xffa500ff
MSColor *MSOrangeRed           (void) { return MSAIndex(&__colorsList, 98) ; } // 0xff4500ff
MSColor *MSOrchid              (void) { return MSAIndex(&__colorsList, 99) ; } // 0xda70d6ff
MSColor *MSPaleGoldenRod       (void) { return MSAIndex(&__colorsList, 100) ; } // 0xeee8aaff
MSColor *MSPaleGreen           (void) { return MSAIndex(&__colorsList, 101) ; } // 0x98fb98ff
MSColor *MSPaleTurquoise       (void) { return MSAIndex(&__colorsList, 102) ; } // 0xafeeeeff
MSColor *MSPaleVioletRed       (void) { return MSAIndex(&__colorsList, 103) ; } // 0xd87093ff
MSColor *MSPapayaWhip          (void) { return MSAIndex(&__colorsList, 104) ; } // 0xffefd5ff
MSColor *MSPeachPuff           (void) { return MSAIndex(&__colorsList, 105) ; } // 0xffdab9ff
MSColor *MSPeru                (void) { return MSAIndex(&__colorsList, 106) ; } // 0xcd853fff
MSColor *MSPink                (void) { return MSAIndex(&__colorsList, 107) ; } // 0xffc0cbff
MSColor *MSPlum                (void) { return MSAIndex(&__colorsList, 108) ; } // 0xdda0ddff
MSColor *MSPowderBlue          (void) { return MSAIndex(&__colorsList, 109) ; } // 0xb0e0e6ff
MSColor *MSPurple              (void) { return MSAIndex(&__colorsList, 110) ; } // 0x800080ff
MSColor *MSRed                 (void) { return MSAIndex(&__colorsList, 111) ; } // 0xff0000ff
MSColor *MSRosyBrown           (void) { return MSAIndex(&__colorsList, 112) ; } // 0xbc8f8fff
MSColor *MSRoyalBlue           (void) { return MSAIndex(&__colorsList, 113) ; } // 0x4169e1ff
MSColor *MSSaddleBrown         (void) { return MSAIndex(&__colorsList, 114) ; } // 0x8b4513ff
MSColor *MSSalmon              (void) { return MSAIndex(&__colorsList, 115) ; } // 0xfa8072ff
MSColor *MSSandyBrown          (void) { return MSAIndex(&__colorsList, 116) ; } // 0xf4a460ff
MSColor *MSSeaGreen            (void) { return MSAIndex(&__colorsList, 117) ; } // 0x2e8b57ff
MSColor *MSSeaShell            (void) { return MSAIndex(&__colorsList, 118) ; } // 0xfff5eeff
MSColor *MSSienna              (void) { return MSAIndex(&__colorsList, 119) ; } // 0xa0522dff
MSColor *MSSilver              (void) { return MSAIndex(&__colorsList, 120) ; } // 0xc0c0c0ff
MSColor *MSSkyBlue             (void) { return MSAIndex(&__colorsList, 121) ; } // 0x87ceebff
MSColor *MSSlateBlue           (void) { return MSAIndex(&__colorsList, 122) ; } // 0x6a5acdff
MSColor *MSSlateGray           (void) { return MSAIndex(&__colorsList, 123) ; } // 0x708090ff
MSColor *MSSnow                (void) { return MSAIndex(&__colorsList, 124) ; } // 0xfffafaff
MSColor *MSSpringGreen         (void) { return MSAIndex(&__colorsList, 125) ; } // 0x00ff7fff
MSColor *MSSteelBlue           (void) { return MSAIndex(&__colorsList, 126) ; } // 0x4682b4ff
MSColor *MSTan                 (void) { return MSAIndex(&__colorsList, 127) ; } // 0xd2b48cff
MSColor *MSTeal                (void) { return MSAIndex(&__colorsList, 128) ; } // 0x008080ff
MSColor *MSThistle             (void) { return MSAIndex(&__colorsList, 129) ; } // 0xd8bfd8ff
MSColor *MSTomato              (void) { return MSAIndex(&__colorsList, 130) ; } // 0xff6347ff
MSColor *MSTransparent         (void) { return MSAIndex(&__colorsList, 131) ; } // 0x00000000
MSColor *MSTurquoise           (void) { return MSAIndex(&__colorsList, 132) ; } // 0x40e0d0ff
MSColor *MSViolet              (void) { return MSAIndex(&__colorsList, 133) ; } // 0xee82eeff
MSColor *MSWheat               (void) { return MSAIndex(&__colorsList, 134) ; } // 0xf5deb3ff
MSColor *MSWhite               (void) { return MSAIndex(&__colorsList, 135) ; } // 0xffffffff
MSColor *MSWhiteSmoke          (void) { return MSAIndex(&__colorsList, 136) ; } // 0xf5f5f5ff
MSColor *MSYellow              (void) { return MSAIndex(&__colorsList, 137) ; } // 0xffff00ff
MSColor *MSYellowGreen         (void) { return MSAIndex(&__colorsList, 138) ; } // 0x9acd32ff
