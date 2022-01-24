#import <Foundation/Foundation.h>
#import "ThrowNativeErrorScenario.h"

@implementation ThrowNativeErrorScenario

- (void)runWithExtraConfig:(NSString *)extraConfig {
  @throw [[NSException alloc] initWithName:@"NSException" reason:@"ThrowNativeErrorScenario" userInfo:nil];
}

@end
