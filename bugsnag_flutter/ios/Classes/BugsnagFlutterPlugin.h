#import <Flutter/Flutter.h>

@interface BugsnagFlutterPlugin : NSObject<FlutterPlugin>

@property (nonatomic) NSSet<NSString *> *availableFunctions;

- (void)setUser:(NSDictionary *)json;
- (NSDictionary *)getUser:(NSDictionary *)json;
- (void)setContext:(NSDictionary *)json;
- (NSString *)getContext:(NSDictionary *)json;
- (void)attach:(NSDictionary *)json;

@end
