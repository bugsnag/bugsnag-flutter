package com.bugsnag.android;

import android.util.Log;

import androidx.annotation.Nullable;

import com.bugsnag.android.internal.ImmutableConfig;
import com.bugsnag.flutter.JSONUtil;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/*
 * Bugsnag Android internal API compatibility. This class shouldn't need to exist.
 */
public class BugsnagAndroid {
    private BugsnagAndroid() {
    }

    public static void notify(Event event) {
        getClient().notifyInternal(event, null);
    }

    public static void notify(JSONObject eventJson) {
        Client client = getClient();
        ImmutableConfig config = client.immutableConfig;
        BugsnagEventMapper eventMapper = new BugsnagEventMapper(getLogger());
        notify(new Event(
                eventMapper.convertToEventImpl$bugsnag_android_core_release(
                        (Map<String, Object>) io.flutter.plugin.common.JSONUtil.unwrap(eventJson),
                        eventJson.optString("apiKey", config.getApiKey())
                ),
                getLogger()
        ));
    }

    public static Error decodeError(JSONObject error) {
        return new Error(
                new ErrorInternal(
                        error.optString("errorClass"),
                        error.optString("message"),
                        decodeStacktrace(error.optJSONArray("stacktrace")),
                        decodeErrorType(error.optString("type"))
                ),
                getLogger()
        );
    }

    private static Stacktrace decodeStacktrace(JSONArray stacktrace) {
        int frameCount = stacktrace.length();
        List<Stackframe> frames = new ArrayList<>(frameCount);
        for (int index = 0; index < frameCount; index++) {
            frames.add(new Stackframe(JSONUtil.toMap(stacktrace.optJSONObject(index))));
        }

        return new Stacktrace(frames);
    }

    public static Event createEmptyEvent(boolean unhandled) {
        Client client = getClient();

        Event event = new Event(
                new EventInternal(
                        client.immutableConfig,
                        new SeverityReason(
                                unhandled
                                        ? SeverityReason.REASON_UNHANDLED_EXCEPTION
                                        : SeverityReason.REASON_HANDLED_EXCEPTION,
                                Severity.WARNING,
                                unhandled,
                                unhandled,
                                null,
                                null
                        )
                ),
                getLogger()
        );

        event.setApp(client.getAppDataCollector().generateAppWithState());
        event.setDevice(client.getDeviceDataCollector().generateDeviceWithState(System.currentTimeMillis()));

        return event;
    }

    private static Logger getLogger() {
        return getClient().getLogger();
    }

    private static Client getClient() {
        return Bugsnag.getClient();
    }

    private static ErrorType decodeErrorType(@Nullable String errorType) {
        if (errorType == null || errorType.equals("android")) {
            return ErrorType.ANDROID;
        } else if (errorType.equals("c")) {
            return ErrorType.C;
        } else if (errorType.equals("reactnativejs")) {
            return ErrorType.REACTNATIVEJS;
        } else {
            getLogger().w("Cannot convert '" + errorType + "' to Android compatible ErrorType");
            return ErrorType.ANDROID;
        }
    }
}
