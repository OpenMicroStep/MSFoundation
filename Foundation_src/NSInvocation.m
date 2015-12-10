#import "FoundationCompatibility_Private.h"
#include <ffi.h> // we include this messy header only here to prevent leaking bad stuff to others
#include <ctype.h>
#include "mman.h"

MS_DECLARE_THREAD_LOCAL(__forward_slot, free);

static IMP ms_objc_msg_forward2(id receiver, SEL _cmd);
static struct objc_slot *ms_objc_msg_forward3(id receiver, SEL _cmd);
static void ms_objc_unexpected_exception(id exception);

struct ffi_type_list {
  struct ffi_type_list *prev;
  struct ffi_type_list *next;
  ffi_type type;
  int size;
  ffi_type *elements[0];
};

struct ffi_types_list {
  struct ffi_types_list *prev;
  struct ffi_types_list *next;
  ffi_type *types[0];
};

static ffi_type *objc_type_to_ffi_type(const char **typep, int level, void **allocs);

static inline void append_tolist(void *ptr, void **allocs) {
  struct ffi_type_list *prev= *allocs;
  if (prev)
    prev->next= ptr;
  ((struct ffi_type_list *)ptr)->prev= prev;
  ((struct ffi_type_list *)ptr)->next= NULL;
  *allocs= ptr;
}

static inline void remove_fromlist(void *ptr, void **allocs) {
  if (ptr) {
    struct ffi_type_list *t= (struct ffi_type_list *)ptr;
    if (t->next)
      t->next->prev= t->prev;
    if (t->prev)
      t->prev->next= t->next;
    if (*allocs == t)
      *allocs= t->prev;
  }
}

static inline void free_allocs(void *allocs) {
  void *tmp;
  while (allocs) {
    tmp= ((struct ffi_types_list *)allocs)->prev;
    free(allocs);
    allocs= tmp;
  }
}

static inline ffi_type* alloc_ffi_type(void **alloc, int elements, void **allocs)
{
  struct ffi_type_list *t= (struct ffi_type_list *)*alloc;
  if (t && t->size < elements)
    return &t->type;
  elements= MSCapacityForCount(elements);
  remove_fromlist(t, allocs);
  t = MSRealloc(t, sizeof(struct ffi_type_list) + elements * sizeof(ffi_type*), "alloc_ffi_type permanent");
  append_tolist(t, allocs);
  t->size= elements;
  t->type.elements= t->elements;
  *alloc= t;
  return &t->type;
}

static ffi_type **ffi_types_from_signature(NSMethodSignature *sig, void ** allocs)
{
  struct ffi_types_list *t;
  NSUInteger argi, argc= [sig numberOfArguments]; const char *type;

  t= MSMalloc(sizeof(struct ffi_types_list) + (argc + 1) * sizeof(ffi_type*), "ffi_types_and_sizes_from_signature permanent");
  append_tolist(t, allocs);
  type= [sig methodReturnType];
  t->types[0]= objc_type_to_ffi_type(&type, 0, allocs);
  for (argi= 0; argi < argc; ++argi) {
    type= [sig getArgumentTypeAtIndex:argi];
    t->types[argi + 1]= objc_type_to_ffi_type(&type, 0, allocs);
  }

  return t->types;
}

