module.exports = {
  name: "libuv",
  environments: {
    "libuv-base" : {
      compiler: "clang"
    },

    "libuv-i386-darwin"      :{"arch": "i386"       , "sysroot-api": "darwin"   , "parent": "libuv-base"},
    "libuv-x86_64-darwin"    :{"arch": "x86_64"     , "sysroot-api": "darwin"   , "parent": "libuv-base"},
    "libuv-univ-darwin"      :{"arch": "i386,x86_64", "sysroot-api": "darwin"   , "parent": "libuv-base"},
    "libuv-i386-linux"       :{"arch": "i386"       , "sysroot-api": "linux"    , "parent": "libuv-base"},
    "libuv-x86_64-linux"     :{"arch": "x86_64"     , "sysroot-api": "linux"    , "parent": "libuv-base"},
    "libuv-i386-mingw-w64"   :{"arch": "i386"       , "sysroot-api": "mingw-w64", "parent": "libuv-base"}, /* openssl win32 asm require non cross platform compiler masm */
    "libuv-x86_64-mingw-w64" :{"arch": "x86_64"     , "sysroot-api": "mingw-w64", "parent": "libuv-base"}, /* openssl win32 asm require non cross platform compiler masm */
    "libuv-i386-msvc"        :{"arch": "i386"       , "sysroot-api": "msvc"     , "parent": "libuv-base"},
    "libuv-x86_64-msvc"      :{"arch": "x86_64"     , "sysroot-api": "msvc"     , "parent": "libuv-base"},
    "libuv": [
      "libuv-i386-darwin"   , "libuv-x86_64-darwin", //"openssl-univ-darwin",
      /*"openssl-i386-linux"    ,*/ "libuv-x86_64-linux",
      "libuv-i386-mingw-w64", "libuv-x86_64-mingw-w64",
      "libuv-i386-msvc", "libuv-x86_64-msvc",
    ]
  },
  files: [
    {group:'libuv', files:[
      {group:'common', files:[
        {file:'include/uv.h'},
        {file:'include/tree.h'},
        {file:'include/uv-errno.h'},
        {file:'include/uv-threadpool.h'},
        {file:'include/uv-version.h'},
        {file:'src/fs-poll.c'},
        {file:'src/heap-inl.h'},
        {file:'src/inet.c'},
        {file:'src/queue.h'},
        {file:'src/threadpool.c'},
        {file:'src/uv-common.c'},
        {file:'src/uv-common.h'},
        {file:'src/version.c'},
      ]},
      {group:'def', files:[
        {file:'libuv.def'},
      ]},
      {group:'win32', files:[
        {file:'include/uv-win.h'},
        {file:'src/win/async.c'},
        {file:'src/win/atomicops-inl.h'},
        {file:'src/win/core.c'},
        {file:'src/win/dl.c'},
        {file:'src/win/error.c'},
        {file:'src/win/fs.c'},
        {file:'src/win/fs-event.c'},
        {file:'src/win/getaddrinfo.c'},
        {file:'src/win/getnameinfo.c'},
        {file:'src/win/handle.c'},
        {file:'src/win/handle-inl.h'},
        {file:'src/win/internal.h'},
        {file:'src/win/loop-watcher.c'},
        {file:'src/win/pipe.c'},
        {file:'src/win/thread.c'},
        {file:'src/win/poll.c'},
        {file:'src/win/process.c'},
        {file:'src/win/process-stdio.c'},
        {file:'src/win/req.c'},
        {file:'src/win/req-inl.h'},
        {file:'src/win/signal.c'},
        {file:'src/win/stream.c'},
        {file:'src/win/stream-inl.h'},
        {file:'src/win/tcp.c'},
        {file:'src/win/tty.c'},
        {file:'src/win/timer.c'},
        {file:'src/win/udp.c'},
        {file:'src/win/util.c'},
        {file:'src/win/winapi.c'},
        {file:'src/win/winapi.h'},
        {file:'src/win/winsock.c'},
        {file:'src/win/winsock.h'},
      ]},
      {group:'unix', files:[
        {file:'include/uv-unix.h'},
        {file:'include/uv-linux.h'},
        {file:'include/uv-sunos.h'},
        {file:'include/uv-darwin.h'},
        {file:'include/uv-bsd.h'},
        {file:'include/uv-aix.h'},
        {file:'src/unix/async.c'},
        {file:'src/unix/atomic-ops.h'},
        {file:'src/unix/core.c'},
        {file:'src/unix/dl.c'},
        {file:'src/unix/fs.c'},
        {file:'src/unix/getaddrinfo.c'},
        {file:'src/unix/getnameinfo.c'},
        {file:'src/unix/internal.h'},
        {file:'src/unix/loop.c'},
        {file:'src/unix/loop-watcher.c'},
        {file:'src/unix/pipe.c'},
        {file:'src/unix/poll.c'},
        {file:'src/unix/process.c'},
        {file:'src/unix/signal.c'},
        {file:'src/unix/spinlock.h'},
        {file:'src/unix/stream.c'},
        {file:'src/unix/tcp.c'},
        {file:'src/unix/thread.c'},
        {file:'src/unix/timer.c'},
        {file:'src/unix/tty.c'},
        {file:'src/unix/udp.c'},
        {file:'src/unix/darwin.c', tags: ["darwin"]},
        {file:'src/unix/fsevents.c', tags: ["darwin"]},
        {file:'src/unix/proctitle.c', tags: ["linux", "darwin", "android"]},
        {file:'src/unix/darwin-proctitle.c', tags: ["darwin"]},
        {file:'src/unix/linux-core.c', tags: ["linux", "android"]},
        {file:'src/unix/linux-inotify.c', tags: ["linux", "android"]},
        {file:'src/unix/linux-syscalls.c', tags: ["linux", "android"]},
        {file:'src/unix/linux-syscalls.h', tags: ["linux", "android"]},
        {file:'src/unix/pthread-fixes.c', tags: ["android"]},
        {file:'src/unix/android-ifaddrs.c', tags: ["android"]},
        {file:'src/unix/kqueue.c', tags: ["bsd"]}
      ]},
    ]},
    {group:'tests', files:[
      {group:"common", files:[
        {file:'test/blackhole-server.c'},
        {file:'test/echo-server.c'},
        {file:'test/runner.c'},
        {file:'test/runner.h'},
        {file:'test/task.h'},
        {file:'test/runner-win.c', tags: ['win32']},
        {file:'test/runner-win.h', tags: ['win32']},
        {file:'test/runner-unix.c', tags: ['unix']},
        {file:'test/runner-unix.h', tags: ['unix']},
      ]},
      {group:'tests', files:[
        {file:'test/run-tests.c'},
        {file:'test/test-get-loadavg.c'},
        {file:'test/test-active.c'},
        {file:'test/test-async.c'},
        {file:'test/test-async-null-cb.c'},
        {file:'test/test-callback-stack.c'},
        {file:'test/test-callback-order.c'},
        {file:'test/test-close-fd.c'},
        {file:'test/test-close-order.c'},
        {file:'test/test-connection-fail.c'},
        {file:'test/test-cwd-and-chdir.c'},
        {file:'test/test-default-loop-close.c'},
        {file:'test/test-delayed-accept.c'},
        {file:'test/test-error.c'},
        {file:'test/test-embed.c'},
        {file:'test/test-emfile.c'},
        {file:'test/test-fail-always.c'},
        {file:'test/test-fs.c'},
        {file:'test/test-fs-event.c'},
        {file:'test/test-get-currentexe.c'},
        {file:'test/test-get-memory.c'},
        {file:'test/test-getaddrinfo.c'},
        {file:'test/test-getnameinfo.c'},
        {file:'test/test-getsockname.c'},
        {file:'test/test-handle-fileno.c'},
        {file:'test/test-homedir.c'},
        {file:'test/test-hrtime.c'},
        {file:'test/test-idle.c'},
        {file:'test/test-ip6-addr.c'},
        {file:'test/test-ipc.c'},
        {file:'test/test-ipc-send-recv.c'},
        {file:'test/test-list.h'},
        {file:'test/test-loop-handles.c'},
        {file:'test/test-loop-alive.c'},
        {file:'test/test-loop-close.c'},
        {file:'test/test-loop-stop.c'},
        {file:'test/test-loop-time.c'},
        {file:'test/test-loop-configure.c'},
        {file:'test/test-walk-handles.c'},
        {file:'test/test-watcher-cross-stop.c'},
        {file:'test/test-multiple-listen.c'},
        {file:'test/test-osx-select.c'},
        {file:'test/test-pass-always.c'},
        {file:'test/test-ping-pong.c'},
        {file:'test/test-pipe-bind-error.c'},
        {file:'test/test-pipe-connect-error.c'},
        {file:'test/test-pipe-connect-prepare.c'},
        {file:'test/test-pipe-getsockname.c'},
        {file:'test/test-pipe-sendmsg.c'},
        {file:'test/test-pipe-server-close.c'},
        {file:'test/test-pipe-close-stdout-read-stdin.c'},
        {file:'test/test-pipe-set-non-blocking.c'},
        {file:'test/test-platform-output.c'},
        {file:'test/test-poll.c'},
        {file:'test/test-poll-close.c'},
        {file:'test/test-poll-close-doesnt-corrupt-stack.c'},
        {file:'test/test-poll-closesocket.c'},
        {file:'test/test-process-title.c'},
        {file:'test/test-ref.c'},
        {file:'test/test-run-nowait.c'},
        {file:'test/test-run-once.c'},
        {file:'test/test-semaphore.c'},
        {file:'test/test-shutdown-close.c'},
        {file:'test/test-shutdown-eof.c'},
        {file:'test/test-shutdown-twice.c'},
        {file:'test/test-signal.c'},
        {file:'test/test-signal-multiple-loops.c'},
        {file:'test/test-socket-buffer-size.c'},
        {file:'test/test-spawn.c'},
        {file:'test/test-fs-poll.c'},
        {file:'test/test-stdio-over-pipes.c'},
        {file:'test/test-tcp-bind-error.c'},
        {file:'test/test-tcp-bind6-error.c'},
        {file:'test/test-tcp-close.c'},
        {file:'test/test-tcp-close-accept.c'},
        {file:'test/test-tcp-close-while-connecting.c'},
        {file:'test/test-tcp-connect-error-after-write.c'},
        {file:'test/test-tcp-shutdown-after-write.c'},
        {file:'test/test-tcp-flags.c'},
        {file:'test/test-tcp-connect-error.c'},
        {file:'test/test-tcp-connect-timeout.c'},
        {file:'test/test-tcp-connect6-error.c'},
        {file:'test/test-tcp-open.c'},
        {file:'test/test-tcp-write-to-half-open-connection.c'},
        {file:'test/test-tcp-write-after-connect.c'},
        {file:'test/test-tcp-writealot.c'},
        {file:'test/test-tcp-write-fail.c'},
        {file:'test/test-tcp-try-write.c'},
        {file:'test/test-tcp-unexpected-read.c'},
        {file:'test/test-tcp-oob.c'},
        {file:'test/test-tcp-read-stop.c'},
        {file:'test/test-tcp-write-queue-order.c'},
        {file:'test/test-threadpool.c'},
        {file:'test/test-threadpool-cancel.c'},
        {file:'test/test-thread-equal.c'},
        {file:'test/test-mutexes.c'},
        {file:'test/test-thread.c'},
        {file:'test/test-barrier.c'},
        {file:'test/test-condvar.c'},
        {file:'test/test-timer-again.c'},
        {file:'test/test-timer-from-check.c'},
        {file:'test/test-timer.c'},
        {file:'test/test-tty.c'},
        {file:'test/test-udp-bind.c'},
        {file:'test/test-udp-dgram-too-big.c'},
        {file:'test/test-udp-ipv6.c'},
        {file:'test/test-udp-open.c'},
        {file:'test/test-udp-options.c'},
        {file:'test/test-udp-send-and-recv.c'},
        {file:'test/test-udp-send-immediate.c'},
        {file:'test/test-udp-send-unreachable.c'},
        {file:'test/test-udp-multicast-join.c'},
        {file:'test/test-udp-multicast-join6.c'},
        {file:'test/test-dlerror.c'},
        {file:'test/test-udp-multicast-ttl.c'},
        {file:'test/test-ip4-addr.c'},
        {file:'test/test-ip6-addr.c'},
        {file:'test/test-udp-multicast-interface.c'},
        {file:'test/test-udp-multicast-interface6.c'},
        {file:'test/test-udp-try-send.c'},
      ]},
      {group:"benchmarks", files:[
        {file:'test/dns-server.c'},
        {file:'test/run-benchmarks.c'},
        {file:'test/benchmark-async.c'},
        {file:'test/benchmark-async-pummel.c'},
        {file:'test/benchmark-fs-stat.c'},
        {file:'test/benchmark-getaddrinfo.c'},
        {file:'test/benchmark-list.h'},
        {file:'test/benchmark-loop-count.c'},
        {file:'test/benchmark-million-async.c'},
        {file:'test/benchmark-million-timers.c'},
        {file:'test/benchmark-multi-accept.c'},
        {file:'test/benchmark-ping-pongs.c'},
        {file:'test/benchmark-pound.c'},
        {file:'test/benchmark-pump.c'},
        {file:'test/benchmark-sizes.c'},
        {file:'test/benchmark-spawn.c'},
        {file:'test/benchmark-thread.c'},
        {file:'test/benchmark-tcp-write-batch.c'},
        {file:'test/benchmark-udp-pummel.c'},
      ]}
    ]},
  ],
  targets:[
    {
      name:"libuv",
      type:"Library",
      files:["libuv.common"],
      environments: ["libuv"],
      includeDirectoriesOfFiles:false,
      includeDirectories: [
        'include',
        'src',
      ],
      static: true,
      configure:function(/** Library */ target) {
        if(target.platform === "win32") {
          target.addWorkspaceFiles(["libuv.win32"]);
          target.addDefines(['_WIN32_WINNT=0x0600', '_GNU_SOURCE']);
          target.addLibraries(['-ladvapi32', '-liphlpapi', '-lole32', '-lpsapi', '-lshell32', '-lws2_32', '-luuid']);
          if (target.sysroot.api === "msvc") {
            target.addLibraries(['oldnames.lib']);
            target.addDefines(['_CRT_SECURE_NO_DEPRECATE', '_CRT_NONSTDC_NO_DEPRECATE']);
          }
        }
        else {
          target.addWorkspaceFiles(["libuv.unix?"]);
          target.addDefines(['_LARGEFILE_SOURCE', '_FILE_OFFSET_BITS=64', '_GNU_SOURCE']);
          target.addLibraries(['-lpthread']);
        }
        if(target.platform === "darwin") {
          target.addDefines(['_DARWIN_USE_64_BIT_INODE']);
          target.addWorkspaceFiles(["libuv.unix?darwin", "libuv.unix?bsd"]);
        }
        if(target.platform === "linux") {
          target.addDefines(['_POSIX_C_SOURCE=200112']);
          target.addWorkspaceFiles(["libuv.unix?linux"]);
          target.addLibraries(['-ldl', '-lrt']);
        }
        target.addDefines(['BUILDING_UV_SHARED=1']);
      },
      exports:{
        configure:function(other_target, self_target) {
          self_target.addDefines(['BUILDING_UV_SHARED=1']);
          other_target.addIncludeDirectory(self_target.resolvePath('include'));
          if (other_target.sysroot.api === "msvc") {
            other_target.addLinkFlags([ // Find why about 10 symbols aren't exported
              '/EXPORT:uv_getaddrinfo',
              '/EXPORT:uv_freeaddrinfo',
              '/EXPORT:uv_getnameinfo',
              '/EXPORT:uv_version_string',
              '/EXPORT:uv_dlopen',
              '/EXPORT:uv_dlerror'
            ]);
            other_target.addTaskModifier("LinkMSVC", function(target, task) {
              task.addDefs(self_target.workspace.resolveFiles(["libuv.def"]));
            });
          }
          if (other_target.platform === "win32")
            other_target.addLibraries(['-ladvapi32', '-liphlpapi', '-lole32', '-lpsapi', '-lshell32', '-lws2_32', '-luuid']);
        }
      }
    },
    {
      name:"libuv-tests",
      type:"Executable",
      files:["tests.common?", "tests.tests"],
      dependencies: ["libuv"],
      environments: ["libuv"],
      configure:function(/** Library */ target) {
        if(target.platform === "win32") {
          target.addWorkspaceFiles(["tests.common?win32"]);
          target.addLibraries(['-lws2_32']);
        }
        else {
          target.addWorkspaceFiles(["tests.common?unix"]);
          target.addDefines(['_GNU_SOURCE', '_LARGEFILE_SOURCE', '_FILE_OFFSET_BITS=64']);
          target.addLibraries(['-lpthread']);
        }
      }
    },
    {
      name:"libuv-benchmarks",
      type:"Executable",
      files:["tests.common?", "tests.benchmarks"],
      dependencies: ["libuv"],
      environments: ["libuv"],
      configure:function(/** Library */ target) {
        if(target.platform === "win32") {
          target.addWorkspaceFiles(["tests.common?win32"]);
          target.addLibraries(['-lws2_32']);
        }
        else {
          target.addWorkspaceFiles(["tests.common?unix"]);
          target.addDefines(['_GNU_SOURCE', '_LARGEFILE_SOURCE', '_FILE_OFFSET_BITS=64']);
          target.addLibraries(['-lpthread']);
        }
      }
    }
  ]
};
