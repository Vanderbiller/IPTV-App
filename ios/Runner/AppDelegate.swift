import UIKit
import Flutter
import AVKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    let videoPlayerChannel = FlutterMethodChannel(
      name: "video_player_channel",
      binaryMessenger: controller.binaryMessenger
    )

    videoPlayerChannel.setMethodCallHandler { [weak controller] (call, result) in
      if call.method == "playVideo",
         let args = call.arguments as? [String: Any],
         let urlString = args["url"] as? String,
         let url = URL(string: urlString) {

        // Present AVPlayerViewController
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: url)
        controller?.present(playerVC, animated: true) {
          playerVC.player?.play()
        }
        result(nil)

      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