static ffi_type *objc_type_to_ffi_type(const char **typep, int level, void **allocs)
{
  const char *type= *typep;
  ffi_type *ret= NULL; void *alloc= NULL;

  type= objc_skip_type_qualifiers(type);
  switch(*type++) {
    case _C_ID      : ret= &ffi_type_pointer;    break;
    case _C_CLASS   : ret= &ffi_type_pointer;    break;
    case _C_SEL     : ret= &ffi_type_pointer;    break;
    case _C_CHARPTR : ret= &ffi_type_pointer;    break;
    case _C_ATOM    : ret= &ffi_type_pointer;    break;
    case _C_BOOL    : ret= &ffi_type_uchar;      break;

    case _C_CHR     : ret= &ffi_type_schar;      break;
    case _C_UCHR    : ret= &ffi_type_uchar;      break;
    case _C_SHT     : ret= &ffi_type_sshort;     break;
    case _C_USHT    : ret= &ffi_type_ushort;     break;
    case _C_INT     : ret= &ffi_type_sint;       break;
    case _C_UINT    : ret= &ffi_type_uint;       break;
    case _C_LNG     : ret= &ffi_type_slong;      break;
    case _C_ULNG    : ret= &ffi_type_ulong;      break;
    case _C_LNG_LNG : ret= &ffi_type_sint64;     break;
    case _C_ULNG_LNG: ret= &ffi_type_uint64;     break;

    case _C_FLT     : ret= &ffi_type_float;      break;
    case _C_DBL     : ret= &ffi_type_double;     break;

    case _C_VOID    : ret= &ffi_type_void;       break;

    case _C_PTR     :
      ret= &ffi_type_pointer;
      objc_type_to_ffi_type(&type, -1, allocs); // consume a type
      break;

    case _C_ARY_B : {
      ffi_type *arrtype; int nb= 0;
      while ('0' <= *type && *type <= '9') {
        nb= nb * 10 + (*type - '0');
        ++type; // consume the count
      }
      if (level > 0) {
        ret= alloc_ffi_type(&alloc, nb + 1, allocs);
        arrtype= objc_type_to_ffi_type(&type, -1, allocs);    // consume the type
        ret->type= FFI_TYPE_STRUCT;
        ret->size= 0;
        ret->alignment= 0;
        ret->elements[nb] = NULL;
        while (nb > 0)
          ret->elements[--nb]= arrtype;
      }
      else {
        ret= &ffi_type_pointer;
      }
      ++type; // consume end of array
      break;
    }

    case _C_UNION_B : {
      size_t max_align= 0, align; const char *max_type;
      while (*type != _C_UNION_E && *type != '=') ++type; // consume the name
      if (*type == '=') ++type;
      while (*type != _C_UNION_E) {
        align= objc_alignof_type(type);
        if (align > max_align) {
          max_type= type;
          max_align= align;
        }
        objc_type_to_ffi_type(&type, -1, allocs);
      }
      if (max_align > 0 && level != -1) {
        ret= alloc_ffi_type(&alloc, 2, allocs);
        ret->type= FFI_TYPE_STRUCT;
        ret->size= 0;
        ret->alignment= 0;
        ret->elements[0]= objc_type_to_ffi_type(&max_type, level + 1, allocs);
        ret->elements[1]= NULL;
      }
      ++type; // consume end of union
      break;
    }

    case _C_STRUCT_B: {
      int i= 0;
      while (*type != _C_STRUCT_E && *type != '=') ++type; // consume the name
      if (*type == '=') ++type;
      if (level != -1) {
        ret= alloc_ffi_type(&alloc, 4, allocs);
        while (*type != _C_STRUCT_E) {
          ret= alloc_ffi_type(&alloc, i + 2, allocs); // count + nil terminaison
          ret->elements[i++] = objc_type_to_ffi_type(&type, level + 1, allocs);
        }
        ret->elements[i]= NULL;
        ret->type= FFI_TYPE_STRUCT;
        ret->size= 0;
        ret->alignment= 0;
      }
      else {
        while (*type != _C_STRUCT_E)
          objc_type_to_ffi_type(&type, -1, allocs); // consume the types
      }
      break;
    }
  }
  while(*type == '+' || *type == '-' || isdigit(*type))
    ++type;
  *typep= type;
  return ret;
}


@implementation NSInvocation {
@protected
  NSMethodSignature *_signature;
  BOOL _retained;
  NSUInteger _argc;
  uint8_t *_frame;
  ffi_cif _cif;
  ffi_type **_types;
  void *_allocs;
}

+ (void)load
{
  __objc_msg_forward3= ms_objc_msg_forward3;
  __objc_msg_forward2= ms_objc_msg_forward2;
  _objc_unexpected_exception= ms_objc_unexpected_exception;
}

static inline size_t _argumentSize(NSInvocation *self, NSUInteger idx)
{
  //printf("size %d is %d\n", (int)idx, (int)self->_types[idx]->size);
  return self->_types[idx]->size;
}
static inline void* _argumentData(NSInvocation *self, NSUInteger idx)
{
  //printf("data %d at %p\n", (int)idx, ((void**)self->_frame)[idx]);
  return ((void**)self->_frame)[idx];
}

