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

MSFoundationExtern MSColor *MSCreateColor(MSUInt rgbaValue);
MSFoundationExtern MSColor *MSCreateCSSColor(MSUInt trgbValue);

MSFoundationExtern MSColor *MSColorNamed(NSString *name);  // example :   MSColor *a = MSColorNamed(@"AliceBlue");

MSFoundationExtern MSColor *MSAliceBlue;            // 0xf0f8ffff
MSFoundationExtern MSColor *MSAntiqueWhite;         // 0xfaebd7ff
MSFoundationExtern MSColor *MSAqua;                 // 0x00ffffff
MSFoundationExtern MSColor *MSAquamarine;           // 0x7fffd4ff
MSFoundationExtern MSColor *MSAzure;                // 0xf0ffffff
MSFoundationExtern MSColor *MSBeige;                // 0xf5f5dcff
MSFoundationExtern MSColor *MSBisque;               // 0xffe4c4ff
MSFoundationExtern MSColor *MSBlack;                // 0x000000ff
MSFoundationExtern MSColor *MSBlanchedAlmond;       // 0xffebcdff
MSFoundationExtern MSColor *MSBlue;                 // 0x0000ffff
MSFoundationExtern MSColor *MSBlueViolet;           // 0x8a2be2ff
MSFoundationExtern MSColor *MSBrown;                // 0xa52a2aff
MSFoundationExtern MSColor *MSBurlyWood;            // 0xdeb887ff
MSFoundationExtern MSColor *MSCadetBlue;            // 0x5f9ea0ff
MSFoundationExtern MSColor *MSChartreuse;           // 0x7fff00ff
MSFoundationExtern MSColor *MSChocolate;            // 0xd2691eff
MSFoundationExtern MSColor *MSCoral;                // 0xff7f50ff
MSFoundationExtern MSColor *MSCornflowerBlue;       // 0x6495edff
MSFoundationExtern MSColor *MSCornsilk;             // 0xfff8dcff
MSFoundationExtern MSColor *MSCrimson;              // 0xdc143cff
MSFoundationExtern MSColor *MSCyan;                 // 0x00ffffff
MSFoundationExtern MSColor *MSDarkBlue;             // 0x00008bff
MSFoundationExtern MSColor *MSDarkCyan;             // 0x008b8bff
MSFoundationExtern MSColor *MSDarkGoldenRod;        // 0xb8860bff
MSFoundationExtern MSColor *MSDarkGray;             // 0xa9a9a9ff
MSFoundationExtern MSColor *MSDarkGreen;            // 0x006400ff
MSFoundationExtern MSColor *MSDarkKhaki;            // 0xbdb76bff
MSFoundationExtern MSColor *MSDarkMagenta;          // 0x8b008bff
MSFoundationExtern MSColor *MSDarkOrange;           // 0xff8c00ff
MSFoundationExtern MSColor *MSDarkOrchid;           // 0x9932ccff
MSFoundationExtern MSColor *MSDarkRed;              // 0x8b0000ff
MSFoundationExtern MSColor *MSDarkSalmon;           // 0xe9967aff
MSFoundationExtern MSColor *MSDarkSeaGreen;         // 0x8fbc8fff
MSFoundationExtern MSColor *MSDarkSlateBlue;        // 0x483d8bff
MSFoundationExtern MSColor *MSDarkSlateGray;        // 0x2f4f4fff
MSFoundationExtern MSColor *MSDarkTurquoise;        // 0x00ced1ff
MSFoundationExtern MSColor *MSDarkViolet;           // 0x9400d3ff
MSFoundationExtern MSColor *MSDeepPink;             // 0xff1493ff
MSFoundationExtern MSColor *MSDeepSkyBlue;          // 0x00bfffff
MSFoundationExtern MSColor *MSDimGray;              // 0x696969ff
MSFoundationExtern MSColor *MSDodgerBlue;           // 0x1e90ffff
MSFoundationExtern MSColor *MSFireBrick;            // 0xb22222ff
MSFoundationExtern MSColor *MSFloralWhite;          // 0xfffaf0ff
MSFoundationExtern MSColor *MSForestGreen;          // 0x228b22ff
MSFoundationExtern MSColor *MSFuchsia;              // 0xff00ffff
MSFoundationExtern MSColor *MSGainsboro;            // 0xdcdcdcff
MSFoundationExtern MSColor *MSGhostWhite;           // 0xf8f8ffff
MSFoundationExtern MSColor *MSGold;                 // 0xffd700ff
MSFoundationExtern MSColor *MSGoldenRod;            // 0xdaa520ff
MSFoundationExtern MSColor *MSGray;                 // 0x808080ff
MSFoundationExtern MSColor *MSGreen;                // 0x008000ff
MSFoundationExtern MSColor *MSGreenYellow;          // 0xadff2fff
MSFoundationExtern MSColor *MSHoneyDew;             // 0xf0fff0ff
MSFoundationExtern MSColor *MSHotPink;              // 0xff69b4ff
MSFoundationExtern MSColor *MSIndianRed;            // 0xcd5c5cff
MSFoundationExtern MSColor *MSIndigo;               // 0x4b0082ff
MSFoundationExtern MSColor *MSIvory;                // 0xfffff0ff
MSFoundationExtern MSColor *MSKhaki;                // 0xf0e68cff
MSFoundationExtern MSColor *MSLavender;             // 0xe6e6faff
MSFoundationExtern MSColor *MSLavenderBlush;        // 0xfff0f5ff
MSFoundationExtern MSColor *MSLawnGreen;            // 0x7cfc00ff
MSFoundationExtern MSColor *MSLemonChiffon;         // 0xfffacdff
MSFoundationExtern MSColor *MSLightBlue;            // 0xadd8e6ff
MSFoundationExtern MSColor *MSLightCoral;           // 0xf08080ff
MSFoundationExtern MSColor *MSLightCyan;            // 0xe0ffffff
MSFoundationExtern MSColor *MSLightGoldenRodYellow; // 0xfafad2ff
MSFoundationExtern MSColor *MSLightGray;            // 0xd3d3d3ff
MSFoundationExtern MSColor *MSLightGreen;           // 0x90ee90ff
MSFoundationExtern MSColor *MSLightPink;            // 0xffb6c1ff
MSFoundationExtern MSColor *MSLightSalmon;          // 0xffa07aff
MSFoundationExtern MSColor *MSLightSeaGreen;        // 0x20b2aaff
MSFoundationExtern MSColor *MSLightSkyBlue;         // 0x87cefaff
MSFoundationExtern MSColor *MSLightSlateGray;       // 0x778899ff
MSFoundationExtern MSColor *MSLightSteelBlue;       // 0xb0c4deff
MSFoundationExtern MSColor *MSLightYellow;          // 0xffffe0ff
MSFoundationExtern MSColor *MSLime;                 // 0x00ff00ff
MSFoundationExtern MSColor *MSLimeGreen;            // 0x32cd32ff
MSFoundationExtern MSColor *MSLinen;                // 0xfaf0e6ff
MSFoundationExtern MSColor *MSMagenta;              // 0xff00ffff
MSFoundationExtern MSColor *MSMaroon;               // 0x800000ff
MSFoundationExtern MSColor *MSMediumAquaMarine;     // 0x66cdaaff
MSFoundationExtern MSColor *MSMediumOrchid;         // 0xba55d3ff
MSFoundationExtern MSColor *MSMediumPurple;         // 0x9370d8ff
MSFoundationExtern MSColor *MSMediumSeaGreen;       // 0x3cb371ff
MSFoundationExtern MSColor *MSMediumStateBlue;      // 0x7b68eeff
MSFoundationExtern MSColor *MSMediumSpringGreen;    // 0x00fa9aff
MSFoundationExtern MSColor *MSMediumTurquoise;      // 0x48d1ccff
MSFoundationExtern MSColor *MSMediumVioletRed;      // 0xc71585ff
MSFoundationExtern MSColor *MSMidnightBlue;         // 0x191970ff
MSFoundationExtern MSColor *MSMintCream;            // 0xf5fffaff
MSFoundationExtern MSColor *MSMistyRose;            // 0xffe4e1ff
MSFoundationExtern MSColor *MSMoccasin;             // 0xffe4b5ff
MSFoundationExtern MSColor *MSNavajoWhite;          // 0xffdeadff
MSFoundationExtern MSColor *MSNavy;                 // 0x000080ff
MSFoundationExtern MSColor *MSOldLace;              // 0xfdf5e6ff
MSFoundationExtern MSColor *MSOlive;                // 0x808000ff
MSFoundationExtern MSColor *MSOliveDrab;            // 0x6b8e23ff
MSFoundationExtern MSColor *MSOrange;               // 0xffa500ff
MSFoundationExtern MSColor *MSOrangeRed;            // 0xff4500ff
MSFoundationExtern MSColor *MSOrchid;               // 0xda70d6ff
MSFoundationExtern MSColor *MSPaleGoldenRod;        // 0xeee8aaff
MSFoundationExtern MSColor *MSPaleGreen;            // 0x98fb98ff
MSFoundationExtern MSColor *MSPaleTurquoise;        // 0xafeeeeff
MSFoundationExtern MSColor *MSPaleVioletRed;        // 0xd87093ff
MSFoundationExtern MSColor *MSPapayaWhip;           // 0xffefd5ff
MSFoundationExtern MSColor *MSPeachPuff;            // 0xffdab9ff
MSFoundationExtern MSColor *MSPeru;                 // 0xcd853fff
MSFoundationExtern MSColor *MSPink;                 // 0xffc0cbff
MSFoundationExtern MSColor *MSPlum;                 // 0xdda0ddff
MSFoundationExtern MSColor *MSPowderBlue;           // 0xb0e0e6ff
MSFoundationExtern MSColor *MSPurple;               // 0x800080ff
MSFoundationExtern MSColor *MSRed;                  // 0xff0000ff
MSFoundationExtern MSColor *MSRosyBrown;            // 0xbc8f8fff
MSFoundationExtern MSColor *MSRoyalBlue;            // 0x4169e1ff
MSFoundationExtern MSColor *MSSaddleBrown;          // 0x8b4513ff
MSFoundationExtern MSColor *MSSalmon;               // 0xfa8072ff
MSFoundationExtern MSColor *MSSandyBrown;           // 0xf4a460ff
MSFoundationExtern MSColor *MSSeaGreen;             // 0x2e8b57ff
MSFoundationExtern MSColor *MSSeaShell;             // 0xfff5eeff
MSFoundationExtern MSColor *MSSienna;               // 0xa0522dff
MSFoundationExtern MSColor *MSSilver;               // 0xc0c0c0ff
MSFoundationExtern MSColor *MSSkyBlue;              // 0x87ceebff
MSFoundationExtern MSColor *MSSlateBlue;            // 0x6a5acdff
MSFoundationExtern MSColor *MSSlateGray;            // 0x708090ff
MSFoundationExtern MSColor *MSSnow;                 // 0xfffafaff
MSFoundationExtern MSColor *MSSpringGreen;          // 0x00ff7fff
MSFoundationExtern MSColor *MSSteelBlue;            // 0x4682b4ff
MSFoundationExtern MSColor *MSTan;                  // 0xd2b48cff
MSFoundationExtern MSColor *MSTeal;                 // 0x008080ff
MSFoundationExtern MSColor *MSThistle;              // 0xd8bfd8ff
MSFoundationExtern MSColor *MSTomato;               // 0xff6347ff
MSFoundationExtern MSColor *MSTransparent;          // 0x00000000
MSFoundationExtern MSColor *MSTurquoise;            // 0x40e0d0ff
MSFoundationExtern MSColor *MSViolet;               // 0xee82eeff
MSFoundationExtern MSColor *MSWheat;                // 0xf5deb3ff
MSFoundationExtern MSColor *MSWhite;                // 0xffffffff
MSFoundationExtern MSColor *MSWhiteSmoke;           // 0xf5f5f5ff
MSFoundationExtern MSColor *MSYellow;               // 0xffff00ff
MSFoundationExtern MSColor *MSYellowGreen;          // 0x9acd32ff
