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

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

class BugsnagFlutter {

    private InternalHooks client;

    private static boolean isAnyAttached = false;
    private boolean isAttached = false;

    private static boolean isAnyStarted = false;
    private boolean isStarted = false;

    /*
     ***********************************************************************************************
     * All methods listed here must also be registered in the BugsnagFlutterPlugin otherwise they
     * won't be callable from the Flutter layer.
     ***********************************************************************************************
     */

    Context context;

    Void attach(@NonNull JSONObject args) throws Exception {
        if (isAttached) {
            throw new IllegalStateException("bugsnag.attach() may not be called more than once");
        }

        if (isAnyAttached) {
            Log.i("BugsnagFlutter", "bugsnag.attach() was called from a previous Flutter context. Ignoring.");
            return null;
        }

        Client nativeClient = InternalHooks.getClient();
        if (nativeClient == null) {
            throw new IllegalStateException("bugsnag.attach() can only be called once the native layer has already been started, have you called Bugsnag.start() from your Android code?");
        }

        if (args != null) {
            JSONObject user = args.optJSONObject("user");
            if (user != null) {
                setUser(user);
            }

            if (args.has("context")) {
                setContext(args);
            }
        }

        addFeatureFlags(args.optJSONArray("featureFlags"));

        client = new InternalHooks(nativeClient);

        Notifier notifier = client.getNotifier();
        JSONObject notifierJson = args.getJSONObject("notifier");
        notifier.setName(notifierJson.getString("name"));
        notifier.setVersion(notifierJson.getString("version"));
        notifier.setUrl(notifierJson.getString("url"));
        notifier.setDependencies(Collections.singletonList(new Notifier()));

        isAnyAttached = true;
        isAttached = true;
        return null;
    }

