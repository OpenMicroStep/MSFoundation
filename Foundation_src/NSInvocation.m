#import "FoundationCompatibility_Private.h"
#include <ffi/ffi.h> // we include this messy header only here to prevent leaking bad stuff to others
#include <ctype.h>
#include <sys/mman.h>

MS_DECLARE_THREAD_LOCAL(__forward_slot, free);

static IMP ms_objc_msg_forward2(id receiver, SEL _cmd);
static struct objc_slot *ms_objc_msg_forward3(id receiver, SEL _cmd);


static inline void alloc_ffi_type(ffi_type **typep, int elements)
{
  ffi_type *type= *typep;
  if (type && *(int*)(type + 1) < elements)
    return;
  elements= MSCapacityForCount(elements);
  type = MSRealloc(type, sizeof(ffi_type) + sizeof(int) + elements * sizeof(ffi_type*), "alloc_ffi_type permanent");
  type->elements= (ffi_type **)(((uint8_t*)type) + sizeof(ffi_type) + sizeof(int));
  *typep= type;
}

size_t sizeof_ffi_type(ffi_type * type)
{
  size_t size= 0; ffi_type **elements;
  if (type) {
    size= type->size;
    elements= type->elements;
    if (elements) {
      while (*elements) {
        size += sizeof_ffi_type(*elements);
        ++elements;
      }
    }
  }
  return size;
}

static ffi_type *objc_type_to_ffi_type(const char **typep, int level)
{
  const char *type= *typep;
  ffi_type *ret= NULL;

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
      objc_type_to_ffi_type(&type, -1); // consume a type
      break;

    case _C_ARY_B : {
      ffi_type *arrtype; int nb= 0;
      while ('0' <= *type && *type <= '9') {
        nb= nb * 10 + (*type - '0');
        ++type; // consume the count
      }
      if (level > 0) {
        alloc_ffi_type(&ret, nb + 1);
        arrtype= objc_type_to_ffi_type(&type, -1);    // consume the type
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
        objc_type_to_ffi_type(&type, -1);
      }
      if (max_align > 0 && level != -1) {
        alloc_ffi_type(&ret, 2);
        ret->type= FFI_TYPE_STRUCT;
        ret->size= 0;
        ret->alignment= 0;
        ret->elements[0]= objc_type_to_ffi_type(&max_type, level + 1);
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
        alloc_ffi_type(&ret, 4);
        while (*type != _C_STRUCT_E) {
          alloc_ffi_type(&ret, i + 2); // count + nil terminaison
          ret->elements[i++] = objc_type_to_ffi_type(&type, level + 1);
        }
        ret->elements[i]= NULL;
        ret->type= FFI_TYPE_STRUCT;
        ret->size= 0;
        ret->alignment= 0;
      }
      else {
        while (*type != _C_STRUCT_E)
          objc_type_to_ffi_type(&type, -1); // consume the types
      }
      break;
    }
  }
  while(*type == '+' || *type == '-' || isdigit(*type))
    ++type;
  *typep= type;
  return ret;
}

ffi_type **ffi_types_from_signature(NSMethodSignature *sig)
{
  ffi_type **types;
  static mtx_t cache_mutex;
  static CDictionary *cached;
  id uniq_id= [sig _uniqid];
  if (!cached) {
    mtx_init(&cache_mutex, mtx_plain);
    cached= CCreateDictionaryWithOptions(0, CDictionaryObject, CDictionaryPointer);
  }
  mtx_lock(&cache_mutex);
  types= (ffi_type**)CDictionaryObjectForKey(cached, uniq_id);
  mtx_unlock(&cache_mutex);
  if (!types) {
    NSUInteger argi, argc= [sig numberOfArguments]; const char *type;
    types= MSMalloc((argc + 1) * sizeof(ffi_type), "ffi_types_from_signature permanent");
    type= [sig methodReturnType];
    types[0]= objc_type_to_ffi_type(&type, 0);
    for (argi= 0; argi < argc; ++argi) {
      type= [sig getArgumentTypeAtIndex:argi];
      types[argi + 1]= objc_type_to_ffi_type(&type, 0);
    }

    mtx_lock(&cache_mutex);
    CDictionarySetObjectForKey(cached, (id)types, uniq_id);
    mtx_unlock(&cache_mutex);
  }
  return types;
}


@implementation NSInvocation {
@protected
  NSMethodSignature *_signature;
  BOOL _retained;
  NSUInteger _argc;
  uint8_t *_frame;
  ffi_type **_types;
}

+ (void)load
{
  __objc_msg_forward3= ms_objc_msg_forward3;
  __objc_msg_forward2= ms_objc_msg_forward2;
}

