/* MSNodeWrapper.h

 This file is is a part of the MicroStep Framework.

 Initial copyright Herve MALAINGRE and Eric BARADAT (1996)
 Contribution from LOGITUD Solutions (logitud@logitud.fr) since 2011

 Herve Malaingre : herve@malaingre.com
 Jean-Michel Bertheas :  jean-michel.bertheas@club-internet.fr

 This software is a computer program whose purpose is to [describe
 functionalities and technical features of your software].

 This software is governed by the CeCILL-C license under French law and
 abiding by the rules of distribution of free software.  You can  use,
 modify and/ or redistribute the software under the terms of the CeCILL-C
 license as circulated by CEA, CNRS and INRIA at the following URL
 "http://www.cecill.info".

 As a counterpart to the access to the source code and  rights to copy,
 modify and redistribute granted by the license, users are provided only
 with a limited warranty  and the software's author,  the holder of the
 economic rights,  and the successive licensors  have only  limited
 liability.

 In this respect, the user's attention is drawn to the risks associated
 with loading,  using,  modifying and/or developing or reproducing the
 software by the user in light of its specific status of free software,
 that may mean  that it is complicated to manipulate,  and  that  also
 therefore means  that it is reserved for developers  and  experienced
 professionals having in-depth computer knowledge. Users are therefore
 encouraged to load and test the software's suitability as regards their
 requirements in conditions enabling the security of their systems and/or
 data to be ensured and,  more generally, to use and operate it in the
 same conditions as regards security.

 The fact that you are presently reading this means that you have had
 knowledge of the CeCILL-C license and that you accept its terms.

 WARNING : outside the MSFoundation framework or the MSCore library,
 this header file cannot be included alone, please direclty include
 MSCore.h or MSFoundation.h
 */

typedef void (*nodejs_callback_t)(id self, const v8::FunctionCallbackInfo<v8::Value> &args);

static inline void *nodejs_persistent_new(v8::Isolate *isolate, v8::Local<v8::Object> v)
{
  return new v8::Persistent<v8::Object>(isolate, v);
}
static inline v8::Local<v8::Object> nodejs_persistent_value(v8::Isolate *isolate, void *pobject)
{
  return v8::Local<v8::Object>::New(isolate, *(v8::Persistent<v8::Object>*)pobject);
}
static inline void nodejs_persistent_delete(void * &pobject)
{
  v8::Persistent<v8::Object> *p= (v8::Persistent<v8::Object>*)pobject;
  if (p) {
    p->Reset();
    delete p;
  }
  pobject= NULL;
}
id nodejs_get(v8::Isolate *isolate, void *pobject, const char *attrname);
id nodejs_to_objc(v8::Isolate *isolate, v8::Local<v8::Value> v);
v8::Local<v8::Object> nodejs_require(const char *module);
v8::Local<v8::Function> nodejs_method(v8::Isolate *isolate, v8::Local<v8::Object> object, const char *methodname);
v8::Local<v8::Value> nodejs_call_with_ids(v8::Isolate *isolate, v8::Local<v8::Object> object, const char *methodname, ...);
v8::Local<v8::Value> nodejs_call(v8::Isolate *isolate, v8::Local<v8::Object> object, const char *methodname, int nbargs = 0, v8::Local<v8::Value> *args = NULL);
v8::Local<v8::Value> nodejs_call_with_ids(v8::Isolate *isolate, void* object, const char *methodname, ...);
v8::Local<v8::Value> nodejs_call(v8::Isolate *isolate, void* object, const char *methodname, int nbargs = 0, v8::Local<v8::Value> *args = NULL);
v8::Local<v8::Function> nodejs_callback(v8::Isolate* isolate, id object, nodejs_callback_t cb);

@protocol V8ObjectInterface
- (v8::Local<v8::Value>)toV8:(v8::Isolate *)isolate;

@optional
- (instancetype)initWithV8:(v8::Local<v8::Value>)value isolate:(v8::Isolate *)isolate;
@end

@interface V8String : NSString <V8ObjectInterface> {
  v8::Persistent<v8::String> _handle;
}

- (NSUInteger)length;
- (unichar)characterAtIndex:(NSUInteger)index;
@end

@interface V8Buffer : NSData <V8ObjectInterface> {
  v8::Persistent<v8::Object> _handle;
}

- (NSUInteger)length;
- (const void *)bytes;
@end

@interface V8Dictionary : NSMutableDictionary <V8ObjectInterface> {
  v8::Persistent<v8::Object> _handle;
}

- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;
- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;
@end


@interface V8Array : NSMutableArray <V8ObjectInterface> {
  v8::Persistent<v8::Array> _handle;
}

- (NSUInteger) count;
- (id)objectAtIndex:(NSUInteger)index;
- (void)addObject:(id)anObject;
@end

@interface NSString (V8Conversion) <V8ObjectInterface>
@end

@interface NSData (V8Conversion) <V8ObjectInterface>
@end

@interface NSDictionary (V8Conversion) <V8ObjectInterface>
@end

@interface NSArray (V8Conversion) <V8ObjectInterface>
@end

@interface NSNumber (V8Conversion) <V8ObjectInterface>
@end
