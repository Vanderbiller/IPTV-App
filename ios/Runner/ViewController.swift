import UIKit
import MobileVLCKit
import GoogleCast

class ViewController: UIViewController, VLCMediaPlayerDelegate, GCKSessionManagerListener {

    private var castButton: GCKUICastButton!

    @IBOutlet weak var videoPlayer: UIView! {
        didSet {
            self.videoPlayer.isUserInteractionEnabled = true
            self.videoPlayer.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(onScreenTap)))
        }
    }
    
    @IBOutlet weak var controlView: UIView! {
        didSet {
            self.controlView.isUserInteractionEnabled = true
            self.controlView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(onScreenTap)))
        }
    }
    
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
    
    
    private var mediaPlayer: VLCMediaPlayer?
    private var videoURL: URL?
    private var initialLoad: Bool = false
    private var isLiveStream: Bool?
    private var updateTimer: Timer?
    private var isControlsVisible: Bool = true
    private var uiTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        addNotificationObservers()
        // Register for Cast session events
        GCKCastContext.sharedInstance().sessionManager.add(self)
        // Add Google Cast button in top-right
        castButton = GCKUICastButton(frame: .zero)
        castButton.translatesAutoresizingMaskIntoConstraints = false
        castButton.tintColor = UIColor.white
        view.addSubview(castButton)
        NSLayoutConstraint.activate([
            castButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            castButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            castButton.widthAnchor.constraint(equalToConstant: 24),
            castButton.heightAnchor.constraint(equalToConstant: 24)
        ])
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
        
        if (mediaPlayer?.state == .playing) {
            startUITimer()
        } else if (mediaPlayer?.state == .paused || mediaPlayer?.state == .stopped) {
            uiTimer?.invalidate()
        }
    }
    
    // MARK: - Hide Controls UI with Timeout
    
    private func startUITimer() {
        uiTimer?.invalidate()
        uiTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
    }
    
    @objc private func onScreenTap() {
        if isControlsVisible {
            hideControls()
        } else {
            showControls()
        }
    }
    
    // Function for when sliding, the UI wont disappear
    @IBAction func sliderTouchStarted(_ sender: Any) {
        uiTimer?.invalidate()
    }
    
    @IBAction func sliderTouchEnded(_ sender: Any) {
        startUITimer()
    }
    
    @objc private func hideControls() {
        uiTimer?.invalidate()
        isControlsVisible = false
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.controlView.alpha = 0.0
            self?.castButton.alpha = 0.0
        }
    }
    
    private func showControls() {
        isControlsVisible = true
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.controlView.alpha = 1.0
            self?.castButton.alpha = 1.0
        }
        startUITimer()
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
        
    @IBAction func sliderValueChanged(_ sender: UISlider) {
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
    
    
    // MARK: - Casting
    
    private func startCast(title: String) {
        guard
            let url = videoURL,
            let session = GCKCastContext.sharedInstance().sessionManager.currentCastSession,
            let mediaClient = session.remoteMediaClient
        else {
            return
        }

        let metadata = GCKMediaMetadata(metadataType: .movie)
        metadata.setString(title, forKey: kGCKMetadataKeyTitle)

        let mediaInfoBuilder = GCKMediaInformationBuilder(contentID: url.absoluteString)
        mediaInfoBuilder.contentType = "application/vnd.apple.mpegurl"
        if let lengthMs = mediaPlayer?.media?.length.intValue, lengthMs > 0 {
            mediaInfoBuilder.streamType = .buffered
            mediaInfoBuilder.streamDuration = Double(lengthMs) / 1000.0
        } else {
            mediaInfoBuilder.streamType = .live
            mediaInfoBuilder.streamDuration = 0.0
        }
        mediaInfoBuilder.metadata = metadata
        let mediaInfo = mediaInfoBuilder.build()

        mediaClient.loadMedia(mediaInfo, autoplay: true)
    }

    private func loadMediaOnCastSession(_ session: GCKCastSession) {
        guard let url = videoURL,
              let mediaClient = session.remoteMediaClient else {
            return
        }
        let metadata = GCKMediaMetadata(metadataType: .movie)
        metadata.setString("Flutter IPTV Stream", forKey: kGCKMetadataKeyTitle)

        let builder = GCKMediaInformationBuilder(contentID: url.absoluteString)
        builder.contentType = "application/vnd.apple.mpegurl"
        if let lengthMs = mediaPlayer?.media?.length.intValue, lengthMs > 0 {
            builder.streamType = .buffered
            builder.streamDuration = Double(lengthMs) / 1000.0
        } else {
            builder.streamType = .live
            builder.streamDuration = 0.0
        }
        builder.metadata = metadata
        let mediaInfo = builder.build()

        mediaClient.loadMedia(mediaInfo, autoplay: true)
    }


    // MARK: - Google Cast Session Manager Listener
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
        // Send media once the Cast session starts
        loadMediaOnCastSession(session)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didResume session: GCKCastSession) {
        // Re-load media if reconnecting to an existing session
        loadMediaOnCastSession(session)
    }

    // MARK: - Cleanup

    deinit {
        NotificationCenter.default.removeObserver(self)
        mediaPlayer?.stop()
        mediaPlayer = nil
        updateTimer?.invalidate()
        updateTimer = nil
        uiTimer?.invalidate()
        uiTimer = nil
    }
}
