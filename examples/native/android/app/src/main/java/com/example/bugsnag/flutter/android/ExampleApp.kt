package com.example.bugsnag.flutter.android

import android.app.Application
import com.bugsnag.android.Bugsnag
import com.bugsnag.flutter.BugsnagFlutterConfiguration

class ExampleApp : Application() {
    override fun onCreate() {
        super.onCreate()

        // Start Bugsnag Android SDK
        Bugsnag.start(this)

        // Uncomment to disable automatic detection of Dart errors:
        // BugsnagFlutterConfiguration.enabledErrorTypes.dartErrors = false
    }
}
