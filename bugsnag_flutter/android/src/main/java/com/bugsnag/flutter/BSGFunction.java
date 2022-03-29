package com.bugsnag.flutter;

import androidx.annotation.NonNull;

import org.json.JSONObject;

interface BSGFunction<T> {
    T invoke(@NonNull JSONObject argument) throws Exception;
}
