package com.bugsnag.flutter.test.app.scenario;

import android.content.Context;

import com.bugsnag.android.Bugsnag;
import com.bugsnag.android.Configuration;
import com.bugsnag.android.EndpointConfiguration;

import java.util.LinkedHashSet;
import java.util.Objects;
import java.util.Set;

import io.flutter.plugin.common.MethodCall;

public class NativeProjectPackagesScenario extends Scenario {
    @Override
    public void run(Context context, MethodCall call) {

        Configuration configuration = Configuration.load(context);
        configuration.setApiKey("abc12312312312312312312312312312");
        configuration.setEndpoints(new EndpointConfiguration(
                Objects.requireNonNull(call.argument("notifyEndpoint")),
                Objects.requireNonNull(call.argument("sessionEndpoint"))));

        Set<String> projectPackages = new LinkedHashSet<>();
        projectPackages.add("test_package");
        projectPackages.add("MazeRunner");
        projectPackages.add("com.bugsnag.flutter.test.app");
        configuration.setProjectPackages(projectPackages);

        Bugsnag.start(context, configuration);
    }
}
