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

APACHE License. See [LICENSE](LICENSE).

---

**Made with ❤️, Swift % Dart** by Adam Vanbaelinghem
