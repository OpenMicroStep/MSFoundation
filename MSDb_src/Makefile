NAME = MSDb_src

PROJECT_TYPE = Component
MAKEFILE = subproj.make

HFILES = MSDBConnection.h MSDBGenericConnection.h MSDBOperation.h MSDBResultSet.h MSDBRow.h MSDBTransaction.h MSDatabase.h MSDatabaseWin32.h MSDb_Private.h MSObi.h MSOdb.h MSOid.h

MFILES = MSDBConnection.m MSDBGenericConnection.m MSDBOperation.m MSDBResultSet.m MSDBRow.m MSDBTransaction.m MSObi.m MSOdb.m MSOid.m

PUBLIC_HEADERS = MSDBConnection.h MSDBGenericConnection.h MSDBOperation.h MSDBResultSet.h MSDBRow.h MSDBTransaction.h MSDatabase.h MSDatabaseWin32.h MSObi.h MSOdb.h MSOid.h

HEADER_PATHS = -I../MSCore_src -I../MSCore_src/MAPM_src -I../MSFoundation_Basics_src -I../MSFoundation_src

include $(MAKEFILEDIR)/platform.make
include $(MAKEFILEDIR)/$(MAKEFILE)
