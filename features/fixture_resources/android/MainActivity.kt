package com.bugsnag.mazerunner

import android.os.Bundle

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity()
    @Override
    protected fun onCreate(@Nullable savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MethodChannel(getFlutterEngine().getDartExecutor(), MainActivity.Companion.MAZE_RUNNER_CHANNEL)
            .setMethodCallHandler(MazeRunnerMethodCallHandler(getApplicationContext()))
    }

    companion object {
        private val MAZE_RUNNER_CHANNEL = "com.bugsnag.mazeRunner/platform"
    }
}
