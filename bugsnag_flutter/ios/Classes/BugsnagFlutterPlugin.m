#import "BugsnagFlutterPlugin.h"
#import "Bugsnag/Bugsnag.h"

static NSString *NSStringOrNil(id value) {
    return [value isKindOfClass:[NSString class]] ? value : nil;
}

@implementation BugsnagFlutterPlugin

- (instancetype)init {
    if ((self = [super init])) {
        _availableFunctions = [NSSet setWithObjects:
                               @"setUser",
                               @"getUser",
                               @"setContext",
                               @"getContext",
                               @"attach",
                               nil
        ];
    }
    
    return self;
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
    if (![_availableFunctions containsObject:call.method]) {
        result(FlutterMethodNotImplemented);
        return;
    }
    
    SEL selector = NSSelectorFromString([call.method stringByAppendingString:@":"]);
    if ([self respondsToSelector:selector]) {
        @try {
            result([self performSelector:selector withObject:call.arguments]);
        } @catch (NSException *exception) {
            result([FlutterError errorWithCode:exception.name message:exception.reason details:nil]);
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

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

- (void)addFeatureFlags:(NSDictionary *)json {
    if ([json[@"featureFlags"] isKindOfClass:[NSArray class]]) {
        NSArray *jsonFeatureFlags = json[@"featureFlags"];
        NSMutableArray *featureFlags = [NSMutableArray arrayWithCapacity:[jsonFeatureFlags count]];
        
        for (NSDictionary *flag in jsonFeatureFlags) {
            [featureFlags addObject:[BugsnagFeatureFlag flagWithName:flag[@"featureFlag"]
                                                             variant:NSStringOrNil(flag[@"variant"])]];
        }
        
        [Bugsnag addFeatureFlags:featureFlags];
    }
}

- (void)attach:(NSDictionary *)json {
    if ([json[@"user"] isKindOfClass:[NSDictionary class]]) {
        [self setUser:json[@"user"]];
    }
    
    if ([json[@"context"] isKindOfClass:[NSString class]]) {
        [self setContext:json];
    }
    
    if ([json[@"featureFlags"] isKindOfClass:[NSDictionary class]]) {
        [self addFeatureFlags:json];
    }
}

@end
