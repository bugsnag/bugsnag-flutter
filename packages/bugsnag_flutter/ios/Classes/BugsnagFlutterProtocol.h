#import <Foundation/Foundation.h>

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

- (void)addMetadata:(NSDictionary *)arguments;
- (void)clearMetadata:(NSDictionary *)arguments;
- (NSDictionary *)getMetadata:(NSDictionary *)arguments;

- (NSDictionary *)attach:(NSDictionary *)json;

- (void)start:(NSDictionary *)arguments;

- (void)startSession:(NSDictionary *)arguments;
- (void)pauseSession:(NSDictionary *)arguments;
- (NSNumber *)resumeSession:(NSDictionary *)arguments;

- (void)markLaunchCompleted:(NSDictionary *)arguments;
- (NSDictionary *)getLastRunInfo:(NSDictionary *)arguments;

- (NSDictionary *)createEvent:(NSDictionary *)json;
- (void)deliverEvent:(NSDictionary *)json;

- (NSString * _Nullable)setGroupingDiscriminator:(NSDictionary *)arguments;
- (NSString * _Nullable)getGroupingDiscriminator:(NSDictionary *)arguments;

@end
