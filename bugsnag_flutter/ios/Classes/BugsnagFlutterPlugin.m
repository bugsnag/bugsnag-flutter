#import "BugsnagFlutterPlugin.h"

#import <Bugsnag/BSG_KSSystemInfo.h>
#import <Bugsnag/Bugsnag+Private.h>
#import <Bugsnag/BugsnagBreadcrumb+Private.h>
#import <Bugsnag/BugsnagBreadcrumbs.h>
#import <Bugsnag/BugsnagClient+Private.h>
#import <Bugsnag/BugsnagConfiguration+Private.h>
#import <Bugsnag/BugsnagError+Private.h>
#import <Bugsnag/BugsnagEvent+Private.h>
#import <Bugsnag/BugsnagHandledState.h>
#import <Bugsnag/BugsnagNotifier.h>
#import <Bugsnag/BugsnagSessionTracker.h>
#import <Bugsnag/BugsnagStackframe+Private.h>
#import <Bugsnag/BugsnagThread+Private.h>

#import <objc/runtime.h>

static NSString *NSStringOrNil(id value) {
    return [value isKindOfClass:[NSString class]] ? value : nil;
}

@interface BugsnagFlutterPlugin ()

@property (nonatomic, getter=isAttached) BOOL attached;
@property (nonatomic, getter=isStarted) BOOL started;

@end

@implementation BugsnagFlutterPlugin

// MARK: - @protocol FlutterPlugin

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

- (void)leaveBreadcrumb:(NSDictionary *)arguments {
    [Bugsnag leaveBreadcrumbWithMessage:arguments[@"name"]
                               metadata:arguments[@"metaData"]
                                andType:BSGBreadcrumbTypeFromString(arguments[@"type"])];
}

- (NSArray<NSDictionary *> *)getBreadcrumbs:(__unused NSDictionary *)arguments {
    NSMutableArray *result = [NSMutableArray array];
    for (BugsnagBreadcrumb *breadcrumb in [Bugsnag breadcrumbs]) {
        [result addObject:[breadcrumb objectValue]];
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

- (void)attach:(NSDictionary *)arguments {
    if (self.isAttached) {
        [NSException raise:NSInternalInconsistencyException format:@"bugsnag.attach() may not be called more than once"];
    }
    
    static BOOL isAnyAttached;
    if (isAnyAttached) {
        NSLog(@"bugsnag.attach() was called from a previous Flutter context. Ignoring.");
        return;
    }
    
    if (!Bugsnag.client) {
        [NSException raise:NSInternalInconsistencyException format:
         @"bugsnag.attach() can only be called once the native layer has already been started, have you called [Bugsnag start] from your iOS code?"];
    }

    if ([arguments[@"user"] isKindOfClass:[NSDictionary class]]) {
        [self setUser:arguments[@"user"]];
    }
    
    if ([arguments[@"context"] isKindOfClass:[NSString class]]) {
        [self setContext:arguments];
    }
    
    NSArray *featureFlags = arguments[@"featureFlags"];
    if ([featureFlags isKindOfClass:[NSArray class]]) {
        [self addFeatureFlags:featureFlags];
    }
    
    NSDictionary *notifier = arguments[@"notifier"];
    Bugsnag.client.notifier.name = notifier[@"name"];
    Bugsnag.client.notifier.version = notifier[@"version"];
    Bugsnag.client.notifier.url = notifier[@"url"];
    Bugsnag.client.notifier.dependencies = @[[[BugsnagNotifier alloc] init]];
    
    isAnyAttached = YES;
    self.attached = YES;
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

    if (Bugsnag.client) {
        [NSException raise:NSInternalInconsistencyException format:@"bugsnag.start() may not be called after starting Bugsnag natively"];
    }
    
    BugsnagConfiguration *configuration = [BugsnagConfiguration loadConfig];
    
    for (NSString *key in @[@"apiKey",
                            @"appHangThresholdMillis",
                            @"appType",
                            @"appVersion",
                            @"autoTrackSessions",
                            @"bundleVersion",
                            @"context",
                            @"launchDurationMillis",
                            @"maxBreadcrumbs",
                            @"maxPersistedEvents",
                            @"maxPersistedSessions",
                            @"redactedKeys",
                            @"releaseStage"]) {
        id value = arguments[key];
        if (value && value != [NSNull null]) {
            [configuration setValue:value forKey:key];
        }
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
    
    NSDictionary *notifier = arguments[@"notifier"];
    configuration.notifier = [[BugsnagNotifier alloc] initWithName:notifier[@"name"]
                                                           version:notifier[@"version"]
                                                               url:notifier[@"url"]
                                                      dependencies:@[[[BugsnagNotifier alloc] init]]];
    
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

- (void)markLaunchComplete:(NSDictionary *)arguments {
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
    NSDictionary *systemInfo = [BSG_KSSystemInfo systemInfo];
    BugsnagClient *client = Bugsnag.client;
    BugsnagError *error = [BugsnagError errorFromJson:json[@"error"]];
    BugsnagEvent *event = [[BugsnagEvent alloc] initWithApp:[client generateAppWithState:systemInfo]
                                                     device:[client generateDeviceWithState:systemInfo]
                                               handledState:[BugsnagHandledState handledStateWithSeverityReason:
                                                             [json[@"unhandled"] boolValue] ? UnhandledException : HandledException]
                                                       user:client.user
                                                   metadata:[client.metadata deepCopy]
                                                breadcrumbs:client.breadcrumbs.breadcrumbs ?: @[]
                                                     errors:@[error]
                                                    threads:@[]
                                                    session:client.sessionTracker.runningSession];
    event.apiKey = client.configuration.apiKey;
    event.context = client.context;

    // TODO: Expose BugsnagClient's featureFlagStore or provide a better way to create an event
    id featureFlagStore = [client valueForKey:@"featureFlagStore"];
    @synchronized (featureFlagStore) {
        event.featureFlagStore = [featureFlagStore copy];
    }
    
    for (BugsnagStackframe *frame in error.stacktrace) {
        if ([frame.type isEqualToString:@"dart"] && !frame.codeIdentifier) {
            frame.codeIdentifier = event.app.dsymUuid;
        }
    }
    
    if (client.configuration.sendThreads == BSGThreadSendPolicyAlways) {
        event.threads = [BugsnagThread allThreads:YES callStackReturnAddresses:NSThread.callStackReturnAddresses];
    }

    NSDictionary *metadata = json[@"flutterMetadata"];
    if (metadata != nil) {
        [event addMetadata:metadata toSection:@"flutter"];
    }
    
    if ([json[@"deliver"] boolValue]) {
        [client notifyInternal:event block:nil];
        return nil;
    } else {
        return [event toJsonWithRedactedKeys:nil];
    }
}

- (void)deliverEvent:(NSDictionary *)json {
    BugsnagEvent *event = [[BugsnagEvent alloc] initWithJson:json];
    [Bugsnag.client notifyInternal:event block:nil];
}

@end
