#import <Flutter/Flutter.h>

/// Declares the methods exposed to Flutter
@protocol BugsnagFlutterProtocol

- (void)setUser:(NSDictionary *)json;
- (NSDictionary *)getUser:(NSDictionary *)json;
- (void)setContext:(NSDictionary *)json;
- (NSString *)getContext:(NSDictionary *)json;
- (void)attach:(NSDictionary *)json;

@end

@interface BugsnagFlutterPlugin : NSObject<FlutterPlugin, BugsnagFlutterProtocol>

@end
