
@interface NSThread : NSObject  {
@private
    int32_t _state;
	NSMutableDictionary *_dic;
	id _target;
	SEL _sel;
	id _arg;
}

+ (BOOL)isMultiThreaded;
+ (NSThread *)currentThread;

+ (void)detachNewThreadSelector:(SEL)selector
                       toTarget:(id)target
                     withObject:(id)object;
- (instancetype)init;
- (instancetype)initWithTarget:(id)target
                      selector:(SEL)selector
                        object:(id)object;
- (NSMutableDictionary *)threadDictionary;

- (void)start;
- (void)main;
- (void)cancel;
- (BOOL)executing;
- (BOOL)finished;
- (BOOL)cancelled;

@end
