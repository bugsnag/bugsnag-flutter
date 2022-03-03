package com.bugsnag.flutter;

import android.content.Context;

import androidx.annotation.Nullable;

import com.bugsnag.android.Bugsnag;
import com.bugsnag.android.FeatureFlag;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * This sits between the Flutter layer of function calls, and the native {@link Bugsnag} class.
 * Each method in this class corresponds to a {@link BSGFunction} listed in
 * {@link BugsnagFlutterPlugin}, and is responsible for unwrapping and wrapping the JSON arguments
 * passed from and to the Flutter layer.
 *
 * In order to support the contract imposed by {@link BSGFunction} methods may need to return
 * {@code Void} (the object) instead of {@code void} as would be typical.
 */
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

    private boolean isBugsnagStarted() {
        try {
            Bugsnag.getClient();
            return true;
        } catch (IllegalArgumentException iae) {
            return false;
        }
    }
}
