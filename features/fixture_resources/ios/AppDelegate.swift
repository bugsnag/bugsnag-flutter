import Flutter
import UIKit
import Bugsnag
import bugsnag_flutter

@main
class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        let controller = window?.rootViewController as! FlutterViewController
        let nativeChannel = FlutterMethodChannel(
            name: "com.bugsnag.mazeRunner/platform",
            binaryMessenger: controller.engine.binaryMessenger
        )

        nativeChannel.setMethodCallHandler { [weak self] call, result in
            self?.onMethod(call: call, result: result)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func onMethod(call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("FlutterMethodCallHandler: \(call.method) \(String(describing: call.arguments))")

        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "InvalidArguments", message: nil, details: nil))
            return
        }

        switch call.method {
        case "getCommand":
            if let url = args["commandUrl"] as? String {
                result(getCommand(urlString: url))
            } else {
                result(nil)
            }

        case "runScenario":
            if let scenarioName = args["scenarioName"] as? String,
               let targetScenario = Scenario.createScenario(named: scenarioName) {
                DispatchQueue.main.async {
                    targetScenario.run(withArguments: args)
                    result(nil)
                }
            } else {
                result(FlutterError(code: "NoSuchScenario", message: args["scenarioName"] as? String, details: nil))
            }

        case "startBugsnag":
            let config = BugsnagConfiguration.loadConfig()
            config.apiKey = "abc12312312312312312312312312312"

            if let notify = args["notifyEndpoint"] as? String,
               let session = args["sessionEndpoint"] as? String {
                config.endpoints = BugsnagEndpointConfiguration(
                    notify: notify,
                    sessions: session
                )
            }

            Bugsnag.start(with: config)

            if let extra = args["extraConfig"] as? String,
               extra.contains("disableDartErrors") {
                BugsnagFlutterConfiguration.enabledErrorTypes().dartErrors = false
            }

            result(nil)

        case "clearPersistentData":
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
            }

            let appSupport = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]
            let bugsnagDir = (appSupport as NSString).appendingPathComponent("com.bugsnag.Bugsnag")

            do {
                try FileManager.default.removeItem(atPath: bugsnagDir)
            } catch let error as NSError {
                if !(error.domain == NSCocoaErrorDomain && error.code == NSFileNoSuchFileError) {
                    print(error)
                }
            }

            result(nil)

        case "appHang":
            DispatchQueue.main.async {
                sleep(3)
                result(nil)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func getCommand(urlString: String) -> String? {
        guard let url = URL(string: urlString),
              let data = try? Data(contentsOf: url) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
