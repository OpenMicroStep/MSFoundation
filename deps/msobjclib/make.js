module.exports = {
  name : "MSObjcLib",
  environments: {
    "openmicrostep-base" : {
      compiler: "clang"
    },

    "openmicrostep-foundation-i386-darwin"      :{"arch": "i386"       , "sysroot-api": "darwin"   , "parent": "openmicrostep-base"},
    "openmicrostep-foundation-x86_64-darwin"    :{"arch": "x86_64"     , "sysroot-api": "darwin"   , "parent": "openmicrostep-base"},
    "openmicrostep-foundation-univ-darwin"      :{"arch": "i386,x86_64", "sysroot-api": "darwin"   , "parent": "openmicrostep-base"},
    "openmicrostep-foundation-i386-linux"       :{"arch": "i386"       , "sysroot-api": "linux"    , "parent": "openmicrostep-base"},
    "openmicrostep-foundation-x86_64-linux"     :{"arch": "x86_64"     , "sysroot-api": "linux"    , "parent": "openmicrostep-base"},
    "openmicrostep-foundation-i386-mingw-w64"   :{"arch": "i386"       , "sysroot-api": "mingw-w64", "parent": "openmicrostep-base"},
    "openmicrostep-foundation-x86_64-mingw-w64" :{"arch": "x86_64"     , "sysroot-api": "mingw-w64", "parent": "openmicrostep-base"},
    "openmicrostep-foundation": [
      "openmicrostep-foundation-i386-darwin"   , "openmicrostep-foundation-x86_64-darwin", "openmicrostep-foundation-univ-darwin",
      "openmicrostep-foundation-i386-linux"    , "openmicrostep-foundation-x86_64-linux",
      "openmicrostep-foundation-i386-mingw-w64", "openmicrostep-foundation-x86_64-mingw-w64",
    ]
  },
  files: [
    {group:"Public API", files: [
      {file: 'objc/Availability.h'},
      {file: 'objc/Object.h'},
      {file: 'objc/Protocol.h'},
      {file: 'objc/blocks_private.h'},
      {file: 'objc/blocks_runtime.h'},
      {file: 'objc/capabilities.h'},
      {file: 'objc/developer.h'},
      {file: 'objc/encoding.h'},
      {file: 'objc/hooks.h'},
      {file: 'objc/message.h'},
      {file: 'objc/objc-api.h'},
      {file: 'objc/objc-arc.h'},
      {file: 'objc/objc-auto.h'},
      {file: 'objc/objc.h'},
      {file: 'objc/runtime-deprecated.h'},
      {file: 'objc/runtime.h'},
      {file: 'objc/slot.h'},
      {file: 'objc/toydispatch.h'},
    ]},
    {group:"Sources", files: [
      {file: 'NSBlocks.m'},
      {file: 'Protocol2.m'},
      {file: 'abi_version.c'},
      {file: 'alias.h'},
      {file: 'alias_table.c'},
      {file: 'arc.m'},
      {file: 'associate.m'},
      {file: 'block_to_imp.c'},
      {file: 'block_trampolines.S'},
      {file: 'blocks_runtime.h'},
      {file: 'blocks_runtime.m'},
      {file: 'buffer.h'},
      {file: 'caps.c'},
      {file: 'category.h'},
      {file: 'category_loader.c'},
      {file: 'class.h'},
      {file: 'class_table.c'},
      {file: 'common.S'},
      {file: 'constant_string.h'},
      {file: 'dtable.c'},
      {file: 'dtable.h'},
      {file: 'dwarf_eh.h'},
      {file: 'eh_personality.c'},
      {file: 'encoding2.c'},
      {file: 'gc_none.c'},
      {file: 'hash_table.c'},
      {file: 'hash_table.h'},
      {file: 'hooks.c'},
      {file: 'ivar.c'},
      {file: 'ivar.h'},
      {file: 'legacy_malloc.c'},
      {file: 'loader.c'},
      {file: 'loader.h'},
      {file: 'lock.h'},
      {file: 'mman.h'},
      {file: 'mman.c'},
      {file: 'method_list.h'},
      {file: 'module.h'},
      {file: 'mutation.m'},
      {file: 'nsobject.h'},
      {file: 'objc_msgSend.S'},
      {file: 'objcxx_eh.h'},
      {file: 'objcxx_eh.cc'},
      {file: 'pool.h'},
      {file: 'properties.h'},
      {file: 'properties.m'},
      {file: 'protocol.c'},
      {file: 'protocol.h'},
      {file: 'runtime.c'},
      {file: 'sarray2.c'},
      {file: 'sarray2.h'},
      {file: 'selector.h'},
      {file: 'selector_table.c'},
      {file: 'sendmsg2.c'},
      {file: 'slot_pool.h'},
      {file: 'spinlock.h'},
      {file: 'statics_loader.c'},
      {file: 'string_hash.h'},
      {file: 'toydispatch.c'},
      {file: 'type_encoding_cases.h'},
      {file: 'unistd.h'},
      {file: 'unwind-arm.h'},
      {file: 'unwind-itanium.h'},
      {file: 'unwind.h'},
      {file: 'visibility.h'},
    ]}
  ],
  targets : [
    {
      "name" : "msobjclib",
      "type" : "Library",
      "files": ["Sources"],
      "environments":["openmicrostep-foundation"],
      "publicHeaders": ["Public API"],
      "publicHeadersPrefix": "objc",
      "defines": ["__OBJC_RUNTIME_INTERNAL__=1"],
      "configure": function(target) {
        if(target.env.compiler === "clang")
          target.addCompileFlags(["-Wno-deprecated-objc-isa-usage", "-Wno-objc-root-class"]);
        target.addTaskModifier("Compile", compileModifier);
        if(!target.static)
          target.addTaskModifier("Link", linkModifier);
        if(target.platform === "win32")
          target.addTaskModifier("Link", win32LinkModifier);
      },
      "exports" : {
        configure: function (other_target, target) {
          if (target.static)
            other_target.addTaskModifier("Link", linkModifier);
        }
      },
      "deepExports" : {
        configure: function (other_target, target) {
          other_target.addIncludeDirectory(target.buildPublicHeaderPath());
          if (!target.static)
            other_target.addLinkFlags([target.sysroot.linkFinalPath(target)]);
          other_target.addTaskModifier("Compile", compileModifier);
          if(other_target.platform === "win32")
            other_target.addTaskModifier("Link", win32LinkModifier);
        }
      }
    }
  ]
};


function compileModifier(target, task) {
  if(task.language === "OBJC" || task.language === "OBJCXX") {
    task.addFlags(["-fconstant-string-class=NSConstantString", "-fobjc-exceptions"]);
    if(task.isInstanceOf("CompileClang"))
      task.addFlags(["-fobjc-runtime=gnustep-1.7"]);
  }
}

function linkModifier(target, task) {
  task.addLibraryFlags(['-lpthread', '-lstdc++']);
}


function win32LinkModifier(target, task) {
  // clang & gcc on windows doesn't export objective-c symbols correctly
  task.addFlagsAtEnd(["-Wl,--export-all-symbols", "-Wl,--allow-multiple-definition"]);
}