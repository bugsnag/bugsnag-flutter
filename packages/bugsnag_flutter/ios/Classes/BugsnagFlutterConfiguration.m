#import "BugsnagFlutterConfiguration.h"

@implementation BugsnagFlutterConfiguration

static BugsnagFlutterEnabledErrorTypes *enabledErrorTypes;

+ (void)initialize {
    enabledErrorTypes = [[BugsnagFlutterEnabledErrorTypes alloc] init];
}

+ (BugsnagFlutterEnabledErrorTypes *)enabledErrorTypes {
    return enabledErrorTypes;
}

@end
