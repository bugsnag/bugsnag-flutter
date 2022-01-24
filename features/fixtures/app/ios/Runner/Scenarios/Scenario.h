#ifndef Scenario_h
#define Scenario_h

#import <Foundation/Foundation.h>
#import <Bugsnag/Bugsnag.h>

@interface Scenario : NSObject

+ (Scenario *)createScenarioNamed:(NSString *)className;

- (instancetype)init;

/**
 * Executes the test case
 */
- (void)runWithExtraConfig:(NSString *)extraConfig;

@end

#endif /* Scenario_h */
