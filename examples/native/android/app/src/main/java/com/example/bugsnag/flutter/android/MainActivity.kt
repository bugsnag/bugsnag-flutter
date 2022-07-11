package com.example.bugsnag.flutter.android

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterActivity

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main);
    }

    fun showFlutterView(view: View) {
        startActivity(FlutterActivity.createDefaultIntent(applicationContext))
    }

    fun unhandledException(view: View) {
        throw RuntimeException("this is an unhandled crash")
    }
}