+ (NSInvocation *)invocationWithMethodSignature:(NSMethodSignature *)signature
{
  return AUTORELEASE([ALLOC(self) initWithMethodSignature:signature]);
}
- (instancetype)initWithMethodSignature:(NSMethodSignature *)signature
{
  NSUInteger argc= [signature numberOfArguments];
  ffi_type **types= ffi_types_from_signature(signature, &_allocs);
  if (!types || ffi_prep_cif(&_cif, FFI_DEFAULT_ABI, argc, types[0], types + 1) != FFI_OK)
    DESTROY(self);
  else {
    size_t offset=0, info[argc + 1]; void ** addrs; uint8_t* values; NSUInteger argi;

    offset= 0;
    info[0]= offset;
    offset+= types[0]->size;
    for(argi= 1; argi <= argc; argi++) {
      info[argi]= offset;
      offset+= types[argi]->size;
    }
    _argc= argc;
    _types= types;
    _signature= [signature retain];
    _frame= (uint8_t*)MSCalloc(1, sizeof(void*) * (argc + 1) + offset, "NSInvocation._frame");
    addrs= (void**)_frame;
    values= (uint8_t*)(addrs + argc + 1);
    for(argi= 0; argi <= argc; argi++) {
      addrs[argi]= values + info[argi];
    }
  }
  return self;
}
- (void)dealloc
{
  if (_retained) {
    if (strcmp(@encode(id), [_signature methodReturnType]) == 0)
      [*(id *)_argumentData(self, 0) release];
    for (NSUInteger i= 0; i < _argc; ++i) {
      if (strcmp(@encode(id), [_signature getArgumentTypeAtIndex:i]) == 0)
        [*(id *)_argumentData(self, i + 1) release];
    }
  }
  [_signature release];
  free_allocs(_allocs);
  MSFree(_frame, "NSInvocation._frame");
  [super dealloc];
}

- (BOOL)argumentsRetained
{
  return _retained;
}

- (void)setArgumentsRetained:(BOOL)argumentsRetained
{
  if (!_retained) {
    if (strcmp(@encode(id), [_signature methodReturnType]) == 0)
      [*(id *)_argumentData(self, 0) retain];
    for (NSUInteger i= 0; i < _argc; ++i) {
      if (strcmp(@encode(id), [_signature getArgumentTypeAtIndex:i]) == 0)
        [*(id *)_argumentData(self, i + 1) retain];
    }
    _retained= YES;
  }
}

- (NSMethodSignature *)methodSignature
{
  return _signature;
}

- (SEL)selector
{
  SEL ret= NULL;
  if (_argc > 1) [self getArgument:&ret atIndex:1];
  return ret;
}
- (void)setSelector:(SEL)selector
{
  [self setArgument:&selector atIndex:1];
}

- (id)target
{
  id ret= nil;
  if (_argc > 0) [self getArgument:&ret atIndex:0];
  return ret;
}

- (void)setTarget:(id)target
{
  [self setArgument:&target atIndex:0];
}

- (void)getArgument:(void *)buffer atIndex:(NSInteger)index
{
  size_t sz;
  if ((sz= _argumentSize(self, index + 1)) > 0)
    memcpy(buffer, _argumentData(self, index + 1), sz);
}
- (void)setArgument:(void *)buffer atIndex:(NSInteger)index
{
  size_t sz;
  if ((sz= _argumentSize(self, index + 1)) > 0)
    memcpy(_argumentData(self, index + 1), buffer, sz);
}

- (void)getReturnValue:(void *)buffer
{
  size_t sz;
  if ((sz= _argumentSize(self, 0)) > 0)
    memcpy(buffer, _argumentData(self, 0), sz);
}
- (void)setReturnValue:(void *)buffer
{
  size_t sz;
  if ((sz= _argumentSize(self, 0)) > 0)
    memcpy(_argumentData(self, 0), buffer, sz);
}

