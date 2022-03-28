package com.bugsnag.flutter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bugsnag.android.FeatureFlag;
import com.bugsnag.android.JsonStream;
import com.bugsnag.android.MetadataAware;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class JsonHelper {
    private JsonHelper() {
    }

    /**
     * Convenience function to encode a {@code Streamable} as a {@code JSONObject}.
     *
     * @param json the object to encode
     * @return the {@code JSONObject} equivalent of {@code json}
     */
    @Nullable
    public static JSONObject toJson(JsonStream.Streamable json) {
        StringWriter writer = new StringWriter();
        JsonStream stream = new JsonStream(writer);
        try {
            json.toStream(stream);
            return new JSONObject(writer.toString());
        } catch (IOException e) {
            return null;
        } catch (JSONException e) {
            return null;
        }
    }

    @SuppressWarnings("unchecked")
    public static Map<String, Object> unwrap(JSONObject object) {
        return (Map<String, Object>) io.flutter.plugin.common.JSONUtil.unwrap(object);
    }

    @SuppressWarnings("unchecked")
    public static <E, C extends Collection<E>> C unwrap(@Nullable JSONArray array, C outputCollection) {
        if (array != null) {
            int arrayLength = array.length();
            for (int index = 0; index < arrayLength; index++) {
                outputCollection.add((E) io.flutter.plugin.common.JSONUtil.unwrap(array.opt(index)));
            }
        }

        return outputCollection;
    }

    @SuppressWarnings("unchecked")
    public static JSONObject wrap(Map<String, Object> wrappedJson) {
        return (JSONObject) io.flutter.plugin.common.JSONUtil.wrap(wrappedJson);
    }

    // unpack Metadata with the Configuration.addMetadata public API
    public static void unpackMetadata(JSONObject metadata, MetadataAware target) {
        if (metadata == null || metadata.length() == 0) {
            return;
        }

        Iterator<String> sections = metadata.keys();
        while (sections.hasNext()) {
            String sectionName = sections.next();
            JSONObject section = metadata.optJSONObject(sectionName);

            if (section != null) {
                target.addMetadata(sectionName, unwrap(section));
            }
        }
    }

    @NonNull
    public static List<FeatureFlag> unpackFeatureFlags(@Nullable JSONArray featureFlags) {
        if (featureFlags == null) {
            return Collections.emptyList();
        }

        List<FeatureFlag> flags = new ArrayList<>(featureFlags.length());
        for (int index = 0; index < featureFlags.length(); index++) {
            JSONObject featureFlag = featureFlags.optJSONObject(index);
            flags.add(new FeatureFlag(
                    featureFlag.optString("featureFlag"),
                    (String) featureFlag.opt("variant")
            ));
        }
        return flags;
    }
}
