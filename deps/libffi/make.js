module.exports = {
  name : "libffi",
  environments: {
    "libffi-i386-darwin"      :{ "arch": "i386"       , "sysroot-api": "darwin"   , "compiler": "clang" },
    "libffi-x86_64-darwin"    :{ "arch": "x86_64"     , "sysroot-api": "darwin"   , "compiler": "clang" },
    "libffi-univ-darwin"      :{ "arch": "i386,x86_64", "sysroot-api": "darwin"   , "compiler": "clang" },
    "libffi-i386-linux"       :{ "arch": "i386"       , "sysroot-api": "linux"    , "compiler": "clang" },
    "libffi-x86_64-linux"     :{ "arch": "x86_64"     , "sysroot-api": "linux"    , "compiler": "clang" },
    "libffi-i386-mingw-w64"   :{ "arch": "i386"       , "sysroot-api": "mingw-w64", "compiler": "clang" },
    "libffi-x86_64-mingw-w64" :{ "arch": "x86_64"     , "sysroot-api": "mingw-w64", "compiler": "clang" },
    "libffi-i386-msvc12"      :{ "arch": "i386"       , "sysroot-api": "msvc"     , "compiler": "clang" },
    "libffi-x86_64-msvc12"    :{ "arch": "x86_64"     , "sysroot-api": "msvc"     , "compiler": "clang" },
    "libffi": [
      "libffi-i386-darwin"   , "libffi-x86_64-darwin", "libffi-univ-darwin",
      /*"libffi-i386-linux"    ,*/ "libffi-x86_64-linux",
      //"libffi-i386-mingw-w64", "libffi-x86_64-mingw-w64",
      "libffi-i386-msvc12"   , "libffi-x86_64-msvc12"
    ]
  },
  files: [
    {file: "include/ffi.h", tags:["Header", "x86_64", "i386"]},
    {file: "src/prep_cif.c", tags:["Core"]},
    {file: "src/types.c", tags:["Core"]},
    {file: "src/raw_api.c", tags:["Core"]},
    {file: "src/java_raw_api.c", tags:["Java"]},
    {file: "src/closures.c", tags:["Core"]},
    {file: "src/x86/ffitarget.h", tags:["Header", "x86_64", "i386"]},
    {file: "src/x86/ffi.c", tags:["x86_64", "i386"]},
    {file: "src/x86/ffi64.c", tags:["i386-darwin", "x86_64-darwin", "x86_64-linux"]},
    {file: "src/x86/darwin.S", tags:["i386-darwin", "x86_64-darwin"]},
    {file: "src/x86/darwin64.S", tags:["x86_64-darwin"]},
    {file: "src/x86/win32.S", tags:["i386-msvc"]},
    {file: "src/x86/win64.S", tags:["x86_64-msvc"]},
    {file: "src/x86/sysv.S", tags:["i386-linux", "x86_64-linux"]},
    {file: "src/x86/unix64.S", tags:["x86_64-linux"]},
  ],
  targets : [
    {
      "name" : "libffi_static",
      "type" : "Library",
      "static": true,
      "files": [
        "?Core"
      ],
      "environments": ["libffi"],
      "publicHeaders": ["?Header"],
      "defines": ["FFI_BUILDING", "PIC"],
      //"static": true,
      "configure" : function(target) {
        // FFI_EXEC_TRAMPOLINE_TABLE=1 is darwin + arm
        target.addCompileFlags(["-Werror"]);
        target.addWorkspacePublicHeaders(["?Header?" + target.arch]);
        target.addWorkspaceFiles(["?" + target.arch]);
        target.addWorkspaceFiles(["?" + target.arch + "-" + target.sysroot.api]);
        //console.warn(target.files);
      },
      "exports" : {
        configure: function (other_target, self_target) {
          other_target.addTaskModifier("Compile", compileModifier);
        }
      }
    }
  ]
};

function compileModifier(target, task) {
  task.addFlags(["-DFFI_BUILDING"]);
}
