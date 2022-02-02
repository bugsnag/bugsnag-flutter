#import <Foundation/Foundation.h>
#import "NativeCrashScenario.h"

@implementation NativeCrashScenario

- (void)runWithExtraConfig:(NSString *)extraConfig {
  @throw [[NSException alloc] initWithName:@"NSException" reason:@"NativeCrashScenario" userInfo:nil];
}

@end