static inline size_t _argumentSize(uint8_t *frame, NSUInteger idx)
{
  return ((size_t *)frame)[idx * 2 + 1];
}
static inline size_t _argumentOffset(uint8_t *frame, NSUInteger idx)
{
  return ((size_t *)frame)[idx * 2];
}
static inline void* _argumentData(uint8_t *frame, NSUInteger idx)
{
  return frame + _argumentOffset(frame, idx);
}

+ (NSInvocation *)invocationWithMethodSignature:(NSMethodSignature *)signature
{
  return AUTORELEASE([ALLOC(self) initWithMethodSignature:signature]);
}
- (instancetype)initWithMethodSignature:(NSMethodSignature *)signature
{
  _types= ffi_types_from_signature(signature);
  if (!_types)
    DESTROY(self);
  else {
    NSUInteger argc= [signature numberOfArguments], argi, argsz;
    size_t offset=0, info[(argc + 1) * 2];

    offset= sizeof(info);
    info[0]= offset;
    offset+= info[1]= sizeof_ffi_type(_types[0]);
    for(argi= 1; argi <= argc; argi++) {
      info[argi * 2]= offset;
      offset+= info[argi * 2 + 1]= sizeof_ffi_type(_types[argi]);
    }

    _signature= [signature retain];
    _argc= argc;
    _frame= (uint8_t*)MSCalloc(1, offset, "NSInvocation._frame");
    memcpy(_frame, info, sizeof(info));
  }
  return self;
}
- (void)dealloc
{
  if (_retained) {
    if (strcmp(@encode(id), [_signature methodReturnType]) == 0)
      [*(id *)_argumentData(_frame, 0) release];
    for (NSUInteger i= 0; i < _argc; ++i) {
      if (strcmp(@encode(id), [_signature getArgumentTypeAtIndex:i]) == 0)
        [*(id *)_argumentData(_frame, i + 1) release];
    }
  }
  [_signature release];
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
      [*(id *)_argumentData(_frame, 0) retain];
    for (NSUInteger i= 0; i < _argc; ++i) {
      if (strcmp(@encode(id), [_signature getArgumentTypeAtIndex:i]) == 0)
        [*(id *)_argumentData(_frame, i + 1) retain];
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
  if ((sz= _argumentSize(_frame, index + 1)) > 0)
    memcpy(buffer, _argumentData(_frame, index + 1), sz);
}
- (void)setArgument:(void *)buffer atIndex:(NSInteger)index
{
  size_t sz;
  if ((sz= _argumentSize(_frame, index + 1)) > 0)
    memcpy(_argumentData(_frame, index + 1), buffer, sz);
}

- (void)getReturnValue:(void *)buffer
{
  size_t sz;
  if ((sz= _argumentSize(_frame, 0)) > 0)
    memcpy(buffer, _argumentData(_frame, 0), sz);
}
- (void)setReturnValue:(void *)buffer
{
  size_t sz;
  if ((sz= _argumentSize(_frame, 0)) > 0)
    memcpy(_argumentData(_frame, 0), buffer, sz);
}

- (void)invoke
{
  IMP imp; id target; SEL sel;
  if ((target= [self target])) {
    sel= [self selector];
    imp= LOOKUP(ISA(target), sel);
    if (imp) {
      ffi_cif cif;
      ffi_status status;

      status= ffi_prep_cif(&cif, FFI_DEFAULT_ABI, _argc, _types[0], _types + 1);
      if (status == FFI_OK) {
        NSUInteger i;
        void *arg_values[_argc];
        for (i= 0; i < _argc; ++i)
          arg_values[i]= _argumentData(_frame, i + 1);
        ffi_call(&cif, FFI_FN(imp), _argumentData(_frame, 0), arg_values);
      }
    }
  }
  else {
    // If no target, return is memory set to 0
    size_t sz;
    if ((sz= _argumentSize(_frame, 0)) > 0)
      memset(_argumentData(_frame, 0), 0, sz);
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
  ffi_cif cif;
  ffi_type **types;
  ffi_status status;

  types= ffi_types_from_signature(_signature);

  if ((_closure = mmap(NULL, sizeof(ffi_closure), PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0)) == (void*)-1)
    ;// TODO: Report the error
  if ((status= ffi_prep_cif(&cif, FFI_DEFAULT_ABI, _argc, types[0], types + 1)) != FFI_OK)
    ;// TODO: Report the error
  if ((status= ffi_prep_closure(_closure, &cif, nsinvocation_closure, self)) != FFI_OK)
    ;// TODO: Report the error
  if (mprotect(_closure, sizeof(ffi_closure), PROT_READ | PROT_EXEC) == -1)
    ;// TODO: Report the error
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
  [NSException raise:NSInvalidArgumentException format:@"-[%s %s]: unrecognized selector sent to instance %p",
    class_getName(ISA(receiver)), sel_getName(_cmd), receiver];
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
