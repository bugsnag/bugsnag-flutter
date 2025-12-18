#import <Bugsnag/Bugsnag.h>
#import <bugsnag_flutter/BugsnagFlutterConfiguration.h>

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
    NSLog(@"FlutterMethodCallHandler: %@ %@", call.method, call.arguments);
    
    if([@"getCommand" isEqualToString:call.method]) {
        result([self getCommandWithUrl:call.arguments[@"commandUrl"]]);
    } else if([@"runScenario" isEqualToString:call.method]) {
        NSString *scenarioName = call.arguments[@"scenarioName"];
        Scenario *targetScenario = [Scenario createScenarioNamed:scenarioName];
        
        if(targetScenario == nil) {
            result([FlutterError errorWithCode:@"NoSuchScenario"
                                       message:scenarioName
                                       details:nil]);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [targetScenario runWithArguments:call.arguments];
                result(nil);
            });
        }
    } else if([@"startBugsnag" isEqualToString:call.method]) {
        BugsnagConfiguration *config = [BugsnagConfiguration loadConfig];
        config.apiKey = @"abc12312312312312312312312312312";
        
        NSString *notifyEndpoint = call.arguments[@"notifyEndpoint"];
        NSString *sessionEndpoint = call.arguments[@"sessionEndpoint"];
        NSString *extraConfig = call.arguments[@"extraConfig"];
        
        if(notifyEndpoint != nil && sessionEndpoint != nil) {
            config.endpoints = [[BugsnagEndpointConfiguration alloc] initWithNotify:notifyEndpoint
                                                                           sessions:sessionEndpoint];
        }
        
        [Bugsnag startWithConfiguration:config];
        
        if ([extraConfig containsString:@"disableDartErrors"]) {
            BugsnagFlutterConfiguration.enabledErrorTypes.dartErrors = NO;
        }
        
        result(nil);
    } else if ([@"clearPersistentData" isEqual:call.method]) {
        [NSUserDefaults.standardUserDefaults removePersistentDomainForName:NSBundle.mainBundle.bundleIdentifier];
        NSString *appSupportDir = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
        NSString *bugsnagDir = [appSupportDir stringByAppendingPathComponent:@"com.bugsnag.Bugsnag"];
        NSError *error = nil;
        if (![NSFileManager.defaultManager removeItemAtPath:bugsnagDir error:&error]) {
            if (![error.domain isEqualToString:NSCocoaErrorDomain] && error.code != NSFileNoSuchFileError) {
                NSLog(@"%@", error);
            }
        }
        result(nil);
    } else if ([@"appHang" isEqualToString:call.method]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sleep(3);
            result(nil);
        });
    }
}


-(NSString *)getCommandWithUrl:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    return ret;
}

@end
