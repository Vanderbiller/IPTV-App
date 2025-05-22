# Flutter IPTV Native Player

[![Swift](https://img.shields.io/badge/Swift-5.6-orange.svg)](https://swift.org) [![Flutter](https://img.shields.io/badge/Flutter-3.0-blue.svg)](https://flutter.dev) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A high-performance, Netflix-style IPTV player built with **Flutter** on the front end and **AVPlayer**/Swift on iOS for a truly native media experience. This project demonstrates advanced Flutter ↔ native integration, custom UI/UX, background playback, AirPlay & PiP, and lock-screen controls—perfect for showcasing mobile multimedia expertise to prospective employers.

---

## 🚀 Features

- **Hybrid Flutter + Native**  
  Seamless MethodChannel bridge to present a native `AVPlayerViewController`–powered player from Flutter.

- **Custom Netflix-Style UI**  
  • Overlaid Play/Pause & Close buttons  
  • 10-second skip controls for VOD  
  • Auto-hide controls with tap-to-show gesture  
  • Clean, minimal seek bar without a thumb knob

- **Live vs. VOD Detection**  
  Dynamically hides seek & skip controls for live streams and displays a “LIVE” badge in the bottom-left.

- **AirPlay Integration**  
  Built-in `AVRoutePickerView` for seamless device discovery & routing.

- **Picture-in-Picture (PiP)**  
  Automatic PiP support on background/lock event via `AVPictureInPictureController`.

- **Background & Lock-Screen Playback**  
  • Configured `AVAudioSession` for background audio  
  • `MPNowPlayingInfoCenter` & `MPRemoteCommandCenter` for rich lock-screen & Control Center controls, including scrub bar and artwork.

---



---

## 📦 Getting Started

### Requirements

- Flutter SDK ≥ 3.0  
- Xcode ≥ 14  
- iOS Deployment Target ≥ 14.0  
- CocoaPods

### Installation

1. **Clone the repo**  
   ```bash
   git clone https://github.com/Vanderbiller/IPTV-App.git
   cd flutter-iptv-native-player
   ```

2. **Install Flutter dependencies**  
   ```bash
   flutter pub get
   ```

3. **Install iOS pods**  
   ```bash
   cd ios
   pod install
   cd ..
   ```

### Running on iOS

```bash
flutter run
```

Or open `ios/Runner.xcworkspace` in Xcode and run on a simulator/device.

---

## 🎯 How It Works

1. **Flutter MethodChannel** (`video_player_channel`) sends a URL to `AppDelegate`.  
2. **AppDelegate** instantiates `PlayerViewController` from Storyboard and passes the URL.  
3. **PlayerViewController**:
   - Sets up `AVPlayer` + `AVPlayerLayer` for rendering.
   - Observes the player item’s status via KVO to detect live vs. VOD.
   - Configures UI controls, airplay button, and PiP controller.
   - Starts a periodic time observer to update the seek bar & lock-screen metadata.
   - Manages control‐visibility timers and gestures for a smooth UX.

---

## 🔧 Customization

- **Change Brand Colors**: Tweak `seekSlider.minimumTrackTintColor` / `maximumTrackTintColor` in `viewDidLoad()`.  
- **Adjust Auto-Hide Duration**: Modify `startUITimer()`’s 5-second interval.  
- **Badge Styling**: Edit `liveLabel`’s font, corner radius, or position in `configureLiveLabel()`.  
- **Artwork & Metadata**: Swap `"AppIcon"` in `setupNowPlayingInfo()` for your own image and adjust `MPMediaItemPropertyTitle`.

---

## 🤝 Contributing

1. Fork the repo.  
2. Create a feature branch: `git checkout -b feature/my-awesome-feature`.  
3. Commit your changes: `git commit -am 'Add awesome feature'`.  
4. Push to the branch: `git push origin feature/my-awesome-feature`.  
5. Open a Pull Request—happy to review improvements!

---

## 📜 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

**Made with ❤️ & Swift** by Adam Vanbaelinghem
