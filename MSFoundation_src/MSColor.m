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

#import "MSFoundation_Private.h"

#define MS_COLOR_LAST_VERSION 201

#define LIGHTER(X)   (float)2.0*(X)*(X)/(float)3.0+(X)/(float)2.0+(float)0.25
#define DARKER(X)    -(X)*(X)/(float)3.0+(float)5.0*(X)/(float)6.0
#define OPAQUE_COLOR ((MSUInt)0xff)

Class __MSColorClass= Nil;
Class __MSIndexedColorClass= Nil;

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

@implementation MSColor

+ (void)initialize
{
  if ([self class] == [MSColor class]) {
    [MSColor setVersion:MS_COLOR_LAST_VERSION];}
}

#pragma mark Class methods

+ (MSColor *)colorWithRGBAValue:(MSUInt)color
{ return AUTORELEASE(MSCreateColor(color)); }

+ (MSColor *)colorWithCSSValue:(MSUInt)color // TTRRGGBB
{ return AUTORELEASE(MSCreateCSSColor(color)); }

+ (MSColor *)colorWithRed:(MSByte)red green:(MSByte)green blue:(MSByte)blue
{ return AUTORELEASE((MSColor*)CCreateColor(red, green, blue, OPAQUE_COLOR)); }

+ (MSColor *)colorWithRed:(MSByte)red green:(MSByte)green blue:(MSByte)blue opacity:(MSByte)alpha
{ return AUTORELEASE((MSColor*)CCreateColor(red, green, blue, alpha)); }

+ (MSColor *)colorWithRedComponent:(float)red greenComponent:(float)green blueComponent:(float)blue
{ return _MSAutoComponentsColor(red, green, blue, 1.0); }

+ (MSColor *)colorWithRedComponent:(float)red greenComponent:(float)green blueComponent:(float)blue alphaComponent:(float)alpha
{ return _MSAutoComponentsColor(red, green, blue, alpha); }

#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone
{
  return CColorCopy(self);
  zone= NULL; // unused parameter
}

#pragma mark Standard methods

- (BOOL)isTrue { return ([self opacity] > 0 ? YES : NO); }

- (BOOL)isEqual:(id)object
{
  if (object == (id)self) return YES;
  if (!object || ![object conformsToProtocol:@protocol(MSColor)]) return NO;
  return [self rgbaValue] == [(id <MSColor>)object rgbaValue];
}

- (unsigned int)unsignedIntValue { return (unsigned int)[self rgbaValue]; }

- (NSString *)toString { return ([self opacity] == OPAQUE_COLOR ? [NSString stringWithFormat:@"#%02x%02x%02x", [self red], [self green], [self blue]] : [NSString stringWithFormat:@"#%02x%02x%02x%02x", [self transparency], [self red], [self green], [self blue]]); }
- (NSString *)description { return [NSString stringWithFormat:@"<color #%02x%02x%02x%02x>", [self red], [self green], [self blue], [self opacity]]; }
- (NSString *)htmlRepresentation { return [NSString stringWithFormat:@"#%02x%02x%02x", [self red], [self green], [self blue]]; } // html representation does not know about opacity
- (NSString *)jsonRepresentation { return [NSString stringWithFormat:@"\"%@\"", [self toString]]; }

#pragma mark MSColor protocol

