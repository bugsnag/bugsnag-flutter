package com.bugsnag.flutter;

import android.content.Context;

import androidx.annotation.Nullable;

import com.bugsnag.android.Bugsnag;

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
class BugsnagFlutter {

    Context context;

    Void attach(@Nullable JSONObject args) {
        Bugsnag.start(context);
        return null;
    }

    JSONObject getUser(@Nullable JSONObject args) {
        return JSONUtil.toJson(Bugsnag.getUser());
    }

    Void setUser(@Nullable JSONObject user) {
        if (user != null) {
            Bugsnag.setUser(
                    user.optString("id"),
                    user.optString("email"),
                    user.optString("name")
            );
        } else {
            Bugsnag.setUser(null, null, null);
        }

        return null;
    }

    Void setContext(@Nullable JSONObject args) {
        Bugsnag.setContext(args.optString("context"));
        return null;
    }

    String getContext(@Nullable JSONObject args) {
        return Bugsnag.getContext();
    }
}
