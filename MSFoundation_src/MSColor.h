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

MSFoundationExport MSColor *MSCreateColor(MSUInt rgbaValue);
MSFoundationExport MSColor *MSCreateCSSColor(MSUInt trgbValue);

MSFoundationExport MSColor *MSColorNamed(NSString *name);  // example :   MSColor *a = MSColorNamed(@"AliceBlue");

MSFoundationExport MSColor *MSAliceBlue;            // 0xf0f8ffff
MSFoundationExport MSColor *MSAntiqueWhite;         // 0xfaebd7ff
MSFoundationExport MSColor *MSAqua;                 // 0x00ffffff
MSFoundationExport MSColor *MSAquamarine;           // 0x7fffd4ff
MSFoundationExport MSColor *MSAzure;                // 0xf0ffffff
MSFoundationExport MSColor *MSBeige;                // 0xf5f5dcff
MSFoundationExport MSColor *MSBisque;               // 0xffe4c4ff
MSFoundationExport MSColor *MSBlack;                // 0x000000ff
MSFoundationExport MSColor *MSBlanchedAlmond;       // 0xffebcdff
MSFoundationExport MSColor *MSBlue;                 // 0x0000ffff
MSFoundationExport MSColor *MSBlueViolet;           // 0x8a2be2ff
MSFoundationExport MSColor *MSBrown;                // 0xa52a2aff
MSFoundationExport MSColor *MSBurlyWood;            // 0xdeb887ff
MSFoundationExport MSColor *MSCadetBlue;            // 0x5f9ea0ff
MSFoundationExport MSColor *MSChartreuse;           // 0x7fff00ff
MSFoundationExport MSColor *MSChocolate;            // 0xd2691eff
MSFoundationExport MSColor *MSCoral;                // 0xff7f50ff
MSFoundationExport MSColor *MSCornflowerBlue;       // 0x6495edff
MSFoundationExport MSColor *MSCornsilk;             // 0xfff8dcff
MSFoundationExport MSColor *MSCrimson;              // 0xdc143cff
MSFoundationExport MSColor *MSCyan;                 // 0x00ffffff
MSFoundationExport MSColor *MSDarkBlue;             // 0x00008bff
MSFoundationExport MSColor *MSDarkCyan;             // 0x008b8bff
MSFoundationExport MSColor *MSDarkGoldenRod;        // 0xb8860bff
MSFoundationExport MSColor *MSDarkGray;             // 0xa9a9a9ff
MSFoundationExport MSColor *MSDarkGreen;            // 0x006400ff
MSFoundationExport MSColor *MSDarkKhaki;            // 0xbdb76bff
MSFoundationExport MSColor *MSDarkMagenta;          // 0x8b008bff
MSFoundationExport MSColor *MSDarkOrange;           // 0xff8c00ff
MSFoundationExport MSColor *MSDarkOrchid;           // 0x9932ccff
MSFoundationExport MSColor *MSDarkRed;              // 0x8b0000ff
MSFoundationExport MSColor *MSDarkSalmon;           // 0xe9967aff
MSFoundationExport MSColor *MSDarkSeaGreen;         // 0x8fbc8fff
MSFoundationExport MSColor *MSDarkSlateBlue;        // 0x483d8bff
MSFoundationExport MSColor *MSDarkSlateGray;        // 0x2f4f4fff
MSFoundationExport MSColor *MSDarkTurquoise;        // 0x00ced1ff
MSFoundationExport MSColor *MSDarkViolet;           // 0x9400d3ff
MSFoundationExport MSColor *MSDeepPink;             // 0xff1493ff
MSFoundationExport MSColor *MSDeepSkyBlue;          // 0x00bfffff
MSFoundationExport MSColor *MSDimGray;              // 0x696969ff
MSFoundationExport MSColor *MSDodgerBlue;           // 0x1e90ffff
MSFoundationExport MSColor *MSFireBrick;            // 0xb22222ff
MSFoundationExport MSColor *MSFloralWhite;          // 0xfffaf0ff
MSFoundationExport MSColor *MSForestGreen;          // 0x228b22ff
MSFoundationExport MSColor *MSFuchsia;              // 0xff00ffff
MSFoundationExport MSColor *MSGainsboro;            // 0xdcdcdcff
MSFoundationExport MSColor *MSGhostWhite;           // 0xf8f8ffff
MSFoundationExport MSColor *MSGold;                 // 0xffd700ff
MSFoundationExport MSColor *MSGoldenRod;            // 0xdaa520ff
MSFoundationExport MSColor *MSGray;                 // 0x808080ff
MSFoundationExport MSColor *MSGreen;                // 0x008000ff
MSFoundationExport MSColor *MSGreenYellow;          // 0xadff2fff
MSFoundationExport MSColor *MSHoneyDew;             // 0xf0fff0ff
MSFoundationExport MSColor *MSHotPink;              // 0xff69b4ff
MSFoundationExport MSColor *MSIndianRed;            // 0xcd5c5cff
MSFoundationExport MSColor *MSIndigo;               // 0x4b0082ff
MSFoundationExport MSColor *MSIvory;                // 0xfffff0ff
MSFoundationExport MSColor *MSKhaki;                // 0xf0e68cff
MSFoundationExport MSColor *MSLavender;             // 0xe6e6faff
MSFoundationExport MSColor *MSLavenderBlush;        // 0xfff0f5ff
MSFoundationExport MSColor *MSLawnGreen;            // 0x7cfc00ff
MSFoundationExport MSColor *MSLemonChiffon;         // 0xfffacdff
MSFoundationExport MSColor *MSLightBlue;            // 0xadd8e6ff
MSFoundationExport MSColor *MSLightCoral;           // 0xf08080ff
MSFoundationExport MSColor *MSLightCyan;            // 0xe0ffffff
MSFoundationExport MSColor *MSLightGoldenRodYellow; // 0xfafad2ff
MSFoundationExport MSColor *MSLightGray;            // 0xd3d3d3ff
MSFoundationExport MSColor *MSLightGreen;           // 0x90ee90ff
MSFoundationExport MSColor *MSLightPink;            // 0xffb6c1ff
MSFoundationExport MSColor *MSLightSalmon;          // 0xffa07aff
MSFoundationExport MSColor *MSLightSeaGreen;        // 0x20b2aaff
MSFoundationExport MSColor *MSLightSkyBlue;         // 0x87cefaff
MSFoundationExport MSColor *MSLightSlateGray;       // 0x778899ff
MSFoundationExport MSColor *MSLightSteelBlue;       // 0xb0c4deff
MSFoundationExport MSColor *MSLightYellow;          // 0xffffe0ff
MSFoundationExport MSColor *MSLime;                 // 0x00ff00ff
MSFoundationExport MSColor *MSLimeGreen;            // 0x32cd32ff
MSFoundationExport MSColor *MSLinen;                // 0xfaf0e6ff
MSFoundationExport MSColor *MSMagenta;              // 0xff00ffff
MSFoundationExport MSColor *MSMaroon;               // 0x800000ff
MSFoundationExport MSColor *MSMediumAquaMarine;     // 0x66cdaaff
MSFoundationExport MSColor *MSMediumOrchid;         // 0xba55d3ff
MSFoundationExport MSColor *MSMediumPurple;         // 0x9370d8ff
MSFoundationExport MSColor *MSMediumSeaGreen;       // 0x3cb371ff
MSFoundationExport MSColor *MSMediumStateBlue;      // 0x7b68eeff
MSFoundationExport MSColor *MSMediumSpringGreen;    // 0x00fa9aff
MSFoundationExport MSColor *MSMediumTurquoise;      // 0x48d1ccff
MSFoundationExport MSColor *MSMediumVioletRed;      // 0xc71585ff
MSFoundationExport MSColor *MSMidnightBlue;         // 0x191970ff
MSFoundationExport MSColor *MSMintCream;            // 0xf5fffaff
MSFoundationExport MSColor *MSMistyRose;            // 0xffe4e1ff
MSFoundationExport MSColor *MSMoccasin;             // 0xffe4b5ff
MSFoundationExport MSColor *MSNavajoWhite;          // 0xffdeadff
MSFoundationExport MSColor *MSNavy;                 // 0x000080ff
MSFoundationExport MSColor *MSOldLace;              // 0xfdf5e6ff
MSFoundationExport MSColor *MSOlive;                // 0x808000ff
MSFoundationExport MSColor *MSOliveDrab;            // 0x6b8e23ff
MSFoundationExport MSColor *MSOrange;               // 0xffa500ff
MSFoundationExport MSColor *MSOrangeRed;            // 0xff4500ff
MSFoundationExport MSColor *MSOrchid;               // 0xda70d6ff
MSFoundationExport MSColor *MSPaleGoldenRod;        // 0xeee8aaff
MSFoundationExport MSColor *MSPaleGreen;            // 0x98fb98ff
MSFoundationExport MSColor *MSPaleTurquoise;        // 0xafeeeeff
MSFoundationExport MSColor *MSPaleVioletRed;        // 0xd87093ff
MSFoundationExport MSColor *MSPapayaWhip;           // 0xffefd5ff
MSFoundationExport MSColor *MSPeachPuff;            // 0xffdab9ff
MSFoundationExport MSColor *MSPeru;                 // 0xcd853fff
MSFoundationExport MSColor *MSPink;                 // 0xffc0cbff
MSFoundationExport MSColor *MSPlum;                 // 0xdda0ddff
MSFoundationExport MSColor *MSPowderBlue;           // 0xb0e0e6ff
MSFoundationExport MSColor *MSPurple;               // 0x800080ff
MSFoundationExport MSColor *MSRed;                  // 0xff0000ff
MSFoundationExport MSColor *MSRosyBrown;            // 0xbc8f8fff
MSFoundationExport MSColor *MSRoyalBlue;            // 0x4169e1ff
MSFoundationExport MSColor *MSSaddleBrown;          // 0x8b4513ff
MSFoundationExport MSColor *MSSalmon;               // 0xfa8072ff
MSFoundationExport MSColor *MSSandyBrown;           // 0xf4a460ff
MSFoundationExport MSColor *MSSeaGreen;             // 0x2e8b57ff
MSFoundationExport MSColor *MSSeaShell;             // 0xfff5eeff
MSFoundationExport MSColor *MSSienna;               // 0xa0522dff
MSFoundationExport MSColor *MSSilver;               // 0xc0c0c0ff
MSFoundationExport MSColor *MSSkyBlue;              // 0x87ceebff
MSFoundationExport MSColor *MSSlateBlue;            // 0x6a5acdff
MSFoundationExport MSColor *MSSlateGray;            // 0x708090ff
MSFoundationExport MSColor *MSSnow;                 // 0xfffafaff
MSFoundationExport MSColor *MSSpringGreen;          // 0x00ff7fff
MSFoundationExport MSColor *MSSteelBlue;            // 0x4682b4ff
MSFoundationExport MSColor *MSTan;                  // 0xd2b48cff
MSFoundationExport MSColor *MSTeal;                 // 0x008080ff
MSFoundationExport MSColor *MSThistle;              // 0xd8bfd8ff
MSFoundationExport MSColor *MSTomato;               // 0xff6347ff
MSFoundationExport MSColor *MSTransparent;          // 0x00000000
MSFoundationExport MSColor *MSTurquoise;            // 0x40e0d0ff
MSFoundationExport MSColor *MSViolet;               // 0xee82eeff
MSFoundationExport MSColor *MSWheat;                // 0xf5deb3ff
MSFoundationExport MSColor *MSWhite;                // 0xffffffff
MSFoundationExport MSColor *MSWhiteSmoke;           // 0xf5f5f5ff
MSFoundationExport MSColor *MSYellow;               // 0xffff00ff
MSFoundationExport MSColor *MSYellowGreen;          // 0x9acd32ff
