package com.bugsnag.android;

import com.bugsnag.flutter.JSONUtil;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Bugsnag Android internal API compatibility.
 */
public class BugsnagAndroid {
    private BugsnagAndroid() {
    }

    public static void notify(JSONObject eventJson) {
        Map<String, Object> eventMap = (Map<String, Object>) io.flutter.plugin.common.JSONUtil.unwrap(eventJson);

        BugsnagEventMapper eventMapper = new BugsnagEventMapper(getLogger());
        Event event = new Event(eventMapper.convertToEventImpl$bugsnag_android_core_release(eventMap, Bugsnag.getClient().immutableConfig.getApiKey()), getLogger());
        Bugsnag.getClient().notifyInternal(event, null);
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
        Event event = new Event(
                new EventInternal(
                        Bugsnag.getClient().immutableConfig,
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

        event.setApp(Bugsnag.getClient().getAppDataCollector().generateAppWithState());
        event.setDevice(Bugsnag.getClient().getDeviceDataCollector().generateDeviceWithState(System.currentTimeMillis()));

        return event;
    }

    private static Logger getLogger() {
        return Bugsnag.getClient().getLogger();
    }

    private static ErrorType decodeErrorType(String errorType) {
        ErrorType type = ErrorType.Companion.fromDescriptor$bugsnag_android_core_release(errorType);
        if (type == null) {
            type = ErrorType.ANDROID;
        }
        return type;
    }
}
