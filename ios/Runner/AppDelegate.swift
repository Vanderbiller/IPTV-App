import Flutter
import UIKit

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

        videoPlayerChannel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "playVideo" {
                guard let args = call.arguments as? [String: Any],
                    let urlString = args["url"] as? String,
                    let url = URL(string: urlString),
                    let title = args["title"] as? String
                else {
                    result(
                        FlutterError(
                            code: "INVALID_ARGUMENT",
                            message: "Invalid or missing URL",
                            details: nil
                        ))
                    return
                }
                self?.presentVideoPlayer(with: url, with: title)
                result(nil)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func presentVideoPlayer(with url: URL, with title: String) {
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first,
            let rootVC = windowScene.windows.first?.rootViewController
        else {
            print("No root view controller found")
            return
        }

        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard
            let playerVC = sb.instantiateViewController(withIdentifier: "ViewController")
                as? ViewController
        else {
            print("Could not instantiate ViewController from storyboard.")
            return
        }

        playerVC.configure(with: url, with: title)
        playerVC.modalPresentationStyle = .fullScreen
        rootVC.present(playerVC, animated: true, completion: nil)
    }
}
