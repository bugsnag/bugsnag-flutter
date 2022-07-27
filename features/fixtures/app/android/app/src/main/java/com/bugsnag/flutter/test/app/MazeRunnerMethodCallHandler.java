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
import com.bugsnag.flutter.BugsnagFlutterConfiguration;
import com.bugsnag.flutter.test.app.scenario.Scenario;

import org.json.JSONException;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Deque;
import java.util.LinkedList;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MazeRunnerMethodCallHandler implements MethodChannel.MethodCallHandler {
    public static final String TAG = "MazeRunner";
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private final Context context;

    MazeRunnerMethodCallHandler(@NonNull Context context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("getCommand")) {
            Thread thread = new Thread() {
                public void run() {
                    getCommand(call, result);
                }
            };
            thread.start();
        } else if (call.method.equals("runScenario")) {
            runScenario(call, result);
        } else if (call.method.equals("startBugsnag")) {
            Configuration config = Configuration.load(context);
            config.setApiKey("abc12312312312312312312312312312");

            String notifyEndpoint = call.argument("notifyEndpoint");
            String sessionEndpoint = call.argument("sessionEndpoint");
            String extraConfig = call.argument("extraConfig");

            if (notifyEndpoint != null && sessionEndpoint != null) {
                config.setEndpoints(new EndpointConfiguration(notifyEndpoint, sessionEndpoint));
            }

            Bugsnag.start(context, config);

            if (extraConfig != null && extraConfig.contains("disableDartErrors")) {
                BugsnagFlutterConfiguration.enabledErrorTypes.dartErrors = false;
            }

            result.success(null);
        } else if (call.method.equals("clearPersistentData")) {
            clearPersistentData();
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    private void clearPersistentData() {
        Deque<File> stack = new LinkedList<>();
        stack.push(context.getCacheDir());

        while (!stack.isEmpty()) {
            File dir = stack.pop();
            File[] entries = dir.listFiles();

            if (entries.length == 0) {
                if (!dir.delete()) {
                    Log.w("MazeRunner", "Couldn't delete directory: " + dir);
                }
            } else {
                stack.push(dir);

                for (File entry : entries) {
                    if (entry.isDirectory()) {
                        stack.push(entry);
                    } else {
                        if (!entry.delete()) {
                            Log.w("MazeRunner", "Couldn't delete file: " + entry);
                        }
                    }
                }
            }
        }
    }

    private void getCommand(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String commandUrl = call.argument("commandUrl");
        try {
            URL url = new URL(commandUrl);
            StringBuilder sb = new StringBuilder();
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            for (String line; (line = reader.readLine()) != null; ) {
                sb.append(line);
            }
            mainHandler.post(() -> {
                result.success(sb.toString());
            });
        } catch (Exception e) {
            mainHandler.post(() -> {
                result.error(e.getClass().getSimpleName(), e.getMessage(), commandUrl);
            });
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
            mainHandler.post(() -> {
                scenario.run(context, call);
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
