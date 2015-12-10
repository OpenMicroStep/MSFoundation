/* fficonfig.h.  Generated from fficonfig.h.in by configure.  */
/* fficonfig.h.in.  Generated from configure.ac by autoheader.  */

/* Specify which architecture libffi is configured for. */

// Operating system detection:
// __sun -> Solaris
// __MACH__ -> MacOS
// _WIN32 -> Windows 32 & 64
// _WIN64 -> Windows 64
// __linux__ -> Linux
// __FreeBSD__ -> FreeBSD

// Architecture detection:
// __arm__ -> ARM
// __i386__ -> ia32
// __x86_64__ -> x86

/* Define if building universal (internal helper macro) */
/* #undef AC_APPLE_UNIVERSAL_BUILD */

/* Define to one of `_getb67', `GETB67', `getb67' for Cray-2 and Cray-YMP
   systems. This function is required for `alloca.c' support on those systems.
   */
/* #undef CRAY_STACKSEG_END */


#if defined(__MACH__)
#  if defined(__i386__)
#    define MACOS_X86 1
#  elif defined(__x86_64__)
#    define MACOS_X64 1
#  else
#    error Unsupported MacOS architecture
#  endif
#elif defined(__linux__)
#  if defined(__i386__)
#    define LINUX_X86 1
#  elif defined(__x86_64__)
#    define LINUX_X64 1
#  elif defined(__arm__)
#    define LINUX_ARM 1
#  else
#    error Unsupported Linux architecture
#  endif
#elif defined(__sun)
#  if defined(__i386__)
#    define SOLARIS_X86 1
#  elif defined(__x86_64__)
#    define SOLARIS_X64 1
#  else
#    error Unsupported Solaris architecture
#  endif
#elif defined(_WIN32)
#  if defined(__i386__)
#    define WINDOWS_X86 1
#  elif defined(__x86_64__)
#    define WINDOWS_X64 1
#  else
#    error Unsupported Windows architecture
#  endif
#elif defined(__FreeBSD__)
#  if defined(__i386__)
#    define FREEBSD_X86 1
#  elif defined(__x86_64__)
#    define FREEBSD_X64 1
#  else
#    error Unsupported FreeBSD architecture
#  endif
#else
#  error Unsupported Operating system
#endif

/* Define to 1 if using `alloca.c'. */
#if WINDOWS_X86 || WINDOWS_X64
#define C_ALLOCA 1
#endif

/* Define to the flags needed for the .section .eh_frame directive. */
#if MACOS_X86 || MACOS_X64 || LINUX_X86 || LINUX_X64 || LINUX_ARM || SOLARIS_X86
#define EH_FRAME_FLAGS "aw"
#elif FREEBSD_X86 || FREEBSD_X64 || SOLARIS_X64
#define EH_FRAME_FLAGS "a"
#endif

/* Define this if you want extra debugging. */
/* #undef FFI_DEBUG */

/* Cannot use PROT_EXEC on this target, so, we revert to alternative means */
/* #undef FFI_EXEC_TRAMPOLINE_TABLE */

/* Define this if you want to enable pax emulated trampolines */
/* #undef FFI_MMAP_EXEC_EMUTRAMP_PAX */

/* Cannot use malloc on this target, so, we revert to alternative means */
#if MACOS_X86 || MACOS_X64 || FREEBSD_X86 || FREEBSD_X64 || SOLARIS_X86 || SOLARIS_X64
#define FFI_MMAP_EXEC_WRIT 1
#endif

/* Define this if you do not want support for the raw API. */
/* #undef FFI_NO_RAW_API */

/* Define this if you do not want support for aggregate types. */
/* #undef FFI_NO_STRUCTS */

/* Define to 1 if you have `alloca', as a function or macro. */
/* Define to 1 if you have <alloca.h> and it should be used (not on Ultrix). */
#if MACOS_X86 || MACOS_X64 || FREEBSD_X86 || FREEBSD_X64 || LINUX_X86 || LINUX_X64 || LINUX_ARM || SOLARIS_X86 || SOLARIS_X64
#define HAVE_ALLOCA 1
#define HAVE_ALLOCA_H 1
#endif

/* Define if your assembler supports .ascii. */
#if FREEBSD_X64 || LINUX_X86 || LINUX_X64 || SOLARIS_X86
#define HAVE_AS_ASCII_PSEUDO_OP 1
#endif