- (void)invoke
{
  IMP imp; id target; SEL sel;
  if ((target= [self target])) {
    sel= [self selector];
    imp= LOOKUP(ISA(target), sel);
    if (imp) {
      ffi_call(&_cif, FFI_FN(imp), _argumentData(self, 0), ((void**)self->_frame) + 1);
    }
    else {
      // TODO: Exception
    }
  }
  else {
    // If no target, return is memory set to 0
    size_t sz;
    if ((sz= _argumentSize(self, 0)) > 0)
      memset(_argumentData(self, 0), 0, sz);
  }
}
- (void)invokeWithTarget:(id)target
{
  [self setTarget:target];
  [self invoke];
}

@end

@interface _NSInvocationExecutableMemory : NSInvocation {
  ffi_closure *_closure;
}
- (IMP)closure;
@end


@implementation _NSInvocationExecutableMemory
static void nsinvocation_closure(ffi_cif* cif, void* result, void** args, void* userdata)
{
  NSUInteger argi, argc;
  _NSInvocationExecutableMemory *self= (_NSInvocationExecutableMemory *)userdata;
  id target= *(id*)args[0];
  SEL sel= *(SEL*)args[1];
  if (![target respondsToSelector:@selector(forwardInvocation:)])
    [NSException raise:NSInvalidArgumentException
                 format:@"NSInvocation: class '%s' does not respond to forwardInvocation: for '%s'",
                 class_getName(ISA(target)), sel_getName(sel)];
  for(argi= 0, argc= self->_argc; argi < argc; ++argi)
    [self setArgument:args[argi] atIndex:argi];
  [target forwardInvocation:self];
  [self getReturnValue:result];
}
- (void)dealloc
{
  munmap(_closure, sizeof(ffi_closure));
  [super dealloc];
}
- (IMP)closure
{
  ffi_status status;

#ifndef WIN32
  if ((_closure = mmap(NULL, sizeof(ffi_closure), PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0)) == (void*)-1)
    ;// TODO: Report the error
#else
  if ((_closure = mmap(NULL, sizeof(ffi_closure), PROT_READ | PROT_WRITE | PROT_EXEC, MAP_ANON | MAP_PRIVATE, -1, 0)) == (void*)-1)
    ;// TODO: Report the error
#endif
  if ((status= ffi_prep_closure(_closure, &_cif, nsinvocation_closure, self)) != FFI_OK)
    ;// TODO: Report the error
#ifndef WIN32
  if (mprotect(_closure, sizeof(ffi_closure), PROT_READ | PROT_EXEC) == -1)
    ;// TODO: Report the error
#endif
  return (IMP)_closure;
}
@end

static IMP ffi_nsinvocation_closure(NSMethodSignature *sig)
{
  id inv;
  inv= AUTORELEASE([ALLOC(_NSInvocationExecutableMemory) initWithMethodSignature:sig]);
  return [inv closure];
}

static IMP ms_objc_msg_forward2(id receiver, SEL _cmd)
{
  NSMethodSignature *sig;
  sig= [receiver methodSignatureForSelector:_cmd];
  if (sig) return ffi_nsinvocation_closure(sig);
  if ([receiver respondsToSelector:@selector(doesNotRecognizeSelector:)])
    [receiver doesNotRecognizeSelector:_cmd];
  [NSException raise:NSInvalidArgumentException format:@"%c[%s %s]: unrecognized selector sent to instance %p",
    class_isMetaClass(ISA(receiver)) ? '+' : '-', class_getName(ISA(receiver)), sel_getName(_cmd), receiver];
  return NULL;
}

static struct objc_slot *ms_objc_msg_forward3(id receiver, SEL _cmd)
{
  struct objc_slot *slot = tss_get(__forward_slot);
  if(!slot) {
    slot= calloc(1, sizeof(struct objc_slot));
    tss_set(__forward_slot, slot);
  }
  slot->method= ms_objc_msg_forward2(receiver, _cmd);
  return slot;
}

static void ms_objc_unexpected_exception(id exception)
{
  NSLog(@"*** Terminating app due to uncaught exception '%@', reason: '%@'", [exception name], [exception reason]);
  abort();
}
