import UIKit
import MobileVLCKit

class ViewController: UIViewController {

    @IBOutlet var videoPlayer: UIView!
    private var mediaPlayer: VLCMediaPlayer?
    private var videoURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }

    func configure(with url: URL) {
        self.videoURL = url
    }

    private func setupPlayer() {
        guard let url = videoURL else { return }

        mediaPlayer = VLCMediaPlayer()
        mediaPlayer?.media = VLCMedia(url: url)
        mediaPlayer?.drawable = videoPlayer

        mediaPlayer?.play()
    }
}
