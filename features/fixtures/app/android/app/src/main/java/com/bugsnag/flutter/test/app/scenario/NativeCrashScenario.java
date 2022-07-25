package com.bugsnag.flutter.test.app.scenario;

import android.content.Context;

import io.flutter.plugin.common.MethodCall;

public class NativeCrashScenario extends Scenario {
    @Override
    public void run(Context context, MethodCall call) {
        throw new RuntimeException("crash from Java");
    }
}
