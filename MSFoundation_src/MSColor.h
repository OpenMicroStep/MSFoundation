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
  implement - (Class)classForCoder ; method
 */


@protocol MSColor <NSObject>

- (float)redComponent ;
- (float)greenComponent ;
- (float)blueComponent ;
- (float)alphaComponent ;

- (float)cyanComponent ;
- (float)magentaComponent ;
- (float)yellowComponent ;
- (float)blackComponent ;

- (MSByte)red ;
- (MSByte)green ;
- (MSByte)blue ;
- (MSByte)opacity ;
- (MSByte)transparency ;

- (MSUInt)rgbaValue ;
- (MSUInt)cssValue ;

- (BOOL)isPaleColor ;
- (float)luminance ;

- (id <MSColor>)lighterColor ;
- (id <MSColor>)darkerColor ;

- (id <MSColor>)lightestColor ;
- (id <MSColor>)darkestColor ;

- (id <MSColor>)matchingVisibleColor ;

- (id <MSColor>)colorWithAlpha:(MSByte)opacity ;

- (BOOL)isEqualToColorObject:(id <MSColor>)color ;
- (NSComparisonResult)compareToColorObject:(id <MSColor>)color ;

@end

@interface MSColor : NSObject <MSColor, NSCopying, NSCoding>

+ (MSColor *)colorWithRGBAValue:(MSUInt)color ; //RRGGBBAA
+ (MSColor *)colorWithCSSValue:(MSUInt)color ;  // TTRRGGBB

+ (MSColor *)colorWithRed:(MSByte)red green:(MSByte)green blue:(MSByte)blue ;
+ (MSColor *)colorWithRed:(MSByte)red green:(MSByte)green blue:(MSByte)blue opacity:(unsigned char)alpha ;

+ (MSColor *)colorWithRedComponent:(float)red greenComponent:(float)green blueComponent:(float)blue ;
+ (MSColor *)colorWithRedComponent:(float)red greenComponent:(float)green blueComponent:(float)blue alphaComponent:(float)alpha;

@end

@interface MSColor (Naming)

+ (MSColor *)colorWithName:(NSString *)name ;

@end

MSExport MSColor *MSCreateColor(MSUInt rgbaValue) ;
MSExport MSColor *MSCreateCSSColor(MSUInt trgbValue) ;

MSExport MSColor *MSColorNamed(NSString *name) ;  // example :   MSColor *a = MSColorNamed(@"AliceBlue") ;

