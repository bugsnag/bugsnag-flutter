package com.bugsnag.flutter;

import static com.bugsnag.flutter.JsonHelper.unpackFeatureFlags;
import static com.bugsnag.flutter.JsonHelper.unpackMetadata;
import static com.bugsnag.flutter.JsonHelper.unwrap;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bugsnag.android.Breadcrumb;
import com.bugsnag.android.Bugsnag;
import com.bugsnag.android.Configuration;
import com.bugsnag.android.EndpointConfiguration;
import com.bugsnag.android.ErrorTypes;
import com.bugsnag.android.Event;
import com.bugsnag.android.InternalHooks;
import com.bugsnag.android.ThreadSendPolicy;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashSet;

class BugsnagFlutter {

    private InternalHooks client;

    /*
     ***********************************************************************************************
     * All methods listed here must also be registered in the BugsnagFlutterPlugin otherwise they
     * won't be callable from the Flutter layer.
     ***********************************************************************************************
     */

    Context context;

    Boolean attach(@Nullable JSONObject args) {
        if (!isBugsnagStarted()) {
            return false;
        }

        if (isAttached()) {
            throw new IllegalStateException("bugsnag.attach may not be called more than once");
        }

        if (args != null) {
            JSONObject user = args.optJSONObject("user");
            if (user != null) {
                setUser(user);
            }

            if (args.has("context")) {
                setContext(args);
            }

            if (args.has("featureFlags")) {
                addFeatureFlags(args);
            }
        }

        client = new InternalHooks(Bugsnag.getClient());
        return true;
    }

    Void start(@Nullable JSONObject args) throws JSONException {
        if (isBugsnagStarted()) {
            throw new IllegalArgumentException("bugsnag.start may not be called after starting Bugsnag natively");
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

        client = new InternalHooks(Bugsnag.start(context, configuration));

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
        Bugsnag.leaveBreadcrumb(args.getString("message"),
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

    Void addFeatureFlags(@Nullable JSONObject args) {
        if (args == null) {
            return null;
        }

        Bugsnag.addFeatureFlags(unpackFeatureFlags(args.optJSONArray("featureFlags")));
        return null;
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

    private boolean isBugsnagStarted() {
        try {
            Bugsnag.getClient();
            return true;
        } catch (IllegalStateException iae) {
            return false;
        }
    }

    private boolean isAttached() {
        return client != null;
    }
}