    Void start(@NonNull JSONObject args) throws Exception {
        if (isStarted) {
            Log.w("BugsnagFlutter", "bugsnag.start() was called more than once. Ignoring.");
            return null;
        }

        if (isAnyStarted) {
            Log.i("BugsnagFlutter", "bugsnag.start() was called from a previous Flutter context. Ignoring.");
            return null;
        }

        if (InternalHooks.getClient() != null) {
            throw new IllegalStateException("bugsnag.start() may not be called after starting Bugsnag natively");
        }

        Configuration configuration = Configuration.load(context);

        configuration.setApiKey(args.optString("apiKey", configuration.getApiKey()));
        configuration.setAppType(args.optString("appType", configuration.getAppType()));
        configuration.setAppVersion(args.optString("appVersion", configuration.getAppVersion()));
        configuration.setAutoTrackSessions(args.optBoolean("autoTrackSessions", configuration.getAutoTrackSessions()));
        configuration.setContext(args.optString("context", configuration.getContext()));
        configuration.setLaunchDurationMillis(args.optLong("launchDurationMillis", configuration.getLaunchDurationMillis()));
        configuration.setMaxBreadcrumbs(args.optInt("maxBreadcrumbs", configuration.getMaxBreadcrumbs()));
        configuration.setMaxPersistedEvents(args.optInt("maxPersistedEvents", configuration.getMaxPersistedEvents()));
        configuration.setMaxPersistedSessions(args.optInt("maxPersistedSessions", configuration.getMaxPersistedSessions()));
        configuration.setReleaseStage(args.optString("releaseStage", configuration.getReleaseStage()));
        configuration.setPersistUser(args.optBoolean("persistUser", configuration.getPersistUser()));

        if (args.has("redactedKeys")) {
            configuration.setRedactedKeys(unwrap(args.optJSONArray("redactedKeys"), new HashSet<>()));
        }

        if (args.has("enabledReleaseStages")) {
            configuration.setEnabledReleaseStages(unwrap(args.optJSONArray("enabledReleaseStages"), new HashSet<>()));
        }

        JSONObject user = args.optJSONObject("user");
        if (user != null) {
            configuration.setUser(
                    user.optString("id", null),
                    user.optString("email", null),
                    user.optString("name", null)
            );
        }

        JSONObject endpoints = args.optJSONObject("endpoints");
        if (endpoints != null) {
            configuration.setEndpoints(
                    new EndpointConfiguration(
                            endpoints.getString("notify"),
                            endpoints.getString("sessions")
                    )
            );
        }

        String sendThreads = args.optString("sendThreads");
        if (sendThreads.equals("always")) {
            configuration.setSendThreads(ThreadSendPolicy.ALWAYS);
        } else if (sendThreads.equals("unhandledOnly")) {
            configuration.setSendThreads(ThreadSendPolicy.UNHANDLED_ONLY);
        } else if (sendThreads.equals("never")) {
            configuration.setSendThreads(ThreadSendPolicy.NEVER);
        }

        configuration.setEnabledBreadcrumbTypes(
                EnumHelper.unwrapBreadcrumbTypes(args.optJSONArray("enabledBreadcrumbTypes"))
        );

        JSONObject enabledErrorTypes = args.optJSONObject("enabledErrorTypes");
        if (enabledErrorTypes != null) {
            ErrorTypes errorTypes = new ErrorTypes();
            errorTypes.setUnhandledExceptions(enabledErrorTypes.optBoolean("unhandledExceptions"));
            errorTypes.setNdkCrashes(enabledErrorTypes.optBoolean("crashes"));
            errorTypes.setAnrs(enabledErrorTypes.optBoolean("anrs"));

            configuration.setEnabledErrorTypes(errorTypes);
        }

        unpackMetadata(args.optJSONObject("metadata"), configuration);

        configuration.addFeatureFlags(unpackFeatureFlags(args.optJSONArray("featureFlags")));

        Notifier notifier = InternalHooks.getNotifier(configuration);
        JSONObject notifierJson = args.getJSONObject("notifier");
        notifier.setName(notifierJson.getString("name"));
        notifier.setVersion(notifierJson.getString("version"));
        notifier.setUrl(notifierJson.getString("url"));
        notifier.setDependencies(Collections.singletonList(new Notifier()));

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
                    (String) user.opt("id"),
                    (String) user.opt("email"),
                    (String) user.opt("name")
            );
        } else {
            Bugsnag.setUser(null, null, null);
        }

        return null;
    }

    Void setContext(@Nullable JSONObject args) {
        if (args != null) {
            Bugsnag.setContext((String) args.opt("context"));
        }

        return null;
    }

    String getContext(@Nullable JSONObject args) {
        return Bugsnag.getContext();
    }

    Void leaveBreadcrumb(@NonNull JSONObject args) throws Exception {
        Bugsnag.leaveBreadcrumb(args.getString("name"),
                JsonHelper.unwrap(args.getJSONObject("metaData")),
                JsonHelper.unpackBreadcrumbType(args.getString("type")));
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

    Void clearFeatureFlag(@NonNull JSONObject args) throws JSONException {
        Bugsnag.clearFeatureFlag(args.getString("name"));
        return null;
    }

    Void clearFeatureFlags(@Nullable JSONObject args) {
        Bugsnag.clearFeatureFlags();
        return null;
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

    Void markLaunchComplete(@Nullable Void args) {
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

    JSONObject createEvent(@Nullable JSONObject args) {
        if (args == null) {
            return null;
        }

        boolean unhandled = args.optBoolean("unhandled");

        Event event = client.createEvent(
                client.createSeverityReason(
                        unhandled ? "unhandledException" : "handledException"
                )
        );

        JSONObject error = args.optJSONObject("error");
        event.getErrors().add(client.unmapError(unwrap(error)));

        Object flutterMetadata = JsonHelper.unwrap(args.optJSONObject("flutterMetadata"));
        if (flutterMetadata instanceof Map) {
            event.addMetadata("flutter", (Map<String, Object>)flutterMetadata);
        }

        if (args.optBoolean("deliver")) {
            // Flutter layer has asked us to deliver the Event immediately
            client.deliverEvent(event);
            return null;
        } else {
            return client.mapEvent(event);
        }
    }

    JSONObject deliverEvent(@Nullable JSONObject eventJson) {
        if (eventJson == null) {
            return null;
        }

        Event event = client.unmapEvent(unwrap(eventJson));
        client.deliverEvent(event);
        return null;
    }
}
