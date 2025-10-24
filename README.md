# 🐰 Rabbit RunTracker

A premium Flutter running app with post-run selfies, daily streaks, and a beautiful dark-themed UI. Track your runs, celebrate victories with selfies, and maintain your running streak!

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.9.2+-blue.svg)

## ✨ Features

### 🏃 Run Tracking
- **GPS Tracking**: Real-time location tracking during runs (ready for implementation)
- **Live Stats**: Distance, time, pace, and calories burned
- **Route Recording**: Save your running routes
- **Auto-Pause Detection**: Framework ready for automatic pause when you stop

### 📸 Post-Run Selfies
- **Victory Selfies**: Capture your post-run glow with integrated camera
- **Stats Overlay**: Run stats automatically overlaid on your selfie
- **Gallery Integration**: Save and share your achievement photos
- **History View**: Browse all your past run selfies

### 🔥 Streak System
- **Daily Streaks**: Track consecutive days of running
- **Milestone Celebrations**: Framework for animations at 7, 30, 100+ days
- **Best Streak Tracking**: Keep track of your longest streak
- **Persistent Storage**: Streaks saved locally on device

### 📊 Progress Dashboard
- **Daily Stats**: Beautiful circular progress rings showing distance, time, and calories
- **Weekly Overview**: Calendar view with highlighted run days
- **Goal Tracking**: Set and monitor daily running goals
- **Total Statistics**: Lifetime running metrics

### 🎨 Premium UI/UX
- **Dark Theme**: Stunning premium dark design with neon green (#BFFF00) accents
- **Smooth Animations**: Polished micro-interactions and press animations
- **Custom Widgets**: Beautiful circular progress rings and gradient cards
- **Responsive Design**: Works on all screen sizes

## 🎨 Design Specifications

### Color Palette
- **Background**: `#0A0A0A` (Pure black)
- **Card Background**: `#1A1A1A` (Dark gray)
- **Secondary Card**: `#242424` (Nested elements)
- **Primary Accent**: `#BFFF00` (Neon green)
- **Text Primary**: `#FFFFFF` (White)
- **Text Secondary**: `#9CA3AF` (Gray)

### Progress Colors
- **Distance**: `#FF9500` (Orange)
- **Time**: `#00D4FF` (Cyan)
- **Calories**: `#FFD60A` (Yellow)

## 🏗️ Architecture

### Project Structure
```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   └── theme/
│       └── app_theme.dart
├── features/
│   ├── camera/
│   ├── fitness/
│   ├── history/
│   ├── home/
│   ├── navigation/
│   └── tracking/
├── shared/
│   ├── models/
│   ├── providers/
│   └── widgets/
└── main.dart
```

### State Management
- **Riverpod**: Used throughout for reactive state management
- **Providers**: User profile, daily stats, run sessions, active run

### Data Persistence
- **SharedPreferences**: Local storage for user data and run history
- **File System**: Selfie images stored in app documents directory

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- iOS 12.0+ / Android 5.0+

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure permissions**

   **iOS (ios/Runner/Info.plist)**
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>We need camera access to take post-run selfies</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need photo library access to save your selfies</string>
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need location access to track your runs</string>
   ```

   **Android (android/app/src/main/AndroidManifest.xml)**
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Key Dependencies

- `flutter_riverpod` - State management
- `camera` - Camera integration for selfies
- `geolocator` - GPS tracking
- `shared_preferences` - Local data persistence
- `intl` - Date formatting
- `fl_chart` - Charts and graphs

## 📱 Screens

1. **Home Screen** - Greeting, daily stats, community feed
2. **Tracking Screen** - Week view, progress rings, start run
3. **Fitness Screen** - Streaks, gym info, workouts
4. **Post-Run Selfie** - Camera with stats overlay
5. **History Screen** - Calendar, run list, selfie gallery

## 🎯 Usage

### Starting a Run
1. Navigate to Tracking screen (center tab)
2. Tap "Start Run" button
3. Run tracking begins (GPS implementation ready)

### Taking a Post-Run Selfie
1. Complete your run
2. Camera opens automatically
3. Capture your victory selfie
4. Save with run stats

### Viewing History
1. Go to Profile → History
2. Browse calendar for run days
3. Tap runs to expand details
4. View selfies and stats

## 🛠️ Custom Widgets

### CircularProgressRing
Animated circular progress indicator with custom colors
```dart
CircularProgressRing(
  progress: 0.75,
  color: AppColors.orangeRing,
  value: '5.2',
  label: 'km',
)
```

### PremiumButton
Styled button with press animation
```dart
PremiumButton(
  text: 'Start Run',
  icon: Icons.play_arrow,
  onPressed: () {},
)
```

### PremiumCard
Elevated card with shadow
```dart
PremiumCard(
  child: YourContent(),
)
```

## 🔜 Upcoming Features

- [ ] GPS tracking implementation
- [ ] Voice announcements per kilometer
- [ ] Route map visualization
- [ ] Social sharing
- [ ] Apple Watch integration
- [ ] Achievements and badges

## 📄 License

Private project. All rights reserved.

---

**Made with Flutter** 🚀
