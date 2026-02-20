import UIKit
import Flutter
import home_widget

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Register Home Widget callback
    HomeWidgetPlugin.setAppGroupId("group.app.snapbeam.photo")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
