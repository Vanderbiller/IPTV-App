
import UIKit
import AVKit
import AVFoundation
import MobileVLCKit


class ViewController : UIViewController, AVPictureInPictureControllerDelegate, VLCMediaPlayerDelegate {
    
    private var isControlsVisible = true
    private var uiTimer: Timer?
    private var timeObserverToken: Any?
    private var isObservingStatus = false
    private var isObservingBuffer = false
    
    private var pipController: AVPictureInPictureController?
    private var vlcPlayer: VLCMediaPlayer?
    private var vlcUpdateTimer: Timer?
    private var initialLoad: Bool = false
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    @IBOutlet var videoPlayer: UIView!
    @IBOutlet weak var imgPause: UIImageView! {
        didSet {
            self.imgPause.isUserInteractionEnabled = true
            self.imgPause.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(togglePlayPause)))
        }
    }
    
    @IBOutlet weak var img10Back: UIImageView! {
        didSet {
            self.img10Back.isUserInteractionEnabled = true
            self.img10Back.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backwardTenSeconds)))
        }
    }
    @IBOutlet weak var img10Fwd: UIImageView! {
        didSet {
            self.img10Fwd.isUserInteractionEnabled = true
            self.img10Fwd.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(forwardTenSeconds)))
        }
    }
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var imgClose: UIImageView! {
        didSet {
            self.imgClose.isUserInteractionEnabled = true
            self.imgClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPlayer)))
        }
    }
    @IBOutlet weak var airplayPicker: AVRoutePickerView!
    @IBOutlet weak var brightnessSlider: BrightnessSliderView!
    @IBOutlet weak var imgBrightness: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var vignetteView: UIView?
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var mediaUrl: URL?
    private var mediaTitle: String?
    private var mediaStartPoint: Double?

    private var flutterChannel: FlutterMethodChannel?

    
    private let liveLabel: UILabel = {
        let label = UILabel()
        label.text = "LIVE"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.backgroundColor = .red
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
        
    func configure(with url: URL, with title: String, with startPoint: Double) {
        mediaUrl = url
        mediaTitle = title
        mediaStartPoint = startPoint
    }
    
    override func viewDidLoad() {
        guard let title = mediaTitle else { return }
        super.viewDidLoad()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let controller = appDelegate.window?.rootViewController as? FlutterViewController {
            flutterChannel = FlutterMethodChannel(
                name: "video_player_channel",
                binaryMessenger: controller.binaryMessenger
            )
        }
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        videoPlayer.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: videoPlayer.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: videoPlayer.centerYAnchor)
        ])
        setupPlayer()
        configureLiveLabel()
        titleLabel.text = title
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onScreenTap))
        videoPlayer.isUserInteractionEnabled = true
        videoPlayer.addGestureRecognizer(tap)
        startUITimer()
        seekSlider.minimumTrackTintColor = .white
        seekSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        seekSlider.isContinuous = true
        airplayPicker.activeTintColor = .white
        airplayPicker.tintColor = .white
        
        // MARK: - Brightness Slider Logic
        brightnessSlider.valueChanged = {
            newValue in
            UIScreen.main.brightness = newValue
        }
        brightnessSlider.value = UIScreen.main.brightness
        brightnessSlider.touchStarted = { [weak self] in
            guard let self = self else { return }
            removeVignette()
            self.uiTimer?.invalidate()
            UIView.animate(withDuration: 0.3) {
                self.imgPause.alpha = 0
                self.imgClose.alpha = 0
                self.img10Back.alpha = 0
                self.img10Fwd.alpha = 0
                self.seekSlider.alpha = 0
                self.timeLabel.alpha = 0
                self.liveLabel.alpha = 0
                self.airplayPicker.alpha = 0
                self.titleLabel.alpha = 0
            }
        }
        
        brightnessSlider.touchEnded = { [weak self] in
            guard let self = self else { return }
            addVignette()
            self.startUITimer()
            UIView.animate(withDuration: 0.3) {
                self.imgPause.alpha = 1
                self.imgClose.alpha = 1
                self.img10Back.alpha = 1
                self.img10Fwd.alpha = 1
                self.seekSlider.alpha = 1
                self.timeLabel.alpha = 1
                if !self.liveLabel.isHidden {
                    self.liveLabel.alpha = 1
                }
                self.airplayPicker.alpha = 1
                self.titleLabel.alpha = 1
            }
        }
        
        DispatchQueue.main.async {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback)
                try session.setActive(true)
            } catch let error as NSError {
                print("Audio session setup failed: \(error), userInfo: \(error.userInfo)")
            }
        }
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        savePlaybackPositionIfNeeded()
    }

    
    private func configureLiveLabel() {
        videoPlayer.addSubview(liveLabel)
        liveLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            liveLabel.bottomAnchor.constraint(equalTo: videoPlayer.bottomAnchor, constant: -16),
            liveLabel.leadingAnchor.constraint(equalTo: videoPlayer.leadingAnchor, constant: 16),
            liveLabel.heightAnchor.constraint(equalToConstant: 20),
            liveLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupPlayer() {
        guard let url = mediaUrl else {return}
        guard let title = mediaTitle else {return}
        loadingIndicator.startAnimating()
        imgPause.isHidden = true
        print(title)
        if url.pathExtension.lowercased() == "mkv" {
            playerLayer?.removeFromSuperlayer()

            let mediaPlayer = VLCMediaPlayer()
            mediaPlayer.drawable = videoPlayer
            mediaPlayer.media = VLCMedia(url: url)
            mediaPlayer.delegate = self
            mediaPlayer.play()
            if let startPoint = mediaStartPoint, startPoint > 0,
               let lengthMs = mediaPlayer.media?.length.intValue, lengthMs > 0 {
                let totalSec = Double(lengthMs) / 1000.0
                if totalSec > 0 {
                    let fraction = startPoint / totalSec
                    mediaPlayer.position = Float(fraction)
                }
            }
            loadingIndicator.startAnimating()
            imgPause.isHidden = true

            self.vlcPlayer = mediaPlayer

            self.liveLabel.isHidden = true

            vlcUpdateTimer?.invalidate()
            vlcUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
                guard let self = self,
                      let vlc = self.vlcPlayer,
                      let media = vlc.media else { return }
                let lengthMs = media.length.intValue
                let totalSec = Double(max(lengthMs, 0)) / 1000.0
                let currentSec = Double(vlc.position) * totalSec
                let remaining = totalSec - currentSec
                self.seekSlider.isHidden = false
                self.img10Back.isHidden = false
                self.img10Fwd.isHidden = false
                self.liveLabel.isHidden = true
                self.airplayPicker.isHidden = true
                self.seekSlider.maximumValue = Float(totalSec)
                self.seekSlider.value = Float(currentSec)
                self.timeLabel.text = self.formatTime(remaining)
            }

            img10Back.isHidden = false
            img10Back.isUserInteractionEnabled = true
            img10Fwd.isHidden = false
            img10Fwd.isUserInteractionEnabled = true
            seekSlider.isHidden = false
            timeLabel.isHidden = false

            return
        }
        player = AVPlayer(url: url)
        if (mediaStartPoint != 0) {
            player?.seek(to: CMTime(seconds: mediaStartPoint!, preferredTimescale: 1000))
        }
        player?.currentItem?.addObserver(self,
                                         forKeyPath: "status",
                                         options: [.initial, .new],
                                         context: nil)
        isObservingStatus = true
        player?.currentItem?.addObserver(self,
                                         forKeyPath: "playbackBufferEmpty",
                                         options: [.new],
                                         context: nil)
        player?.currentItem?.addObserver(self,
                                         forKeyPath: "playbackLikelyToKeepUp",
                                         options: [.new],
                                         context: nil)
        isObservingBuffer = true
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        if let layer = playerLayer {
            videoPlayer.layer.insertSublayer(layer, at: 0)
            
            if AVPictureInPictureController.isPictureInPictureSupported(), let layer = playerLayer {
                pipController = AVPictureInPictureController(playerLayer: layer)
                pipController?.delegate = self
            }
        }


        player?.play()

        loadingIndicator.startAnimating()
        imgPause.isHidden = true
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let currentItem = self.player?.currentItem,
                  currentItem.duration.isNumeric else { return }
            let duration = currentItem.duration.seconds
            let current = time.seconds
            let remaining = duration - current

            self.seekSlider.maximumValue = Float(duration)
            self.seekSlider.value = Float(current)
            self.timeLabel.text = self.formatTime(remaining)
        }
        startUITimer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoPlayer.bounds

        view.bringSubviewToFront(imgPause)
        view.bringSubviewToFront(img10Back)
        view.bringSubviewToFront(img10Fwd)
        view.bringSubviewToFront(seekSlider)
        view.bringSubviewToFront(timeLabel)
        view.bringSubviewToFront(imgClose)
        view.bringSubviewToFront(airplayPicker)
        view.bringSubviewToFront(brightnessSlider)
        view.bringSubviewToFront(imgBrightness)
        view.bringSubviewToFront(titleLabel)
        videoPlayer.bringSubviewToFront(liveLabel)
    }
    
    
    // MARK: - Control Visibility
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

    @objc private func hideControls() {
        isControlsVisible = false
        removeVignette()
        UIView.animate(withDuration: 0.3) {
            self.imgPause.alpha = 0
            self.imgClose.alpha = 0
            self.img10Back.alpha = 0
            self.img10Fwd.alpha = 0
            self.seekSlider.alpha = 0
            self.timeLabel.alpha = 0
            self.liveLabel.alpha = 0
            self.airplayPicker.alpha = 0
            self.brightnessSlider.alpha = 0
            self.imgBrightness.alpha = 0
            self.titleLabel.alpha = 0
        }
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }

    private func showControls() {
        isControlsVisible = true
        addVignette()
        UIView.animate(withDuration: 0.3) {
            self.imgPause.alpha = 1
            self.imgClose.alpha = 1
            self.img10Back.alpha = 1
            self.img10Fwd.alpha = 1
            self.seekSlider.alpha = 1
            self.timeLabel.alpha = 1
            if !self.liveLabel.isHidden {
                self.liveLabel.alpha = 1
            }
            self.airplayPicker.alpha = 1
            self.brightnessSlider.alpha = 1
            self.imgBrightness.alpha = 1
            self.titleLabel.alpha = 1
        }
        startUITimer()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    // MARK: - Orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let intSec = Int(seconds)
        let hrs = intSec / 3600
        let mins = (intSec % 3600) / 60
        let secs = intSec % 60
        if hrs > 0 {
            return String(format: "%d:%02d:%02d", hrs, mins, secs)
        } else {
            return String(format: "%02d:%02d", mins, secs)
        }
    }
    
    // MARK: - Video Controls
    @objc private func togglePlayPause() {
        if let vlc = vlcPlayer {
            if vlc.isPlaying {
                vlc.pause()
                imgPause.image = UIImage(systemName: "play.fill")
            } else {
                vlc.play()
                imgPause.image = UIImage(systemName: "pause.fill")
            }
            return
        }
        guard let player = player else { return }
        if player.timeControlStatus == .playing {
            player.pause()
            imgPause.image = UIImage(systemName: "play.fill")
        } else {
            player.play()
            imgPause.image = UIImage(systemName: "pause.fill")
        }
    }

    @objc private func backwardTenSeconds() {
        if let vlc = vlcPlayer, let media = vlc.media {
            let lengthMs = media.length.intValue
            if lengthMs > 0 {
                let totalSec = Float(lengthMs) / 1000
                let newPos = max(vlc.position - (10 / totalSec), 0)
                vlc.position = newPos
            }
            return
        }
        guard let player = player else { return }
        let currentTime = player.currentTime()
        let tenSeconds = CMTime(seconds: 10, preferredTimescale: currentTime.timescale)
        let newTime = CMTimeSubtract(currentTime, tenSeconds)
        let seekTime = CMTimeMaximum(newTime, .zero)
        player.seek(to: seekTime)
    }
    
    @objc private func forwardTenSeconds() {
        if let vlc = vlcPlayer, let media = vlc.media {
            let lengthMs = media.length.intValue
            if lengthMs > 0 {
                let totalSec = Float(lengthMs) / 1000
                let newPos = min(vlc.position + (10 / totalSec), 1)
                vlc.position = newPos
            }
            return
        }
        guard let player = player else { return }
        let currentTime = player.currentTime()
        let tenSeconds = CMTime(seconds: 10, preferredTimescale: currentTime.timescale)
        let newTime = CMTimeAdd(currentTime, tenSeconds)
        let seekTime = CMTimeMaximum(newTime, .zero)
        player.seek(to: seekTime)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        if let vlc = vlcPlayer, let media = vlc.media {
            let lengthMs = media.length.intValue
            if lengthMs > 0 {
                let totalSec = Float(lengthMs) / 1000
                vlc.position = sender.value / totalSec
                let currentSec = Double(sender.value)
                let remaining = Double(totalSec) - currentSec
                timeLabel.text = formatTime(remaining)
            }
            return
        }
        let seconds = Double(sender.value)
        let targetTime = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: targetTime)
    }
    
    private func savePlaybackPositionIfNeeded() {
        //Save timestamp on exit
        if let vlc = vlcPlayer, let media = vlc.media {
            let lengthMs = media.length.intValue
            if lengthMs > 0, let urlString = mediaUrl?.absoluteString {
                let totalSec = Double(lengthMs) / 1000.0
                let currentSec = Double(vlc.position) * totalSec
                let remainingSec = totalSec - currentSec
                let remainingRatio = remainingSec / totalSec

                let key = "lastPos__\(urlString)"
                if remainingRatio > 0.02 {
                    UserDefaults.standard.set(currentSec, forKey: key)
                    flutterChannel?.invokeMethod(
                        "positionUpdated",
                        arguments: ["url": urlString, "position": currentSec]
                    )
                    print("Saved position \(currentSec) for \(urlString)")
                } else {
                    UserDefaults.standard.removeObject(forKey: key)
                    flutterChannel?.invokeMethod(
                        "positionUpdated",
                        arguments: ["url": urlString, "position": 0.0]
                    )
                    print("Removed saved position for \(urlString)")
                }
            }
        }
        else if let player = player, let urlString = mediaUrl?.absoluteString,
                let currentItem = player.currentItem, currentItem.duration.isNumeric {
            let durationCM = currentItem.duration
            let totalSec = durationCM.seconds
            let currentCM = player.currentTime()
            let currentSec = CMTimeGetSeconds(currentCM).isFinite
                           ? CMTimeGetSeconds(currentCM)
                           : 0.0
            let remainingSec = totalSec - currentSec
            let remainingRatio = (totalSec > 0) ? (remainingSec / totalSec) : 0.0

            let key = "lastPos__\(urlString)"
            if remainingRatio > 0.02 {
                UserDefaults.standard.set(currentSec, forKey: key)
                flutterChannel?.invokeMethod(
                    "positionUpdated",
                    arguments: ["url": urlString, "position": currentSec]
                )
                print("Saved position \(currentSec) for \(urlString)")
            } else {
                UserDefaults.standard.removeObject(forKey: key)
                flutterChannel?.invokeMethod(
                    "positionUpdated",
                    arguments: ["url": urlString, "position": 0.0]
                )
                print("Removed saved position for \(urlString)")
            }
            print("★ ALL UserDefaults keys now: \(UserDefaults.standard.dictionaryRepresentation().keys.sorted())")
        }
    }

    @objc private func dismissPlayer() {
        savePlaybackPositionIfNeeded()
        //Handle Dismiss
        if let vlc = vlcPlayer {
            vlc.stop()
            vlcPlayer = nil
            vlcUpdateTimer?.invalidate()
            vlcUpdateTimer = nil
        } else {
            player?.pause()
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - SeekerSlider View Logic
    @IBAction func sliderTouchStarted(_ sender: UISlider) {
        uiTimer?.invalidate()
        if let vlc = vlcPlayer {
            vlcUpdateTimer?.invalidate()
            vlc.pause()
            return
        }
        player?.pause()
    }

    @IBAction func sliderTouchEnded(_ sender: UISlider) {
        startUITimer()
        if let vlc = vlcPlayer {
            vlcUpdateTimer?.invalidate()
            vlcUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
                guard let self = self,
                      let vlc = self.vlcPlayer,
                      let media = vlc.media else { return }
                let lengthMs = media.length.intValue
                let totalSec = Double(max(lengthMs, 0)) / 1000.0
                let currentSec = Double(vlc.position) * totalSec
                let remaining = totalSec - currentSec
                
                self.seekSlider.isHidden = false
                self.img10Back.isHidden = false
                self.img10Fwd.isHidden = false
                self.liveLabel.isHidden = true

                self.seekSlider.maximumValue = Float(totalSec)
                self.seekSlider.value = Float(currentSec)
                self.timeLabel.text = self.formatTime(remaining)
            }
            vlc.play()
            return
        }
        player?.play()
    }
     
    // MARK: - Vignette Logic
    func addVignette() {
        vignetteView?.removeFromSuperview()
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlay.isUserInteractionEnabled = false
        overlay.alpha = 0
        view.addSubview(overlay)
        vignetteView = overlay

        UIView.animate(withDuration: 0.3) {
            overlay.alpha = 1
        }
    }
    
    func removeVignette() {
        UIView.animate(withDuration: 0.3, animations: {
            self.vignetteView?.alpha = 0
        }) { _ in
            self.vignetteView?.removeFromSuperview()
            self.vignetteView = nil
        }
    }
    
    // MARK: - Observe PlayerItem Status
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "status",
           let item = object as? AVPlayerItem,
           item == player?.currentItem,
           item.status == .readyToPlay {
            let duration = item.duration
            DispatchQueue.main.async {
                if duration.isIndefinite {
                    self.img10Back.isHidden = true
                    self.img10Fwd.isHidden = true
                    self.seekSlider.isHidden = true
                    self.timeLabel.isHidden = true
                    self.liveLabel.isHidden = false
                } else {
                    self.img10Back.isHidden = false
                    self.img10Back.isUserInteractionEnabled = true
                    self.img10Fwd.isHidden = false
                    self.img10Fwd.isUserInteractionEnabled = true
                    self.seekSlider.isHidden = false
                    self.timeLabel.isHidden = false
                    self.liveLabel.isHidden = true
                }
                self.loadingIndicator.stopAnimating()
                self.imgPause.isHidden = false
                self.startUITimer()
            }
            item.removeObserver(self, forKeyPath: "status")
            isObservingStatus = false
        }
        DispatchQueue.main.async {
            if keyPath == "playbackBufferEmpty" {
                self.loadingIndicator.startAnimating()
                return
            } else if keyPath == "playbackLikelyToKeepUp" {
                self.loadingIndicator.stopAnimating()
                return
            }
        }
    }
    
    @objc private func handleWillResignActive() {
        savePlaybackPositionIfNeeded()
        pipController?.startPictureInPicture()
    }
    
    @objc private func handleDidBecomeActive() {
        pipController?.stopPictureInPicture()
    }
    
    deinit {
        vlcUpdateTimer?.invalidate()
        vlcUpdateTimer = nil
        vlcPlayer?.stop()
        vlcPlayer = nil
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
        if isObservingStatus {
            player?.currentItem?.removeObserver(self, forKeyPath: "status")
        }
        if isObservingBuffer {
            player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            player?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        }
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    // MARK: - VLCMediaPlayerDelegate
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        if vlcPlayer?.state == .playing && !initialLoad {
            initialLoad = true
            loadingIndicator.stopAnimating()
            imgPause.isHidden = false
        }
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pipController: AVPictureInPictureController) {
        savePlaybackPositionIfNeeded()
    }
}
