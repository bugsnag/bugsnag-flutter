#import <Flutter/Flutter.h>

/// Declares the methods exposed to Flutter
@protocol BugsnagFlutterProtocol

- (void)setUser:(NSDictionary *)json;
- (NSDictionary *)getUser:(NSDictionary *)json;

- (void)setContext:(NSDictionary *)json;
- (NSString *)getContext:(NSDictionary *)json;

- (void)addFeatureFlags:(NSDictionary *)json;

- (NSNumber *)attach:(NSDictionary *)json;

- (NSDictionary *)createEvent:(NSDictionary *)json;
- (void)deliverEvent:(NSDictionary *)json;

@end

@interface BugsnagFlutterPlugin : NSObject<FlutterPlugin, BugsnagFlutterProtocol>

@property (nonatomic, getter=isAttached) BOOL attached;

@end
