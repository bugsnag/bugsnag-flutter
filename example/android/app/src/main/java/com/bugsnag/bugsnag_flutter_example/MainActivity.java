package com.bugsnag.bugsnag_flutter_example;

import android.os.Bundle;

import com.bugsnag.android.Bugsnag;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Bugsnag.start(getApplicationContext());
    }
}
