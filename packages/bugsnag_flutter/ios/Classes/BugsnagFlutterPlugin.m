#import "BugsnagFlutterPlugin.h"

#import "BugsnagFlutterConfiguration.h"
#import <Bugsnag/Bugsnag.h>

#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>

// Constructs a key path, with a compile-time check in DEBUG builds.
// https://pspdfkit.com/blog/2017/even-swiftier-objective-c/#checked-keypaths
#if defined(DEBUG) && DEBUG
#define BSG_KEYPATH(object, property) ((void)(NO && ((void)object.property, NO)), @ #property)
#else
#define BSG_KEYPATH(object, property) @ #property
#endif

// Will be nil in debug builds because they not contain any Dart code (App.framework)
static NSString *DartCodeBuildId;

static void DyldImageAdded(const struct mach_header *mh, intptr_t slide) {
    Dl_info dli = {0};
    if (!dladdr(mh, &dli)) {
        return;
    }
    if (!strstr(dli.dli_fname, "/App.framework/App")) {
        return;
    }
    const struct load_command *lc = NULL;
    switch (mh->magic) {
        case MH_MAGIC:
            lc = (void *)((uintptr_t)mh + sizeof(struct mach_header));
            break;
        case MH_MAGIC_64:
            lc = (void *)((uintptr_t)mh + sizeof(struct mach_header_64));
            break;
        default:
            return;
    }
    for (uint32_t lci = 0; lci < mh->ncmds; lci++) {
        if (lc->cmd == LC_UUID) {
            const struct uuid_command *cmd = (void *)lc;
            DartCodeBuildId = [[[NSUUID alloc] initWithUUIDBytes:cmd->uuid] UUIDString];
            break;
        }
        lc = (void *)((uintptr_t)lc + lc->cmdsize);
    }
}

static NSString *NSStringOrNil(id value) {
    return [value isKindOfClass:[NSString class]] ? value : nil;
}

static NSArray *jsonToRegularExpressions(NSArray *source) {
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *element in source) {
        NSString *pattern = element[@"pattern"];
        NSInteger options = 0;
        if ([element[@"isDotAll"] boolValue]) {
            options |= NSRegularExpressionDotMatchesLineSeparators;
        }
        if (![element[@"isCaseSensitive"] boolValue]) {
            options |= NSRegularExpressionCaseInsensitive;
        }
        if ([element[@"isMultiLine"] boolValue]) {
            options |= NSRegularExpressionAnchorsMatchLines;
        }
        NSError *error = nil;
        NSRegularExpression *expression =  [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&error];
        if (expression != nil) {
            [result addObject: expression];
        } else if (error) {
            NSLog(@"Error encountered while parsing regular expression %@", error);
        }
    }
    return result;
}

@interface BugsnagEvent (BugsnagFlutterPlugin)

@property (nullable, nonatomic) NSArray *projectPackages;

@end

@interface BugsnagStackframe (BugsnagFlutterPlugin)

@property (nullable, nonatomic) NSString *loadAddress;

@end

// MARK: -

@interface BugsnagFlutterPlugin ()

@property (nonatomic, getter=isStarted) BOOL started;
@property (nullable, nonatomic) NSArray *projectPackages;

@end

// MARK: -

@implementation BugsnagFlutterPlugin

