import UIKit
import MobileVLCKit

class ViewController: UIViewController, VLCMediaPlayerDelegate {

    @IBOutlet weak var videoPlayer: UIView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var lbTotalTime: UILabel!
    @IBOutlet weak var seekSlider: UISlider!
    
    @IBOutlet weak var imgPlay: UIImageView! {
        didSet {
            self.imgPlay.isUserInteractionEnabled = true
            self.imgPlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapPlayPause)))
        }
    }
    
    @IBOutlet weak var imgClose: UIImageView! {
        didSet {
            self.imgClose.isUserInteractionEnabled = true
            self.imgClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapClose)))
        }
    }
    
    @IBOutlet weak var imgCast: UIImageView!
    
    private var mediaPlayer: VLCMediaPlayer?
    private var videoURL: URL?
    private var initialLoad: Bool = false
    private var isLiveStream: Bool?
    private var updateTimer: Timer?
    private var isControlsVisible: Bool = true
    
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

        mediaPlayer = VLCMediaPlayer()
        mediaPlayer?.media = VLCMedia(url: url)
        
        mediaPlayer?.drawable = videoPlayer
        videoPlayer.backgroundColor = .black
        
        mediaPlayer?.delegate = self
        mediaPlayer?.play()
    }
    
    
    // MARK: - Make sure the video is playing
    
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        if (mediaPlayer?.state == .playing && !initialLoad) {
            initialLoad = true
            let totalTime = mediaPlayer?.media?.length
            if let totalTime = totalTime, totalTime.intValue == 0 {
                lbTotalTime.text = " Live •"
                lbTotalTime.textAlignment = .center
                lbTotalTime.backgroundColor = .red
                lbTotalTime.textColor = .white
                lbTotalTime.layer.cornerRadius = 8
                lbTotalTime.clipsToBounds = true
                lbTotalTime.font = UIFont.boldSystemFont(ofSize: 14)
                seekSlider.isEnabled = false
                seekSlider.isHidden = true
            }
            else {
                updateTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
            }
            
        }
    }
    
    // MARK: - Slider handling
    
    @objc private func updateUI() {
        guard let mediaPlayer = mediaPlayer else { return }
        
        //Remaining Time
        let totalTime = mediaPlayer.media?.length.intValue ?? 0
        let currentTime = mediaPlayer.time.intValue
        
        let remainingTime = totalTime - currentTime
        
        //Update Slider and Timer
        lbTotalTime.text = formatTime(Int(remainingTime))
        
        //Only update slider if user isnt interacting with it
        
        if !seekSlider.isTracking {
            seekSlider.value = Float(currentTime)
            seekSlider.maximumValue = Float(totalTime)
        }
    }
        
    @IBAction func sliderTouchEnded(_ sender: UISlider) {
        guard let mediaPlayer = mediaPlayer else { return }
        
        let newTime = Int32(sender.value)
        mediaPlayer.time = VLCTime(int: newTime)
        seekSlider.value = Float(newTime)
        
        if mediaPlayer.state == .paused {
            mediaPlayer.play()
        }
    }
    
    private func formatTime(_ timeInMs: Int) -> String {
        let time = timeInMs / 1000
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return String(format: "%02d", seconds)
        }
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
    
    // MARK: - UI Controls
    
    @objc private func onTapPlayPause() {
        if mediaPlayer?.isPlaying == true {
            mediaPlayer?.pause()
            imgPlay.image = UIImage(systemName: "play.fill")
        }
        else {
            mediaPlayer?.play()
            imgPlay.image = UIImage(systemName: "pause.fill")
        }
    }
    
    @objc private func onTapClose() {
        mediaPlayer?.stop()
        mediaPlayer = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Cleanup

    deinit {
        NotificationCenter.default.removeObserver(self)
        mediaPlayer?.stop()
        mediaPlayer = nil
    }
}
