package com.bugsnag.flutter.test.app;

import android.content.Context;

import androidx.annotation.NonNull;

import com.bugsnag.android.Bugsnag;
import com.bugsnag.flutter.test.app.scenario.Scenario;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MazeRunnerMethodCallHandler implements MethodChannel.MethodCallHandler {
    private final Context context;

    MazeRunnerMethodCallHandler(@NonNull Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("runScenario")) {
            runScenario(call, result);
        } else if (call.method.equals("startBugsnag")) {
            Bugsnag.start(context);
        }

        result.notImplemented();
    }

    private void runScenario(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String scenarioName = call.argument("scenario");
        try {
            @SuppressWarnings("unchecked")
            Class<? extends Scenario> scenarioClass = (Class<? extends Scenario>) Class.forName(scenarioName);
            Scenario scenario = scenarioClass.newInstance();
            scenario.run(call.argument("extraConfig"));
            result.success(null);
        } catch (Exception e) {
            result.error(e.getClass().getSimpleName(), e.getMessage(), scenarioName);
        }
    }
}
