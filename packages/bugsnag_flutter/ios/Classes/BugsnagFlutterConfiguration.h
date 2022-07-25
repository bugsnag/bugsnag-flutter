#import "BugsnagFlutterEnabledErrorTypes.h"

@interface BugsnagFlutterConfiguration : NSObject

@property (class, readonly, nonnull) BugsnagFlutterEnabledErrorTypes *enabledErrorTypes;

/**
 * The (Dart) package names that Bugsnag should consider to be part of the running application.
 * 
 * Dart stack frames are marked as in-project if they originate from any of these packages, and
 * this allows us to improve the visual display of the stacktrace on the dashboard.
 */
@property (class, copy, nullable) NSArray<NSString *> *projectPackages;

@end
