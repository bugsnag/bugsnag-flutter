package com.bugsnag.flutter;

import static com.bugsnag.flutter.JsonHelper.unpackFeatureFlags;
import static com.bugsnag.flutter.JsonHelper.unpackMetadata;
import static com.bugsnag.flutter.JsonHelper.unwrap;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bugsnag.android.Breadcrumb;
import com.bugsnag.android.Bugsnag;
import com.bugsnag.android.Client;
import com.bugsnag.android.Configuration;
import com.bugsnag.android.EndpointConfiguration;
import com.bugsnag.android.ErrorTypes;
import com.bugsnag.android.Event;
import com.bugsnag.android.InternalHooks;
import com.bugsnag.android.LastRunInfo;
import com.bugsnag.android.Notifier;
import com.bugsnag.android.ThreadSendPolicy;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

class BugsnagFlutter {

    private InternalHooks client;

    private static boolean isAttached = false;

    private static boolean isAnyStarted = false;
    private boolean isStarted = false;

    /*
     ***********************************************************************************************
     * All methods listed here must also be registered in the BugsnagFlutterPlugin otherwise they
     * won't be callable from the Flutter layer.
     ***********************************************************************************************
     */

    Context context;

    JSONObject attach(@Nullable JSONObject args) throws Exception {
        JSONObject result = new JSONObject()
                .put("config", new JSONObject()
                        .put("enabledErrorTypes", new JSONObject()
                                .put("dartErrors", BugsnagFlutterConfiguration.enabledErrorTypes.dartErrors)
                        )
                );

        if (isAttached) {
            Log.i("BugsnagFlutter", "bugsnag.attach() has already been called. Ignoring.");
            return result;
        }

        Client nativeClient = InternalHooks.getClient();
        if (nativeClient == null) {
            throw new IllegalStateException("bugsnag.attach() can only be called once the native layer has already been started, have you called Bugsnag.start() from your Android code?");
        }

        client = new InternalHooks(nativeClient);

        if (args != null && args.has("notifier")) {
            Notifier notifier = client.getNotifier();
            JSONObject notifierJson = args.getJSONObject("notifier");
            notifier.setName(notifierJson.getString("name"));
            notifier.setVersion(notifierJson.getString("version"));
            notifier.setUrl(notifierJson.getString("url"));
            notifier.setDependencies(Collections.singletonList(new Notifier()));
        }

        isAttached = true;
        return result;
    }

