NAME = MSSQLiteAdaptor

PROJECT_TYPE = Component
MAKEFILE = subproj.make

HFILES = MSSQLiteConnection.h MSSQLiteResultSet.h MSSQLiteTransaction.h

MFILES = MSSQLiteConnection.m MSSQLiteResultSet.m MSSQLiteTransaction.m

PUBLIC_HEADERS = MSSQLiteConnection.h MSSQLiteResultSet.h MSSQLiteTransaction.h

HEADER_PATHS = -I../../MSCore_src -I../../MSCore_src/MAPM_src -I../../MSFoundation_Basics_src -I../../MSFoundation_src -I../MSSQLCipherAdaptor/sqlcipher

include $(MAKEFILEDIR)/platform.make
include $(MAKEFILEDIR)/$(MAKEFILE)
