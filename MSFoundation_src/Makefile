NAME = MSFoundation_src

PROJECT_TYPE = Component
MAKEFILE = subproj.make

HFILES = MSFoundation_Private.h MSArray_.h MSArray.h MSMutableArray.h\
         MSBuffer.h MSUnicodeBuffer.h

MFILES = MSCObject.m MSArray.m MSMutableArray.m\
         MSBuffer.m MSUnicodeBuffer.m

HEADER_PATHS = -I../MSCore_src -I../MSFoundation_Basics_src

include $(MAKEFILEDIR)/platform.make
include $(MAKEFILEDIR)/$(MAKEFILE)
