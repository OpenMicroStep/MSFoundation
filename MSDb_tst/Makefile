NAME = MSDb_tst

PROJECT_TYPE = Component
MAKEFILE = subproj.make

HFILES = msdb_validate.h

MFILES = msdb_obi_validate.m msdb_repository_validate.m msdb_test.m

PUBLIC_HEADERS = msdb_validate.h

HEADER_PATHS = -I../MHMessenger_src -I../MHRepositoryServer_src -I../MSCore_src -I../MSCore_src/MAPM_src -I../MSCore_tst -I../MSDb_src -I../MSFoundation_Basics_src -I../MSFoundation_src -I../MSFoundation_tst -I../MSNet_src -I../MSNet_src/Crypto_src -I../MS_src

include $(MAKEFILEDIR)/platform.make
include $(MAKEFILEDIR)/$(MAKEFILE)
