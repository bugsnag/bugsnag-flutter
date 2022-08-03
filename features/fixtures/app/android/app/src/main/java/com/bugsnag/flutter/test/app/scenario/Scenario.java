package com.bugsnag.flutter.test.app.scenario;

import android.content.Context;

import io.flutter.plugin.common.MethodCall;

public abstract class Scenario {
    public abstract void run(Context context, MethodCall call);
}
