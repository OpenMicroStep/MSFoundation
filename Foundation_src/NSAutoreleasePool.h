
@interface NSAutoreleasePool : NSObject {
@private
    NSAutoreleasePool *_parent;
    void *_objects;
}

+(void)addObject:(id)object;

-(void)addObject:(id)object;
-(void)drain;
@end
