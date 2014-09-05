NAME = MSCore_tst

PROJECT_TYPE = Component
MAKEFILE = subproj.make

SUBPROJECTS = MAPM_tst

HFILES = mscore_validate.h

CFILES = mscore_c_validate.c mscore_carray_validate.c mscore_cbuffer_validate.c mscore_ccolor_validate.c mscore_ccouple_validate.c mscore_cdate_validate.c mscore_cdecimal_validate.c mscore_cdictionary_validate.c mscore_cstring_validate.c mscore_mste_validate.c mscore_tools_validate.c

PUBLIC_HEADERS = mscore_validate.h

HEADER_PATHS = -I../MSCore_src -I../MSCore_src/MAPM_src

include $(MAKEFILEDIR)/platform.make
include $(MAKEFILEDIR)/$(MAKEFILE)
