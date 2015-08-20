var path = require('path');
module.exports = {
  name : "OpenMicroStep", // Name of the workspace
  environments: {
    "openmicrostep-base" : {
      compiler: "clang",
      compilerOptions: { "std":"c11" },
      directories: {
        intermediates: ".intermediates",
        output: "out",
        publicHeaders: "include",
        target: {
          "Library": "lib",
          "Framework": "framework",
          "Executable": "bin",
          "Bundle": "bundle",
          "CXXExternal": "lib"
        }
      }
    },

    "openmicrostep-core-i386-darwin"            :{"arch": "i386"       , "sysroot-api": "darwin"   , "parent": "openmicrostep-base"},
    "openmicrostep-core-x86_64-darwin"          :{"arch": "x86_64"     , "sysroot-api": "darwin"   , "parent": "openmicrostep-base"},
    "openmicrostep-core-univ-darwin"            :{"arch": "i386,x86_64", "sysroot-api": "darwin"   , "parent": "openmicrostep-base"},
    "openmicrostep-core-i386-linux"             :{"arch": "i386"       , "sysroot-api": "linux"    , "parent": "openmicrostep-base"},
    "openmicrostep-core-x86_64-linux"           :{"arch": "x86_64"     , "sysroot-api": "linux"    , "parent": "openmicrostep-base"},
    "openmicrostep-core-i386-mingw-w64"         :{"arch": "i386"       , "sysroot-api": "mingw-w64", "parent": "openmicrostep-base"},
    "openmicrostep-core-x86_64-mingw-w64"       :{"arch": "x86_64"     , "sysroot-api": "mingw-w64", "parent": "openmicrostep-base"},
    "openmicrostep-core-i386-msvc12"            :{"arch": "i386"       , "sysroot-api": "msvc"     , "parent": "openmicrostep-base"},
    "openmicrostep-core-x86_64-msvc12"          :{"arch": "x86_64"     , "sysroot-api": "msvc"     , "parent": "openmicrostep-base"},
    "openmicrostep-core": [
      "openmicrostep-core-i386-darwin"   , "openmicrostep-core-x86_64-darwin", //"openmicrostep-core-univ-darwin",
      /*"openmicrostep-core-i386-linux"    ,*/ "openmicrostep-core-x86_64-linux",
      "openmicrostep-core-i386-mingw-w64", "openmicrostep-core-x86_64-mingw-w64", 
      "openmicrostep-core-i386-msvc12",  "openmicrostep-core-x86_64-msvc12"
    ],

    "openmicrostep-foundation-i386-darwin"      :{"arch": "i386"       , "sysroot-api": "darwin"   , "parent": "openmicrostep-base"},
    "openmicrostep-foundation-x86_64-darwin"    :{"arch": "x86_64"     , "sysroot-api": "darwin"   , "parent": "openmicrostep-base"},
    "openmicrostep-foundation-univ-darwin"      :{"arch": "i386,x86_64", "sysroot-api": "darwin"   , "parent": "openmicrostep-base"},
    "openmicrostep-foundation-i386-linux"       :{"arch": "i386"       , "sysroot-api": "linux"    , "parent": "openmicrostep-base"},
    "openmicrostep-foundation-x86_64-linux"     :{"arch": "x86_64"     , "sysroot-api": "linux"    , "parent": "openmicrostep-base"},
    "openmicrostep-foundation-i386-mingw-w64"   :{"arch": "i386"       , "sysroot-api": "mingw-w64", "parent": "openmicrostep-base"},
    "openmicrostep-foundation-x86_64-mingw-w64" :{"arch": "x86_64"     , "sysroot-api": "mingw-w64", "parent": "openmicrostep-base"},
    "openmicrostep-foundation-i386-msvc12"      :{"arch": "i386"       , "sysroot-api": "msvc"     , "parent": "openmicrostep-base"},
    "openmicrostep-foundation-x86_64-msvc12"    :{"arch": "x86_64"     , "sysroot-api": "msvc"     , "parent": "openmicrostep-base"},
    "openmicrostep-foundation": [
      "openmicrostep-foundation-i386-darwin"   , "openmicrostep-foundation-x86_64-darwin", //"openmicrostep-foundation-univ-darwin",
      /*"openmicrostep-foundation-i386-linux"    ,*/ "openmicrostep-foundation-x86_64-linux",
      "openmicrostep-foundation-i386-mingw-w64", "openmicrostep-foundation-x86_64-mingw-w64", 
      "openmicrostep-foundation-i386-msvc12",  "openmicrostep-foundation-x86_64-msvc12"
    ],

    "openmicrostep-cocoa-i386-darwin"      :{"arch": "i386"       , "sysroot-api": "darwin"   , "parent": "openmicrostep-base", cocoa: true},
    "openmicrostep-cocoa-x86_64-darwin"    :{"arch": "x86_64"     , "sysroot-api": "darwin"   , "parent": "openmicrostep-base", cocoa: true},
    "openmicrostep-cocoa-univ-darwin"      :{"arch": "i386,x86_64", "sysroot-api": "darwin"   , "parent": "openmicrostep-base", cocoa: true},
    "openmicrostep-cocoa": [
      "openmicrostep-cocoa-i386-darwin", "openmicrostep-cocoa-x86_64-darwin", //"openmicrostep-cocoa-univ-darwin",
    ],
    "openmicrostep-node": [
      /* TODO:"openmicrostep-foundation-i386-darwin",*/ "openmicrostep-foundation-x86_64-darwin",
      // TODO: "openmicrostep-foundation-i386-linux", "openmicrostep-foundation-x86_64-linux",
      // Instable: "openmicrostep-foundation-i386-mingw-w64", "openmicrostep-foundation-x86_64-mingw-w64", 
      "openmicrostep-foundation-i386-msvc12", "openmicrostep-foundation-x86_64-msvc12",
      /* TODO: "openmicrostep-cocoa-i386-darwin", */"openmicrostep-cocoa-x86_64-darwin",
    ],
  },
  files: [
    {group: "MSCore", files:[
      {group: "Headers", files:[
        {file: "MSCore_src/MSCore.h", tags: ["MSCorePublicHeader"]},
        {file: "MSCore_src/MSCore_Public.h"},
        {file: "MSCore_src/MSCore_Private.h"},
      ]},
      {group:"Abstraction", files: [
        {file: "MSCore_src/MSCoreTypes.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCoreSystem.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCoreSystem.c"},
        {file: "MSCore_src/MSCoreTools.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCoreTools.c"},
        {file: "MSCore_src/MSCoreToolsCompress.c"},
      ]},
      {group:"Sources", files: [
        {file: "MSCore_src/MSCArray.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCArray.c"},
        {file: "MSCore_src/MSCBuffer.c"},
        {file: "MSCore_src/MSCArray.md"},
        {file: "MSCore_src/MSCColor.c"},
        {file: "MSCore_src/MSCBuffer.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCCouple.c"},
        {file: "MSCore_src/MSCColor.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCDate.c"},
        {file: "MSCore_src/MSCCouple.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCDate.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCDecimal.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCDecimal.c"},
        {file: "MSCore_src/MSCDictionary.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCDictionary.c"},
        {file: "MSCore_src/MSCGrow.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCGrow.c"},
        {file: "MSCore_src/MSCMessage.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCMessage.c"},
        {file: "MSCore_src/MSCObject.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCString.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCString.c"},
        {file: "MSCore_src/MSCoreSES.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCoreSES.c"},
        {file: "MSCore_src/MSCoreUnichar.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MSCoreUnichar_Private.h"},
        {file: "MSCore_src/MSCoreUnichar.c"},
        {file: "MSCore_src/MSTE.h"},
        {file: "MSCore_src/MSTE.c"},
      ]},
      {group:"MAPM", files: [
        {file: "MSCore_src/MAPM_src/m_apm.h", tags: ["MSPublicHeaders"]},
        {file: "MSCore_src/MAPM_src/m_apm_lc.h"},
        {file: "MSCore_src/MAPM_src/mapm5sin.c"},
        {file: "MSCore_src/MAPM_src/mapm_add.c"},
        {file: "MSCore_src/MAPM_src/mapm_cpi.c"},
        {file: "MSCore_src/MAPM_src/mapm_div.c"},
        {file: "MSCore_src/MAPM_src/mapm_exp.c"},
        {file: "MSCore_src/MAPM_src/mapm_fft.c"},
        {file: "MSCore_src/MAPM_src/mapm_flr.c"},
        {file: "MSCore_src/MAPM_src/mapm_fpf.c"},
        {file: "MSCore_src/MAPM_src/mapm_gcd.c"},
        {file: "MSCore_src/MAPM_src/mapm_lg2.c"},
        {file: "MSCore_src/MAPM_src/mapm_lg3.c"},
        {file: "MSCore_src/MAPM_src/mapm_lg4.c"},
        {file: "MSCore_src/MAPM_src/mapm_log.c"},
        {file: "MSCore_src/MAPM_src/mapm_mul.c"},
        {file: "MSCore_src/MAPM_src/mapm_pow.c"},
        {file: "MSCore_src/MAPM_src/mapm_rcp.c"},
        {file: "MSCore_src/MAPM_src/mapm_set.c"},
        {file: "MSCore_src/MAPM_src/mapm_sin.c"},
        {file: "MSCore_src/MAPM_src/mapmasin.c"},
        {file: "MSCore_src/MAPM_src/mapmasn0.c"},
        {file: "MSCore_src/MAPM_src/mapmcbrt.c"},
        {file: "MSCore_src/MAPM_src/mapmcnst.c"},
        {file: "MSCore_src/MAPM_src/mapmfact.c"},
        {file: "MSCore_src/MAPM_src/mapmfmul.c"},
        {file: "MSCore_src/MAPM_src/mapmgues.c"},
        {file: "MSCore_src/MAPM_src/mapmhasn.c"},
        {file: "MSCore_src/MAPM_src/mapmhsin.c"},
        {file: "MSCore_src/MAPM_src/mapmipwr.c"},
        {file: "MSCore_src/MAPM_src/mapmistr.c"},
        {file: "MSCore_src/MAPM_src/mapmpwr2.c"},
        {file: "MSCore_src/MAPM_src/mapmrsin.c"},
        {file: "MSCore_src/MAPM_src/mapmsqrt.c"},
        {file: "MSCore_src/MAPM_src/mapmutil.c"},
        {file: "MSCore_src/MAPM_src/mapmutl1.c"},
        {file: "MSCore_src/MAPM_src/mapmutl2.c"},
      ]},
      {group:"Tests", files: [
        {file: "MSCore_tst/MAPM_tst/mapm_validate.c"},
        {file: "MSCore_tst/mscore_c_validate.c"},
        {file: "MSCore_tst/mscore_carray_validate.c"},
        {file: "MSCore_tst/mscore_cbuffer_validate.c"},
        {file: "MSCore_tst/mscore_ccolor_validate.c"},
        {file: "MSCore_tst/mscore_ccouple_validate.c"},
        {file: "MSCore_tst/mscore_cdate_validate.c"},
        {file: "MSCore_tst/mscore_cdictionary_validate.c"},
        {file: "MSCore_tst/mscore_cstring_validate.c"},
        {file: "MSCore_tst/mscore_mste_validate.c" },
        {file: "MSCore_tst/mscore_ses_validate.c"},
        {file: "MSCore_tst/mscore_tools_validate.c"},
        {file: "MSCore_tst/mscore_validate.c"},
        {file: "MSCore_tst/mscore_cdecimal_validate.c"},
        {file: "MSCore_tst/mscore_validate.h"},
      ]},
      {group:"Object", files: [
        {file: "MSCore_src/MSCObject.c"},
      ]},
    ]},
    {group:"Foundation", files: [
      {group:"Headers", files:[
        {file: "Foundation_src/Foundation-Info.plist"},
        {file: "Foundation_src/FoundationCompatibility.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/FoundationCompatibility_Private.h"},
        {file: "Foundation_src/FoundationCompatibility_Private.m"},
        {file: "Foundation_src/FoundationCompatibility_Public.h"},
        {file: "Foundation_src/FoundationTypes.h", tags: ["MSPublicHeaders"]},
      ]},
      {group:"Sources", files: [
        {file: "Foundation_src/NSArray.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSArray.m"},
        {file: "Foundation_src/NSAutoreleasePool.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSAutoreleasePool.m"},
        {file: "Foundation_src/NSBundle.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSBundle.m"},
        {file: "Foundation_src/NSCharacterSet.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSCharacterSet.m"},
        {file: "Foundation_src/NSCoding.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSCoder.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSCoder.m"},
        {file: "Foundation_src/NSArchiver.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSUnarchiver.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSArchiver.m"},
        {file: "Foundation_src/NSConstantString.m"},
        {file: "Foundation_src/NSCopying.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSData.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSData.m"},
        {file: "Foundation_src/NSDate.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSDate.m"},
        {file: "Foundation_src/NSDictionary.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSDictionary.m"},
        {file: "Foundation_src/NSEnumerator.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSEnumerator.m"},
        {file: "Foundation_src/NSException.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSException.m"},
        {file: "Foundation_src/NSFileHandle.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSFileHandle.m"},
        {file: "Foundation_src/NSFileManager.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSFileManager.m"},
        {file: "Foundation_src/NSInvocation.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSInvocation.m"},
        {file: "Foundation_src/NSLock.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSLock.m"},
        {file: "Foundation_src/NSNotification.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSNotification.m"},
        {file: "Foundation_src/NSNotificationCenter.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSNotificationCenter.m"},
        {file: "Foundation_src/NSNull.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSNull.m"},
        {file: "Foundation_src/NSNumber.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSNumber.m"},
        {file: "Foundation_src/NSObjCRuntime.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSObjCRuntime.m"},
        {file: "Foundation_src/NSObject.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSObject.m"},
        {file: "Foundation_src/NSProcessInfo.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSProcessInfo.m"},
        {file: "Foundation_src/NSRange.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSRange.m"},
        {file: "Foundation_src/NSRunLoop.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSRunLoop.m"},
        {file: "Foundation_src/NSScanner.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSScanner.m"},
        {file: "Foundation_src/NSString.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSString.m"},
        {file: "Foundation_src/NSTask.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSTask.m"},
        {file: "Foundation_src/NSTimer.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSTimer.m"},
        {file: "Foundation_src/NSTimeZone.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSTimeZone.m"},
        {file: "Foundation_src/NSThread.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSThread.m"},
        {file: "Foundation_src/NSValue.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSValue.m"},
        {file: "Foundation_src/NSZone.h", tags: ["MSPublicHeaders"]},
        {file: "Foundation_src/NSZone.m"},
      ]},
      {group:"Tests", files: [
        {file: "Foundation_tst/foundation_nsarray_validate.m"},
        {file: "Foundation_tst/foundation_nsdata_validate.m"},
        {file: "Foundation_tst/foundation_nsdate_validate.m"},
        {file: "Foundation_tst/foundation_nsdictionary_validate.m"},
        {file: "Foundation_tst/foundation_nsnull_validate.m"},
        {file: "Foundation_tst/foundation_nsstring_validate.m"},
        {file: "Foundation_tst/foundation_validate.m"},
        {file: "Foundation_tst/foundation_validate.h"},
        {file: "Foundation_tst/foundation_nsautoreleasepool_validate.m"},
        {file: "Foundation_tst/foundation_nsobject_validate.m"},
        {file: "Foundation_tst/foundation_nsnumber_validate.m"},
      ]}
    ]},
    {group:"MSFoundation", files: [
      {group:"Headers", files: [
        {file: "MSFoundation_src/MSFoundation.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_src/MSFoundation_Public.h"},
        {file: "MSFoundation_src/MSFoundation_Private.h"},
        {file: "MSFoundation_src/MSFoundation-Info.plist"},
        {file: "MSFoundation_src/MSFoundationForCocoa-Info.plist"},
      ]},
      {group:"Sources", files: [
        {file: "MSFoundation_src/MSCObject.m"},
        {file: "MSFoundation_src/MSFinishLoading.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_src/MSFinishLoading.m"},
        {file: "MSFoundation_src/MSArray.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_src/MSArray.m"},
        {file: "MSFoundation_src/MSBuffer.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_src/MSBuffer.m"},
        {file: "MSFoundation_src/MSColor.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_src/MSColor.m"},
        {file: "MSFoundation_src/MSCouple.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_src/MSCouple.m"},
        {file: "MSFoundation_src/MSDate.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_src/MSDate.m"},
        {file: "MSFoundation_src/MSDecimal.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_src/MSDecimal.m"},
        {file: "MSFoundation_src/MSDictionary.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_src/MSDictionary.m"},
        {file: "MSFoundation_src/MSFoundationPlatform.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_src/MSFoundationPlatform.m"},
        {file: "MSFoundation_src/MSMSTEDecoder.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_src/MSMSTEDecoder.m"},
        {file: "MSFoundation_src/MSString.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_src/MSString.m"},
        {file: "MSFoundation_src/MSStringBooleanAdditions_Private.i"},
      ]},
      {group:"Basics", files: [
        {file: "MSFoundation_Basics_src/MSASCIIString.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSASCIIString.m"},
        {file: "MSFoundation_Basics_src/MSBool.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSBool.m"},
        {file: "MSFoundation_Basics_src/MSCNaturalArray.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSCNaturalArray.m"},
        {file: "MSFoundation_Basics_src/MSCharsets_Private.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSCharsets_Private.m"},
        {file: "MSFoundation_Basics_src/MSCoderAdditions.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSCoderAdditions.m"},
        {file: "MSFoundation_Basics_src/MSExceptionAdditions.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSExceptionAdditions.m"},
        {file: "MSFoundation_Basics_src/MSFileManipulation.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSFileManipulation.m"},
        {file: "MSFoundation_Basics_src/MSFileManipulation_unix_Private.i"},
        {file: "MSFoundation_Basics_src/MSFileManipulation_win32_Private.i"},
        {file: "MSFoundation_Basics_src/MSFoundationDefines.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSLanguage.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSLanguage.m"},
        {file: "MSFoundation_Basics_src/MSMutex.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSMutex.m"},
        {file: "MSFoundation_Basics_src/MSNaturalArray.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSNaturalArray.m"},
        {file: "MSFoundation_Basics_src/MSNaturalArrayEnumerator.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSNaturalArrayEnumerator.m"},
        {file: "MSFoundation_Basics_src/MSNaturalArrayEnumerator_Private.h"},
        {file: "MSFoundation_Basics_src/MSObjectAdditions.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSObjectAdditions.m"},
        {file: "MSFoundation_Basics_src/MSRow.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSRow.m"},
        {file: "MSFoundation_Basics_src/MSStringParsing.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSStringParsing.m"},
        {file: "MSFoundation_Basics_src/MSStringParsing_Private.h"},
        {file: "MSFoundation_Basics_src/MSTDecoder.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSTDecoder.m"},
        {file: "MSFoundation_Basics_src/MSTEncoder.h", tags: ["MSPublicHeaders"]},
        {file: "MSFoundation_Basics_src/MSTEncoder.m"},
      ]},
      {group:"Tests", files: [
        {file: "MSFoundation_tst/msfoundation_array_validate.m"},
        {file: "MSFoundation_tst/msfoundation_buffer_validate.m"},
        {file: "MSFoundation_tst/msfoundation_color_validate.m"},
        {file: "MSFoundation_tst/msfoundation_couple_validate.m"},
        {file: "MSFoundation_tst/msfoundation_decimal_validate.m"},
        {file: "MSFoundation_tst/msfoundation_dictionary_validate.m"},
        {file: "MSFoundation_tst/msfoundation_string_validate.m"},
        {file: "MSFoundation_tst/msfoundation_validate.m"},
        {file: "MSFoundation_tst/msfoundation_mste_validate.m"},
        {file: "MSFoundation_tst/msfoundation_date_validate.m"},
        {file: "MSFoundation_tst/msfoundation_validate.h"},
      ]},
    ]},
    {group:"Test libs", files: [
      {file: "MSCore_tst/mscore_test.c", tags:["MSCoreTest"]},
      {file: "MSFoundation_tst/msfoundation_test.m", tags:["MSFoundationTest"]},
      {file: "MSFoundation_tst/msfoundationforcocoa_test.m", tags:["MSFoundationForCocoaTest"]},
    ]},
    {group:"MSTests", files: [
      {file: "MSTests_src/MSTests.c"},
      {file: "MSTests_src/MSTests.h", tags: ["MSPublicHeaders"]},
    ]},
    {group:"MSNet", files: [
      {group:"Crypto", files: [
        {file: "MSNet_src/Crypto_src/_MSCipherPrivate.h", tags: ["MSPublicHeaders"]},
        {file: "MSNet_src/Crypto_src/_MSDigest.h", tags: ["MSPublicHeaders"]},
        {file: "MSNet_src/Crypto_src/_MSDigest.m"},
        {file: "MSNet_src/Crypto_src/_RSACipher.h", tags: ["MSPublicHeaders"]},
        {file: "MSNet_src/Crypto_src/_RSACipher.m"},
        {file: "MSNet_src/Crypto_src/_SymmetricCipher.h", tags: ["MSPublicHeaders"]},
        {file: "MSNet_src/Crypto_src/_SymmetricCipher.m"},
        {file: "MSNet_src/Crypto_src/_SymmetricRSACipher.h", tags: ["MSPublicHeaders"]},
        {file: "MSNet_src/Crypto_src/_SymmetricRSACipher.m"},
        {file: "MSNet_src/Crypto_src/MSCertificate.h", tags: ["MSPublicHeaders"]},
        {file: "MSNet_src/Crypto_src/MSCertificate.m"},
        {file: "MSNet_src/Crypto_src/MSCipher.h", tags: ["MSPublicHeaders"]},
        {file: "MSNet_src/Crypto_src/MSCipher.m"},
        {file: "MSNet_src/Crypto_src/MSDigest.h", tags: ["MSPublicHeaders"]},
        {file: "MSNet_src/Crypto_src/MSDigest.m"},
        {file: "MSNet_src/Crypto_src/MSSecureHash.h", tags: ["MSPublicHeaders"]},
        {file: "MSNet_src/Crypto_src/MSSecureHash.m"},
      ]},
      {file:"MSNet_src/_CHTTPMessagePrivate.h"},
      {file:"MSNet_src/_CNotificationPrivate.h"},
      {file:"MSNet_src/_MHAdminApplication.h"},
      {file:"MSNet_src/_MHAdminApplication.m"},
      {file:"MSNet_src/_MHApplicationClientPrivate.h"},
      {file:"MSNet_src/_MHApplicationClientPrivate.m"},
      {file:"MSNet_src/_MHApplicationPrivate.h"},
      {file:"MSNet_src/_MHApplicationPrivate.m"},
      {file:"MSNet_src/_MHBunchAllocatorPrivate.h"},
      {file:"MSNet_src/_MHBunchAllocatorPrivate.m"},
      {file:"MSNet_src/_MHBunchRegisterPrivate.h"},
      {file:"MSNet_src/_MHBunchRegisterPrivate.m"},
      {file:"MSNet_src/_MHContext.h"},
      {file:"MSNet_src/_MHContext.m"},
      {file:"MSNet_src/_MHHTTPMessagePrivate.h"},
      {file:"MSNet_src/_MHHTTPMessagePrivate.m"},
      {file:"MSNet_src/_MHNotificationPrivate.h"},
      {file:"MSNet_src/_MHNotificationPrivate.m"},
      {file:"MSNet_src/_MHOpenSSLPrivate.h"},
      {file:"MSNet_src/_MHOpenSSLPrivate.m"},
      {file:"MSNet_src/_MHPostProcessingDelegate.h"},
      {file:"MSNet_src/_MHPostProcessingDelegate.m"},
      {file:"MSNet_src/_MHQueuePrivate.h"},
      {file:"MSNet_src/_MHQueuePrivate.m"},
      {file:"MSNet_src/_MHResourcePrivate.h"},
      {file:"MSNet_src/_MHResourcePrivate.m"},
      {file:"MSNet_src/_MHServerPrivate.h"},
      {file:"MSNet_src/_MHServerPrivate.m"},
      {file:"MSNet_src/_MHSession.h"},
      {file:"MSNet_src/_MHSession.m"},
      {file:"MSNet_src/_MHSSLSocketPrivate.h"},
      {file:"MSNet_src/_MHSSLSocketPrivate.m"},
      {file:"MSNet_src/_MHThreadPrivate.h"},
      {file:"MSNet_src/_MHThreadPrivate.m"},
      {file:"MSNet_src/MHApplication.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MHApplication.m"},
      {file:"MSNet_src/MHApplicationClient.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MHApplicationClient.m"},
      {file:"MSNet_src/MHBunchableObject.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MHBunchableObject.m"},
      {file:"MSNet_src/MHHTTPMessage.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MHHTTPMessage.m"},
      {file:"MSNet_src/MHLogging.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MHLogging.m"},
      {file:"MSNet_src/MHNotification.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MHNotification.m"},
      {file:"MSNet_src/MHPublicProtocols.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MHResource.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MHResource.m"},
      {file:"MSNet_src/MHServer.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MHServer.m"},
      {file:"MSNet_src/MHSSLSocket.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MHSSLSocket.m"},
      {file:"MSNet_src/MSCSSLInterface.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MSCSSLInterface.m"},
      //{file:"MSNet_src/MSCurlHandler.h", tags: ["MSPublicHeaders"]},
      //{file:"MSNet_src/MSCurlHandler.m"},
      //{file:"MSNet_src/MSCurlInterface_Private.h", tags: ["MSPublicHeaders"]},
      //{file:"MSNet_src/MSCurlInterface_Private.m"},
      //{file:"MSNet_src/MSCurlSendMail.h", tags: ["MSPublicHeaders"]},
      //{file:"MSNet_src/MSCurlSendMail.m"},
      {file:"MSNet_src/MSHTTPRequest.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MSHTTPRequest.m"},
      {file:"MSNet_src/MSHTTPResponse.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MSHTTPResponse.m"},
      {file:"MSNet_src/MSJSONEncoder.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MSJSONEncoder.m"},
      {file:"MSNet_src/MSNet.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MSNet_Private.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MSNet_Public.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MSNetPlatform.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MSThreadSafeProxy.h", tags: ["MSPublicHeaders"]},
      {file:"MSNet_src/MSThreadSafeProxy.m"},
    ]},
    {group:"MSServer", files: [
      {file:"MHServer_src/MASHServer.config"},
      {file:"MHServer_src/MASHServer_main.m"},
    ]},
    {group:"MSDatabase", files: [
      {group:"MySQLAdaptor", files: []},
      {group:"SQLCipherAdaptor", files: [
        {file:"MSDBAdaptors_src/MSSQLCipherAdaptor/MSSQLCipherAdaptor-Info.plist"},
        {file:"MSDBAdaptors_src/MSSQLCipherAdaptor/MSSQLCipherAdaptorKit.h"},
        {file:"MSDBAdaptors_src/MSSQLCipherAdaptor/MSSQLCipherConnection.h"},
        {file:"MSDBAdaptors_src/MSSQLCipherAdaptor/MSSQLCipherConnection.m"},
        {file:"MSDBAdaptors_src/MSSQLCipherAdaptor/MSSQLCipherResultSet.h"},
        {file:"MSDBAdaptors_src/MSSQLCipherAdaptor/MSSQLCipherResultSet.m"},
        {file:"MSDBAdaptors_src/MSSQLCipherAdaptor/MSSQLCipherStatement.h"},
        {file:"MSDBAdaptors_src/MSSQLCipherAdaptor/MSSQLCipherStatement.m"},
        {file:"MSDBAdaptors_src/MSSQLCipherAdaptor/sqlite3.h"},
        {file:"MSDBAdaptors_src/MSSQLCipherAdaptor/sqlite3.c"},
      ]},
      {group:"ODBCAdaptor", files: [
        {file:"MSDBAdaptors_src/MSODBCAdaptor/MSODBCAdaptor-Info.plist"},
        {file:"MSDBAdaptors_src/MSODBCAdaptor/MSODBCAdaptorKit.h"},
        {file:"MSDBAdaptors_src/MSODBCAdaptor/_MSODBCConnectionPrivate.h"},
        {file:"MSDBAdaptors_src/MSODBCAdaptor/MSODBCConnection.h"},
        {file:"MSDBAdaptors_src/MSODBCAdaptor/MSODBCConnection.m"},
        {file:"MSDBAdaptors_src/MSODBCAdaptor/_MSODBCResultSetPrivate.h"},
        {file:"MSDBAdaptors_src/MSODBCAdaptor/MSODBCResultSet.h"},
        {file:"MSDBAdaptors_src/MSODBCAdaptor/MSODBCResultSet.m"},
        {file:"MSDBAdaptors_src/MSODBCAdaptor/MSODBCStatement.h"},
        {file:"MSDBAdaptors_src/MSODBCAdaptor/MSODBCStatement.m"},
      ]},
      {group:"OracleAdaptor", files: []},
      {group:"Headers", files: [
        {file:"MSDb_src/MSDatabase.h", tags: ["MSPublicHeaders"]},
        {file:"MSDb_src/MSDatabase_Public.h", tags: ["MSPublicHeaders"]},
        {file:"MSDb_src/MSDatabase_Private.h", tags: ["MSPublicHeaders"]},
        {file:"MSDb_src/MSDatabaseDefines.h", tags: ["MSPublicHeaders"]},
      ]},
      {group:"Sources", files: [
        {file:"MSDb_src/MSDBConnection.h", tags: ["MSPublicHeaders"]},
        {file:"MSDb_src/MSDBConnectionPool.h", tags: ["MSPublicHeaders"]},
        {file:"MSDb_src/MSDBGenericConnection.h", tags: ["MSPublicHeaders"]},
        {file:"MSDb_src/MSDBOperation.h", tags: ["MSPublicHeaders"]},
        {file:"MSDb_src/MSDBResultSet.h", tags: ["MSPublicHeaders"]},
        {file:"MSDb_src/MSDBStatement.h", tags: ["MSPublicHeaders"]},
        {file:"MSDb_src/MSDBTransaction.h", tags: ["MSPublicHeaders"]},
        {file:"MSDb_src/MSObi.h", tags: ["MSPublicHeaders"]},
        {file:"MSDb_src/MSOdb.h", tags: ["MSPublicHeaders"]},
        {file:"MSDb_src/MSOid.h", tags: ["MSPublicHeaders"]},
        {file:"MSDb_src/MSDBConnection.m"},
        {file:"MSDb_src/MSDBConnectionPool.m"},
        {file:"MSDb_src/MSDBGenericConnection.m"},
        {file:"MSDb_src/MSDBOperation.m"},
        {file:"MSDb_src/MSDBResultSet.m"},
        {file:"MSDb_src/MSDBStatement.m"},
        {file:"MSDb_src/MSDBTransaction.m"},
        {file:"MSDb_src/MSObi.m"},
        {file:"MSDb_src/MSOdb.m"},
        {file:"MSDb_src/MSOid.m"}
      ]}
    ]},
    {group:"MSNode", files:[
      {file:"MSNode_src/_MSCipherPrivate.h"},
      {file:"MSNode_src/_MSDigest.h"},
      {file:"MSNode_src/_MSDigest.m"},
      {file:"MSNode_src/_RSACipher.h"},
      {file:"MSNode_src/_RSACipher.m"},
      {file:"MSNode_src/_SymmetricCipher.h"},
      {file:"MSNode_src/_SymmetricCipher.m"},
      {file:"MSNode_src/_SymmetricRSACipher.h"},
      {file:"MSNode_src/_SymmetricRSACipher.m"},
      {file:"MSNode_src/MSAsync.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSAsync.m"},
      {file:"MSNode_src/MSCipher.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSCipher.m"},
      {file:"MSNode_src/MSDigest.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSDigest.m"},
      {file:"MSNode_src/MSHttpApplication.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSHttpApplication.m"},
      {file:"MSNode_src/MSHttpClientRequest.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSHttpClientRequest.mm"},
      {file:"MSNode_src/MSHttpCookieMiddleware.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSHttpCookieMiddleware.m"},
      {file:"MSNode_src/MSHttpMSTEMiddleware.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSHttpMSTEMiddleware.m"},
      {file:"MSNode_src/MSHttpRouter.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSHttpRouter.mm"},
      {file:"MSNode_src/MSHttpServer.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSHttpServer.mm"},
      {file:"MSNode_src/MSHttpSessionMiddleware.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSHttpSessionMiddleware.m"},
      {file:"MSNode_src/MSHttpStaticFilesMiddleware.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSHttpStaticFilesMiddleware.m"},
      {file:"MSNode_src/MSHttpTransaction.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSHttpTransaction.mm"},
      {file:"MSNode_src/MSNode_Private.h"},
      {file:"MSNode_src/MSNode_Public.h"},
      {file:"MSNode_src/MSNode.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSNode.m"},
      {file:"MSNode_src/MSNodeWorker.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSNodeWorker.mm"},
      {file:"MSNode_src/MSNodeWrapper.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSNodeWrapper.mm"},
      {file:"MSNode_src/MSSecureHash.h", tags: ["MSPublicHeaders"]},
      {file:"MSNode_src/MSSecureHash.m"},
    ]},
    {group:"MHMessenger", files: [
      {group:"Framework", files: [
        {file:"MHMessenger_src/MHMessenger-Info.plist"},
        {file:"MHMessenger_src/MHMessenger.h", tags: ["MSPublicHeaders"]},
        {file:"MHMessenger_src/MHMessenger_Public.h"},
        {file:"MHMessenger_src/MHMessenger_Private.h"},
        //{file:"MHMessenger_src/_MHMessengerMessagePrivate.h"},
        //{file:"MHMessenger_src/_MHMessengerMessagePrivate.m"},
        {file:"MHMessenger_src/MHMessengerClient.h", tags: ["MSPublicHeaders"]},
        {file:"MHMessenger_src/MHMessengerClient.m"},
        {file:"MHMessenger_src/MHMessengerDBAccessor.h", tags: ["MSPublicHeaders"]},
        {file:"MHMessenger_src/MHMessengerDBAccessor.m"},
        {file:"MHMessenger_src/MHMessengerMessage.h", tags: ["MSPublicHeaders"]},
        {file:"MHMessenger_src/MHMessengerMessage.m"},
        {file:"MHMessenger_src/MHMessengerMessageMiddleware.h", tags: ["MSPublicHeaders"]},
        {file:"MHMessenger_src/MHMessengerMessageMiddleware.m"},
        //{file:"MHMessenger_src/DBMessengerMessage.h", tags: ["MSPublicHeaders"]},
        //{file:"MHMessenger_src/DBMessengerMessage.m"},
      ]},
      {group:"WebApp", files: [
        {file:"MHMessenger_src/MHMessengerApp-Info.plist"},
        {file:"MHMessenger_src/MHMessengerApp.h"},
        {file:"MHMessenger_src/MHMessengerApp.m"},
      ]},
      {group:"Resources", files: [
        {file:"MHMessenger_src/Resources/1.sql"},
        {file:"MHMessenger_src/Resources/bundle.config"},
        {file:"MHMessenger_src/Resources/version.config"},
      ]}
    ]},
    {group:"MHRepository", files: [
      {group:"Framework", files: [
        {file:"MHRepository_src/MHRepository-Info.plist"},
        {file:"MHRepository_src/MHRepositoryApi.h", tags: ["MSPublicHeaders"]},
        {file:"MHRepository_src/MHRepository.h", tags: ["MSPublicHeaders"]},
        {file:"MHRepository_src/MHRepositoryDefines.h", tags: ["MSPublicHeaders"]},
        {file:"MHRepository_src/MHRepository_Public.h"},
        {file:"MHRepository_src/MHRepository_Private.h"},
        {file:"MHRepository_src/MHRepository.m"},
        {file:"MHRepository_src/MHRepository.i"},
        {file:"MHRepository_src/MHRepositoryLibs.h", tags: ["MSPublicHeaders"]},
        {file:"MHRepository_src/MHRepositoryLibs.m"},
        {file:"MHRepository_src/MHNetRepositoryClient.h", tags: ["MSPublicHeaders"]},
        {file:"MHRepository_src/MHNetRepositoryClient.m"},
        {file:"MHRepository_src/MHNetRepositorySession.h", tags: ["MSPublicHeaders"]},
        {file:"MHRepository_src/MHNetRepositorySession.m"},
      ]},
      {group:"Server", files: [
        {group:"Config example", files: [
          {file:"MHRepositoryServer_src/MHNetRepositoryServer.config"}
        ]},
        {file:"MHRepositoryServer_src/MHRepositoryServer-Info.plist"},
        {file:"MHRepositoryServer_src/MHNetRepository.h"},
        {file:"MHRepositoryServer_src/MHNetRepositoryApplication.h"},
        {file:"MHRepositoryServer_src/MHNetRepositoryApplication.m"},
        {file:"MHRepositoryServer_src/MHNetRepositoryServer_main.m"},
        {file:"MHRepositoryServer_src/MHRepositoryServer_Private.h"},
      ]},
      {group:"WebApp", files: [
        {file:"MHRepositoryAdministrator_src/MHRepositoryAdministrator-Info.plist"},
        {file:"MHRepositoryAdministrator_src/MHRepositoryAdministrator.h"},
        {file:"MHRepositoryAdministrator_src/MHRepositoryAdministrator.m"},
        {file:"MHRepositoryAdministrator_src/MHRepositoryAdministratorKit.h"},
        {file:"MHRepositoryAdministrator_src/NetRepositoryTreeObject.h"},
        {file:"MHRepositoryAdministrator_src/NetRepositoryTreeObject.m"},
      ]}
    ]},
  ],
  targets : [
    {
      "name" : "MSCore",
      "type" : "Library",
      "environments" : ["openmicrostep-core"],
      "files": ["MSCore.Headers", "MSCore.Abstraction", "MSCore.Sources", "MSCore.Object", "MSCore.MAPM"],
      "publicHeaders": ["?MSCorePublicHeader", "MSCore?MSPublicHeaders"],
      "defines": ["MSCORE_STANDALONE", "MSSTD_EXPORT"],
      "dependencies" : [
        {workspace: 'deps/msstdlib', target:'MSStd'} // The MSSTd lib is embedded inside MSCore
      ],
      "configure": function(target) {
        //target.addCompileFlags(['-Wall', '-Werror']);
        target.addIncludeDirectory('deps/msstdlib');
        target.addPublicHeaders(target.getDependency('MSStd').publicHeaders);
      },
      exports: {
        "defines":["MSCORE_STANDALONE"]
      }
    },
    {
      "name" : "MSCoreTests",
      "type" : "Library",
      "environments" : ["openmicrostep-core"],
      "dependencies" : ["MSCore", "MSTests"],
      "files": ["MSCore.Tests", "MSCore.Test", "Test libs?MSCoreTest"],
      "includeDirectoriesOfFiles": ["MSCore", "MSTests"],
      "includeDirectories": ["deps/msstdlib"],
    },
    {
      "name" : "MSTests",
      "type" : "Executable",
      "environments" : ["openmicrostep-core"],
      "dependencies" : ["MSCore"],
      "files": ["MSTests"],
      "publicHeaders": ["MSTests?MSPublicHeaders"],
      "configure": function(target) {
        if(target.platform === "linux") {
          target.addLibraries(['-ldl', '-lpthread', '-lrt']);
        }
      }
    },
    {
      "name" : "MSFoundation",
      "type" : "Framework",
      "environments" : ["openmicrostep-foundation", "openmicrostep-cocoa"],
      "dependencies" : [
        {workspace: 'deps/msstdlib', target:'MSStd'},
        {workspace: 'deps/msobjclib', target:'MSObjc', condition:function(target) { return !target.env.cocoa; }},
        {workspace: 'deps/libuv', target:'libuv', condition:function(target) { return !target.env.cocoa; }}
      ],
      "files" : [
        "MSCore.Abstraction", "MSCore.Sources", "MSCore.MAPM",
        "MSFoundation.Headers", "MSFoundation.Sources", "MSFoundation.Basics",

      ],
      "publicHeaders": ["?MSFoundationPublicHeader", "MSCore?MSPublicHeaders", "MSFoundation?MSPublicHeaders"],
      "includeDirectories": ["deps/libuv/include", "deps/msstdlib"],
      "configure": function(target) {
        if(target.env.cocoa) {
          target.addFrameworks(["Foundation"]);
          target.addDefines(["MSFOUNDATION_FORCOCOA=1"]);
        }
        else {
          target.addWorkspaceFiles(["Foundation.Headers", "Foundation.Sources"]);
          target.addWorkspacePublicHeaders(["Foundation?MSPublicHeaders"]);
          target.addDefines(["MSSTD_EXPORT=1"]);
        }
        target.addPublicHeaders(target.getDependency('MSStd').publicHeaders);
      },
      "exports": {
        configure: function(other_target, target) {
          if(target.env.cocoa) {
            other_target.addFrameworks(["Foundation"]);
            other_target.addDefines(["MSFOUNDATION_FORCOCOA=1"]);
          }
        }
      }
    },
    {
      "name": "MSFoundationTests",
      "type": "Library",
      "environments": ["openmicrostep-foundation", "openmicrostep-cocoa"],
      "dependencies": ["MSFoundation"],
      "files": ["MSCore.Tests", "Foundation.Tests", "MSFoundation.Tests"],
      "includeDirectoriesOfFiles": ["MSCore", "MSTests", "MSFoundation", "Foundation"],
      "includeDirectories": ["deps/msstdlib"],
      "configure": function(target) {
        if(target.env.cocoa)
          target.addWorkspaceFiles(["Test libs?MSFoundationTest"]);
        else
          target.addWorkspaceFiles(["Test libs?MSFoundationForCocoaTest"]);
      }
    },
    {
      "name" : "MSNet",
      "type" : "Framework",
      "environments" : ["openmicrostep-foundation", "openmicrostep-cocoa"],
      "dependencies" : [
        "MSFoundation",
        {workspace: 'deps/openssl', target:'openssl'}
      ],
      "files" : ["MSNet"],
      "publicHeaders": ["MSNet?MSPublicHeaders"],
      "configure": function(target) {
        target.addBundleResources([{from: "MSNet_src/Resources", to:""}]);
        if (target.platform === "win32") {
          target.addLibraries(['-lWs2_32']);
        }
      }
    },
    {
      "name" : "MASHServer",
      "type" : "Executable",
      "environments" : ["openmicrostep-node"],
      "dependencies" : ["MSFoundation", "MSNode"],
      "files" : ["MSServer"],
      "configure": function(target) {
        target.addCompileFlags(['-Wall', '-Werror']);
      }
    },
    {
      "name": "MSDatabase",
      "type": "Framework",
      "environments": ["openmicrostep-foundation", "openmicrostep-cocoa"],
      "dependencies": ["MSFoundation"],
      "files": ["MSDatabase.Sources"],
      "publicHeaders": ["MSDatabase?MSPublicHeaders"]
    },
    {
      "name": "MSSQLCipherAdaptor",
      "type": "Bundle",
      "environments": ["openmicrostep-foundation", "openmicrostep-cocoa"],
      "dependencies": [
        "MSFoundation",
        "MSDatabase",
        {workspace: 'deps/openssl', target:'openssl'}
      ],
      "bundleInfo": {
        "CFBundleIdentifier": "org.microstep.dbadaptor.sqlcipher",
        "NSPrincipalClass": "MSSQLCipherConnection"
      },
      "bundleExtension": "dbadaptor",
      "defines":["SQLITE_HAS_CODEC", "SQLITE_TEMP_STORE=2"], // TODO: Find a nice way to apply those defines to a subset of files
      "files": ["MSDatabase.SQLCipherAdaptor"],
      "configure": function(target) {
        target.output = target.getDependency("MSDatabase").buildResourcesPath();
      }
    },
    {
      "name": "ODBCAdaptor",
      "type": "Bundle",
      "environments": ["openmicrostep-foundation-i386-mingw-w64", "openmicrostep-foundation-x86_64-mingw-w64"],
      "dependencies": [
        "MSFoundation",
        "MSDatabase"
      ],
      "bundleInfo": {
        "CFBundleIdentifier": "org.microstep.dbadaptor.odbc",
        "NSPrincipalClass": "MSODBCConnection"
      },
      "bundleExtension": "dbadaptor",
      "defines":["SQLITE_HAS_CODEC", "SQLITE_TEMP_STORE=2"], // TODO: Find a nice way to apply those defines to a subset of files
      "files": ["MSDatabase.ODBCAdaptor"],
      "configure": function(target) {
        target.output = target.getDependency("MSDatabase").buildResourcesPath();
        target.addLibraries(['-lodbc32']);
      }
    },
    {
      "name": "MSNode",
      "type": "Framework",
      "environments": ["openmicrostep-node"],
      "dependencies": [
        "MSFoundation",
        {workspace: 'deps/openssl', target:'openssl'},
        {workspace: 'deps/libuv', target:'libuv', condition:function(target) { return target.env.cocoa; }}
      ],
      "files": ["MSNode"],
      "publicHeaders": ["MSNode?MSPublicHeaders"],
      "includeDirectories": ["deps/node/src", "deps/node/deps/cares/include", "deps/node/deps/debugger-agent/include", "deps/node/deps/v8/include", "deps/libuv/include", "deps/node/deps/openssl/openssl/include"],
      "configure": function(target) {
        target.addCompileFlags(['-Wall', '-Werror']);
        if (target.sysroot.api === "msvc") {
            var dir = 'deps/node-build/' + target.arch + '-msvc12/' + (target.variant === 'debug' ? 'debug' : 'release') + '/';
            target.addLibraries([target.resolvePath(dir + 'node.lib')]);
        }
        else if (target.sysroot.api === "darwin") {
            target.addLibraries([target.resolvePath('deps/node-build/' + target.arch + '-darwin/' + (target.variant === 'debug' ? 'debug' : 'release') + '/libnode.dylib')]);
        }
        else {
            throw "Unsupported env " + target.env;
        }
        if (target.sysroot.api === "msvc")
            target.addCompileFlags(['-fno-exceptions']);
        else
            target.addLibraries(['-lstdc++', '-lc++']);
      }
    },
    {
      "name": "MHMessenger",
      "type": "Framework",
      "environments": ["openmicrostep-node"],
      "dependencies": ["MSFoundation", "MSDatabase", "MSNode", "MHRepository"],
      "files": ["MHMessenger.Framework"],
      "publicHeaders": ["MHMessenger.Framework?MSPublicHeaders"],
      "bundleResources": ["MHMessenger.Resources"],
      "configure": function(target) {
        target.addCompileFlags(['-Wall', '-Werror']);
        target.addBundleResources([{from: "MHMessenger_src/Resources", to:""}]);
      }
    },
    {
      "name": "MASHMessenger",
      "type": "Bundle",
      "bundleInfo": {
        "CFBundleIdentifier": "org.microstep.net.messenger",
        "NSPrincipalClass": "MHMessengerApplication"
      },
      "environments": ["openmicrostep-node"],
      "dependencies": ["MSFoundation", "MHMessenger", "MHRepository", "MSNode"],
      "files": ["MHMessenger.WebApp"],
      "configure": function(target) {
        target.addCompileFlags(['-Wall', '-Werror']);
        target.addBundleResources([{from: "MHMessenger_src/Resources", to:""}]);
      }
    },
    {
      "name": "MHRepository",
      "type": "Framework",
      "environments": ["openmicrostep-node"],
      "dependencies": ["MSFoundation", "MSDatabase", "MSNode"],
      "files": ["MHRepository.Framework"],
      "publicHeaders": ["MHRepository.Framework?MSPublicHeaders"],
      "configure": function(target) {
        target.addCompileFlags(['-Wall', '-Werror']);
        target.addBundleResources([{from:"MHRepositoryAdministrator_src/Resources/login.html", to:"login.html"}]);
      }
    },
    {
      "name": "MASHRepositoryServer",
      "type": "Executable",
      "environments": ["openmicrostep-node"],
      "dependencies": ["MSFoundation", "MSDatabase", "MSNode", "MHRepository"],
      "files": ["MHRepository.Server"],
      "configure": function(target) {
        target.addCompileFlags(['-Wall', '-Werror']);
      }
    },
    {
      "name": "MASHRepositoryAdministrator",
      "type": "Bundle",
      "bundleInfo": {
        "CFBundleIdentifier": "org.microstep.net.repository",
        "NSPrincipalClass": "MHRepositoryAdministrator"
      },
      "environments": ["openmicrostep-node"],
      "dependencies": ["MSFoundation", "MSDatabase", "MSNode", "MHRepository"],
      "files": ["MHRepository.WebApp"],
      "configure": function(target) {
        target.addCompileFlags(['-Wall', '-Werror']);
        target.addBundleResources([{from:"MHRepositoryAdministrator_src/Resources", to:""}]);
        target.addBundleResources([{from:"MHRepositoryAdministrator_src/Resources/login.html", to:"login.html"}]);
      }
    },
  ]
};
