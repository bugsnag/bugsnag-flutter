package com.bugsnag.flutter;

import androidx.annotation.Nullable;

import com.bugsnag.android.JsonStream;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.StringWriter;

class JSONUtil {
    private JSONUtil() {
    }

    /**
     * Convenience function to encode a {@code Streamable} as a {@code JSONObject}.
     *
     * @param json the object to encode
     * @return the {@code JSONObject} equivilent of {@code json}
     */
    @Nullable
    static JSONObject toJson(JsonStream.Streamable json) {
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
}
