#import <Bugsnag/Bugsnag.h>

#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "Scenarios/Scenario.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];

    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* nativeChannel = [FlutterMethodChannel methodChannelWithName:@"com.bugsnag.mazeRunner/platform"
              binaryMessenger:controller.engine.binaryMessenger
    ];
    
    [nativeChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        [self onMethod :call :result];
    }];

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

-(void)onMethod:(FlutterMethodCall*) call
               :(FlutterResult) result {
    
    if([@"runScenario" isEqualToString:call.method]) {
        NSString *scenarioName = call.arguments[@"scenario"];
        NSString *extraConfig = call.arguments[@"extraConfig"];
        Scenario *targetScenario = [Scenario createScenarioNamed:scenarioName];
        
        if(targetScenario == nil) {
            result([FlutterError errorWithCode:@"NoSuchScenario"
                                       message:scenarioName
                                       details:nil]);
        } else {
            [targetScenario runWithExtraConfig:extraConfig];
            result(nil);
        }
    } else if([@"startBugsnag" isEqualToString:call.method]) {
        [Bugsnag start];
    }
}

@end
