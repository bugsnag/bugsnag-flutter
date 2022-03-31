package com.bugsnag.flutter;

interface BSGFunction<T> {
    Object invoke(T argument) throws Exception;
}
