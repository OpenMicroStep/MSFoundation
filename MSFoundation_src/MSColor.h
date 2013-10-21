/* MSColor.h
 
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
 
 WARNING : this header file cannot be included alone, please direclty
 include <MSFoundation/MSFoundation.h>
 
 */

/*
  if you intend to subclass MSColor class, you will need to
  implement - (Class)classForCoder; method
 */


@protocol MSColor <NSObject>

- (float)redComponent;
- (float)greenComponent;
- (float)blueComponent;
- (float)alphaComponent;

- (float)cyanComponent;
- (float)magentaComponent;
- (float)yellowComponent;
- (float)blackComponent;

- (MSByte)red;
- (MSByte)green;
- (MSByte)blue;
- (MSByte)opacity;
- (MSByte)transparency;

- (MSUInt)rgbaValue;
- (MSUInt)cssValue;

- (BOOL)isPaleColor;
- (float)luminance;

- (id <MSColor>)lighterColor;
- (id <MSColor>)darkerColor;

- (id <MSColor>)lightestColor;
- (id <MSColor>)darkestColor;

- (id <MSColor>)matchingVisibleColor;

- (id <MSColor>)colorWithAlpha:(MSByte)opacity;

- (BOOL)isEqualToColorObject:(id <MSColor>)color;
- (NSComparisonResult)compareToColorObject:(id <MSColor>)color;

@end

@interface MSColor : NSObject <MSColor, NSCopying, NSCoding>

+ (MSColor*)colorWithRGBAValue:(MSUInt)color; // RRGGBBAA
+ (MSColor*)colorWithCSSValue:(MSUInt)color;  // TTRRGGBB

+ (MSColor*)colorWithRed:(MSByte)red green:(MSByte)green blue:(MSByte)blue;
+ (MSColor*)colorWithRed:(MSByte)red green:(MSByte)green blue:(MSByte)blue opacity:(unsigned char)alpha;

+ (MSColor*)colorWithRedComponent:(float)red greenComponent:(float)green blueComponent:(float)blue;
+ (MSColor*)colorWithRedComponent:(float)red greenComponent:(float)green blueComponent:(float)blue alphaComponent:(float)alpha;

@end

@interface MSColor (Naming)

+ (MSColor *)colorWithName:(NSString *)name;

@end

MSExport MSColor *MSCreateColor(MSUInt rgbaValue);
MSExport MSColor *MSCreateCSSColor(MSUInt trgbValue);

MSExport MSColor *MSColorNamed(NSString *name);  // example :   MSColor *a = MSColorNamed(@"AliceBlue");

