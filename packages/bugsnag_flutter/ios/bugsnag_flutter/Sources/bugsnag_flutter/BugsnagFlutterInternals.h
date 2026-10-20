#import <Bugsnag/Bugsnag.h>

/**
 * Redeclares Bugsnag Cocoa internal APIs used by this plugin.
 *
 * BugsnagInternals.h is a project header in bugsnag-cocoa, so it is visible to
 * CocoaPods builds but not to Swift Package Manager (which only exports public
 * headers). These declarations match the cocoa internals used by bugsnag-flutter.
 */

@class BugsnagHandledState;
@class BugsnagNotifier;
@class BugsnagMetadata;
@class BugsnagAppWithState;
@class BugsnagDeviceWithState;

typedef NS_ENUM(NSUInteger, SeverityReasonType) {
    UnhandledException,
    Signal,
    HandledError,
    HandledException,
    UserSpecifiedSeverity,
    UserCallbackSetSeverity,
    PromiseRejection,
    LogMessage,
    LikelyOutOfMemory,
    AppHang,
    ThermalKill,
};

NS_ASSUME_NONNULL_BEGIN

@interface BugsnagNotifier : NSObject

- (instancetype)init;
- (instancetype)initWithName:(NSString *)name
                     version:(NSString *)version
                         url:(NSString *)url
                dependencies:(NSArray *)dependencies;

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *version;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSArray *dependencies;

@end

@interface BugsnagHandledState : NSObject

+ (instancetype)handledStateWithSeverityReason:(SeverityReasonType)severityReason;

@end

@interface Bugsnag (BugsnagFlutterInternals)

@property (class, readonly, nonatomic) BugsnagClient *client;

@end

@interface BugsnagClient (BugsnagFlutterInternals)

@property (retain, nonatomic) BugsnagConfiguration *configuration;
@property (readonly, nonatomic) id featureFlagStore;
@property (strong, nonatomic) BugsnagMetadata *metadata;
@property (readonly, nonatomic) BugsnagNotifier *notifier;

- (BugsnagAppWithState *)generateAppWithState:(NSDictionary *)systemInfo;
- (BugsnagDeviceWithState *)generateDeviceWithState:(NSDictionary *)systemInfo;
- (void)notifyInternal:(BugsnagEvent *)event block:(nullable BugsnagOnErrorBlock)block;

@end

@interface BugsnagConfiguration (BugsnagFlutterInternals)

@property (nullable, nonatomic) BugsnagNotifier *notifier;

@end

@interface BugsnagBreadcrumb (BugsnagFlutterInternals)

- (nullable NSDictionary *)objectValue;

@end

BUGSNAG_EXTERN BSGBreadcrumbType BSGBreadcrumbTypeFromString(NSString * _Nullable value);

@interface BugsnagError (BugsnagFlutterInternals)

+ (BugsnagError *)errorFromJson:(NSDictionary *)json;

@end

@interface BugsnagEvent (BugsnagFlutterInternals)

- (instancetype)initWithApp:(BugsnagAppWithState *)app
                     device:(BugsnagDeviceWithState *)device
               handledState:(BugsnagHandledState *)handledState
                       user:(BugsnagUser *)user
                   metadata:(BugsnagMetadata *)metadata
                breadcrumbs:(NSArray *)breadcrumbs
                     errors:(NSArray *)errors
                    threads:(NSArray *)threads
                    session:(nullable BugsnagSession *)session;

- (instancetype)initWithJson:(NSDictionary *)json;
- (void)symbolicateIfNeeded;
- (NSDictionary *)toJsonWithRedactedKeys:(nullable NSSet *)redactedKeys;

@property (readwrite, strong, nonnull, nonatomic) id featureFlagStore;

@end

@interface BugsnagStackframe (BugsnagFlutterInternals)

+ (instancetype)frameFromJson:(NSDictionary *)json;

@property (copy, nullable, nonatomic) NSString *codeIdentifier;

- (NSDictionary *)toDictionary;

@end

@interface BugsnagThread (BugsnagFlutterInternals)

+ (NSArray *)allThreads:(BOOL)allThreads callStackReturnAddresses:(NSArray *)callStackReturnAddresses;

@end

@interface NSObject (BugsnagFlutterFeatureFlagStore)

- (id)copyMemoryStore;

@end

BUGSNAG_EXTERN NSDictionary * BSGGetSystemInfo(void);

NS_ASSUME_NONNULL_END
