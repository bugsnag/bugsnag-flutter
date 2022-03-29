package com.bugsnag.flutter;

import androidx.annotation.NonNull;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * BugsnagFlutterPlugin
 */
public class BugsnagFlutterPlugin implements FlutterPlugin, MethodCallHandler {
    private final Map<String, BSGFunction<?>> functions = new HashMap<>();
    private final BugsnagFlutter bugsnag = new BugsnagFlutter();

    private MethodChannel channel;

    public BugsnagFlutterPlugin() {
        functions.put("createEvent", bugsnag::createEvent);
        functions.put("deliverEvent", bugsnag::deliverEvent);
        functions.put("setUser", bugsnag::setUser);
        functions.put("getUser", bugsnag::getUser);
        functions.put("setContext", bugsnag::setContext);
        functions.put("getContext", bugsnag::getContext);
        functions.put("leaveBreadcrumb", bugsnag::leaveBreadcrumb);
        functions.put("getBreadcrumbs", bugsnag::getBreadcrumbs);
        functions.put("addFeatureFlags", bugsnag::addFeatureFlags);
        functions.put("attach", bugsnag::attach);
        functions.put("start", bugsnag::start);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        bugsnag.context = flutterPluginBinding.getApplicationContext();

        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.bugsnag/client", JSONMethodCodec.INSTANCE);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        BSGFunction<?> function = functions.get(call.method);

        if (function != null) {
            try {
                result.success(function.invoke((JSONObject) call.arguments));
            } catch (Exception exception) {
                result.error(
                        exception.getClass().getSimpleName(),
                        exception.getMessage(),
                        exception.getStackTrace()
                );
            }
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        bugsnag.context = null;
        channel.setMethodCallHandler(null);
    }
}
