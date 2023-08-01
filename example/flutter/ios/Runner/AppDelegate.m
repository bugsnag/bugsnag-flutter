#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  
  [[FlutterMethodChannel methodChannelWithName:@"com.bugsnag.example/channel" binaryMessenger:
    ((FlutterViewController *)self.window.rootViewController).engine.binaryMessenger]
   setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    if ([call.method isEqualToString:@"fatalAppHang"]) {
      NSParameterAssert(NSThread.isMainThread);
      sleep(3);
      kill(getpid(), SIGKILL);
    }
    if ([call.method isEqualToString:@"oom"]) {
      // This is not a real OOM and future versions of bugsnag-cocoa may stop reporting it.
      kill(getpid(), SIGKILL);
    }
  }];
  
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