- (float)redComponent   { return ((float)[self red    ])/(float)255.0; }
- (float)greenComponent { return ((float)[self green  ])/(float)255.0; }
- (float)blueComponent  { return ((float)[self blue   ])/(float)255.0; }
- (float)alphaComponent { return ((float)[self opacity])/(float)255.0; }
- (float)cyanComponent
{
  float C= (float)1.0 - ((float)[self red  ])/(float)255.0;
  float M= (float)1.0 - ((float)[self green])/(float)255.0;
  float Y= (float)1.0 - ((float)[self blue ])/(float)255.0;
  float K= (float)1.0;
  if ( C < K ) K= C;
  if ( M < K ) K= M;
  if ( Y < K ) K= Y;
  if (K >= 1.0) return 0.0;
  return (C - K) / (1 - K);
  
}
- (float)magentaComponent
{
  float C= (float)1.0 - ((float)[self red  ])/(float)255.0;
  float M= (float)1.0 - ((float)[self green])/(float)255.0;
  float Y= (float)1.0 - ((float)[self blue ])/(float)255.0;
  float K= (float)1.0;
  if ( C < K ) K= C;
  if ( M < K ) K= M;
  if ( Y < K ) K= Y;
  if (K >= 1.0) return 0.0;
  return (M - K) / (1 - K);
}
- (float)yellowComponent
{
  float C= (float)1.0 - ((float)[self red  ])/(float)255.0;
  float M= (float)1.0 - ((float)[self green])/(float)255.0;
  float Y= (float)1.0 - ((float)[self blue ])/(float)255.0;
  float K= (float)1.0;
  if ( C < K ) K= C;
  if ( M < K ) K= M;
  if ( Y < K ) K= Y;
  if (K >= 1.0) return 0.0;
  return (Y - K) / (1 - K);
}
- (float)blackComponent
{
  float C= (float)1.0 - ((float)[self red  ])/(float)255.0;
  float M= (float)1.0 - ((float)[self green])/(float)255.0;
  float Y= (float)1.0 - ((float)[self blue ])/(float)255.0;
  float K= 1.0;
  if ( C < K ) K= C;
  if ( M < K ) K= M;
  if ( Y < K ) K= Y;
  return K;
}

// this 4 methods are considered as internal primitives for MSColor
- (MSByte)red          { return CColorRedValue         ((CColor*)self); }
- (MSByte)green        { return CColorGreenValue       ((CColor*)self); }
- (MSByte)blue         { return CColorBlueValue        ((CColor*)self); }
- (MSByte)opacity      { return CColorOpacityValue     ((CColor*)self); }
- (MSByte)transparency { return CColorTransparencyValue((CColor*)self); }

- (BOOL)isPaleColor { return CColorIsPale   ((CColor*)self); }
- (float)luminance  { return CColorLuminance((CColor*)self); }
- (MSUInt)rgbaValue { return CColorRGBAValue((CColor*)self); }
- (MSUInt)cssValue  { return CColorCSSValue ((CColor*)self); }

- (id <MSColor>)lighterColor
{
  float rf= [self redComponent  ];
  float gf= [self greenComponent];
  float bf= [self blueComponent ];
  return _MSAutoComponentsColor(LIGHTER(rf), LIGHTER(gf), LIGHTER(bf), [self alphaComponent]);
}

- (id <MSColor>)darkerColor
{
  float rf= [self redComponent  ];
  float gf= [self greenComponent];
  float bf= [self blueComponent ];
  return _MSAutoComponentsColor(DARKER(rf), DARKER(gf), DARKER(bf), [self alphaComponent]);
}

- (id <MSColor>)lightestColor
{
  float rf= [self redComponent  ];
  float gf= [self greenComponent];
  float bf= [self blueComponent ];
  rf= LIGHTER(rf);
  gf= LIGHTER(gf);
  bf= LIGHTER(bf);
  return _MSAutoComponentsColor(LIGHTER(rf), LIGHTER(gf), LIGHTER(bf), [self alphaComponent]);
}

- (id <MSColor>)darkestColor
{
  float rf= [self redComponent  ];
  float gf= [self greenComponent];
  float bf= [self blueComponent ];
  rf= DARKER(rf);
  gf= DARKER(gf);
  bf= DARKER(bf);
  return _MSAutoComponentsColor(DARKER(rf), DARKER(gf), DARKER(bf), [self alphaComponent]);
}

- (id <MSColor>)matchingVisibleColor { return CColorIsPale((CColor*)self) ? [self darkestColor] : [self lightestColor]; }

