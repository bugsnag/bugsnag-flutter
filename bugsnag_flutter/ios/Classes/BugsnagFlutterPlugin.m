#import "BugsnagFlutterPlugin.h"

#import <Bugsnag/Bugsnag+Private.h>
#import <objc/runtime.h>

static NSString *NSStringOrNil(id value) {
    return [value isKindOfClass:[NSString class]] ? value : nil;
}

@implementation BugsnagFlutterPlugin

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
            id returnValue = nil;
            const char *returnType = [methodSignature methodReturnType];
            if (strcmp(methodSignature.methodReturnType, @encode(id)) == 0) {
                [invocation getReturnValue:&returnValue];
            } else if (strcmp(returnType, @encode(void)) != 0) {
                result([FlutterError errorWithCode:@"Invalid return type" message:
                        [NSString stringWithFormat:@"'%@' does not return id or void",
                         NSStringFromSelector(selector)] details:nil]);
                return;
            }
            result(returnValue);
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

- (NSNumber *)attach:(NSDictionary *)json {
    if (Bugsnag.client == nil) {
        return @NO;
    }

    if ([json[@"user"] isKindOfClass:[NSDictionary class]]) {
        [self setUser:json[@"user"]];
    }
    
    if ([json[@"context"] isKindOfClass:[NSString class]]) {
        [self setContext:json];
    }
    
    if ([json[@"featureFlags"] isKindOfClass:[NSDictionary class]]) {
        [self addFeatureFlags:json];
    }

    return @YES;
}

@end
