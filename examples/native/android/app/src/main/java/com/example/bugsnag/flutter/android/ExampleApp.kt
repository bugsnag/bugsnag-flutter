package com.example.bugsnag.flutter.android

import android.app.Application
import com.bugsnag.android.Bugsnag
import com.bugsnag.android.Configuration
import com.bugsnag.flutter.BugsnagFlutterConfiguration

class ExampleApp : Application() {
    override fun onCreate() {
        super.onCreate()

        val config = Configuration.load(this)

        // Add the names of Dart packages that should be displayed as "in-project" on your dashboard
        config.projectPackages = setOf(packageName, "example_flutter")

        // Start Bugsnag Android SDK
        Bugsnag.start(this, config)

        // Uncomment to disable automatic detection of Dart errors:
        // BugsnagFlutterConfiguration.enabledErrorTypes.dartErrors = false
    }
}
