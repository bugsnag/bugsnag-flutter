#import <objc/runtime.h>

#import "Scenario.h"

@implementation Scenario

+ (Scenario *)createScenarioNamed:(NSString *)className {
    Class clz = NSClassFromString(className);

    NSAssert(clz != nil, @"Failed to find class named '%@'", className);

    BOOL implementsRun = method_getImplementation(class_getInstanceMethod([Scenario class], @selector(runWithExtraConfig))) !=
    method_getImplementation(class_getInstanceMethod(clz, @selector(runWithExtraConfig)));

    NSAssert(implementsRun, @"Class '%@' does not implement the run method", className);

    id obj = [clz alloc];

    NSAssert([obj isKindOfClass:[Scenario class]], @"Class '%@' is not a subclass of Scenario", className);

    return [(Scenario *)obj init];
}

- (instancetype)init {
    return self;
}

- (void)runWithExtraConfig:(NSString *)extraConfig {
}

@end