- (id <MSColor>)colorWithAlpha:(MSByte)opacity
{
  return AUTORELEASE((MSColor*)CCreateColor([self red], [self green], [self blue], opacity));
}

- (BOOL)isEqualToColorObject:(id <MSColor>)color
{
  return CColorEquals((CColor*)self, (CColor*)color);
}

- (NSComparisonResult)compareToColorObject:(id <MSColor>)color
{
  return CColorsCompare((CColor*)self, (CColor*)color);
}

#pragma mark NSCoding

- (Class)classForCoder     { return __MSColorClass; }
- (Class)classForAchiver   { return [self classForCoder]; }
- (Class)classForPortCoder { return [self classForCoder]; }

- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder
{
  if ([encoder isBycopy]) return self;
  return [super replacementObjectForPortCoder:encoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  MSUInt u= [self rgbaValue];
  if ([aCoder allowsKeyedCoding]) {
    MSInt i= *((MSInt *)&u);
    [aCoder encodeInt32:i forKey:@"color"];
  }
  else {
    [aCoder encodeValueOfObjCType:@encode(MSUInt) at:&u];
  }
}

- (id)initWithCoder:(NSCoder *)aDecoder
// this class must not be dearchived
{
  ASSIGN(self,nil);
  return nil;
  aDecoder= nil; // unused parameter
}

@end

#pragma mark ********** Clusters classes **********

@interface _MSRGBAColor : MSColor
{ 
@protected
  struct {
#ifdef __BIG_ENDIAN__
  MSUInt r:8;
  MSUInt g:8;
  MSUInt b:8;
  MSUInt a:8;
#else
  MSUInt a:8;
  MSUInt b:8;
  MSUInt g:8;
  MSUInt r:8;
#endif
  } _rgba;
}
@end
@interface _MSIndexedColor : _MSRGBAColor
{
@private
  NSString *_name;
  int _colorIndex;
}
@end
#define MS_RGBACOLOR_LAST_VERSION  301

@implementation _MSRGBAColor : MSColor
+ (void)load { if (!__MSColorClass) {  __MSColorClass= [_MSRGBAColor class]; }}
+ (void)initialize
{
  if ([self class] == [_MSRGBAColor class]) {
    [_MSRGBAColor setVersion:MS_RGBACOLOR_LAST_VERSION];
  }
}

- (NSString *)listItemString { return [self toString]; }
- (NSString *)displayString  { return [self toString]; }

- (id)initWithCoder:(NSCoder *)aDecoder
{
  MSUInt value;
  if ([aDecoder allowsKeyedCoding]) {
    MSInt v= [aDecoder decodeInt32ForKey:@"color"];
    value= *((MSUInt *)&v);
  }
  else {
    [aDecoder decodeValueOfObjCType:@encode(MSUInt) at:&value];
  }
  _rgba.r= (MSByte)((value >> 24) & 0xff);
  _rgba.g= (MSByte)((value >> 16) & 0xff);
  _rgba.b= (MSByte)((value >>  8) & 0xff);
  _rgba.a= (MSByte)((value      ) & 0xff);
  return self;
}

@end

#pragma mark Named colors

@implementation MSColor (Naming)
+ (MSColor *)colorWithName:(NSString *)name { return MSColorNamed(name); }
@end

static NSMutableDictionary *__namedColors= nil;
static MSArray *__colorsList= nil;
#define COLOR_LIST_COUNT 139

MSColor *MSColorNamed(NSString *name)
{
  MSColor *ret= nil;
  if (name) {
    ret= [__namedColors objectForKey:name];
    if (!ret) ret= [__namedColors objectForKey:[name lowercaseString]];
  }
  return ret;
}

struct _MSColorDefinition {
  MSColor **color;
  char     *name;
  MSUInt    value;};
static const struct _MSColorDefinition __colorTable [COLOR_LIST_COUNT]= {
  {&MSAliceBlue           , "AliceBlue"           , 0xf0f8ffff},
  {&MSAntiqueWhite        , "AntiqueWhite"        , 0xfaebd7ff},
  {&MSAqua                , "Aqua"                , 0x00ffffff},
  {&MSAquamarine          , "Aquamarine"          , 0x7fffd4ff},
  {&MSAzure               , "Azure"               , 0xf0ffffff},
  {&MSBeige               , "Beige"               , 0xf5f5dcff},
  {&MSBisque              , "Bisque"              , 0xffe4c4ff},
  {&MSBlack               , "Black"               , 0x000000ff},
  {&MSBlanchedAlmond      , "BlanchedAlmond"      , 0xffebcdff},
  {&MSBlue                , "Blue"                , 0x0000ffff},
  {&MSBlueViolet          , "BlueViolet"          , 0x8a2be2ff},
  {&MSBrown               , "Brown "              , 0xa52a2aff},
  {&MSBurlyWood           , "BurlyWood"           , 0xdeb887ff},
  {&MSCadetBlue           , "CadetBlue"           , 0x5f9ea0ff},
  {&MSChartreuse          , "Chartreuse"          , 0x7fff00ff},
  {&MSChocolate           , "Chocolate"           , 0xd2691eff},
  {&MSCoral               , "Coral"               , 0xff7f50ff},
  {&MSCornflowerBlue      , "CornflowerBlue"      , 0x6495edff},
  {&MSCornsilk            , "Cornsilk"            , 0xfff8dcff},
  {&MSCrimson             , "Crimson"             , 0xdc143cff},
  {&MSCyan                , "Cyan"                , 0x00ffffff},
  {&MSDarkBlue            , "DarkBlue"            , 0x00008bff},
  {&MSDarkCyan            , "DarkCyan"            , 0x008b8bff},
  {&MSDarkGoldenRod       , "DarkGoldenRod"       , 0xb8860bff},
  {&MSDarkGray            , "DarkGray"            , 0xa9a9a9ff},
  {&MSDarkGreen           , "DarkGreen"           , 0x006400ff},
  {&MSDarkKhaki           , "DarkKhaki"           , 0xbdb76bff},
  {&MSDarkMagenta         , "DarkMagenta"         , 0x8b008bff},
  {&MSDarkOrange          , "DarkOrange"          , 0xff8c00ff},
  {&MSDarkOrchid          , "DarkOrchid"          , 0x9932ccff},
  {&MSDarkRed             , "DarkRed"             , 0x8b0000ff},
  {&MSDarkSalmon          , "DarkSalmon"          , 0xe9967aff},
  {&MSDarkSeaGreen        , "DarkSeaGreen"        , 0x8fbc8fff},
  {&MSDarkSlateBlue       , "DarkSlateBlue"       , 0x483d8bff},
  {&MSDarkSlateGray       , "DarkSlateGray"       , 0x2f4f4fff},
  {&MSDarkTurquoise       , "DarkTurquoise"       , 0x00ced1ff},
  {&MSDarkViolet          , "DarkViolet"          , 0x9400d3ff},
  {&MSDeepPink            , "DeepPink"            , 0xff1493ff},
  {&MSDeepSkyBlue         , "DeepSkyBlue"         , 0x00bfffff},
  {&MSDimGray             , "DimGray"             , 0x696969ff},
  {&MSDodgerBlue          , "DodgerBlue"          , 0x1e90ffff},
  {&MSFireBrick           , "FireBrick"           , 0xb22222ff},
  {&MSFloralWhite         , "FloralWhite"         , 0xfffaf0ff},
  {&MSForestGreen         , "ForestGreen"         , 0x228b22ff},
  {&MSFuchsia             , "Fuchsia"             , 0xff00ffff},
  {&MSGainsboro           , "Gainsboro"           , 0xdcdcdcff},
  {&MSGhostWhite          , "GhostWhite"          , 0xf8f8ffff},
  {&MSGold                , "Gold"                , 0xffd700ff},
  {&MSGoldenRod           , "GoldenRod"           , 0xdaa520ff},
  {&MSGray                , "Gray"                , 0x808080ff},
  {&MSGreen               , "Green"               , 0x008000ff},
  {&MSGreenYellow         , "GreenYellow"         , 0xadff2fff},
  {&MSHoneyDew            , "HoneyDew"            , 0xf0fff0ff},
  {&MSHotPink             , "HotPink"             , 0xff69b4ff},
  {&MSIndianRed           , "IndianRed"           , 0xcd5c5cff},
  {&MSIndigo              , "Indigo"              , 0x4b0082ff},
  {&MSIvory               , "Ivory"               , 0xfffff0ff},
  {&MSKhaki               , "Khaki"               , 0xf0e68cff},
  {&MSLavender            , "Lavender"            , 0xe6e6faff},
  {&MSLavenderBlush       , "LavenderBlush"       , 0xfff0f5ff},
  {&MSLawnGreen           , "LawnGreen"           , 0x7cfc00ff},
  {&MSLemonChiffon        , "LemonChiffon"        , 0xfffacdff},
  {&MSLightBlue           , "LightBlue"           , 0xadd8e6ff},
  {&MSLightCoral          , "LightCoral"          , 0xf08080ff},
  {&MSLightCyan           , "LightCyan"           , 0xe0ffffff},
  {&MSLightGoldenRodYellow, "LightGoldenRodYellow", 0xfafad2ff},
  {&MSLightGray           , "LightGray"           , 0xd3d3d3ff},
  {&MSLightGreen          , "LightGreen"          , 0x90ee90ff},
  {&MSLightPink           , "LightPink"           , 0xffb6c1ff},
  {&MSLightSalmon         , "LightSalmon"         , 0xffa07aff},
  {&MSLightSeaGreen       , "LightSeaGreen"       , 0x20b2aaff},
  {&MSLightSkyBlue        , "LightSkyBlue"        , 0x87cefaff},
  {&MSLightSlateGray      , "LightSlateGray"      , 0x778899ff},
  {&MSLightSteelBlue      , "LightSteelBlue"      , 0xb0c4deff},
  {&MSLightYellow         , "LightYellow"         , 0xffffe0ff},
  {&MSLime                , "Lime"                , 0x00ff00ff},
  {&MSLimeGreen           , "LimeGreen"           , 0x32cd32ff},
  {&MSLinen               , "Linen"               , 0xfaf0e6ff},
  {&MSMagenta             , "Magenta"             , 0xff00ffff},
  {&MSMaroon              , "Maroon"              , 0x800000ff},
  {&MSMediumAquaMarine    , "MediumAquaMarine"    , 0x66cdaaff},
  {&MSMediumOrchid        , "MediumOrchid"        , 0xba55d3ff},
  {&MSMediumPurple        , "MediumPurple"        , 0x9370d8ff},
  {&MSMediumSeaGreen      , "MediumSeaGreen"      , 0x3cb371ff},
  {&MSMediumStateBlue     , "MediumStateBlue"     , 0x7b68eeff},
  {&MSMediumSpringGreen   , "MediumSpringGreen"   , 0x00fa9aff},
  {&MSMediumTurquoise     , "MediumTurquoise"     , 0x48d1ccff},
  {&MSMediumVioletRed     , "MediumVioletRed"     , 0xc71585ff},
  {&MSMidnightBlue        , "MidnightBlue"        , 0x191970ff},
  {&MSMintCream           , "MintCream"           , 0xf5fffaff},
  {&MSMistyRose           , "MistyRose"           , 0xffe4e1ff},
  {&MSMoccasin            , "Moccasin"            , 0xffe4b5ff},
  {&MSNavajoWhite         , "NavajoWhite"         , 0xffdeadff},
  {&MSNavy                , "Navy"                , 0x000080ff},
  {&MSOldLace             , "OldLace"             , 0xfdf5e6ff},
  {&MSOlive               , "Olive"               , 0x808000ff},
  {&MSOliveDrab           , "OliveDrab"           , 0x6b8e23ff},
  {&MSOrange              , "Orange"              , 0xffa500ff},
  {&MSOrangeRed           , "OrangeRed"           , 0xff4500ff},
  {&MSOrchid              , "Orchid"              , 0xda70d6ff},
  {&MSPaleGoldenRod       , "PaleGoldenRod"       , 0xeee8aaff},
  {&MSPaleGreen           , "PaleGreen"           , 0x98fb98ff},
  {&MSPaleTurquoise       , "PaleTurquoise"       , 0xafeeeeff},
  {&MSPaleVioletRed       , "PaleVioletRed"       , 0xd87093ff},
  {&MSPapayaWhip          , "PapayaWhip"          , 0xffefd5ff},
  {&MSPeachPuff           , "PeachPuff"           , 0xffdab9ff},
  {&MSPeru                , "Peru"                , 0xcd853fff},
  {&MSPink                , "Pink"                , 0xffc0cbff},
  {&MSPlum                , "Plum"                , 0xdda0ddff},
  {&MSPowderBlue          , "PowderBlue"          , 0xb0e0e6ff},
  {&MSPurple              , "Purple"              , 0x800080ff},
  {&MSRed                 , "Red"                 , 0xff0000ff},
  {&MSRosyBrown           , "RosyBrown"           , 0xbc8f8fff},
  {&MSRoyalBlue           , "RoyalBlue"           , 0x4169e1ff},
  {&MSSaddleBrown         , "SaddleBrown"         , 0x8b4513ff},
  {&MSSalmon              , "Salmon"              , 0xfa8072ff},
  {&MSSandyBrown          , "SandyBrown"          , 0xf4a460ff},
  {&MSSeaGreen            , "SeaGreen"            , 0x2e8b57ff},
  {&MSSeaShell            , "SeaShell"            , 0xfff5eeff},
  {&MSSienna              , "Sienna"              , 0xa0522dff},
  {&MSSilver              , "Silver"              , 0xc0c0c0ff},
  {&MSSkyBlue             , "SkyBlue"             , 0x87ceebff},
  {&MSSlateBlue           , "SlateBlue"           , 0x6a5acdff},
  {&MSSlateGray           , "SlateGray"           , 0x708090ff},
  {&MSSnow                , "Snow"                , 0xfffafaff},
  {&MSSpringGreen         , "SpringGreen"         , 0x00ff7fff},
  {&MSSteelBlue           , "SteelBlue"           , 0x4682b4ff},
  {&MSTan                 , "Tan"                 , 0xd2b48cff},
  {&MSTeal                , "Teal"                , 0x008080ff},
  {&MSThistle             , "Thistle"             , 0xd8bfd8ff},
  {&MSTomato              , "Tomato"              , 0xff6347ff},
  {&MSTransparent         , "Transparent"         , 0x00000000},
  {&MSTurquoise           , "Turquoise"           , 0x40e0d0ff},
  {&MSViolet              , "Violet"              , 0xee82eeff},
  {&MSWheat               , "Wheat"               , 0xf5deb3ff},
  {&MSWhite               , "White"               , 0xffffffff},
  {&MSWhiteSmoke          , "WhiteSmoke"          , 0xf5f5f5ff},
  {&MSYellow              , "Yellow"              , 0xffff00ff},
  {&MSYellowGreen         , "YellowGreen"         , 0x9acd32ff}};

#define MS_INDEXEDCOLOR_LAST_VERSION  401

@implementation _MSIndexedColor
+ (void)load { if (!__MSIndexedColorClass) {  __MSIndexedColorClass= [_MSIndexedColor class]; }}
+ (void)initialize
{
  if ([self class] == [_MSIndexedColor class]) {
    [_MSIndexedColor setVersion:MS_INDEXEDCOLOR_LAST_VERSION];

    if (!__namedColors) {
      // TODO: initialize called before releasepool is setup
      NSAutoreleasePool *pool= [NSAutoreleasePool new];
      struct _MSColorDefinition entry;
      _MSIndexedColor *c;
      NSString *s;
      int i;
      __namedColors= (MSDictionary *)CCreateDictionary(COLOR_LIST_COUNT*2);
      __colorsList= (MSArray *)CCreateArray(COLOR_LIST_COUNT);
      for (i= 0; i < COLOR_LIST_COUNT; i++) {
        entry= __colorTable[i];
        s= [NSString stringWithUTF8String:entry.name];
        // load is done after initialize !
        c= (_MSIndexedColor*)MSCreateObject([_MSIndexedColor class]);
        c->_rgba.r= (MSByte)((entry.value >> 24) & 0xff);
        c->_rgba.g= (MSByte)((entry.value >> 16) & 0xff);
        c->_rgba.b= (MSByte)((entry.value >>  8) & 0xff);
        c->_rgba.a= (MSByte)((entry.value      ) & 0xff);
        c->_name= RETAIN(s);
        c->_colorIndex= i;
        *entry.color= c;
        [__namedColors setObject:c forKey:[s lowercaseString]];
        [__namedColors setObject:c forKey:s];
        [__colorsList addObject:c];
        }
    [pool release];
    }}
}
- (oneway void)release {}
- (id)retain { return self;}
- (id)autorelease { return self;}
- (void)dealloc {if (0) [super dealloc];} // No warning
- (Class)classForCoder { return __MSIndexedColorClass; }
- (id)copyWithZone:(NSZone *)z { return self; z= nil;}
- (id)copy { return self; }
- (id)initWithCoder:(NSCoder *)aDecoder
{
  int i= -1;
  if ([aDecoder allowsKeyedCoding]) {
    i= [aDecoder decodeIntForKey:@"color-index"];
  }
  else {
    [aDecoder decodeValueOfObjCType:@encode(int) at:&i];
  }
  RELEASE(self);
  if (0 <= i && i < COLOR_LIST_COUNT) {
    return [__colorsList objectAtIndex:(NSUInteger)i];
  }
  return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  if ([aCoder allowsKeyedCoding]) {
    [aCoder encodeInt:_colorIndex forKey:@"color-index"];
  }
  else {
    [aCoder encodeValueOfObjCType:@encode(int) at:&_colorIndex];
  }
}

- (NSString *)htmlRepresentation { return _name; }

@end

MSColor *MSAliceBlue;
MSColor *MSAntiqueWhite;
MSColor *MSAqua;
MSColor *MSAquamarine;
MSColor *MSAzure;
MSColor *MSBeige;
MSColor *MSBisque;
MSColor *MSBlack;
MSColor *MSBlanchedAlmond;
MSColor *MSBlue;
MSColor *MSBlueViolet;
MSColor *MSBrown;
MSColor *MSBurlyWood;
MSColor *MSCadetBlue;
MSColor *MSChartreuse;
MSColor *MSChocolate;
MSColor *MSCoral;
MSColor *MSCornflowerBlue;
MSColor *MSCornsilk;
MSColor *MSCrimson;
MSColor *MSCyan;
MSColor *MSDarkBlue;
MSColor *MSDarkCyan;
MSColor *MSDarkGoldenRod;
MSColor *MSDarkGray;
MSColor *MSDarkGreen;
MSColor *MSDarkKhaki;
MSColor *MSDarkMagenta;
MSColor *MSDarkOrange;
MSColor *MSDarkOrchid;
MSColor *MSDarkRed;
MSColor *MSDarkSalmon;
MSColor *MSDarkSeaGreen;
MSColor *MSDarkSlateBlue;
MSColor *MSDarkSlateGray;
MSColor *MSDarkTurquoise;
MSColor *MSDarkViolet;
MSColor *MSDeepPink;
MSColor *MSDeepSkyBlue;
MSColor *MSDimGray;
MSColor *MSDodgerBlue;
MSColor *MSFireBrick;
MSColor *MSFloralWhite;
MSColor *MSForestGreen;
MSColor *MSFuchsia;
MSColor *MSGainsboro;
MSColor *MSGhostWhite;
MSColor *MSGold;
MSColor *MSGoldenRod;
MSColor *MSGray;
MSColor *MSGreen;
MSColor *MSGreenYellow;
MSColor *MSHoneyDew;
MSColor *MSHotPink;
MSColor *MSIndianRed;
MSColor *MSIndigo;
MSColor *MSIvory;
MSColor *MSKhaki;
MSColor *MSLavender;
MSColor *MSLavenderBlush;
MSColor *MSLawnGreen;
MSColor *MSLemonChiffon;
MSColor *MSLightBlue;
MSColor *MSLightCoral;
MSColor *MSLightCyan;
MSColor *MSLightGoldenRodYellow;
MSColor *MSLightGray;
MSColor *MSLightGreen;
MSColor *MSLightPink;
MSColor *MSLightSalmon;
MSColor *MSLightSeaGreen;
MSColor *MSLightSkyBlue;
MSColor *MSLightSlateGray;
MSColor *MSLightSteelBlue;
MSColor *MSLightYellow;
MSColor *MSLime;
MSColor *MSLimeGreen;
MSColor *MSLinen;
MSColor *MSMagenta;
MSColor *MSMaroon;
MSColor *MSMediumAquaMarine;
MSColor *MSMediumOrchid;
MSColor *MSMediumPurple;
MSColor *MSMediumSeaGreen;
MSColor *MSMediumStateBlue;
MSColor *MSMediumSpringGreen;
MSColor *MSMediumTurquoise;
MSColor *MSMediumVioletRed;
MSColor *MSMidnightBlue;
MSColor *MSMintCream;
MSColor *MSMistyRose;
MSColor *MSMoccasin;
MSColor *MSNavajoWhite;
MSColor *MSNavy;
MSColor *MSOldLace;
MSColor *MSOlive;
MSColor *MSOliveDrab;
MSColor *MSOrange;
MSColor *MSOrangeRed;
MSColor *MSOrchid;
MSColor *MSPaleGoldenRod;
MSColor *MSPaleGreen;
MSColor *MSPaleTurquoise;
MSColor *MSPaleVioletRed;
MSColor *MSPapayaWhip;
MSColor *MSPeachPuff;
MSColor *MSPeru;
MSColor *MSPink;
MSColor *MSPlum;
MSColor *MSPowderBlue;
MSColor *MSPurple;
MSColor *MSRed;
MSColor *MSRosyBrown;
MSColor *MSRoyalBlue;
MSColor *MSSaddleBrown;
MSColor *MSSalmon;
MSColor *MSSandyBrown;
MSColor *MSSeaGreen;
MSColor *MSSeaShell;
MSColor *MSSienna;
MSColor *MSSilver;
MSColor *MSSkyBlue;
MSColor *MSSlateBlue;
MSColor *MSSlateGray;
MSColor *MSSnow;
MSColor *MSSpringGreen;
MSColor *MSSteelBlue;
MSColor *MSTan;
MSColor *MSTeal;
MSColor *MSThistle;
MSColor *MSTomato;
MSColor *MSTransparent;
MSColor *MSTurquoise;
MSColor *MSViolet;
MSColor *MSWheat;
MSColor *MSWhite;
MSColor *MSWhiteSmoke;
MSColor *MSYellow;
MSColor *MSYellowGreen;
