module.exports = {
  name : "OpenMicroStep", // Name of the workspace
  profile: "OpenMicroStep", // Profile used as base configuration for the workspace
  buildOptions: {
    "FORCOCOA" : { type : "boolean", value:false }
  },
  supportedToolchains : [
    "darwin-x86_64-clang",
    "debian7-x86_64-clang"
  ],
  supportedBuildOptions: [
    { options:{ "FORCOCOA" : false } },
    { options:{ "FORCOCOA" : true }, toolchains : ["darwin-x86_64-clang"] }
  ],
  files : {
    "MSCore" : {
      "Headers" : [
        "MSCore_src/MSCore.h",
        "MSCore_src/MSCore_Public.h",
        "MSCore_src/MSCore_Private.h",
      ],
      "Abstraction" :[
         "MSCore_src/MSCorePlatform.h",
         "MSCore_src/MSCorePlatform.c",
         "MSCore_src/MSCorePlatform-apple.i",
         "MSCore_src/MSCorePlatform-unix.i",
         "MSCore_src/MSCorePlatform-win32.i",
         "MSCore_src/MSCorePlatform-wo451.i",
         "MSCore_src/MSCoreTypes.h",
         "MSCore_src/MSCoreSystem.h",
         "MSCore_src/MSCoreSystem.c",
         "MSCore_src/MSCoreTools.h",
         "MSCore_src/MSCoreTools.c",
         "MSCore_src/MSCoreToolsCompress.c",
      ],
      "Sources" :[
        "MSCore_src/MSCArray.h",
        "MSCore_src/MSCArray.c",
        "MSCore_src/MSCBuffer.c",
        "MSCore_src/MSCArray.md",
        "MSCore_src/MSCColor.c",
        "MSCore_src/MSCBuffer.h",
        "MSCore_src/MSCCouple.c",
        "MSCore_src/MSCColor.h",
        "MSCore_src/MSCDate.c",
        "MSCore_src/MSCCouple.h",
        "MSCore_src/MSCDate.h",
        "MSCore_src/MSCDecimal.h",
        "MSCore_src/MSCDecimal.c",
        "MSCore_src/MSCDictionary.h",
        "MSCore_src/MSCDictionary.c",
        "MSCore_src/MSCGrow.h",
        "MSCore_src/MSCGrow.c",
        "MSCore_src/MSCMessage.h",
        "MSCore_src/MSCMessage.c",
        "MSCore_src/MSCObject.h",
        "MSCore_src/MSCObject.c",
        "MSCore_src/MSCString.h",
        "MSCore_src/MSCString.c",
        "MSCore_src/MSCoreSES.h",
        "MSCore_src/MSCoreSES.c",
        "MSCore_src/MSCoreUnichar.h",
        "MSCore_src/MSCoreUnichar.c",
        "MSCore_src/MSCoreUnichar_Private.h",
        "MSCore_src/MSTE.h",
        "MSCore_src/MSTE.c"
      ],
      "MAPM" : [
        "MSCore_src/MAPM_src/m_apm.h",
        "MSCore_src/MAPM_src/m_apm_lc.h",
        "MSCore_src/MAPM_src/mapm5sin.c",
        "MSCore_src/MAPM_src/mapm_add.c",
        "MSCore_src/MAPM_src/mapm_cpi.c",
        "MSCore_src/MAPM_src/mapm_div.c",
        "MSCore_src/MAPM_src/mapm_exp.c",
        "MSCore_src/MAPM_src/mapm_fft.c",
        "MSCore_src/MAPM_src/mapm_flr.c",
        "MSCore_src/MAPM_src/mapm_fpf.c",
        "MSCore_src/MAPM_src/mapm_gcd.c",
        "MSCore_src/MAPM_src/mapm_lg2.c",
        "MSCore_src/MAPM_src/mapm_lg3.c",
        "MSCore_src/MAPM_src/mapm_lg4.c",
        "MSCore_src/MAPM_src/mapm_log.c",
        "MSCore_src/MAPM_src/mapm_mul.c",
        "MSCore_src/MAPM_src/mapm_pow.c",
        "MSCore_src/MAPM_src/mapm_rcp.c",
        "MSCore_src/MAPM_src/mapm_set.c",
        "MSCore_src/MAPM_src/mapm_sin.c",
        "MSCore_src/MAPM_src/mapmasin.c",
        "MSCore_src/MAPM_src/mapmasn0.c",
        "MSCore_src/MAPM_src/mapmcbrt.c",
        "MSCore_src/MAPM_src/mapmcnst.c",
        "MSCore_src/MAPM_src/mapmfact.c",
        "MSCore_src/MAPM_src/mapmfmul.c",
        "MSCore_src/MAPM_src/mapmgues.c",
        "MSCore_src/MAPM_src/mapmhasn.c",
        "MSCore_src/MAPM_src/mapmhsin.c",
        "MSCore_src/MAPM_src/mapmipwr.c",
        "MSCore_src/MAPM_src/mapmistr.c",
        "MSCore_src/MAPM_src/mapmpwr2.c",
        "MSCore_src/MAPM_src/mapmrsin.c",
        "MSCore_src/MAPM_src/mapmsqrt.c",
        "MSCore_src/MAPM_src/mapmutil.c",
        "MSCore_src/MAPM_src/mapmutl1.c",
        "MSCore_src/MAPM_src/mapmutl2.c",
      ],
      "Tests": [
        "MSCore_tst/MAPM_tst/mapm_validate.c",
        "MSCore_tst/mscore_c_validate.c",
        "MSCore_tst/mscore_carray_validate.c",
        "MSCore_tst/mscore_cbuffer_validate.c",
        "MSCore_tst/mscore_ccolor_validate.c",
        "MSCore_tst/mscore_ccouple_validate.c",
        "MSCore_tst/mscore_cdate_validate.c",
        "MSCore_tst/mscore_cdictionary_validate.c",
        "MSCore_tst/mscore_cstring_validate.c",
        //"MSCore_tst/mscore_mste_validate.c",
        "MSCore_tst/mscore_ses_validate.c",
        "MSCore_tst/mscore_test.c",
        "MSCore_tst/mscore_tools_validate.c",
        "MSCore_tst/mscore_validate.c",
        "MSCore_tst/mscore_cdecimal_validate.c",
        "MSCore_tst/mscore_validate.h",
      ]
    },
    "Foundation" : {
      "Headers" : [
        "Foundation_src/Foundation-Info.plist",
        "Foundation_src/FoundationCompatibility.h",
        "Foundation_src/FoundationCompatibility_Private.h",
        "Foundation_src/FoundationCompatibility_Private.m",
        "Foundation_src/FoundationCompatibility_Public.h",
        "Foundation_src/FoundationTypes.h",
      ],
      "Sources" : [
        "Foundation_src/NSArray.h",
        "Foundation_src/NSArray.m",
        "Foundation_src/NSAutoreleasePool.h",
        "Foundation_src/NSAutoreleasePool.m",
        "Foundation_src/NSCoder.h",
        "Foundation_src/NSCoder.m",
        "Foundation_src/NSCoding.h",
        "Foundation_src/NSConstantString.m",
        "Foundation_src/NSCopying.h",
        "Foundation_src/NSData.h",
        "Foundation_src/NSData.m",
        "Foundation_src/NSDate.h",
        "Foundation_src/NSDate.m",
        "Foundation_src/NSDictionary.h",
        "Foundation_src/NSDictionary.m",
        "Foundation_src/NSEnumerator.h",
        "Foundation_src/NSEnumerator.m",
        "Foundation_src/NSException.h",
        "Foundation_src/NSException.m",
        "Foundation_src/NSInvocation.h",
        "Foundation_src/NSInvocation.m",
        "Foundation_src/NSLock.h",
        "Foundation_src/NSLock.m",
        "Foundation_src/NSNotification.h",
        "Foundation_src/NSNotification.m",
        "Foundation_src/NSNotificationCenter.h",
        "Foundation_src/NSNotificationCenter.m",
        "Foundation_src/NSNull.h",
        "Foundation_src/NSNull.m",
        "Foundation_src/NSNumber.h",
        "Foundation_src/NSNumber.m",
        "Foundation_src/NSObjCRuntime.h",
        "Foundation_src/NSObjCRuntime.m",
        "Foundation_src/NSObject.h",
        "Foundation_src/NSObject.m",
        "Foundation_src/NSRange.h",
        "Foundation_src/NSRange.m",
        "Foundation_src/NSString.h",
        "Foundation_src/NSString.m",
        "Foundation_src/NSTimeZone.h",
        "Foundation_src/NSTimeZone.m",
        "Foundation_src/NSValue.h",
        "Foundation_src/NSValue.m",
        "Foundation_src/NSZone.h",
        "Foundation_src/NSZone.m",
      ],
      "Tests": [
        "Foundation_tst/foundation_nsarray_validate.m",
        "Foundation_tst/foundation_nsdata_validate.m",
        "Foundation_tst/foundation_nsdictionary_validate.m",
        "Foundation_tst/foundation_nsnull_validate.m",
        "Foundation_tst/foundation_nsstring_validate.m",
        "Foundation_tst/foundation_validate.m",
        "Foundation_tst/foundation_validate.h",
        "Foundation_tst/foundation_nsautoreleasepool_validate.m",
        "Foundation_tst/foundation_nsobject_validate.m",
      ]
    },
    "MSFoundation" : {
      "Headers" : [
        "MSFoundation_src/MSFoundation.h",
        "MSFoundation_src/MSFoundation_Public.h",
        "MSFoundation_src/MSFoundation_Private.h",
        "MSFoundation_src/MSFoundation-Info.plist",
        "MSFoundation_src/MSFoundationForCocoa-Info.plist",
      ],
      "Sources" : [
        "MSFoundation_src/MSCObject.m",
        "MSFoundation_src/MSFinishLoading.h",
        "MSFoundation_src/MSFinishLoading.m",
        "MSFoundation_src/MSArray.h",
        "MSFoundation_src/MSArray.m",
        "MSFoundation_src/MSBuffer.h",
        "MSFoundation_src/MSBuffer.m",
        "MSFoundation_src/MSColor.h",
        "MSFoundation_src/MSColor.m",
        "MSFoundation_src/MSCouple.h",
        "MSFoundation_src/MSCouple.m",
        "MSFoundation_src/MSDate.h",
        "MSFoundation_src/MSDate.m",
        "MSFoundation_src/MSDecimal.h",
        "MSFoundation_src/MSDecimal.m",
        "MSFoundation_src/MSDictionary.h",
        "MSFoundation_src/MSDictionary.m",
        "MSFoundation_src/MSFoundationPlatform.h",
        "MSFoundation_src/MSFoundationPlatform.m",
        "MSFoundation_src/MSString.h",
        "MSFoundation_src/MSString.m",
        "MSFoundation_src/MSStringBooleanAdditions_Private.i",
      ],
      "Basics" : [
        "MSFoundation_Basics_src/MSASCIIString.h",
        "MSFoundation_Basics_src/MSASCIIString.m",
        "MSFoundation_Basics_src/MSBool.h",
        "MSFoundation_Basics_src/MSBool.m",
        "MSFoundation_Basics_src/MSCNaturalArray.h",
        "MSFoundation_Basics_src/MSCNaturalArray.m",
        "MSFoundation_Basics_src/MSCharsets_Private.h",
        "MSFoundation_Basics_src/MSCharsets_Private.m",
        "MSFoundation_Basics_src/MSCoderAdditions.h",
        "MSFoundation_Basics_src/MSCoderAdditions.m",
        "MSFoundation_Basics_src/MSExceptionAdditions.h",
        "MSFoundation_Basics_src/MSExceptionAdditions.m",
        "MSFoundation_Basics_src/MSFileManipulation.h",
        //"MSFoundation_Basics_src/MSFileManipulation.m",
        // "MSFoundation_Basics_src/MSFileManipulation_unix_Private.i",
        // "MSFoundation_Basics_src/MSFileManipulation_win32_Private.i",
        "MSFoundation_Basics_src/MSFoundationDefines.h",
        "MSFoundation_Basics_src/MSLanguage.h",
        "MSFoundation_Basics_src/MSLanguage.m",
        "MSFoundation_Basics_src/MSMutex.h",
        "MSFoundation_Basics_src/MSMutex.m",
        "MSFoundation_Basics_src/MSNaturalArray.h",
        "MSFoundation_Basics_src/MSNaturalArray.m",
        "MSFoundation_Basics_src/MSNaturalArrayEnumerator.h",
        "MSFoundation_Basics_src/MSNaturalArrayEnumerator.m",
        "MSFoundation_Basics_src/MSNaturalArrayEnumerator_Private.h",
        "MSFoundation_Basics_src/MSObjectAdditions.h",
        "MSFoundation_Basics_src/MSObjectAdditions.m",
        "MSFoundation_Basics_src/MSRow.h",
        "MSFoundation_Basics_src/MSRow.m",
        "MSFoundation_Basics_src/MSStringParsing.h",
        "MSFoundation_Basics_src/MSStringParsing.m",
        "MSFoundation_Basics_src/MSStringParsing_Private.h",
        "MSFoundation_Basics_src/MSTDecoder.h",
        "MSFoundation_Basics_src/MSTDecoder.m",
        "MSFoundation_Basics_src/MSTEncoder.h",
        "MSFoundation_Basics_src/MSTEncoder.m",
      ],
      "Tests": [
        "MSFoundation_tst/msfoundation_array_validate.m",
        "MSFoundation_tst/msfoundation_buffer_validate.m",
        "MSFoundation_tst/msfoundation_color_validate.m",
        "MSFoundation_tst/msfoundation_couple_validate.m",
        "MSFoundation_tst/msfoundation_decimal_validate.m",
        "MSFoundation_tst/msfoundation_dictionary_validate.m",
        "MSFoundation_tst/msfoundation_test.m",
        "MSFoundation_tst/msfoundationforcocoa_test.m",
        "MSFoundation_tst/msfoundation_string_validate.m",
        "MSFoundation_tst/msfoundation_validate.m",
        "MSFoundation_tst/msfoundation_mste_validate.m",
        "MSFoundation_tst/msfoundation_date_validate.m",
        "MSFoundation_tst/msfoundation_validate.h",
      ]
    },
    "MSTests" : [
      "MSTests_src/MSTests.h",
      "MSTests_src/MSTests.c",
    ]
  },
  targets : [
    {
      "name" : "MSCore",
      "type" : "Library",
      "configure": function(MSCore, /** @type TargetBuildOptions */ options, callback) {
        MSCore.addFiles(this.files.MSCore.Headers);
        MSCore.addFiles(this.files.MSCore.Abstraction);
        MSCore.addFiles(this.files.MSCore.Sources);
        MSCore.addFiles(this.files.MSCore.MAPM);
        MSCore.addPublicHeaders(_.filter(MSCore.files, function(v) { return /\/\w+\.h$/.test(v); }));
        MSCore.addIncludeDirectoriesOfFiles();
        MSCore.addDefines("MSCORE_STANDALONE");
        MSCore.addLinkMiddleware(function linkMiddleware(options, task, next) {
          if(options.toolchain.platform === "linux") {
            task.addFlags(['-lm', '-luuid', '-ldl']);
          }
          next();
        });
        callback();
      }
      // TODO: Some target that depends on MSCore headers can't receive such a define
      /*"exports" : function(MSCore, MSCore_options, target, target_options, callback) {
        target.addDefines("MSCORE_STANDALONE");
        callback();
      }*/
    },
    {
      "name" : "MSCoreTests",
      "type" : "Library",
      "dependencies" : ["MSCore", /* for the headers > */ "MSTests"],
      "configure": function(MSCoreTests, /** @type TargetBuildOptions */ options, callback) {
        MSCoreTests.addFiles(this.files.MSCore.Tests)
        MSCoreTests.addDefines("MSCORE_STANDALONE"); // TODO: MSCore should provide this automatically (options on the dependencies ?)
        MSCoreTests.addIncludeDirectoriesOfFiles();
        callback();
      }
    },
    {
      "name" : "MSFoundation",
      "type" : "Framework",
      "dependencies" : [{
        workspace: 'deps/msobjclib',
        target:'msobjclib',
        condition: function(options) { return !options.buildOptions.FORCOCOA; }
      }],
      "configure": function(MSFoundation, /** @type TargetBuildOptions */ options, callback) {
        MSFoundation.addFiles(this.files.MSCore.Abstraction);
        MSFoundation.addFiles(_.filter(this.files.MSCore.Sources, function(v) { return !v.endsWith("MSCObject.c")}));
        MSFoundation.addFiles(this.files.MSCore.MAPM);
        if(!options.buildOptions.FORCOCOA) {
          MSFoundation.addFiles(this.files.Foundation.Headers);
          MSFoundation.addFiles(this.files.Foundation.Sources);
        }
        else {
          MSFoundation.addFrameworks("Foundation");
          MSFoundation.addDefines("MSFOUNDATION_FORCOCOA");
        }
        MSFoundation.addFiles(this.files.MSFoundation.Headers);
        MSFoundation.addFiles(this.files.MSFoundation.Sources);
        MSFoundation.addFiles(this.files.MSFoundation.Basics);
        MSFoundation.addPublicHeaders(_.filter(MSFoundation.files, function(v) { return /\/\w+\.h$/.test(v); }));
        MSFoundation.addIncludeDirectoriesOfFiles();
        callback();
      },
      "exports" : function(MSFoundation, MSFoundation_options, target, target_options, callback) {
        if(MSFoundation_options.buildOptions.FORCOCOA) {
          target.addFrameworks("Foundation");
          target.addDefines("MSFOUNDATION_FORCOCOA");
        }
        callback();
      }
    },
    {
      "name" : "MSFoundationTests",
      "type" : "Library",
      "dependencies" : ["MSFoundation", /* for the headers > */ "MSCore", "MSTests"],
      "configure": function(MSFoundationTests, /** @type TargetBuildOptions */ options, callback) {
        MSFoundationTests.addFiles(_.filter(this.files.MSCore.Tests, function(v) {
          return !v.endsWith("/mscore_test.c");
        }));
        MSFoundationTests.addFiles(this.files.Foundation.Tests);
        var filter = options.buildOptions.FORCOCOA ? "/msfoundation_test.m" : "/msfoundationforcocoa_test.m";
        MSFoundationTests.addFiles(_.filter(this.files.MSFoundation.Tests, function(v) {
          return !v.endsWith(filter);
        }));
        MSFoundationTests.addIncludeDirectoriesOfFiles();
        callback();
      }
    },
    {
      "name" : "MSTests",
      "type" : "Executable",
      "dependencies" : ["MSCore"],
      "configure": function(/** @type Executable */ MSTests, /** @type TargetBuildOptions */ options, callback) {
        MSTests.addFiles(this.files.MSTests);
        MSTests.addDefines("MSCORE_STANDALONE"); // TODO: MSCore should provide this automatically (options on the dependencies ?)
        MSTests.addIncludeDirectoriesOfFiles();
        callback();
      },
      "exports" : function(mstests, mstests_options, target, target_options, callback) {
        target.addIncludeDirectory(require('path').join(mstests.workspace.directory, "MSTests_src"));
        callback();
      }
    }
  ]
};
