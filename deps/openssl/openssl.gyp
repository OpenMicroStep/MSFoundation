# Copyright (c) 2012 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

{
  'variables': {
    'is_clang': 0,
    'gcc_version': 0,
    'openssl_no_asm%': 0
  },

  'targets': [
    {
      'target_name': 'openssl',
      'type': '<(library)',
      'sources': [

      ],
      'sources/': [
        ['exclude', 'md2/.*$'],
        ['exclude', 'store/.*$']
      ],
      'conditions': [
        ['target_arch!="ia32" and target_arch!="x64" and target_arch!="arm" or openssl_no_asm!=0', {
          # Disable asm
          'defines': [
            'OPENSSL_NO_ASM'
           ],
          'sources': [
            'openssl/crypto/aes/aes_cbc.c',
            'openssl/crypto/aes/aes_core.c',
            'openssl/crypto/bf/bf_enc.c',
            'openssl/crypto/bn/bn_asm.c',
            'openssl/crypto/cast/c_enc.c',
            'openssl/crypto/camellia/camellia.c',
            'openssl/crypto/camellia/cmll_cbc.c',
            'openssl/crypto/camellia/cmll_misc.c',
            'openssl/crypto/des/des_enc.c',
            'openssl/crypto/des/fcrypt_b.c',
            'openssl/crypto/mem_clr.c',
            'openssl/crypto/rc4/rc4_enc.c',
            'openssl/crypto/rc4/rc4_skey.c',
            'openssl/crypto/whrlpool/wp_block.c'
         ]
        }, {
          # Enable asm
          'defines': [
            'AES_ASM',
            'CPUID_ASM',
            'OPENSSL_BN_ASM_MONT',
            'OPENSSL_CPUID_OBJ',
            'SHA1_ASM',
            'SHA256_ASM',
            'SHA512_ASM',
            'GHASH_ASM',
          ],
          'conditions': [
            # Extended assembly on non-arm platforms
            ['target_arch!="arm"', {
              'defines': [
                'VPAES_ASM',
                'BN_ASM',
                'BF_ASM',
                'BNCO_ASM',
                'DES_ASM',
                'LIB_BN_ASM',
                'MD5_ASM',
                'OPENSSL_BN_ASM',
                'RIP_ASM',
                'RMD160_ASM',
                'WHIRLPOOL_ASM',
                'WP_ASM',
              ],
            }],
            ['OS!="win" and OS!="mac" and target_arch=="ia32"', {
              'sources': [
                'asm/x86-elf-gas/aes/aes-586.s',
                'asm/x86-elf-gas/aes/aesni-x86.s',
                'asm/x86-elf-gas/aes/vpaes-x86.s',
                'asm/x86-elf-gas/bf/bf-686.s',
                'asm/x86-elf-gas/bn/x86-mont.s',
                'asm/x86-elf-gas/bn/x86.s',
                'asm/x86-elf-gas/camellia/cmll-x86.s',
                'asm/x86-elf-gas/cast/cast-586.s',
                'asm/x86-elf-gas/des/crypt586.s',
                'asm/x86-elf-gas/des/des-586.s',
                'asm/x86-elf-gas/md5/md5-586.s',
                'asm/x86-elf-gas/rc4/rc4-586.s',
                'asm/x86-elf-gas/rc5/rc5-586.s',
                'asm/x86-elf-gas/ripemd/rmd-586.s',
                'asm/x86-elf-gas/sha/sha1-586.s',
                'asm/x86-elf-gas/sha/sha256-586.s',
                'asm/x86-elf-gas/sha/sha512-586.s',
                'asm/x86-elf-gas/whrlpool/wp-mmx.s',
                'asm/x86-elf-gas/modes/ghash-x86.s',
                'asm/x86-elf-gas/x86cpuid.s',
                'openssl/crypto/whrlpool/wp_block.c'
              ]
            }],
            ['OS!="win" and OS!="mac" and target_arch=="x64"', {
              'defines': [
                'OPENSSL_BN_ASM_MONT5',
                'OPENSSL_BN_ASM_GF2m',
                'OPENSSL_IA32_SSE2',
                'BSAES_ASM',
              ],
              'sources': [
                'asm/x64-elf-gas/aes/aes-x86_64.s',
                'asm/x64-elf-gas/aes/aesni-x86_64.s',
                'asm/x64-elf-gas/aes/vpaes-x86_64.s',
                'asm/x64-elf-gas/aes/bsaes-x86_64.s',
                'asm/x64-elf-gas/aes/aesni-sha1-x86_64.s',
                'asm/x64-elf-gas/bn/modexp512-x86_64.s',
                'asm/x64-elf-gas/bn/x86_64-mont.s',
                'asm/x64-elf-gas/bn/x86_64-mont5.s',
                'asm/x64-elf-gas/bn/x86_64-gf2m.s',
                'asm/x64-elf-gas/camellia/cmll-x86_64.s',
                'asm/x64-elf-gas/md5/md5-x86_64.s',
                'asm/x64-elf-gas/rc4/rc4-x86_64.s',
                'asm/x64-elf-gas/rc4/rc4-md5-x86_64.s',
                'asm/x64-elf-gas/sha/sha1-x86_64.s',
                'asm/x64-elf-gas/sha/sha256-x86_64.s',
                'asm/x64-elf-gas/sha/sha512-x86_64.s',
                'asm/x64-elf-gas/whrlpool/wp-x86_64.s',
                'asm/x64-elf-gas/modes/ghash-x86_64.s',
                'asm/x64-elf-gas/x86_64cpuid.s',
                # Non-generated asm
                'openssl/crypto/bn/asm/x86_64-gcc.c',
                # No asm available
                'openssl/crypto/bf/bf_enc.c',
                'openssl/crypto/cast/c_enc.c',
                'openssl/crypto/camellia/cmll_misc.c',
                'openssl/crypto/des/des_enc.c',
                'openssl/crypto/des/fcrypt_b.c'
              ]
            }],
            ['OS=="mac" and target_arch=="ia32"', {
              'sources': [
                'asm/x86-macosx-gas/aes/aes-586.s',
                'asm/x86-macosx-gas/aes/aesni-x86.s',
                'asm/x86-macosx-gas/aes/vpaes-x86.s',
                'asm/x86-macosx-gas/bf/bf-686.s',
                'asm/x86-macosx-gas/bn/x86-mont.s',
                'asm/x86-macosx-gas/bn/x86.s',
                'asm/x86-macosx-gas/camellia/cmll-x86.s',
                'asm/x86-macosx-gas/cast/cast-586.s',
                'asm/x86-macosx-gas/des/crypt586.s',
                'asm/x86-macosx-gas/des/des-586.s',
                'asm/x86-macosx-gas/md5/md5-586.s',
                'asm/x86-macosx-gas/rc4/rc4-586.s',
                'asm/x86-macosx-gas/rc5/rc5-586.s',
                'asm/x86-macosx-gas/ripemd/rmd-586.s',
                'asm/x86-macosx-gas/sha/sha1-586.s',
                'asm/x86-macosx-gas/sha/sha256-586.s',
                'asm/x86-macosx-gas/sha/sha512-586.s',
                'asm/x86-macosx-gas/whrlpool/wp-mmx.s',
                'asm/x86-macosx-gas/modes/ghash-x86.s',
                'asm/x86-macosx-gas/x86cpuid.s',
                'openssl/crypto/whrlpool/wp_block.c'
              ]
            }],
            ['OS=="mac" and target_arch=="x64"', {
              'defines': [
                'OPENSSL_BN_ASM_MONT5',
                'OPENSSL_BN_ASM_GF2m',
                'OPENSSL_IA32_SSE2',
                'BSAES_ASM',
              ],
              'sources': [
                'asm/x64-macosx-gas/aes/aes-x86_64.s',
                'asm/x64-macosx-gas/aes/aesni-x86_64.s',
                'asm/x64-macosx-gas/aes/vpaes-x86_64.s',
                'asm/x64-macosx-gas/aes/bsaes-x86_64.s',
                'asm/x64-macosx-gas/aes/aesni-sha1-x86_64.s',
                'asm/x64-macosx-gas/bn/modexp512-x86_64.s',
                'asm/x64-macosx-gas/bn/x86_64-mont.s',
                'asm/x64-macosx-gas/bn/x86_64-mont5.s',
                'asm/x64-macosx-gas/bn/x86_64-gf2m.s',
                'asm/x64-macosx-gas/camellia/cmll-x86_64.s',
                'asm/x64-macosx-gas/md5/md5-x86_64.s',
                'asm/x64-macosx-gas/rc4/rc4-x86_64.s',
                'asm/x64-macosx-gas/rc4/rc4-md5-x86_64.s',
                'asm/x64-macosx-gas/sha/sha1-x86_64.s',
                'asm/x64-macosx-gas/sha/sha256-x86_64.s',
                'asm/x64-macosx-gas/sha/sha512-x86_64.s',
                'asm/x64-macosx-gas/whrlpool/wp-x86_64.s',
                'asm/x64-macosx-gas/modes/ghash-x86_64.s',
                'asm/x64-macosx-gas/x86_64cpuid.s',
                # Non-generated asm
                'openssl/crypto/bn/asm/x86_64-gcc.c',
                # No asm available
                'openssl/crypto/bf/bf_enc.c',
                'openssl/crypto/cast/c_enc.c',
                'openssl/crypto/camellia/cmll_misc.c',
                'openssl/crypto/des/des_enc.c',
                'openssl/crypto/des/fcrypt_b.c'
              ]
            }],
            ['target_arch=="arm"', {
              'sources': [
                'asm/arm-elf-gas/aes/aes-armv4.s',
                'asm/arm-elf-gas/bn/armv4-mont.s',
                'asm/arm-elf-gas/bn/armv4-gf2m.s',
                'asm/arm-elf-gas/sha/sha1-armv4-large.s',
                'asm/arm-elf-gas/sha/sha512-armv4.s',
                'asm/arm-elf-gas/sha/sha256-armv4.s',
                'asm/arm-elf-gas/modes/ghash-armv4.s',
                # No asm available
                'openssl/crypto/aes/aes_cbc.c',
                'openssl/crypto/bf/bf_enc.c',
                'openssl/crypto/bn/bn_asm.c',
                'openssl/crypto/cast/c_enc.c',
                'openssl/crypto/camellia/camellia.c',
                'openssl/crypto/camellia/cmll_cbc.c',
                'openssl/crypto/camellia/cmll_misc.c',
                'openssl/crypto/des/des_enc.c',
                'openssl/crypto/des/fcrypt_b.c',
                'openssl/crypto/rc4/rc4_enc.c',
                'openssl/crypto/rc4/rc4_skey.c',
                'openssl/crypto/whrlpool/wp_block.c',
                # PCAP stuff
                'openssl/crypto/armcap.c',
                'openssl/crypto/armv4cpuid.S',
              ]
            }],
            ['OS=="win" and target_arch=="ia32"', {
              'sources': [
                'asm/x86-win32-masm/aes/aes-586.asm',
                'asm/x86-win32-masm/aes/aesni-x86.asm',
                'asm/x86-win32-masm/aes/vpaes-x86.asm',
                'asm/x86-win32-masm/bf/bf-686.asm',
                'asm/x86-win32-masm/bn/x86-mont.asm',
                'asm/x86-win32-masm/bn/x86.asm',
                'asm/x86-win32-masm/camellia/cmll-x86.asm',
                'asm/x86-win32-masm/cast/cast-586.asm',
                'asm/x86-win32-masm/des/crypt586.asm',
                'asm/x86-win32-masm/des/des-586.asm',
                'asm/x86-win32-masm/md5/md5-586.asm',
                'asm/x86-win32-masm/rc4/rc4-586.asm',
                'asm/x86-win32-masm/rc5/rc5-586.asm',
                'asm/x86-win32-masm/ripemd/rmd-586.asm',
                'asm/x86-win32-masm/sha/sha1-586.asm',
                'asm/x86-win32-masm/sha/sha256-586.asm',
                'asm/x86-win32-masm/sha/sha512-586.asm',
                'asm/x86-win32-masm/whrlpool/wp-mmx.asm',
                'asm/x86-win32-masm/modes/ghash-x86.asm',
                'asm/x86-win32-masm/x86cpuid.asm',
                'openssl/crypto/whrlpool/wp_block.c'
              ],
              'rules': [
                {
                  'rule_name': 'Assemble',
                  'extension': 'asm',
                  'inputs': [],
                  'outputs': [
                    '<(INTERMEDIATE_DIR)/<(RULE_INPUT_ROOT).obj',
                  ],
                  'action': [
                    'ml.exe',
                    '/Zi',
                    '/safeseh',
                    '/Fo', '<(INTERMEDIATE_DIR)/<(RULE_INPUT_ROOT).obj',
                    '/c', '<(RULE_INPUT_PATH)',
                  ],
                  'process_outputs_as_sources': 0,
                  'message': 'Assembling <(RULE_INPUT_PATH) to <(INTERMEDIATE_DIR)/<(RULE_INPUT_ROOT).obj.',
                }
              ]
            }],
            ['OS=="win" and target_arch=="x64"', {
              'defines': [
                'OPENSSL_BN_ASM_MONT5',
                'OPENSSL_BN_ASM_GF2m',
                'OPENSSL_IA32_SSE2',
                'BSAES_ASM',
              ],
              'sources': [
                'asm/x64-win32-masm/aes/aes-x86_64.asm',
                'asm/x64-win32-masm/aes/aesni-x86_64.asm',
                'asm/x64-win32-masm/aes/vpaes-x86_64.asm',
                'asm/x64-win32-masm/aes/bsaes-x86_64.asm',
                'asm/x64-win32-masm/aes/aesni-sha1-x86_64.asm',
                'asm/x64-win32-masm/bn/modexp512-x86_64.asm',
                'asm/x64-win32-masm/bn/x86_64-mont.asm',
                'asm/x64-win32-masm/bn/x86_64-mont5.asm',
                'asm/x64-win32-masm/bn/x86_64-gf2m.asm',
                'asm/x64-win32-masm/camellia/cmll-x86_64.asm',
                'asm/x64-win32-masm/md5/md5-x86_64.asm',
                'asm/x64-win32-masm/rc4/rc4-x86_64.asm',
                'asm/x64-win32-masm/rc4/rc4-md5-x86_64.asm',
                'asm/x64-win32-masm/sha/sha1-x86_64.asm',
                'asm/x64-win32-masm/sha/sha256-x86_64.asm',
                'asm/x64-win32-masm/sha/sha512-x86_64.asm',
                'asm/x64-win32-masm/whrlpool/wp-x86_64.asm',
                'asm/x64-win32-masm/modes/ghash-x86_64.asm',
                'asm/x64-win32-masm/x86_64cpuid.asm',
                # No asm available
                'openssl/crypto/bn/bn_asm.c',
                'openssl/crypto/bf/bf_enc.c',
                'openssl/crypto/cast/c_enc.c',
                'openssl/crypto/camellia/cmll_misc.c',
                'openssl/crypto/des/des_enc.c',
                'openssl/crypto/des/fcrypt_b.c'
              ],
              'rules': [
                {
                  'rule_name': 'Assemble',
                  'extension': 'asm',
                  'inputs': [],
                  'outputs': [
                    '<(INTERMEDIATE_DIR)/<(RULE_INPUT_ROOT).obj',
                  ],
                  'action': [
                    'ml64.exe',
                    '/Zi',
                    '/Fo', '<(INTERMEDIATE_DIR)/<(RULE_INPUT_ROOT).obj',
                    '/c', '<(RULE_INPUT_PATH)',
                  ],
                  'process_outputs_as_sources': 0,
                  'message': 'Assembling <(RULE_INPUT_PATH) to <(INTERMEDIATE_DIR)/<(RULE_INPUT_ROOT).obj.',
                }
              ]
            }]
          ]
        }],
        ['OS=="win"', {
          'link_settings': {
            'libraries': [
              '-lgdi32.lib',
              '-luser32.lib',
            ]
          },
          'defines': [
            'DSO_WIN32',
          ],
        }, {
          'defines': [
            'DSO_DLFCN',
            'HAVE_DLFCN_H'
          ],
        }],
      ],
      'include_dirs': [
        '.',
        'openssl',
        'openssl/crypto',
        'openssl/crypto/asn1',
        'openssl/crypto/evp',
        'openssl/crypto/md2',
        'openssl/crypto/modes',
        'openssl/crypto/store',
        'openssl/include',
      ],
      'direct_dependent_settings': {
        'include_dirs': ['openssl/include'],
      },
    },
    {
      'target_name': 'openssl-cli',
      'type': 'executable',
      'dependencies': [
        'openssl',
      ],
      'defines': [
        'MONOLITH',
      ],
      'sources': [
        'openssl/apps/app_rand.c',
        'openssl/apps/apps.c',
        'openssl/apps/asn1pars.c',
        'openssl/apps/ca.c',
        'openssl/apps/ciphers.c',
        'openssl/apps/cms.c',
        'openssl/apps/crl.c',
        'openssl/apps/crl2p7.c',
        'openssl/apps/dgst.c',
        'openssl/apps/dh.c',
        'openssl/apps/dhparam.c',
        'openssl/apps/dsa.c',
        'openssl/apps/dsaparam.c',
        'openssl/apps/ec.c',
        'openssl/apps/ecparam.c',
        'openssl/apps/enc.c',
        'openssl/apps/engine.c',
        'openssl/apps/errstr.c',
        'openssl/apps/gendh.c',
        'openssl/apps/gendsa.c',
        'openssl/apps/genpkey.c',
        'openssl/apps/genrsa.c',
        'openssl/apps/nseq.c',
        'openssl/apps/ocsp.c',
        'openssl/apps/openssl.c',
        'openssl/apps/passwd.c',
        'openssl/apps/pkcs12.c',
        'openssl/apps/pkcs7.c',
        'openssl/apps/pkcs8.c',
        'openssl/apps/pkey.c',
        'openssl/apps/pkeyparam.c',
        'openssl/apps/pkeyutl.c',
        'openssl/apps/prime.c',
        'openssl/apps/rand.c',
        'openssl/apps/req.c',
        'openssl/apps/rsa.c',
        'openssl/apps/rsautl.c',
        'openssl/apps/s_cb.c',
        'openssl/apps/s_client.c',
        'openssl/apps/s_server.c',
        'openssl/apps/s_socket.c',
        'openssl/apps/s_time.c',
        'openssl/apps/sess_id.c',
        'openssl/apps/smime.c',
        'openssl/apps/speed.c',
        'openssl/apps/spkac.c',
        'openssl/apps/srp.c',
        'openssl/apps/ts.c',
        'openssl/apps/verify.c',
        'openssl/apps/version.c',
        'openssl/apps/x509.c',
      ],
      'conditions': [
        ['OS=="solaris"', {
          'libraries': [
            '-lsocket',
            '-lnsl',
          ]
        }],
        ['OS=="win"', {
          'link_settings': {
            'libraries': [
              '-lws2_32.lib',
              '-lgdi32.lib',
              '-ladvapi32.lib',
              '-lcrypt32.lib',
              '-luser32.lib',
            ],
          },
        }],
        [ 'OS in "linux android"', {
          'link_settings': {
            'libraries': [
              '-ldl',
            ],
          },
        }],
      ]
    }
  ],
  'target_defaults': {
    'include_dirs': [
      '.',
      'openssl',
      'openssl/crypto',
      'openssl/crypto/asn1',
      'openssl/crypto/evp',
      'openssl/crypto/md2',
      'openssl/crypto/modes',
      'openssl/crypto/store',
      'openssl/include',
    ],
    'defines': [
      # No clue what these are for.
      'L_ENDIAN',
      'PURIFY',
      '_REENTRANT',

      # Heartbeat is a TLS extension, that couldn't be turned off or
      # asked to be not advertised. Unfortunately this is unacceptable for
      # Microsoft's IIS, which seems to be ignoring whole ClientHello after
      # seeing this extension.
      'OPENSSL_NO_HEARTBEATS',
    ],
    'conditions': [
      ['OS=="win"', {
        'defines': [
          'MK1MF_BUILD',
          'WIN32_LEAN_AND_MEAN',
          'OPENSSL_SYSNAME_WIN32',
        ],
      }, {
        'defines': [
          # ENGINESDIR must be defined if OPENSSLDIR is.
          'ENGINESDIR="/dev/null"',
          'TERMIOS',
        ],
        'cflags': ['-Wno-missing-field-initializers'],
        'conditions': [
          ['OS=="mac"', {
            'defines': [
              # Set to ubuntu default path for convenience. If necessary,
              # override this at runtime with the SSL_CERT_DIR environment
              # variable.
              'OPENSSLDIR="/System/Library/OpenSSL/"',
            ],
          }, {
            'defines': [
              # Set to ubuntu default path for convenience. If necessary,
              # override this at runtime with the SSL_CERT_DIR environment
              # variable.
              'OPENSSLDIR="/etc/ssl"',
            ],
          }],
        ]
      }],
      ['is_clang==1 or gcc_version>=43', {
        'cflags': ['-Wno-old-style-declaration'],
      }],
      ['OS=="solaris"', {
        'defines': ['__EXTENSIONS__'],
      }],
    ],
  },
}

# Local Variables:
# tab-width:2
# indent-tabs-mode:nil
# End:
# vim: set expandtab tabstop=2 shiftwidth=2:
