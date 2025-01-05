import UIKit
import MobileVLCKit

class ViewController: UIViewController {

    @IBOutlet weak var videoPlayer: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var lbCurrTime: UILabel!
    @IBOutlet weak var lbTotalTime: UILabel!
    @IBOutlet weak var seekSlider: UISlider!

    private var mediaPlayer: VLCMediaPlayer?
    private var videoURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        addNotificationObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Force landscape orientation
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset orientation to portrait when exiting
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }

    func configure(with url: URL) {
        self.videoURL = url
    }

    private func setupPlayer() {
        guard let url = videoURL else { return }

        // Initialize VLCMediaPlayer
        mediaPlayer = VLCMediaPlayer()
        mediaPlayer?.media = VLCMedia(url: url)
        
        let videoLayer = CALayer()
        videoLayer.frame = videoPlayer.bounds
        videoLayer.contentsGravity = .resizeAspectFill
        videoPlayer.layer.addSublayer(videoLayer)
        mediaPlayer?.drawable = videoPlayer

        // Start playback
        mediaPlayer?.play()
        bringControlsToFront()
        
    }
    
    // MARK: - Device Orientation Handling

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    // MARK: - Full-Screen Immersive Mode

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    private func bringControlsToFront() {
        // Bring all UI elements to the front
        view.bringSubviewToFront(stackView)
        view.bringSubviewToFront(imgPlay)
        view.bringSubviewToFront(lbCurrTime)
        view.bringSubviewToFront(lbTotalTime)
        view.bringSubviewToFront(seekSlider)
    }
    
    // MARK: - Notification Observers for System Gestures

    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc private func handleAppBecameActive() {
        // Resume playback when app becomes active
        mediaPlayer?.play()
    }
    
    @objc private func handleAppWillResignActive() {
        // Pause playback when app resigns active
        mediaPlayer?.pause()
    }
    
    // MARK: - Cleanup

    deinit {
        NotificationCenter.default.removeObserver(self)
        mediaPlayer?.stop()
        mediaPlayer = nil
    }
}
