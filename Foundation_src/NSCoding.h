@class NSCoder;

@protocol NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end

@protocol NSSecureCoding <NSCoding>
@required
// This method must be return YES on all classes that allow secure coding. Subclasses of classes that adopt NSSecureCoding and override initWithCoder: must also override this method and return YES.
// The Secure Coding Guide should be consulted when writing methods that decode data.
+ (BOOL)supportsSecureCoding;
@end