MSExport MSColor *MSAliceBlue           ; // 0xf0f8ffff
MSExport MSColor *MSAntiqueWhite        ; // 0xfaebd7ff
MSExport MSColor *MSAqua                ; // 0x00ffffff
MSExport MSColor *MSAquamarine          ; // 0x7fffd4ff
MSExport MSColor *MSAzure               ; // 0xf0ffffff
MSExport MSColor *MSBeige               ; // 0xf5f5dcff
MSExport MSColor *MSBisque              ; // 0xffe4c4ff
MSExport MSColor *MSBlack               ; // 0x000000ff
MSExport MSColor *MSBlanchedAlmond      ; // 0xffebcdff
MSExport MSColor *MSBlue                ; // 0x0000ffff
MSExport MSColor *MSBlueViolet          ; // 0x8a2be2ff
MSExport MSColor *MSBrown               ; // 0xa52a2aff
MSExport MSColor *MSBurlyWood           ; // 0xdeb887ff
MSExport MSColor *MSCadetBlue           ; // 0x5f9ea0ff
MSExport MSColor *MSChartreuse          ; // 0x7fff00ff
MSExport MSColor *MSChocolate           ; // 0xd2691eff
MSExport MSColor *MSCoral               ; // 0xff7f50ff
MSExport MSColor *MSCornflowerBlue      ; // 0x6495edff
MSExport MSColor *MSCornsilk            ; // 0xfff8dcff
MSExport MSColor *MSCrimson             ; // 0xdc143cff
MSExport MSColor *MSCyan                ; // 0x00ffffff
MSExport MSColor *MSDarkBlue            ; // 0x00008bff
MSExport MSColor *MSDarkCyan            ; // 0x008b8bff
MSExport MSColor *MSDarkGoldenRod       ; // 0xb8860bff
MSExport MSColor *MSDarkGray            ; // 0xa9a9a9ff
MSExport MSColor *MSDarkGreen           ; // 0x006400ff
MSExport MSColor *MSDarkKhaki           ; // 0xbdb76bff
MSExport MSColor *MSDarkMagenta         ; // 0x8b008bff
MSExport MSColor *MSDarkOrange          ; // 0xff8c00ff
MSExport MSColor *MSDarkOrchid          ; // 0x9932ccff
MSExport MSColor *MSDarkRed             ; // 0x8b0000ff
MSExport MSColor *MSDarkSalmon          ; // 0xe9967aff
MSExport MSColor *MSDarkSeaGreen        ; // 0x8fbc8fff
MSExport MSColor *MSDarkSlateBlue       ; // 0x483d8bff
MSExport MSColor *MSDarkSlateGray       ; // 0x2f4f4fff
MSExport MSColor *MSDarkTurquoise       ; // 0x00ced1ff
MSExport MSColor *MSDarkViolet          ; // 0x9400d3ff
MSExport MSColor *MSDeepPink            ; // 0xff1493ff
MSExport MSColor *MSDeepSkyBlue         ; // 0x00bfffff
MSExport MSColor *MSDimGray             ; // 0x696969ff
MSExport MSColor *MSDodgerBlue          ; // 0x1e90ffff
MSExport MSColor *MSFireBrick           ; // 0xb22222ff
MSExport MSColor *MSFloralWhite         ; // 0xfffaf0ff
MSExport MSColor *MSForestGreen         ; // 0x228b22ff
MSExport MSColor *MSFuchsia             ; // 0xff00ffff
MSExport MSColor *MSGainsboro           ; // 0xdcdcdcff
MSExport MSColor *MSGhostWhite          ; // 0xf8f8ffff
MSExport MSColor *MSGold                ; // 0xffd700ff
MSExport MSColor *MSGoldenRod           ; // 0xdaa520ff
MSExport MSColor *MSGray                ; // 0x808080ff
MSExport MSColor *MSGreen               ; // 0x008000ff
MSExport MSColor *MSGreenYellow         ; // 0xadff2fff
MSExport MSColor *MSHoneyDew            ; // 0xf0fff0ff
MSExport MSColor *MSHotPink             ; // 0xff69b4ff
MSExport MSColor *MSIndianRed           ; // 0xcd5c5cff
MSExport MSColor *MSIndigo              ; // 0x4b0082ff
MSExport MSColor *MSIvory               ; // 0xfffff0ff
MSExport MSColor *MSKhaki               ; // 0xf0e68cff
MSExport MSColor *MSLavender            ; // 0xe6e6faff
MSExport MSColor *MSLavenderBlush       ; // 0xfff0f5ff
MSExport MSColor *MSLawnGreen           ; // 0x7cfc00ff
MSExport MSColor *MSLemonChiffon        ; // 0xfffacdff
MSExport MSColor *MSLightBlue           ; // 0xadd8e6ff
MSExport MSColor *MSLightCoral          ; // 0xf08080ff
MSExport MSColor *MSLightCyan           ; // 0xe0ffffff
MSExport MSColor *MSLightGoldenRodYellow; // 0xfafad2ff
MSExport MSColor *MSLightGray           ; // 0xd3d3d3ff
MSExport MSColor *MSLightGreen          ; // 0x90ee90ff
MSExport MSColor *MSLightPink           ; // 0xffb6c1ff
MSExport MSColor *MSLightSalmon         ; // 0xffa07aff
MSExport MSColor *MSLightSeaGreen       ; // 0x20b2aaff
MSExport MSColor *MSLightSkyBlue        ; // 0x87cefaff
MSExport MSColor *MSLightSlateGray      ; // 0x778899ff
MSExport MSColor *MSLightSteelBlue      ; // 0xb0c4deff
MSExport MSColor *MSLightYellow         ; // 0xffffe0ff
MSExport MSColor *MSLime                ; // 0x00ff00ff
MSExport MSColor *MSLimeGreen           ; // 0x32cd32ff
MSExport MSColor *MSLinen               ; // 0xfaf0e6ff
MSExport MSColor *MSMagenta             ; // 0xff00ffff
MSExport MSColor *MSMaroon              ; // 0x800000ff
MSExport MSColor *MSMediumAquaMarine    ; // 0x66cdaaff
MSExport MSColor *MSMediumOrchid        ; // 0xba55d3ff
MSExport MSColor *MSMediumPurple        ; // 0x9370d8ff
MSExport MSColor *MSMediumSeaGreen      ; // 0x3cb371ff
MSExport MSColor *MSMediumStateBlue     ; // 0x7b68eeff
MSExport MSColor *MSMediumSpringGreen   ; // 0x00fa9aff
MSExport MSColor *MSMediumTurquoise     ; // 0x48d1ccff
MSExport MSColor *MSMediumVioletRed     ; // 0xc71585ff
MSExport MSColor *MSMidnightBlue        ; // 0x191970ff
MSExport MSColor *MSMintCream           ; // 0xf5fffaff
MSExport MSColor *MSMistyRose           ; // 0xffe4e1ff
MSExport MSColor *MSMoccasin            ; // 0xffe4b5ff
MSExport MSColor *MSNavajoWhite         ; // 0xffdeadff
MSExport MSColor *MSNavy                ; // 0x000080ff
MSExport MSColor *MSOldLace             ; // 0xfdf5e6ff
MSExport MSColor *MSOlive               ; // 0x808000ff
MSExport MSColor *MSOliveDrab           ; // 0x6b8e23ff
MSExport MSColor *MSOrange              ; // 0xffa500ff
MSExport MSColor *MSOrangeRed           ; // 0xff4500ff
MSExport MSColor *MSOrchid              ; // 0xda70d6ff
MSExport MSColor *MSPaleGoldenRod       ; // 0xeee8aaff
MSExport MSColor *MSPaleGreen           ; // 0x98fb98ff
MSExport MSColor *MSPaleTurquoise       ; // 0xafeeeeff
MSExport MSColor *MSPaleVioletRed       ; // 0xd87093ff
MSExport MSColor *MSPapayaWhip          ; // 0xffefd5ff
MSExport MSColor *MSPeachPuff           ; // 0xffdab9ff
MSExport MSColor *MSPeru                ; // 0xcd853fff
MSExport MSColor *MSPink                ; // 0xffc0cbff
MSExport MSColor *MSPlum                ; // 0xdda0ddff
MSExport MSColor *MSPowderBlue          ; // 0xb0e0e6ff
MSExport MSColor *MSPurple              ; // 0x800080ff
MSExport MSColor *MSRed                 ; // 0xff0000ff
MSExport MSColor *MSRosyBrown           ; // 0xbc8f8fff
MSExport MSColor *MSRoyalBlue           ; // 0x4169e1ff
MSExport MSColor *MSSaddleBrown         ; // 0x8b4513ff
MSExport MSColor *MSSalmon              ; // 0xfa8072ff
MSExport MSColor *MSSandyBrown          ; // 0xf4a460ff
MSExport MSColor *MSSeaGreen            ; // 0x2e8b57ff
MSExport MSColor *MSSeaShell            ; // 0xfff5eeff
MSExport MSColor *MSSienna              ; // 0xa0522dff
MSExport MSColor *MSSilver              ; // 0xc0c0c0ff
MSExport MSColor *MSSkyBlue             ; // 0x87ceebff
MSExport MSColor *MSSlateBlue           ; // 0x6a5acdff
MSExport MSColor *MSSlateGray           ; // 0x708090ff
MSExport MSColor *MSSnow                ; // 0xfffafaff
MSExport MSColor *MSSpringGreen         ; // 0x00ff7fff
MSExport MSColor *MSSteelBlue           ; // 0x4682b4ff
MSExport MSColor *MSTan                 ; // 0xd2b48cff
MSExport MSColor *MSTeal                ; // 0x008080ff
MSExport MSColor *MSThistle             ; // 0xd8bfd8ff
MSExport MSColor *MSTomato              ; // 0xff6347ff
MSExport MSColor *MSTransparent         ; // 0x00000000
MSExport MSColor *MSTurquoise           ; // 0x40e0d0ff
MSExport MSColor *MSViolet              ; // 0xee82eeff
MSExport MSColor *MSWheat               ; // 0xf5deb3ff
MSExport MSColor *MSWhite               ; // 0xffffffff
MSExport MSColor *MSWhiteSmoke          ; // 0xf5f5f5ff
MSExport MSColor *MSYellow              ; // 0xffff00ff
MSExport MSColor *MSYellowGreen         ; // 0x9acd32ff
