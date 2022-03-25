#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

#import <Bugsnag/Bugsnag.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  [Bugsnag start];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
