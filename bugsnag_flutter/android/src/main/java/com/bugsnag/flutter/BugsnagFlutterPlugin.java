package com.bugsnag.flutter;

import androidx.annotation.NonNull;

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
        addFunction("createEvent",          bugsnag::createEvent);
        addFunction("deliverEvent",         bugsnag::deliverEvent);
        addFunction("setUser",              bugsnag::setUser);
        addFunction("getUser",              bugsnag::getUser);
        addFunction("setContext",           bugsnag::setContext);
        addFunction("getContext",           bugsnag::getContext);
        addFunction("leaveBreadcrumb",      bugsnag::leaveBreadcrumb);
        addFunction("getBreadcrumbs",       bugsnag::getBreadcrumbs);
        addFunction("addFeatureFlag",       bugsnag::addFeatureFlag);
        addFunction("addFeatureFlags",      bugsnag::addFeatureFlags);
        addFunction("clearFeatureFlag",     bugsnag::clearFeatureFlag);
        addFunction("clearFeatureFlags",    bugsnag::clearFeatureFlags);
        addFunction("attach",               bugsnag::attach);
        addFunction("start",                bugsnag::start);
    }

    private <T> void addFunction(String name, BSGFunction<T> function) {
        functions.put(name, function);
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
                result.success(function.invoke(call.arguments()));
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
