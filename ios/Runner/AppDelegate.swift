import UIKit
import Flutter
import MobileVLCKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var mediaPlayer: VLCMediaPlayer?
    private var videoViewController: UIViewController?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Set up MethodChannel
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        let videoPlayerChannel = FlutterMethodChannel(
            name: "video_player_channel",
            binaryMessenger: controller.binaryMessenger
        )

        // Handle method calls
        videoPlayerChannel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "playVideo" {
                guard let args = call.arguments as? [String: Any],
                      let urlString = args["url"] as? String,
                      let url = URL(string: urlString) else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid or missing URL", details: nil))
                    return
                }
                self?.presentVideoPlayer(with: url)
                result(nil)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func presentVideoPlayer(with url: URL) {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            print("No root view controller found")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let videoPlayerVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
            return
        }
        videoPlayerVC.configure(with: url)
        rootViewController.present(videoPlayerVC, animated: true, completion: nil)
    }
}
