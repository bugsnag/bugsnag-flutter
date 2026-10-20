#import "./include/bugsnag_flutter/BugsnagFlutterEnabledErrorTypes.h"

@implementation BugsnagFlutterEnabledErrorTypes

- (instancetype)init {
    if ((self = [super init])) {
        _dartErrors = YES;
    }
    return self;
}

@end
