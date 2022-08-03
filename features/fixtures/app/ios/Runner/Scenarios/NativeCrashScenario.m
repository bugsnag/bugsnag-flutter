#import <Foundation/Foundation.h>
#import "NativeCrashScenario.h"

@implementation NativeCrashScenario

- (void)runWithArguments:(NSDictionary *)extraConfig {
  @throw [[NSException alloc] initWithName:@"NSException" reason:@"NativeCrashScenario" userInfo:nil];
}

@end
