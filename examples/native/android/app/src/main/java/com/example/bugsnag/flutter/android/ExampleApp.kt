package com.example.bugsnag.flutter.android

import android.app.Application
import com.bugsnag.android.Bugsnag

class ExampleApp : Application() {
    override fun onCreate() {
        super.onCreate()

        // Start Bugsnag Android SDK
        Bugsnag.start(this)
    }
}
