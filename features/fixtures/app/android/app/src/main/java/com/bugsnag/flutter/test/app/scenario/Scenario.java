package com.bugsnag.flutter.test.app.scenario;

import androidx.annotation.Nullable;

public abstract class Scenario {
    public abstract void run(@Nullable String extraConfig);
}
