package com.bugsnag.android;

import androidx.annotation.NonNull;

import com.bugsnag.android.internal.ImmutableConfig;
import com.bugsnag.flutter.JsonHelper;

import org.json.JSONObject;

import java.util.List;
import java.util.Map;

public class InternalHooks {
    private final Client client;
    private final Logger logger;
    private final ImmutableConfig config;

    private final BugsnagEventMapper eventMapper;

    public InternalHooks(Client client) {
        this.client = client;
        this.logger = client.getLogger();
        this.config = client.getConfig();
        this.eventMapper = new BugsnagEventMapper(logger);
    }

    public Event createEvent(Object severityReason) {
        Event event = new Event(
                new EventInternal(
                        null,
                        config,
                        (SeverityReason) severityReason,
                        client.getMetadataState().getMetadata(),
                        client.getFeatureFlagState().getFeatureFlags()
                ),
                logger
        );

        event.setContext(client.getContext());
        event.setApp(client.getAppDataCollector().generateAppWithState());
        event.setDevice(client.getDeviceDataCollector().generateDeviceWithState(System.currentTimeMillis()));

        return event;
    }

    public Object createSeverityReason(String severityReasonType) {
        return SeverityReason.newInstance(severityReasonType);
    }

    public void deliverEvent(@NonNull Event event) {
        client.notifyInternal(event, null);
    }

    public JSONObject mapError(Error error) {
        return JsonHelper.toJson(error);
    }

    public Error unmapError(Map<String, Object> mappedError) {
        fixErrorType(mappedError);

        return new Error(
                eventMapper.convertErrorInternal$bugsnag_android_core_release(mappedError),
                logger
        );
    }

    public JSONObject mapEvent(Event event) {
        return JsonHelper.toJson(event);
    }

    @SuppressWarnings("unchecked")
    public Event unmapEvent(Map<String, Object> mappedEvent) {
        // Remove this once bugsnag-android supports Flutter ErrorTypes
        List<Map<String, Object>> errors = (List<Map<String, Object>>) mappedEvent.get("exceptions");
        for (Map<String, Object> error : errors) {
            fixErrorType(error);
        }

        String apiKey = (String) mappedEvent.get("apiKey");
        if (apiKey == null) {
            apiKey = config.getApiKey();
        }

        return new Event(
                eventMapper.convertToEventImpl$bugsnag_android_core_release(mappedEvent, apiKey),
                logger
        );
    }

    private void fixErrorType(Map<String, Object> mappedError) {
        // Remove this once bugsnag-android supports Flutter ErrorTypes
        if ("flutter".equals(mappedError.get("type"))) {
            mappedError.put("type", "android");
        }
    }

}
