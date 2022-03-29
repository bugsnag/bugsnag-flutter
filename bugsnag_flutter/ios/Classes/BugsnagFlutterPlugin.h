#import <Flutter/Flutter.h>

/// Declares the methods exposed to Flutter
@protocol BugsnagFlutterProtocol

- (void)setUser:(NSDictionary *)json;
- (NSDictionary *)getUser:(NSDictionary *)json;

- (void)setContext:(NSDictionary *)json;
- (NSString *)getContext:(NSDictionary *)json;

- (void)leaveBreadcrumb:(NSDictionary *)arguments;
- (NSArray<NSDictionary *> *)getBreadcrumbs:(NSDictionary *)arguments;

- (void)addFeatureFlags:(NSDictionary *)json;

- (NSNumber *)attach:(NSDictionary *)json;

- (void)start:(NSDictionary *)arguments;

- (NSDictionary *)createEvent:(NSDictionary *)json;
- (void)deliverEvent:(NSDictionary *)json;

@end

@interface BugsnagFlutterPlugin : NSObject<FlutterPlugin, BugsnagFlutterProtocol>

@property (nonatomic, getter=isAttached) BOOL attached;

@end
