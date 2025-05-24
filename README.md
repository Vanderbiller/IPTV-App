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

# Flutter IPTV Native Player

[![Swift](https://img.shields.io/badge/Swift-5.6-orange.svg)](https://swift.org) [![Flutter](https://img.shields.io/badge/Flutter-3.0-blue.svg)](https://flutter.dev) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **A premium, Netflix-style IPTV app—built to demonstrate modern cross-platform skills, advanced native/Flutter integration, and a world-class video streaming experience.**

---

## 🌟 Why This Project Stands Out

- **Hybrid Architecture:** Combines Flutter’s UI flexibility with native iOS power (AVPlayer/Swift) for a responsive, platform-optimized experience.
- **Production-Grade UX:** Features intuitive controls, AirPlay, PiP, and dynamic live/VOD detection—matching leading streaming apps in polish.
- **Enterprise-Ready Code:** Well-structured, modular codebase with native bridges, background audio, and lock-screen integration.
- **Perfect for Hiring Managers:** This project highlights mobile expertise, native/Flutter communication, and the ability to deliver high-quality, real-world video apps.

---

## 🚀 Key Features

- **Seamless Flutter ↔ Native Integration**  
  Presents a fully native `AVPlayerViewController` from Flutter via robust MethodChannel communication.

- **Netflix-Style Custom UI**  
  - Overlay Play/Pause & Close buttons  
  - 10-second skip for VOD  
  - Minimal, thumb-less seek bar  
  - Auto-hide controls & tap-to-show

- **Live vs. VOD Detection**  
  - Hides seek/skip for live streams  
  - Displays a real-time “LIVE” badge

- **AirPlay & Picture-in-Picture**  
  - Native AirPlay device picker  
  - System-level PiP with seamless transitions

- **Background & Lock-Screen Playback**  
  - Background audio via AVAudioSession  
  - Full Now Playing & remote control integration

---

## 📦 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.0  
- Xcode ≥ 14  
- iOS Deployment Target ≥ 14.0  
- CocoaPods

### Installation

```bash
git clone https://github.com/Vanderbiller/IPTV-App.git
cd flutter-iptv-native-player
flutter pub get
cd ios
pod install
cd ..
flutter run
```

Or open `ios/Runner.xcworkspace` in Xcode and run on a simulator/device.

---

## 🛠️ Architecture Overview

1. **Flutter MethodChannel** sends video URLs to native iOS.
2. **AppDelegate** launches the native player.
3. **PlayerViewController** manages AVPlayer, UI controls, AirPlay, PiP, and live/VOD status.
4. **Background playback and lock-screen controls** are handled natively for a premium, responsive UX.

---

## 🎨 Customization

- **Branding:** Change track colors, badge style, and artwork in Swift.
- **Control Visibility:** Tweak auto-hide duration in `startUITimer()`.
- **Lock-Screen:** Update Now Playing metadata and artwork for your app.

---

## 🤝 Contribution

- Fork, branch, and PR—happy to review improvements!
- Codebase is modular and ready for feature extension.

---

## 📜 License

MIT License. See [LICENSE](LICENSE).

---

**Built by Adam Vanbaelinghem — focused on clarity, code quality, and a real-world streaming experience.**