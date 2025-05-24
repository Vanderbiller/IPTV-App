import UIKit

class BrightnessSliderView: UIView {
    var value: CGFloat = 0.5 {
        didSet {
            value = min(max(value, 0), 1)
            setNeedsLayout()
            valueChanged?(value)
        }
    }
    
    var valueChanged: ((CGFloat) -> Void)?
    var touchStarted: (() -> Void)?
    var touchEnded: (() -> Void)?
    
    // MARK: - Slider Logic and Appearance
    private let trackView = UIView()
    private let progressView = UIView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        trackView.backgroundColor = UIColor(white: 1, alpha: 0.25)
        trackView.layer.cornerRadius = 2
        addSubview(trackView)
        
        progressView.backgroundColor = .white
        progressView.layer.cornerRadius = 2
        addSubview(progressView)
        
        //Plan on not using thumbview, add here if want a thumb on the bar
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(pan)
        
        //If want onTap func, add here
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let trackWidth: CGFloat = 4
        let x = (bounds.width - trackWidth) / 2
        trackView.frame = CGRect(x: x, y: 0, width: trackWidth, height: bounds.height)
        
        let progressHeight = value * bounds.height
        let progressY = bounds.height - progressHeight
        progressView.frame = CGRect(x: x, y: progressY, width: trackWidth, height: progressHeight)
        
        //Add thumb frame logic here if needed
    }
    

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let loc = gesture.location(in: self)
        value = 1.0 - min(max(loc.y / bounds.height, 0), 1)
        switch gesture.state {
        case .began:
            touchStarted?()
        case .ended, .cancelled, .failed:
            touchEnded?()
        default:
            break
        }
    }
}

