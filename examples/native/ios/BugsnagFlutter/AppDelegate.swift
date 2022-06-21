//
//  AppDelegate.swift
//  BugsnagFlutter
//

import Bugsnag
import bugsnag_flutter
import Flutter
import FlutterPluginRegistrant
import UIKit

@main
class AppDelegate: FlutterAppDelegate {
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Start Bugsnag iOS SDK
        Bugsnag.start()
        
        // Runs the default Dart entrypoint with a default Flutter route.
        flutterEngine.run();
        
        // Connect plugins (bugsnag_flutter includes a plugin with iOS platform code).
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions);
    }
}

var flutterEngine = FlutterEngine(name: "example flutter engine")
