package com.bugsnag.android;

import androidx.annotation.NonNull;

import com.bugsnag.android.internal.BugsnagMapper;
import com.bugsnag.android.internal.ImmutableConfig;
import com.bugsnag.flutter.JsonHelper;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.Map;

/**
 * Provides access to Bugsnag internals by being part of package com.bugsnag.android
 */
public class InternalHooks {
    private final Client client;
    private final Logger logger;
    private final ImmutableConfig config;

    private final BugsnagMapper modelMapper;

    public InternalHooks(Client client) {
        this.client = client;
        this.logger = client.getLogger();
        this.config = client.getConfig();
        this.modelMapper = new BugsnagMapper(logger);
    }

    public static Client getClient() {
        return Bugsnag.client;
    }

    public Notifier getNotifier() {
        return client.notifier;
    }

    public static Notifier getNotifier(Configuration configuration) {
        return configuration.getNotifier();
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

        event.setBreadcrumbs(client.getBreadcrumbs());

        User user = client.getUser();
        event.setUser(user.getId(), user.getEmail(), user.getName());

        AppDataCollector appDataCollector = client.getAppDataCollector();
        event.setApp(appDataCollector.generateAppWithState());
        event.addMetadata("app", appDataCollector.getAppDataMetadata());

        DeviceDataCollector deviceDataCollector = client.getDeviceDataCollector();
        event.setDevice(deviceDataCollector.generateDeviceWithState(System.currentTimeMillis()));
        event.addMetadata("device", deviceDataCollector.getDeviceMetadata());

        event.setContext(client.getContext());

        return event;
    }

    public Object createSeverityReason(String severityReasonType) {
        return SeverityReason.newInstance(severityReasonType);
    }

    public void deliverEvent(@NonNull Event event) {
        client.notifyInternal(event, null);

        if (event.getImpl().getOriginalUnhandled()) {
            client.getEventStore().flushAsync();
        }
    }

    /**
     * Check if an Event should be discarded while it's still in it's JSON form. This allows us
     * to avoid unmapping JSON events that will just be discarded.
     *
     * @see #shouldDiscardError(JSONObject)
     */
    public boolean shouldDiscardEvent(JSONObject event) {
        JSONArray errors = event.optJSONArray("exceptions");
        if (errors == null) {
            // there are no exceptions - which is weird, but not strictly
            return false;
        }

        int errorCount = errors.length();

        for (int i = 0; i < errorCount; i++) {
            JSONObject error = errors.optJSONObject(i);
            if (shouldDiscardError(error)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Check if an Error should be discarded while it's still in it's JSON form. This allows us
     * to avoid unmapping JSON errors that will just be discarded.
     */
    public boolean shouldDiscardError(JSONObject error) {
        if (error != null) {
            String errorClass = error.optString("errorClass");
            return config.shouldDiscardError(errorClass);
        }

        return false;
    }

    public Error unmapError(Map<String, Object> mappedError) {
        return modelMapper.convertToError(mappedError);
    }

    public JSONObject mapEvent(Event event) {
        return JsonHelper.wrap(modelMapper.convertToMap(event));
    }

    public Event unmapEvent(Map<String, Object> mappedEvent) {
        String apiKey = (String) mappedEvent.get("apiKey");
        if (apiKey == null) {
            apiKey = config.getApiKey();
        }

        return modelMapper.convertToEvent(mappedEvent, apiKey);
    }

}
