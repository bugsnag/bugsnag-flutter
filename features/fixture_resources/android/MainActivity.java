package com.bugsnag.flutter.test.app;

import android.os.Bundle;

import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String MAZE_RUNNER_CHANNEL = "com.bugsnag.mazeRunner/platform";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        new MethodChannel(getFlutterEngine().getDartExecutor(), MAZE_RUNNER_CHANNEL)
                .setMethodCallHandler(new MazeRunnerMethodCallHandler(getApplicationContext()));
    }
}
