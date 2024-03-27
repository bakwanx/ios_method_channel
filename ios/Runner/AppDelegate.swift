import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var methodChannel: FlutterMethodChannel?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      
      
      
//      exerciseMethodChannel()
      exerciseVida()
    
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func exerciseVida(){
        if let controller = (window?.rootViewController as? FlutterViewController) {
            window?.rootViewController = UINavigationController(rootViewController: controller)
            methodChannel =
            FlutterMethodChannel.init(name: "id.vida.vidaLiveness", binaryMessenger: controller.binaryMessenger)
            methodChannel?
                .setMethodCallHandler({ [weak self](call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                    
                    guard self != nil else {
                        result(FlutterMethodNotImplemented)
                        return
                    }
                    if call.method == "doLiveness" {
                        let vidaLiveness = StartLivenessService()
                        vidaLiveness.startLivenessProcess()
                    }
                })
        }
    }
    
    private func exerciseMethodChannel(){
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let batteryChannel = FlutterMethodChannel(name: "samples.flutter.dev/battery", binaryMessenger: controller.binaryMessenger)
        
        batteryChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // This method is invoked on the UI thread.
          guard call.method == "getBatteryLevel" else {
            result(FlutterMethodNotImplemented)
            return
          }
            self.receiveBatteryLevel(result: result)
        })
        
        
    }
    
    private func receiveBatteryLevel(result: FlutterResult) {
      let device = UIDevice.current
      device.isBatteryMonitoringEnabled = true
      if device.batteryState == UIDevice.BatteryState.unknown {
        result(FlutterError(code: "UNAVAILABLE",
                            message: "Woy ini pesan data dari native",
                            details: nil))
      } else {
        result(Int(device.batteryLevel * 100))
      }
    }
    
}
