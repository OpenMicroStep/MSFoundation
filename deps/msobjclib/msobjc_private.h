#ifndef MSOBJC_PRIVATE_H
#define MSOBJC_PRIVATE_H

#ifndef CONSTANT_STRING_CLASS
# define CONSTANT_STRING_CLASS "NSConstantString"
#endif

#include "MSStd.h"
#include <assert.h>
#include <ctype.h>
#include "objc/runtime.h"
#include "objc/blocks_runtime.h"
#include "objc/capabilities.h"
#include "objc/developer.h"
#include "objc/encoding.h"
#include "objc/hooks.h"
#include "objc/objc-arc.h"
#include "objc/objc-auto.h"
#include "objc/slot.h"

#include "visibility.h"
#include "lock.h"
#include "sarray2.h"
#include "class.h"
#include "category.h"
#include "method_list.h"
#include "module.h"
#include "selector.h"
#include "properties.h"

#include "alias.h"
#include "protocol.h"
#include "blocks_runtime.h"
#include "dtable.h"
#include "gc_ops.h"
#include "ivar.h"
#include "loader.h"
#include "mman.h"
#include "spinlock.h"
#include "string_hash.h"
#include "visibility.h"

#ifdef __OBJC__
#import "nsobject.h"
#else
#include "objc/toydispatch.h"
#endif

#endif // MSOBJC_PRIVATE_H