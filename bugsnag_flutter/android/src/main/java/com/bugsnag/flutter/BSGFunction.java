package com.bugsnag.flutter;

import androidx.annotation.Nullable;

import org.json.JSONObject;

interface BSGFunction<T> {
    T invoke(@Nullable JSONObject argument);
}
