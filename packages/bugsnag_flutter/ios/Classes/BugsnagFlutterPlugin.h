#if __has_include(<Flutter/Flutter.h>)
#import <Flutter/Flutter.h>
#else
#import "BSGFlutterSPMShim.h"
#endif

#import "BugsnagFlutterProtocol.h"

@interface BugsnagFlutterPlugin : NSObject<FlutterPlugin, BugsnagFlutterProtocol>

@end
