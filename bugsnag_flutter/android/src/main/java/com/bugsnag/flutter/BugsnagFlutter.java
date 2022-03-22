package com.bugsnag.flutter;

import android.content.Context;

import androidx.annotation.Nullable;

import com.bugsnag.android.Bugsnag;
import com.bugsnag.android.BugsnagAndroid;
import com.bugsnag.android.Event;
import com.bugsnag.android.FeatureFlag;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

class BugsnagFlutter {

    private boolean isAttached = false;

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

        isAttached = true;
        return true;
    }

    JSONObject getUser(@Nullable JSONObject args) {
        return JSONUtil.toJson(Bugsnag.getUser());
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

        Event event = BugsnagAndroid.createEmptyEvent(args.optBoolean("unhandled"));
        JSONObject error = args.optJSONObject("error");

        event.getErrors().add(BugsnagAndroid.decodeError(error));

        if (args.optBoolean("delivery")) {
            // Flutter layer has asked us to deliver the Event immediately
            BugsnagAndroid.notify(event);
            return null;
        } else {
            return JSONUtil.toJson(event);
        }
    }

    JSONObject deliverEvent(@Nullable JSONObject args) {
        if (args == null) {
            return null;
        }

        BugsnagAndroid.notify(args);
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
