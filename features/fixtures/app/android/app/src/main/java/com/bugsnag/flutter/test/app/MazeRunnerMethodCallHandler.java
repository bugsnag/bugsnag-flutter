package com.bugsnag.flutter.test.app;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bugsnag.android.Bugsnag;
import com.bugsnag.android.Configuration;
import com.bugsnag.android.EndpointConfiguration;
import com.bugsnag.flutter.test.app.scenario.Scenario;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

import java.lang.Thread;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;


public class MazeRunnerMethodCallHandler implements MethodChannel.MethodCallHandler {
    public static final String TAG = "MazeRunner";
    private final Handler scenarioRunner = new Handler(Looper.getMainLooper());
    private final Context context;

    MazeRunnerMethodCallHandler(@NonNull Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("getCommand")) {
            Thread thread = new Thread(){
                public void run(){
                    getCommand(call, result);
                }
            };
            thread.start();
        } else if (call.method.equals("runScenario")) {
            runScenario(call, result);
        } else if (call.method.equals("startBugsnag")) {
            Configuration config = Configuration.load(context);
            config.setApiKey("abc12312312312312312312312312312");
            if (call.hasArgument("notifyEndpoint") && call.hasArgument("sessionEndpoint")) {
                config.setEndpoints(new EndpointConfiguration(
                        call.argument("notifyEndpoint"),
                        call.argument("sessionEndpoint")
                ));
            }
            Bugsnag.start(context, config);
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    private void getCommand(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {

        // TODO Pass URL in
        String commandUrl = "http://bs-local.com:9339/command";
        try {
            URL url = new URL(commandUrl);
            StringBuilder sb = new StringBuilder();
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            for (String line; (line = reader.readLine()) != null; ) {
                sb.append(line);
            }
            result.success(sb.toString());
        } catch (Exception e) {
            result.error(e.getClass().getSimpleName(), e.getMessage(), commandUrl);
        }
    }

    private void runScenario(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String scenarioName = call.argument("scenarioName");
        if (scenarioName == null || scenarioName.isEmpty()) {
            Log.w(TAG, "No scenario name specified: " + scenarioName);
            result.error("NullPointerException", "scenarioName", null);
            return;
        }

        String scenarioClassName = "com.bugsnag.flutter.test.app.scenario." + scenarioName;
        Scenario scenario = initScenario(result, scenarioClassName);

        if (scenario != null) {
            // we push all scenarios to the main thread to stop Flutter catching the exceptions
            scenarioRunner.post(() -> {
                scenario.run(call.argument("extraConfig"));
                result.success(null);
            });
        }
    }

    @Nullable
    private Scenario initScenario(MethodChannel.Result result, String scenarioName) {
        Log.v(TAG, "Attempting to init scenario: " + scenarioName);
        Scenario scenario = null;
        try {
            @SuppressWarnings("unchecked")
            Class<? extends Scenario> scenarioClass = (Class<? extends Scenario>) Class.forName(scenarioName);
            scenario = scenarioClass.newInstance();
        } catch (Exception e) {
            Log.e(TAG, "Failed to init scenario: " + scenarioName, e);
            result.error(e.getClass().getSimpleName(), e.getMessage(), scenarioName);
        }

        return scenario;
    }
}
