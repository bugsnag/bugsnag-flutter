package com.bugsnag.android;

import androidx.annotation.Nullable;

import com.bugsnag.android.internal.ImmutableConfig;
import com.bugsnag.flutter.JSONUtil;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Bugsnag Android internal API compatibility. All of this needs to move away the Flutter plugin
 * otherwise we likely won't be able to publish.
 */
public class BugsnagAndroid {
    private BugsnagAndroid() {
    }

    public static void notify(Event event) {
        getClient().notifyInternal(event, null);
    }

    public static void notify(JSONObject eventJson) {
        Client client = getClient();
        EventStore eventStore = client.getEventStore();
        ImmutableConfig config = client.immutableConfig;

        if (!config.shouldDiscardByReleaseStage()) {
            String filename = eventStore.getFilename(eventJson.optString("apiKey", config.getApiKey()));
            eventStore.enqueueContentForDelivery(eventJson.toString(), filename);
        }
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
