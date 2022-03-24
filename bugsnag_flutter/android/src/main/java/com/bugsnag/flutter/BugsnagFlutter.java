package com.bugsnag.flutter;

import static com.bugsnag.flutter.JsonHelper.unwrap;

import android.content.Context;

import androidx.annotation.Nullable;

import com.bugsnag.android.Bugsnag;
import com.bugsnag.android.Event;
import com.bugsnag.android.FeatureFlag;
import com.bugsnag.android.InternalHooks;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

class BugsnagFlutter {

    private boolean isAttached = false;

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

        if (isAttached) {
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
        isAttached = true;
        return true;
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

    Void addFeatureFlags(@Nullable JSONObject args) {
        if (args == null) {
            return null;
        }

        JSONArray featureFlags = args.optJSONArray("featureFlags");
        if (featureFlags != null) {
            List<FeatureFlag> flags = new ArrayList<>(featureFlags.length());
            for (int index = 0; index < featureFlags.length(); index++) {
                JSONObject featureFlag = featureFlags.optJSONObject(index);
                flags.add(new FeatureFlag(
                        featureFlag.optString("featureFlag"),
                        (String) featureFlag.opt("variant")
                ));
            }
        }

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
        } catch (IllegalArgumentException iae) {
            return false;
        }
    }
}
