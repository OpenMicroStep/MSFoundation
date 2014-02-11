NAME = MSCore_src

PROJECT_TYPE = Component
MAKEFILE = subproj.make

SUBPROJECTS = MAPM_src

HFILES = MSCore_Private.h MSCoreIncludes.h MSCoreTypes.h MSCoreSystem.h\
         MSCoreTools.h MSCObject.h MSCArray.h MSCBuffer.h MSCColor.h\
         MSCCouple.h MSCDate.h MSCDecimal.h MSCDictionary.h\
         MSCoreUnichar_Private.c.h MSCoreUnichar.h MSCoreSES.h MSCString.h

CFILES = MSCoreSystem.c MSCoreTools.c MSCoreToolsCompress.c\
         MSCObject.c MSCArray.c MSCBuffer.c MSCColor.c\
         MSCCouple.c MSCDate.c MSCDecimal.c MSCDictionary.c\
         MSCoreUnichar.c MSCoreSES.c MSCString.c

HEADER_PATHS = -IMAPM_src

include $(MAKEFILEDIR)/platform.make
include $(MAKEFILEDIR)/$(MAKEFILE)
