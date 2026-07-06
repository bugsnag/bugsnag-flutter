// Temporary SPM-only Flutter declarations.
// Used only when Flutter framework headers are unavailable.

#import <Foundation/Foundation.h>

@class FlutterMethodChannel;
@class FlutterMethodCall;
@class FlutterError;
@protocol FlutterPlugin;
@protocol FlutterPluginRegistrar;
@protocol FlutterBinaryMessenger;

typedef void (^FlutterResult)(id _Nullable result);

FOUNDATION_EXPORT NSObject * const FlutterMethodNotImplemented;

@interface FlutterJSONMethodCodec : NSObject
+ (instancetype)sharedInstance;
@end

@interface FlutterError : NSObject
+ (instancetype)errorWithCode:(NSString *)code
                      message:(NSString * _Nullable)message
                      details:(id _Nullable)details;
@property(readonly) NSString *code;
@property(readonly, nullable) NSString *message;
@property(readonly, nullable) id details;
@end

@interface FlutterMethodCall : NSObject
@property(readonly) NSString *method;
@property(readonly, nullable) id arguments;
@end

@interface FlutterMethodChannel : NSObject
+ (instancetype)methodChannelWithName:(NSString *)name
                      binaryMessenger:(id<FlutterBinaryMessenger>)messenger
                                codec:(NSObject *)codec;
@end

@protocol FlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;
@optional
- (void)dummyMethodToEnforceBundling;
@end

@protocol FlutterPluginRegistrar <NSObject>
- (id<FlutterBinaryMessenger>)messenger;
- (void)addMethodCallDelegate:(NSObject<FlutterPlugin> *)delegate
                      channel:(FlutterMethodChannel *)channel;
@end

@protocol FlutterBinaryMessenger <NSObject>
@end

