package com.bugsnag.flutter;

import android.content.Context;

import androidx.annotation.Nullable;

import com.bugsnag.android.Bugsnag;

import org.json.JSONObject;

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