    Void start(@Nullable JSONObject args) throws Exception {
        if (isStarted) {
            Log.w("BugsnagFlutter", "bugsnag.start() was called more than once. Ignoring.");
            return null;
        }

        if (isAnyStarted) {
            Log.w("BugsnagFlutter", "bugsnag.start() was called from a previous Flutter context. Reusing existing client. Config not applied.");
            client = new InternalHooks(InternalHooks.getClient());
            return null;
        }

        if (InternalHooks.getClient() != null) {
            throw new IllegalStateException("bugsnag.start() may not be called after starting Bugsnag natively");
        }
        JSONObject arguments = args != null ? args : new JSONObject();

        Configuration configuration = arguments.has("apiKey")
                ? new Configuration(arguments.getString("apiKey"))
                : Configuration.load(context);

        configuration.setAppType(getString(arguments, "appType", configuration.getAppType()));
        configuration.setAppVersion(getString(arguments, "appVersion", configuration.getAppVersion()));
        configuration.setAutoTrackSessions(arguments.optBoolean("autoTrackSessions", configuration.getAutoTrackSessions()));
        configuration.setAutoDetectErrors(arguments.optBoolean("autoDetectErrors", configuration.getAutoDetectErrors()));
        configuration.setContext(getString(arguments, "context", configuration.getContext()));
        configuration.setLaunchDurationMillis(arguments.optLong("launchDurationMillis", configuration.getLaunchDurationMillis()));
        configuration.setSendLaunchCrashesSynchronously(arguments.optBoolean("sendLaunchCrashesSynchronously", configuration.getSendLaunchCrashesSynchronously()));
        configuration.setMaxBreadcrumbs(arguments.optInt("maxBreadcrumbs", configuration.getMaxBreadcrumbs()));
        configuration.setMaxPersistedEvents(arguments.optInt("maxPersistedEvents", configuration.getMaxPersistedEvents()));
        configuration.setMaxPersistedSessions(arguments.optInt("maxPersistedSessions", configuration.getMaxPersistedSessions()));
        configuration.setMaxStringValueLength(arguments.optInt("maxStringValueLength", configuration.getMaxStringValueLength()));
        configuration.setReleaseStage(getString(arguments, "releaseStage", configuration.getReleaseStage()));
        configuration.setPersistUser(arguments.optBoolean("persistUser", configuration.getPersistUser()));

        if (arguments.has("redactedKeys")) {
            configuration.setRedactedKeys(unwrap(arguments.optJSONArray("redactedKeys"), new HashSet<>()));
        }

        if (arguments.has("discardClasses")) {
            configuration.setDiscardClasses(unwrap(arguments.optJSONArray("discardClasses"), new HashSet<>()));
        }

        if (arguments.has("enabledReleaseStages")) {
            configuration.setEnabledReleaseStages(unwrap(arguments.optJSONArray("enabledReleaseStages"), new HashSet<>()));
        }

        JSONObject user = arguments.optJSONObject("user");
        if (user != null) {
            configuration.setUser(
                    getString(user, "id"),
                    getString(user, "email"),
                    getString(user, "name")
            );
        }

        JSONObject endpoints = arguments.optJSONObject("endpoints");
        if (endpoints != null) {
            configuration.setEndpoints(
                    new EndpointConfiguration(
                            endpoints.getString("notify"),
                            endpoints.getString("sessions")
                    )
            );
        }

        String sendThreads = arguments.optString("sendThreads");
        if (sendThreads.equals("always")) {
            configuration.setSendThreads(ThreadSendPolicy.ALWAYS);
        } else if (sendThreads.equals("unhandledOnly")) {
            configuration.setSendThreads(ThreadSendPolicy.UNHANDLED_ONLY);
        } else if (sendThreads.equals("never")) {
            configuration.setSendThreads(ThreadSendPolicy.NEVER);
        }

        configuration.setEnabledBreadcrumbTypes(
                EnumHelper.unwrapBreadcrumbTypes(arguments.optJSONArray("enabledBreadcrumbTypes"))
        );

        JSONObject enabledErrorTypes = arguments.optJSONObject("enabledErrorTypes");
        if (enabledErrorTypes != null) {
            ErrorTypes errorTypes = new ErrorTypes();
            errorTypes.setUnhandledExceptions(enabledErrorTypes.optBoolean("unhandledExceptions"));
            errorTypes.setNdkCrashes(enabledErrorTypes.optBoolean("crashes"));
            errorTypes.setAnrs(enabledErrorTypes.optBoolean("anrs"));

            configuration.setEnabledErrorTypes(errorTypes);
        }

        unpackMetadata(arguments.optJSONObject("metadata"), configuration);

        configuration.addFeatureFlags(unpackFeatureFlags(arguments.optJSONArray("featureFlags")));

        Notifier notifier = InternalHooks.getNotifier(configuration);
        if (arguments.has("notifier")) {
            JSONObject notifierJson = arguments.getJSONObject("notifier");
            notifier.setName(notifierJson.getString("name"));
            notifier.setVersion(notifierJson.getString("version"));
            notifier.setUrl(notifierJson.getString("url"));
            notifier.setDependencies(Collections.singletonList(new Notifier()));
        }

        if (arguments.has("persistenceDirectory")) {
            configuration.setPersistenceDirectory(new File(arguments.getString("persistenceDirectory")));
        }

        if (arguments.has("projectPackages")) {
            JSONObject projectPackages = arguments.optJSONObject("projectPackages");

            JSONArray packageNames = projectPackages.getJSONArray("packageNames");
            final int packageCount = packageNames.length();
            Set<String> packagesSet = new LinkedHashSet<>(packageCount);

            for (int index = 0; index < packageCount; index++) {
                packagesSet.add(packageNames.getString(index));
            }

            if (projectPackages.optBoolean("includeDefaults")) {
                packagesSet.add(context.getPackageName());
            }

            configuration.setProjectPackages(packagesSet);
        }

        if (arguments.has("telemetry")) {
            configuration.setTelemetry(EnumHelper.unwrapTelemetry(arguments.optJSONArray("telemetry")));
        }

        if (arguments.has("versionCode")) {
            configuration.setVersionCode(arguments.getInt("versionCode"));
        }

        client = new InternalHooks(Bugsnag.start(context, configuration));
        isAnyStarted = true;
        isStarted = true;
        return null;
    }

    JSONObject getUser(@Nullable JSONObject args) {
        return JsonHelper.toJson(Bugsnag.getUser());
    }

    Void setUser(@Nullable JSONObject user) {
        if (user != null) {
            Bugsnag.setUser(
                    getString(user, "id"),
                    getString(user, "email"),
                    getString(user, "name")
            );
        } else {
            Bugsnag.setUser(null, null, null);
        }

        return null;
    }

    Void setContext(@Nullable JSONObject args) {
        if (args != null) {
            Bugsnag.setContext(getString(args, "context"));
        }

        return null;
    }

    String getContext(@Nullable JSONObject args) {
        return Bugsnag.getContext();
    }

    Void leaveBreadcrumb(@Nullable JSONObject args) throws Exception {
        if (args != null &&
                hasString(args, "name") &&
                args.has("metaData") &&
                hasString(args, "type")) {
            Bugsnag.leaveBreadcrumb(args.getString("name"),
                    JsonHelper.unwrap(args.getJSONObject("metaData")),
                    JsonHelper.unpackBreadcrumbType(args.getString("type")));
        }
        return null;
    }

