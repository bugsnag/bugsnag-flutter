#import "Scenario.h"

#import <bugsnag_flutter/BugsnagFlutterConfiguration.h>

@interface NativeProjectPackagesScenario : Scenario

@end

@implementation NativeProjectPackagesScenario

- (void)runWithArguments:(NSDictionary *)arguments {
    BugsnagConfiguration *configuration = [BugsnagConfiguration loadConfig];
    configuration.apiKey = @"abc12312312312312312312312312312";
    configuration.endpoints = [[BugsnagEndpointConfiguration alloc] initWithNotify:arguments[@"notifyEndpoint"]
                                                                          sessions:arguments[@"sessionEndpoint"]];
    [Bugsnag startWithConfiguration:configuration];
    
    BugsnagFlutterConfiguration.projectPackages = @[@"test_package",
                                                    @"MazeRunner",
                                                    @"com.bugsnag.flutter.test.app"];
}

@end
