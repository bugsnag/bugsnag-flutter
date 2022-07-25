#import "BugsnagFlutterEnabledErrorTypes.h"

@interface BugsnagFlutterConfiguration : NSObject

@property (class, readonly, nonnull) BugsnagFlutterEnabledErrorTypes *enabledErrorTypes;

@property (class, copy, nullable) NSArray<NSString *> *projectPackages;

@end
