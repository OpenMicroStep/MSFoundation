
FoundationExtern NSString* const NSDefaultRunLoopMode;
FoundationExtern NSString* const NSRunLoopCommonModes;

@interface NSRunLoop : NSObject {
@private
	void *_uv_loop;
}

+ (NSRunLoop *)currentRunLoop;
- (void)addTimer:(NSTimer *)aTimer forMode:(NSString *)mode;
- (void)run;
- (BOOL)runMode:(NSString *)mode beforeDate:(NSDate *)limitDate;
- (void)runUntilDate:(NSDate *)limitDate;
- (void)acceptInputForMode:(NSString *)mode beforeDate:(NSDate *)limitDate;
- (void)performSelector:(SEL)aSelector
                 target:(id)target
               argument:(id)anArgument
                  order:(NSUInteger)order
                  modes:(NSArray *)modes;
- (void)cancelPerformSelector:(SEL)aSelector
                       target:(id)target
                     argument:(id)anArgument;
- (void)cancelPerformSelectorsWithTarget:(id)target;
@end