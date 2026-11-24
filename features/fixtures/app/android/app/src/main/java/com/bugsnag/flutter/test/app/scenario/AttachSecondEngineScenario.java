package com.bugsnag.flutter.test.app.scenario;

import android.content.Context;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodCall;

/**
 * Starts a second FlutterEngine in the same process, as an add-to-app host does when it opens a
 * Flutter screen with its own engine. The engine registers its own plugin instances and runs the
 * {@code attachSecondEngineMain} entry point from {@code main.dart}.
 */
public class AttachSecondEngineScenario extends Scenario {
    // held statically so the engine stays alive for the rest of the scenario
    private static FlutterEngine secondEngine;

    @Override
    public void run(Context context, MethodCall call) {
        secondEngine = new FlutterEngine(context);
        secondEngine.getDartExecutor().executeDartEntrypoint(
                new DartExecutor.DartEntrypoint(
                        FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                        "attachSecondEngineMain"
                )
        );
    }
}
