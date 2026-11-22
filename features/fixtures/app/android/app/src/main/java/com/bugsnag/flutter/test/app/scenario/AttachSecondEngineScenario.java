package com.bugsnag.flutter.test.app.scenario;

import android.content.Context;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodCall;

public class AttachSecondEngineScenario extends Scenario {
    private static FlutterEngine secondEngine;

    @Override
    public void run(Context context, MethodCall call) {
        secondEngine = new FlutterEngine(context);
        secondEngine.getDartExecutor().executeDartEntrypoint(
                new DartExecutor.DartEntrypoint(
                        FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                        "package:MazeRunner/scenarios/attach_second_engine_scenario.dart",
                        "secondEngineMain"
                )
        );
    }
}
