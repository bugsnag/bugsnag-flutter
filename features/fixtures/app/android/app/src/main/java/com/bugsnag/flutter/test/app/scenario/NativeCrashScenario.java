package com.bugsnag.flutter.test.app.scenario;

import androidx.annotation.Nullable;

public class NativeCrashScenario extends Scenario {
    @Override
    public void run(@Nullable String extraConfig) {
        throw new RuntimeException("crash from Java");
    }
}