+ (void)initialize {
    _dyld_register_func_for_add_image(DyldImageAdded);
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:@"com.bugsnag/client"
            binaryMessenger:[registrar messenger]
                      codec:FlutterJSONMethodCodec.sharedInstance
  ];
  BugsnagFlutterPlugin *instance = [[BugsnagFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    SEL selector = NSSelectorFromString([call.method stringByAppendingString:@":"]);

    // Defend against executing arbitrary methods
    if (!protocol_getMethodDescription(@protocol(BugsnagFlutterProtocol), selector, YES, YES).name) {
        result(FlutterMethodNotImplemented);
        return;
    }

    if ([self respondsToSelector:selector]) {
        @try {
            // "For methods that return anything other than an object, use NSInvocation."
            id arguments = call.arguments;
            NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
            if ([methodSignature numberOfArguments] != 3) {
                result([FlutterError errorWithCode:@"Invalid number of arguments" message:
                        [NSString stringWithFormat:@"'%@' does not take a single argument",
                         NSStringFromSelector(selector)] details:nil]);
                return;
            }
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setTarget:self];
            [invocation setSelector:selector];
            [invocation setArgument:&arguments atIndex:2];
            [invocation invoke];
            const char *returnType = [methodSignature methodReturnType];
            if (strcmp(methodSignature.methodReturnType, @encode(id)) == 0) {
                void *returnValue = NULL;
                [invocation getReturnValue:&returnValue];
                result((__bridge id)(returnValue));
            } else if (strcmp(returnType, @encode(void)) != 0) {
                result([FlutterError errorWithCode:@"Invalid return type" message:
                        [NSString stringWithFormat:@"'%@' does not return id or void",
                         NSStringFromSelector(selector)] details:nil]);
                return;
            }
            result(nil);
        } @catch (NSException *exception) {
            result([FlutterError errorWithCode:exception.name message:exception.reason details:nil]);
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

// MARK: -

- (void)setUser:(NSDictionary *)json {
    [Bugsnag setUser:NSStringOrNil(json[@"id"]) withEmail:NSStringOrNil(json[@"email"]) andName:NSStringOrNil(json[@"name"])];
}

- (NSDictionary *)getUser:(NSDictionary *)json {
    BugsnagUser *user = Bugsnag.user;
    return @{
      @"id": user.id ?: [NSNull null],
      @"email": user.email ?: [NSNull null],
      @"name": user.name ?: [NSNull null]
    };
}

- (void)setContext:(NSDictionary *)json {
    Bugsnag.context = json[@"context"];
}

- (NSString *)getContext:(NSDictionary *)json {
    return Bugsnag.context;
}

- (NSString * _Nullable)setGroupingDiscriminator:(NSDictionary *)arguments {
    NSString *value = NSStringOrNil(arguments[@"value"]);
    // Atomic swap handled by native; returns previous value (may be nil)
    return [Bugsnag setGroupingDiscriminator:value];
}

- (NSString * _Nullable)getGroupingDiscriminator:(NSDictionary *)arguments {
    return [Bugsnag groupingDiscriminator]; // may be nil
}

- (NSNumber *)isStarted:(NSDictionary *)arguments {
    return @([Bugsnag isStarted]);
}

- (void)leaveBreadcrumb:(NSDictionary *)arguments {
    // Map breadcrumb type string to internal enum (simplified version)
    NSString *typeStr = arguments[@"type"];
    BSGBreadcrumbType type = BSGBreadcrumbTypeLog; // default
    if ([typeStr isEqualToString:@"error"]) {
        type = BSGBreadcrumbTypeError;
    } else if ([typeStr isEqualToString:@"navigation"]) {
        type = BSGBreadcrumbTypeNavigation;
    } else if ([typeStr isEqualToString:@"process"]) {
        type = BSGBreadcrumbTypeProcess;
    } else if ([typeStr isEqualToString:@"request"]) {
        type = BSGBreadcrumbTypeRequest;
    } else if ([typeStr isEqualToString:@"state"]) {
        type = BSGBreadcrumbTypeState;
    } else if ([typeStr isEqualToString:@"user"]) {
        type = BSGBreadcrumbTypeUser;
    }
    [Bugsnag leaveBreadcrumbWithMessage:arguments[@"name"]
                               metadata:arguments[@"metaData"]
                                andType:type];
}

- (NSArray<NSDictionary *> *)getBreadcrumbs:(__unused NSDictionary *)arguments {
    NSMutableArray *result = [NSMutableArray array];
    for (BugsnagBreadcrumb *breadcrumb in [Bugsnag breadcrumbs]) {
        // Convert breadcrumb to dictionary using public API
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"message"] = breadcrumb.message;
        dict[@"type"] = [NSNumber numberWithInt:breadcrumb.type];
        dict[@"metadata"] = breadcrumb.metadata ?: @{};
        dict[@"timestamp"] = breadcrumb.timestamp ?: [NSDate date];
        [result addObject:dict];
    }
    return result;
}

- (void)addFeatureFlags:(NSArray *)featureFlags {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[featureFlags count]];
    for (NSDictionary *flag in featureFlags) {
        [array addObject:[BugsnagFeatureFlag flagWithName:flag[@"featureFlag"]
                                                  variant:flag[@"variant"]]];
    }
    [Bugsnag addFeatureFlags:array];
}

- (void)clearFeatureFlag:(NSDictionary *)arguments {
    [Bugsnag clearFeatureFlagWithName:arguments[@"name"]];
}

- (void)clearFeatureFlags:(__unused NSDictionary *)arguments {
    [Bugsnag clearFeatureFlags];
}

- (void)addMetadata:(NSDictionary *)arguments {
    [Bugsnag addMetadata:arguments[@"metadata"] toSection:arguments[@"section"]];
}

- (void)clearMetadata:(NSDictionary *)arguments {
    if ([arguments[@"key"] isKindOfClass:[NSString class]]) {
        [Bugsnag clearMetadataFromSection:arguments[@"section"] withKey:arguments[@"key"]];
    } else {
        [Bugsnag clearMetadataFromSection:arguments[@"section"]];
    }
}

- (NSDictionary *)getMetadata:(NSDictionary *)arguments {
    return [Bugsnag getMetadataFromSection:arguments[@"section"]];
}

- (NSDictionary *)attach:(NSDictionary *)arguments {
    NSDictionary *result = @{
        @"config": @{
            @"enabledErrorTypes": @{
                @"dartErrors": BugsnagFlutterConfiguration.enabledErrorTypes.dartErrors ? @YES : @NO
            }
        }
    };
    
    static BOOL isAttached;
    if (isAttached) {
        NSLog(@"bugsnag.attach() has already been called. Ignoring.");
        return result;
    }
    
    if (![Bugsnag isStarted]) {
        [NSException raise:NSInternalInconsistencyException format:
         @"bugsnag.attach() can only be called once the native layer has already been started, have you called [Bugsnag startWithConfiguration:] from your iOS code?"];
    }

    self.projectPackages = BugsnagFlutterConfiguration.projectPackages;

    isAttached = YES;
    return result;
}

- (void)start:(NSDictionary *)arguments {
    if (self.isStarted) {
        NSLog(@"bugsnag.start() was called more than once. Ignoring.");
        return;
    }

    static BOOL isAnyStarted;
    if (isAnyStarted) {
        NSLog(@"bugsnag.start() was called from a previous Flutter context. Ignoring.");
        return;
    }

    if ([Bugsnag isStarted]) {
        [NSException raise:NSInternalInconsistencyException format:@"bugsnag.start() may not be called after starting Bugsnag natively"];
    }
    
    BugsnagConfiguration *configuration = [BugsnagConfiguration loadConfig];
    
    for (NSString *key in @[BSG_KEYPATH(configuration, apiKey),
                            BSG_KEYPATH(configuration, appHangThresholdMillis),
                            BSG_KEYPATH(configuration, appType),
                            BSG_KEYPATH(configuration, appVersion),
                            BSG_KEYPATH(configuration, autoDetectErrors),
                            BSG_KEYPATH(configuration, autoTrackSessions),
                            BSG_KEYPATH(configuration, bundleVersion),
                            BSG_KEYPATH(configuration, context),
                            BSG_KEYPATH(configuration, launchDurationMillis),
                            BSG_KEYPATH(configuration, maxBreadcrumbs),
                            BSG_KEYPATH(configuration, maxPersistedEvents),
                            BSG_KEYPATH(configuration, maxPersistedSessions),
                            BSG_KEYPATH(configuration, maxStringValueLength),
                            BSG_KEYPATH(configuration, releaseStage),
                            BSG_KEYPATH(configuration, sendLaunchCrashesSynchronously)]) {
        id value = arguments[key];
        if (value && value != [NSNull null]) {
            [configuration setValue:value forKey:key];
        }
    }

    NSArray *redactedKeys = arguments[@"redactedKeys"];
    if ([redactedKeys isKindOfClass:[NSArray class]]) {
        configuration.redactedKeys = [NSSet setWithArray: jsonToRegularExpressions(redactedKeys)];
    }

    NSArray *discardClasses = arguments[@"discardClasses"];
    if ([discardClasses isKindOfClass:[NSArray class]]) {
        configuration.discardClasses = [NSSet setWithArray: jsonToRegularExpressions(discardClasses)];
    }

    NSArray *enabledReleaseStages = arguments[@"enabledReleaseStages"];
    if ([enabledReleaseStages isKindOfClass:[NSArray class]]) {
        configuration.enabledReleaseStages = [NSSet setWithArray:enabledReleaseStages];
    }

    NSDictionary *user = arguments[@"user"];
    if ([user isKindOfClass:[NSDictionary class]]) {
        [configuration setUser:user[@"id"]
                     withEmail:user[@"email"]
                       andName:user[@"name"]];
    }
    
    NSNumber *persistUser = arguments[@"persistUser"];
    if ([persistUser isKindOfClass:[NSNumber class]] &&
        configuration.persistUser != [persistUser boolValue]) {
        configuration.persistUser = [persistUser boolValue];
    }
    
    NSDictionary *endpoints = arguments[@"endpoints"];
    if ([endpoints isKindOfClass:[NSDictionary class]]) {
        configuration.endpoints.notify = endpoints[@"notify"];
        configuration.endpoints.sessions = endpoints[@"sessions"];
    }
    
    NSString *sendThreads = arguments[@"sendThreads"];
    if ([sendThreads isKindOfClass:[NSString class]]) {
        if ([sendThreads isEqualToString:@"always"]) {
            configuration.sendThreads = BSGThreadSendPolicyAlways;
        } else if ([sendThreads isEqualToString:@"unhandledOnly"]) {
            configuration.sendThreads = BSGThreadSendPolicyUnhandledOnly;
        } else if ([sendThreads isEqualToString:@"never"]) {
            configuration.sendThreads = BSGThreadSendPolicyNever;
        }
    }
    
    NSArray *enabledBreadcrumbTypes = arguments[@"enabledBreadcrumbTypes"];
    if ([enabledBreadcrumbTypes isKindOfClass:[NSArray class]]) {
        BSGEnabledBreadcrumbType value =
        ([enabledBreadcrumbTypes containsObject:@"error"]       ? BSGEnabledBreadcrumbTypeError         : 0) |
        ([enabledBreadcrumbTypes containsObject:@"log"]         ? BSGEnabledBreadcrumbTypeLog           : 0) |
        ([enabledBreadcrumbTypes containsObject:@"navigation"]  ? BSGEnabledBreadcrumbTypeNavigation    : 0) |
        ([enabledBreadcrumbTypes containsObject:@"process"]     ? BSGEnabledBreadcrumbTypeProcess       : 0) |
        ([enabledBreadcrumbTypes containsObject:@"request"]     ? BSGEnabledBreadcrumbTypeRequest       : 0) |
        ([enabledBreadcrumbTypes containsObject:@"state"]       ? BSGEnabledBreadcrumbTypeState         : 0) |
        ([enabledBreadcrumbTypes containsObject:@"user"]        ? BSGEnabledBreadcrumbTypeUser          : 0);
        configuration.enabledBreadcrumbTypes = value;
    }
    
    NSDictionary *enabledErrorTypes = arguments[@"enabledErrorTypes"];
    if ([enabledErrorTypes isKindOfClass:[NSDictionary class]]) {
        configuration.enabledErrorTypes.unhandledExceptions = [enabledErrorTypes[@"crashes"] boolValue];
        configuration.enabledErrorTypes.signals             = [enabledErrorTypes[@"crashes"] boolValue];
        configuration.enabledErrorTypes.cppExceptions       = [enabledErrorTypes[@"crashes"] boolValue];
        configuration.enabledErrorTypes.machExceptions      = [enabledErrorTypes[@"crashes"] boolValue];
        configuration.enabledErrorTypes.ooms                = [enabledErrorTypes[@"ooms"] boolValue];
        configuration.enabledErrorTypes.thermalKills        = [enabledErrorTypes[@"thermalKills"] boolValue];
        configuration.enabledErrorTypes.appHangs            = [enabledErrorTypes[@"appHangs"] boolValue];
    }
    
    NSDictionary *metadata = arguments[@"metadata"];
    if ([metadata isKindOfClass:[NSDictionary class]]) {
        for (NSString *section in metadata) {
            [configuration addMetadata:metadata[section] toSection:section];
        }
    }
    
    NSArray *featureFlags = arguments[@"featureFlags"];
    if ([featureFlags isKindOfClass:[NSArray class]]) {
        for (NSDictionary *flag in featureFlags) {
            [configuration addFeatureFlagWithName:flag[@"featureFlag"] variant:flag[@"variant"]];
        }
    }
    
    NSDictionary *projectPackages = arguments[@"projectPackages"];
    if ([projectPackages isKindOfClass:[NSDictionary class]]) {
        self.projectPackages = projectPackages[@"packageNames"];
    }
    
    NSArray *telemetry = arguments[@"telemetry"];
    if ([telemetry isKindOfClass:[NSArray class]]) {
        BSGTelemetryOptions value = 
        ([telemetry containsObject:@"internalErrors"] ? BSGTelemetryInternalErrors : 0) |
        ([telemetry containsObject:@"usage"]          ? BSGTelemetryUsage          : 0) ;
        configuration.telemetry = value;
    }
    
    [Bugsnag startWithConfiguration:configuration];
    
    self.started = YES;
    isAnyStarted = YES;
}

- (void)startSession:(NSDictionary *)arguments {
    [Bugsnag startSession];
}

- (void)pauseSession:(NSDictionary *)arguments {
    [Bugsnag pauseSession];
}

- (NSNumber *)resumeSession:(NSDictionary *)arguments {
    return @([Bugsnag resumeSession]);
}

- (void)markLaunchCompleted:(NSDictionary *)arguments {
    [Bugsnag markLaunchCompleted];
}

- (NSDictionary *)getLastRunInfo:(NSDictionary *)arguments {
    BugsnagLastRunInfo *lastRunInfo = Bugsnag.lastRunInfo;
    return lastRunInfo ? @{
        @"consecutiveLaunchCrashes": @(lastRunInfo.consecutiveLaunchCrashes),
        @"crashed": @(lastRunInfo.crashed),
        @"crashedDuringLaunch": @(lastRunInfo.crashedDuringLaunch),
    } : nil;
}

- (NSDictionary *)createEvent:(NSDictionary *)json {
    // For now, createEvent returns nil since event delivery is handled via the public notify API
    // The Flutter layer should use the notifyError: approach for proper integration with SPM
    if ([json[@"deliver"] boolValue]) {
        // Create a simple error that can be sent via public API
        NSString *message = json[@"error"][@"message"] ?: @"Error from Flutter";
        NSError *error = [NSError errorWithDomain:@"FlutterError"
                                             code:1
                                         userInfo:@{NSLocalizedDescriptionKey: message}];
        [Bugsnag notifyError:error block:^BOOL(BugsnagEvent * _Nonnull event) {
            // Add Flutter-specific metadata
            NSDictionary *metadata = json[@"flutterMetadata"];
            if (metadata != nil) {
                [event addMetadata:metadata toSection:@"flutter"];
            }

            // Add correlation info if present
            NSDictionary *correlation = json[@"correlation"];
            if (correlation != nil) {
                NSString *traceId = correlation[@"traceId"];
                NSString *spanId = correlation[@"spanId"];
                if (traceId != nil && spanId != nil) {
                    [event setCorrelationTraceId:traceId spanId:spanId];
                }
            }

            // Add grouping discriminator
            NSString *dartGroupingDiscriminator = NSStringOrNil(json[@"groupingDiscriminator"]);
            if (dartGroupingDiscriminator != nil) {
                event.groupingDiscriminator = dartGroupingDiscriminator;
            } else {
                NSString *global = [Bugsnag groupingDiscriminator];
                if (global != nil) {
                    event.groupingDiscriminator = global;
                }
            }

            // Return YES to report the event
            return YES;
        }];
        return nil;
    } else {
        // For non-delivery case, return empty dict as we can't create events without client internals
        return @{};
    }
}

- (void)deliverEvent:(NSDictionary *)json {
    // No longer needed with public API approach
}

@end
