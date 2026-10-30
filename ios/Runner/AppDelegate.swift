import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let deviceChannel = FlutterMethodChannel(
      name: "com.matching61.hotswing/device",
      binaryMessenger: controller.binaryMessenger
    )

    deviceChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "setKeepScreenOn":
        if let args = call.arguments as? [String: Any],
           let enable = args["enable"] as? Bool {
          UIApplication.shared.isIdleTimerDisabled = enable
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Argument 'enable' is required", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
