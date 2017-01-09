module.exports = {
  name : "MSStdLib",
  environments: {
    "msstdlib-i386-darwin"      :{ "arch": "i386"       , "sysroot-api": "darwin"   , "compiler": "clang" },
    "msstdlib-x86_64-darwin"    :{ "arch": "x86_64"     , "sysroot-api": "darwin"   , "compiler": "clang" },
    "msstdlib-univ-darwin"      :{ "arch": "i386,x86_64", "sysroot-api": "darwin"   , "compiler": "clang" },
    "msstdlib-i386-linux"       :{ "arch": "i386"       , "sysroot-api": "linux"    , "compiler": "clang" },
    "msstdlib-x86_64-linux"     :{ "arch": "x86_64"     , "sysroot-api": "linux"    , "compiler": "clang" },
    "msstdlib-i386-mingw-w64"   :{ "arch": "i386"       , "sysroot-api": "mingw-w64", "compiler": "clang" },
    "msstdlib-x86_64-mingw-w64" :{ "arch": "x86_64"     , "sysroot-api": "mingw-w64", "compiler": "clang" },
    "msstdlib-i386-msvc12"      :{ "arch": "i386"       , "sysroot-api": "msvc"     , "compiler": "clang" },
    "msstdlib-x86_64-msvc12"    :{ "arch": "x86_64"     , "sysroot-api": "msvc"     , "compiler": "clang" },
    "msstdlib": [
      "msstdlib-i386-darwin"   , "msstdlib-x86_64-darwin", "msstdlib-univ-darwin",
      "msstdlib-i386-linux"    , "msstdlib-x86_64-linux",
      "msstdlib-i386-mingw-w64", "msstdlib-x86_64-mingw-w64",
      "msstdlib-i386-msvc12"   , "msstdlib-x86_64-msvc12"
    ]
  },
  files: [
    {file: "MSStdTime.c", tags:["CompileC"]},
    {file: "MSStdTime-unix.c"},
    {file: "MSStdTime-win32.c"},
    {file: "MSStd.c", tags:["CompileC"]},
    {file: "MSStd.h", tags:["Header"]},
    {file: "MSStd_Private.h"},
    {file: "MSStdShared.c", tags:["CompileC"]},
    {file: "MSStdShared-unix.c"},
    {file: "MSStdShared-win32.c"},
    {file: "MSStdThreads.c", tags:["CompileC"]},
    {file: "MSStdThreads-unix.c"},
    {file: "MSStdThreads-win32.c"},
    {file: "MSStdBacktrace.c", tags:["CompileC"]},
    {file: "MSStdBacktrace-unix.c"},
    {file: "MSStdBacktrace-win32.c"},
    {file: "mman.c", tags:["CompileC"]},
    {file: "mman.h", tags:["Header"]},
  ],
  targets : [
    {
      "name" : "MSStd",
      "type" : "Library",
      "files": ["?CompileC"],
      "environments":["msstdlib"],
      "publicHeaders": ["?Header"],
      "static": true,
      "configure" : function(target) {
        if (target.sysroot.api === "mingw-w64")
          target.addDefines(["MINGW_HAS_SECURE_API"]);
        if (target.sysroot.api === "msvc")
          target.addDefines(["WIN32_LEAN_AND_MEAN=1"]);

        target.addCompileFlags(["-Werror"]);

        if (target.platform === "linux")
          target.addLibraries(['-lm', '-luuid', '-ldl']);
        else if (target.platform === "win32")
          target.addLibraries(['-lRpcrt4', '-lPsapi', '-lDbghelp']);
      },
      "exports" : {
        configure: function (other_target, target) {
          if (other_target.platform === "linux") {
            other_target.addLibraries(['-lm', '-luuid', '-ldl']);
          }
          else if (other_target.platform === "win32") {
            other_target.addLibraries(['-lRpcrt4', '-lPsapi', '-lDbghelp']);
          }
        }
      },
      "deepExports" : {
        configure: function (other_target, target) {
        if (other_target.sysroot.api === "msvc")
          other_target.addDefines(['WIN32_LEAN_AND_MEAN', '_CRT_SECURE_NO_DEPRECATE', '_CRT_NONSTDC_NO_DEPRECATE']);
        }
      }
    }
  ]
};
