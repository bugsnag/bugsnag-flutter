#import "BugsnagFlutterConfiguration.h"

@implementation BugsnagFlutterConfiguration

static BugsnagFlutterEnabledErrorTypes *enabledErrorTypes;
static NSArray<NSString *> *projectPackages;

+ (void)initialize {
    enabledErrorTypes = [[BugsnagFlutterEnabledErrorTypes alloc] init];
}

+ (BugsnagFlutterEnabledErrorTypes *)enabledErrorTypes {
    return enabledErrorTypes;
}

+ (NSArray<NSString *> *)projectPackages {
    return projectPackages;
}

+ (void)setProjectPackages:(NSArray<NSString *> *)newValue {
    projectPackages = newValue;
}

@end
