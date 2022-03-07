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
    
    if([@"getCommand" isEqualToString:call.method]) {
        result([self getCommand]);
    } else if([@"runScenario" isEqualToString:call.method]) {
        NSString *scenarioName = call.arguments[@"scenarioName"];
        NSString *extraConfig = call.arguments[@"extraConfig"];
        Scenario *targetScenario = [Scenario createScenarioNamed:scenarioName];
        
        if(targetScenario == nil) {
            result([FlutterError errorWithCode:@"NoSuchScenario"
                                       message:scenarioName
                                       details:nil]);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [targetScenario runWithExtraConfig:extraConfig];
                result(nil);
            });
        }
    } else if([@"startBugsnag" isEqualToString:call.method]) {
        [Bugsnag start];
        result(nil);
    }
}


-(NSString *)getCommand {
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://bs-local.com:9339/command"]];
    NSURL *url = [NSURL URLWithString:@"http://bs-local.com:9339/command"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (![response isKindOfClass:[NSHTTPURLResponse class]] || [(NSHTTPURLResponse *)response statusCode] != 200) {
//            NSLog(@"%s request failed with %@", __PRETTY_FUNCTION__, response ?: error);
//            return @"{}";
//        }
//        NSString *command = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        return command;
//    }] resume];

    return ret;
}

@end