/* Define if your assembler supports .cfi_* directives. */
#if FREEBSD_X86 || FREEBSD_X64 || LINUX_X86 || LINUX_X64 || LINUX_ARM || SOLARIS_X86 || SOLARIS_X64
#define HAVE_AS_CFI_PSEUDO_OP 1
#endif

/* Define if your assembler supports .register. */
/* #undef HAVE_AS_REGISTER_PSEUDO_OP */

/* Define if your assembler and linker support unaligned PC relative relocs.
   */
/* #undef HAVE_AS_SPARC_UA_PCREL */

/* Define if your assembler supports .string. */
#if FREEBSD_X64 || LINUX_X86 || LINUX_X64 || SOLARIS_X86
#define HAVE_AS_STRING_PSEUDO_OP 1
#endif

/* Define if your assembler supports unwind section type. */
#if FREEBSD_X64 || LINUX_X64 || SOLARIS_X64
#define HAVE_AS_X86_64_UNWIND_SECTION_TYPE 1
#endif

/* Define if your assembler supports PC relative relocs. */
#if FREEBSD_X64 || LINUX_X86 || LINUX_X64 || SOLARIS_X86 || SOLARIS_X64
#define HAVE_AS_X86_PCREL 1
#endif

/* Define if __attribute__((visibility("hidden"))) is supported. */
#if !defined(_WIN32)
#define HAVE_HIDDEN_VISIBILITY_ATTRIBUTE 1
#endif

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define if you have the long double type and it is bigger than a double */
#if defined(__LONG_DOUBLE_128__) || defined(__mips64) || (DBL_MANT_DIG < LDBL_MANT_DIG)
#define HAVE_LONG_DOUBLE 1
#endif

/* Define if you support more than one size of the long double type */
#if defined(TODO_POWERPC_LINUX_SYSV_OPENBSD_FREEBSD)
#define HAVE_LONG_DOUBLE_VARIANT 1
#endif

/* Define to 1 if you have the `memcpy' function. */
#define HAVE_MEMCPY 1

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define to 1 if you have the `mkostemp' function. */
/* #undef HAVE_MKOSTEMP */

/* Define to 1 if you have the `mmap' function. */
#define HAVE_MMAP 1

/* Define if mmap with MAP_ANON(YMOUS) works. */
#define HAVE_MMAP_ANON 1

/* Define if mmap of /dev/zero works. */
#define HAVE_MMAP_DEV_ZERO 1

/* Define if .eh_frame sections should be read-only. */
#if defined(TODO_SPARC)
#define HAVE_RO_EH_FRAME 1
#endif

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Define if symbols are underscored. */
#define SYMBOL_UNDERSCORE 1

/* Define this if you are using Purify and want to suppress spurious messages. */
/* #undef USING_PURIFY */

/* Define WORDS_BIGENDIAN to 1 if your processor stores words with the most
   significant byte first (like Motorola and SPARC, unlike Intel). */
#if defined __BIG_ENDIAN__
#define WORDS_BIGENDIAN 1
#endif

#ifdef HAVE_HIDDEN_VISIBILITY_ATTRIBUTE
#ifdef LIBFFI_ASM
#define FFI_HIDDEN(name) .hidden name
#else
#define FFI_HIDDEN __attribute__ ((visibility ("hidden")))
#endif
#else
#ifdef LIBFFI_ASM
#define FFI_HIDDEN(name)
#else
#define FFI_HIDDEN
#endif
#endif

#ifdef MACOS_X86
#undef MACOS_X86
#endif
#ifdef MACOS_X64
#undef MACOS_X64
#endif
#ifdef LINUX_X86
#undef LINUX_X86
#endif
#ifdef LINUX_X64
#undef LINUX_X64
#endif
#ifdef LINUX_ARM
#undef LINUX_ARM
#endif
#ifdef SOLARIS_X86
#undef SOLARIS_X86
#endif
#ifdef SOLARIS_X64
#undef SOLARIS_X64
#endif
#ifdef WINDOWS_X86
#undef WINDOWS_X86
#endif
#ifdef WINDOWS_X64
#undef WINDOWS_X64
#endif
#ifdef FREEBSD_X86
#undef FREEBSD_X86
#endif
#ifdef FREEBSD_X64
#undef FREEBSD_X64
#endif
