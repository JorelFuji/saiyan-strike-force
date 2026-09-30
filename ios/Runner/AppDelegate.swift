import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    UNUserNotificationCenter.current().delegate = self
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return result
    }
    let channel = FlutterMethodChannel(
      name: "vulcan_fitness/storage",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { call, callback in
      guard call.method == "excludeFromBackup",
            let arguments = call.arguments as? [String: Any],
            let directoryPath = arguments["directoryPath"] as? String else {
        callback(FlutterError(code: "invalid_request", message: "Storage protection failed.", details: nil))
        return
      }

      let url = URL(fileURLWithPath: directoryPath, isDirectory: true)
      do {
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var protectedUrl = url
        try protectedUrl.setResourceValues(values)
        callback(nil)
      } catch {
        callback(FlutterError(code: "storage_protection_failed", message: "Storage protection failed.", details: nil))
      }
    }
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
