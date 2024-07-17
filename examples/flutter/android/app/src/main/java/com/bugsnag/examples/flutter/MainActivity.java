package com.bugsnag.examples.flutter;

import android.os.Bundle;
import android.os.Looper;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        new MethodChannel(getFlutterEngine().getDartExecutor(), "com.bugsnag.example/channel")
                .setMethodCallHandler((call, result) -> {
                    if ("anr".equals(call.method)) {
                        assert(Looper.myLooper() == Looper.getMainLooper());
                        try {
                            Thread.sleep(10_000);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        result.success(null);
                    }
                });
    }
}
