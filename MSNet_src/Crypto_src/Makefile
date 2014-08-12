NAME = Crypto_src

PROJECT_TYPE = Component
MAKEFILE = subproj.make

HFILES = MSCertificate.h MSCipher.h MSDigest.h _MSCipherPrivate.h _MSDigest.h _RSACipher.h _SymmetricCipher.h _SymmetricRSACipher.h

MFILES = MSCertificate.m MSCipher.m MSDigest.m _MSDigest.m _RSACipher.m _SymmetricCipher.m _SymmetricRSACipher.m

PUBLIC_HEADERS = MSCertificate.h MSCipher.h MSDigest.h _MSDigest.h _RSACipher.h _SymmetricCipher.h _SymmetricRSACipher.h

HEADER_PATHS = -I.. -I../../3rdparty/wo451/include -I../../MSCore_src -I../../MSCore_src/MAPM_src -I../../MSFoundation_Basics_src -I../../MSFoundation_src

include $(MAKEFILEDIR)/platform.make
include $(MAKEFILEDIR)/$(MAKEFILE)