MSExport MSColor *MSAliceBlue           (void) ; // 0xf0f8ffff
MSExport MSColor *MSAntiqueWhite        (void) ; // 0xfaebd7ff
MSExport MSColor *MSAqua                (void) ; // 0x00ffffff
MSExport MSColor *MSAquamarine          (void) ; // 0x7fffd4ff
MSExport MSColor *MSAzure               (void) ; // 0xf0ffffff
MSExport MSColor *MSBeige               (void) ; // 0xf5f5dcff
MSExport MSColor *MSBisque              (void) ; // 0xffe4c4ff
MSExport MSColor *MSBlack               (void) ; // 0x000000ff
MSExport MSColor *MSBlanchedAlmond      (void) ; // 0xffebcdff
MSExport MSColor *MSBlue                (void) ; // 0x0000ffff
MSExport MSColor *MSBlueViolet          (void) ; // 0x8a2be2ff
MSExport MSColor *MSBrown               (void) ; // 0xa52a2aff
MSExport MSColor *MSBurlyWood           (void) ; // 0xdeb887ff
MSExport MSColor *MSCadetBlue           (void) ; // 0x5f9ea0ff
MSExport MSColor *MSChartreuse          (void) ; // 0x7fff00ff
MSExport MSColor *MSChocolate           (void) ; // 0xd2691eff
MSExport MSColor *MSCoral               (void) ; // 0xff7f50ff
MSExport MSColor *MSCornflowerBlue      (void) ; // 0x6495edff
MSExport MSColor *MSCornsilk            (void) ; // 0xfff8dcff
MSExport MSColor *MSCrimson             (void) ; // 0xdc143cff
MSExport MSColor *MSCyan                (void) ; // 0x00ffffff
MSExport MSColor *MSDarkBlue            (void) ; // 0x00008bff
MSExport MSColor *MSDarkCyan            (void) ; // 0x008b8bff
MSExport MSColor *MSDarkGoldenRod       (void) ; // 0xb8860bff
MSExport MSColor *MSDarkGray            (void) ; // 0xa9a9a9ff
MSExport MSColor *MSDarkGreen           (void) ; // 0x006400ff
MSExport MSColor *MSDarkKhaki           (void) ; // 0xbdb76bff
MSExport MSColor *MSDarkMagenta         (void) ; // 0x8b008bff
MSExport MSColor *MSDarkOrange          (void) ; // 0xff8c00ff
MSExport MSColor *MSDarkOrchid          (void) ; // 0x9932ccff
MSExport MSColor *MSDarkRed             (void) ; // 0x8b0000ff
MSExport MSColor *MSDarkSalmon          (void) ; // 0xe9967aff
MSExport MSColor *MSDarkSeaGreen        (void) ; // 0x8fbc8fff
MSExport MSColor *MSDarkSlateBlue       (void) ; // 0x483d8bff
MSExport MSColor *MSDarkSlateGray       (void) ; // 0x2f4f4fff
MSExport MSColor *MSDarkTurquoise       (void) ; // 0x00ced1ff
MSExport MSColor *MSDarkViolet          (void) ; // 0x9400d3ff
MSExport MSColor *MSDeepPink            (void) ; // 0xff1493ff
MSExport MSColor *MSDeepSkyBlue         (void) ; // 0x00bfffff
MSExport MSColor *MSDimGray             (void) ; // 0x696969ff
MSExport MSColor *MSDodgerBlue          (void) ; // 0x1e90ffff
MSExport MSColor *MSFireBrick           (void) ; // 0xb22222ff
MSExport MSColor *MSFloralWhite         (void) ; // 0xfffaf0ff
MSExport MSColor *MSForestGreen         (void) ; // 0x228b22ff
MSExport MSColor *MSFuchsia             (void) ; // 0xff00ffff
MSExport MSColor *MSGainsboro           (void) ; // 0xdcdcdcff
MSExport MSColor *MSGhostWhite          (void) ; // 0xf8f8ffff
MSExport MSColor *MSGold                (void) ; // 0xffd700ff
MSExport MSColor *MSGoldenRod           (void) ; // 0xdaa520ff
MSExport MSColor *MSGray                (void) ; // 0x808080ff
MSExport MSColor *MSGreen               (void) ; // 0x008000ff
MSExport MSColor *MSGreenYellow         (void) ; // 0xadff2fff
MSExport MSColor *MSHoneyDew            (void) ; // 0xf0fff0ff
MSExport MSColor *MSHotPink             (void) ; // 0xff69b4ff
MSExport MSColor *MSIndianRed           (void) ; // 0xcd5c5cff
MSExport MSColor *MSIndigo              (void) ; // 0x4b0082ff
MSExport MSColor *MSIvory               (void) ; // 0xfffff0ff
MSExport MSColor *MSKhaki               (void) ; // 0xf0e68cff
MSExport MSColor *MSLavender            (void) ; // 0xe6e6faff
MSExport MSColor *MSLavenderBlush       (void) ; // 0xfff0f5ff
MSExport MSColor *MSLawnGreen           (void) ; // 0x7cfc00ff
MSExport MSColor *MSLemonChiffon        (void) ; // 0xfffacdff
MSExport MSColor *MSLightBlue           (void) ; // 0xadd8e6ff
MSExport MSColor *MSLightCoral          (void) ; // 0xf08080ff
MSExport MSColor *MSLightCyan           (void) ; // 0xe0ffffff
MSExport MSColor *MSLightGoldenRodYellow(void) ; // 0xfafad2ff
MSExport MSColor *MSLightGray           (void) ; // 0xd3d3d3ff
MSExport MSColor *MSLightGreen          (void) ; // 0x90ee90ff
MSExport MSColor *MSLightPink           (void) ; // 0xffb6c1ff
MSExport MSColor *MSLightSalmon         (void) ; // 0xffa07aff
MSExport MSColor *MSLightSeaGreen       (void) ; // 0x20b2aaff
MSExport MSColor *MSLightSkyBlue        (void) ; // 0x87cefaff
MSExport MSColor *MSLightSlateGray      (void) ; // 0x778899ff
MSExport MSColor *MSLightSteelBlue      (void) ; // 0xb0c4deff
MSExport MSColor *MSLightYellow         (void) ; // 0xffffe0ff
MSExport MSColor *MSLime                (void) ; // 0x00ff00ff
MSExport MSColor *MSLimeGreen           (void) ; // 0x32cd32ff
MSExport MSColor *MSLinen               (void) ; // 0xfaf0e6ff
MSExport MSColor *MSMagenta             (void) ; // 0xff00ffff
MSExport MSColor *MSMaroon              (void) ; // 0x800000ff
MSExport MSColor *MSMediumAquaMarine    (void) ; // 0x66cdaaff
MSExport MSColor *MSMediumOrchid        (void) ; // 0xba55d3ff
MSExport MSColor *MSMediumPurple        (void) ; // 0x9370d8ff
MSExport MSColor *MSMediumSeaGreen      (void) ; // 0x3cb371ff
MSExport MSColor *MSMediumStateBlue     (void) ; // 0x7b68eeff
MSExport MSColor *MSMediumSpringGreen   (void) ; // 0x00fa9aff
MSExport MSColor *MSMediumTurquoise     (void) ; // 0x48d1ccff
MSExport MSColor *MSMediumVioletRed     (void) ; // 0xc71585ff
MSExport MSColor *MSMidnightBlue        (void) ; // 0x191970ff
MSExport MSColor *MSMintCream           (void) ; // 0xf5fffaff
MSExport MSColor *MSMistyRose           (void) ; // 0xffe4e1ff
MSExport MSColor *MSMoccasin            (void) ; // 0xffe4b5ff
MSExport MSColor *MSNavajoWhite         (void) ; // 0xffdeadff
MSExport MSColor *MSNavy                (void) ; // 0x000080ff
MSExport MSColor *MSOldLace             (void) ; // 0xfdf5e6ff
MSExport MSColor *MSOlive               (void) ; // 0x808000ff
MSExport MSColor *MSOliveDrab           (void) ; // 0x6b8e23ff
MSExport MSColor *MSOrange              (void) ; // 0xffa500ff
MSExport MSColor *MSOrangeRed           (void) ; // 0xff4500ff
MSExport MSColor *MSOrchid              (void) ; // 0xda70d6ff
MSExport MSColor *MSPaleGoldenRod       (void) ; // 0xeee8aaff
MSExport MSColor *MSPaleGreen           (void) ; // 0x98fb98ff
MSExport MSColor *MSPaleTurquoise       (void) ; // 0xafeeeeff
MSExport MSColor *MSPaleVioletRed       (void) ; // 0xd87093ff
MSExport MSColor *MSPapayaWhip          (void) ; // 0xffefd5ff
MSExport MSColor *MSPeachPuff           (void) ; // 0xffdab9ff
MSExport MSColor *MSPeru                (void) ; // 0xcd853fff
MSExport MSColor *MSPink                (void) ; // 0xffc0cbff
MSExport MSColor *MSPlum                (void) ; // 0xdda0ddff
MSExport MSColor *MSPowderBlue          (void) ; // 0xb0e0e6ff
MSExport MSColor *MSPurple              (void) ; // 0x800080ff
MSExport MSColor *MSRed                 (void) ; // 0xff0000ff
MSExport MSColor *MSRosyBrown           (void) ; // 0xbc8f8fff
MSExport MSColor *MSRoyalBlue           (void) ; // 0x4169e1ff
MSExport MSColor *MSSaddleBrown         (void) ; // 0x8b4513ff
MSExport MSColor *MSSalmon              (void) ; // 0xfa8072ff
MSExport MSColor *MSSandyBrown          (void) ; // 0xf4a460ff
MSExport MSColor *MSSeaGreen            (void) ; // 0x2e8b57ff
MSExport MSColor *MSSeaShell            (void) ; // 0xfff5eeff
MSExport MSColor *MSSienna              (void) ; // 0xa0522dff
MSExport MSColor *MSSilver              (void) ; // 0xc0c0c0ff
MSExport MSColor *MSSkyBlue             (void) ; // 0x87ceebff
MSExport MSColor *MSSlateBlue           (void) ; // 0x6a5acdff
MSExport MSColor *MSSlateGray           (void) ; // 0x708090ff
MSExport MSColor *MSSnow                (void) ; // 0xfffafaff
MSExport MSColor *MSSpringGreen         (void) ; // 0x00ff7fff
MSExport MSColor *MSSteelBlue           (void) ; // 0x4682b4ff
MSExport MSColor *MSTan                 (void) ; // 0xd2b48cff
MSExport MSColor *MSTeal                (void) ; // 0x008080ff
MSExport MSColor *MSThistle             (void) ; // 0xd8bfd8ff
MSExport MSColor *MSTomato              (void) ; // 0xff6347ff
MSExport MSColor *MSTransparent         (void) ; // 0x00000000
MSExport MSColor *MSTurquoise           (void) ; // 0x40e0d0ff
MSExport MSColor *MSViolet              (void) ; // 0xee82eeff
MSExport MSColor *MSWheat               (void) ; // 0xf5deb3ff
MSExport MSColor *MSWhite               (void) ; // 0xffffffff
MSExport MSColor *MSWhiteSmoke          (void) ; // 0xf5f5f5ff
MSExport MSColor *MSYellow              (void) ; // 0xffff00ff
MSExport MSColor *MSYellowGreen         (void) ; // 0x9acd32ff
