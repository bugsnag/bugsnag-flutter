#import <objc/runtime.h>

#import "Scenario.h"

@implementation Scenario

+ (Scenario *)createScenarioNamed:(NSString *)className {
    Class class = NSClassFromString(className);

    if (!class) {
        [NSException raise:NSInvalidArgumentException format:@"Failed to find scenario class named %@", className];
    }

    return (Scenario *)[class new];
}

- (instancetype)init {
    return self;
}

- (void)runWithArguments:(NSString *)extraConfig {
    [self doesNotRecognizeSelector:_cmd];
}

@end