    JSONArray getBreadcrumbs(@Nullable JSONObject args) {
        JSONArray array = new JSONArray();
        for (Breadcrumb breadcrumb : Bugsnag.getBreadcrumbs()) {
            array.put(JsonHelper.toJson(breadcrumb));
        }
        return array;
    }

    Void addFeatureFlags(@Nullable JSONArray args) {
        if (args != null) {
            Bugsnag.addFeatureFlags(unpackFeatureFlags(args));
        }
        return null;
    }

    Void clearFeatureFlag(@Nullable JSONObject args) throws JSONException {
        if (args != null && hasString(args, "name")) {
            Bugsnag.clearFeatureFlag(args.getString("name"));
        }
        return null;
    }

    Void clearFeatureFlags(@Nullable JSONObject args) {
        Bugsnag.clearFeatureFlags();
        return null;
    }

    Void addMetadata(@Nullable JSONObject args) throws JSONException {
        if (args == null || !hasString(args,"section") || !args.has("metadata")) {
            return null;
        }

        String section = args.getString("section");
        Map<String, ? extends Object> metadata = JsonHelper.unwrap(args.getJSONObject("metadata"));

        Bugsnag.addMetadata(section, metadata);
        return null;
    }

    Void clearMetadata(@Nullable JSONObject args) throws JSONException {
        if (args == null || !hasString(args, "section")) {
            return null;
        }

        if (hasString(args, "key")) {
            Bugsnag.clearMetadata(args.getString("section"), args.getString("key"));
        } else {
            Bugsnag.clearMetadata(args.getString("section"));
        }

        return null;
    }

    JSONObject getMetadata(@Nullable JSONObject args) throws JSONException {
        if (args == null || !hasString(args, "section")) {
            return null;
        }

        return JsonHelper.wrap(Bugsnag.getMetadata(args.getString("section")));
    }

    Void startSession(@Nullable Void args) {
        Bugsnag.startSession();
        return null;
    }

    Void pauseSession(@Nullable Void args) {
        Bugsnag.pauseSession();
        return null;
    }

    Boolean resumeSession(@Nullable Void args) {
        return Bugsnag.resumeSession();
    }

    Void markLaunchCompleted(@Nullable Void args) {
        Bugsnag.markLaunchCompleted();
        return null;
    }

    JSONObject getLastRunInfo(@Nullable Void args) throws JSONException {
        LastRunInfo lastRunInfo = Bugsnag.getLastRunInfo();
        return (lastRunInfo == null) ? null : new JSONObject()
                .put("consecutiveLaunchCrashes", lastRunInfo.getConsecutiveLaunchCrashes())
                .put("crashed", lastRunInfo.getCrashed())
                .put("crashedDuringLaunch", lastRunInfo.getCrashedDuringLaunch());
    }

    @SuppressWarnings("unchecked")
    JSONObject createEvent(@Nullable JSONObject args) throws JSONException {
        if (args == null || !args.has("error") || client == null) {
            return null;
        }

        JSONObject error = args.getJSONObject("error");
        boolean deliver = args.optBoolean("deliver");

        // early exit if we are going to discard this Error, but *only* if we would also deliver
        // immediately - otherwise the Dart layer could modify it and avoid discard
        if (deliver && client.shouldDiscardError(error)) {
            return null;
        }

        boolean unhandled = args.optBoolean("unhandled");

        Event event = client.createEvent(
                client.createSeverityReason(
                        unhandled ? "unhandledException" : "handledException"
                )
        );

        event.getErrors().add(client.unmapError(unwrap(error)));

        Object flutterMetadata = JsonHelper.unwrap(args.optJSONObject("flutterMetadata"));
        if (flutterMetadata instanceof Map) {
            event.addMetadata("flutter", (Map<String, Object>) flutterMetadata);
        }

        if (deliver) {
            // Flutter layer has asked us to deliver the Event immediately
            client.deliverEvent(event);
            return null;
        } else {
            return client.mapEvent(event);
        }
    }

    JSONObject deliverEvent(@Nullable JSONObject eventJson) {
        if (eventJson == null || client == null) {
            return null;
        }

        if (client.shouldDiscardEvent(eventJson)) {
            return null;
        }

        Event event = client.unmapEvent(unwrap(eventJson));
        client.deliverEvent(event);
        return null;
    }

    @Nullable String getString(JSONObject args, String key) {
        Object value = args.opt(key);
        return value instanceof String ? (String) value : null;
    }

    @Nullable String getString(JSONObject args, String key, @Nullable String fallback) {
        String value = getString(args, key);
        return value != null ? value : fallback;
    }

    boolean hasString(JSONObject args, String key) {
        return getString(args, key) != null;
    }
}
