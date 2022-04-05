#import <Flutter/Flutter.h>

/// Declares the methods exposed to Flutter
@protocol BugsnagFlutterProtocol

- (void)setUser:(NSDictionary *)json;
- (NSDictionary *)getUser:(NSDictionary *)json;

- (void)setContext:(NSDictionary *)json;
- (NSString *)getContext:(NSDictionary *)json;

- (void)leaveBreadcrumb:(NSDictionary *)arguments;
- (NSArray<NSDictionary *> *)getBreadcrumbs:(NSDictionary *)arguments;

- (void)addFeatureFlags:(NSArray *)featureFlags;
- (void)clearFeatureFlag:(NSDictionary *)arguments;
- (void)clearFeatureFlags:(NSDictionary *)arguments;

- (void)attach:(NSDictionary *)json;

- (void)start:(NSDictionary *)arguments;

- (void)startSession:(NSDictionary *)arguments;
- (void)pauseSession:(NSDictionary *)arguments;
- (NSNumber *)resumeSession:(NSDictionary *)arguments;

- (void)markLaunchComplete:(NSDictionary *)arguments;
- (NSDictionary *)getLastRunInfo:(NSDictionary *)arguments;

- (NSDictionary *)createEvent:(NSDictionary *)json;
- (void)deliverEvent:(NSDictionary *)json;

@end

@interface BugsnagFlutterPlugin : NSObject<FlutterPlugin, BugsnagFlutterProtocol>

@end
