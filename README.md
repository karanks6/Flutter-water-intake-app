# 💧 Water Intake Logger

A premium, modern, and feature-rich Flutter application designed to help users establish healthy hydration habits. By allowing users to log their daily water consumption, track streaks, schedule timezone-aware reminders, and view insightful analytics, **Water Intake Logger** acts as a personal hydration assistant.

Built using **Flutter & Dart**, the app employs modern architecture patterns like **MVVM (Model-View-ViewModel)** backed by **Provider** for state management, and implements local data persistence with **SharedPreferences** for full offline support.

---

## 🚀 Key Features

*   **Real-time Hydration Progress Tracking:** Visual circular and linear progress indicators showing today's completion percentage relative to the daily goal.
*   **Quick Logging Presets:** One-tap logging buttons for standard drinking containers (Glass: `250 ml`, Bottle: `500 ml`, Large Thermos: `1000 ml`).
*   **Detailed Custom Log Entries:** Screen to log exact quantities, modify timestamps (for past logs), and append optional notes for each drink.
*   **Intelligent Notification & Reminder System:**
    *   Timezone-aware scheduled reminders.
    *   Flexible intervals (every 1, 2, 3, 4, or 6 hours) during active waking hours.
    *   Instant goal achievement congratulations notifications when the target is reached.
    *   Progress update alerts.
*   **Historical Analysis & Management:** A dedicated calendar log screen to review past dates, view daily totals, edit entries, or delete logs.
*   **Comprehensive Analytics Dashboard:**
    *   Current Streak Tracker (with a smart algorithm that doesn't break today's streak before the day ends).
    *   All-time statistics: best hydration day, average daily volume, total volume logged, and total goals achieved.
    *   Weekly Progress Bar Chart showing water levels color-coded by performance (Goal Met, Close, Below).
*   **Data Integrity & Management:** A configuration screen to adjust targets (presets: Light, Normal, Active, Athlete), toggle/adjust reminder settings, or perform a factory wipe of all data.

---

## 🛠 Technical Architecture & Codebase Structure

The project follows a clean **MVVM-inspired architecture** that separates data models, business logic/state, device-specific service interfaces, and visual elements.

```
water_intake/
├── android/                  # Android native project files and configurations
├── ios/                      # iOS native project files and configurations
├── icons/                    # App launcher icons assets
├── lib/                      # Core Flutter application code
│   ├── main.dart             # Application entry point & AppInitializer widget
│   ├── models/
│   │   └── intake_entry.dart # IntakeEntry data model (serialization logic)
│   ├── providers/
│   │   └── intake_provider.dart # State manager, stats math, persistence link
│   ├── services/
│   │   └── notification_service.dart # Wrapper for flutter_local_notifications
│   ├── screens/
│   │   ├── home_screen.dart       # Main hub: quick adds, today progress, charts
│   │   ├── history_screen.dart    # Calendar history view with CRUD actions
│   │   ├── log_entry_screen.dart  # Form for adding/editing a custom water log
│   │   └── settings_screen.dart   # App configurations & statistics dashboard
│   └── widgets/
│       ├── intake_card.dart       # Reusable card component for single entry details
│       └── progress_chart.dart    # Custom bar chart visualizing last 7 days
├── pubspec.yaml              # App configuration, metadata, and dependencies
└── README.md                 # Project documentation
```

### Component Breakdown

1.  **State Management & Persistence ([intake_provider.dart](file:///d:/Project_Ground/Flutter-water-intake-app/water_intake/lib/providers/intake_provider.dart))**
    *   Utilizes the **Provider** package implementing `ChangeNotifier`.
    *   Decoupled from the UI; handles all core logic such as adding, deleting, updating entries, and recalculating streaks.
    *   Integrates with `SharedPreferences` to automatically serialize entries as JSON lists and store settings locally, ensuring seamless offline functionality.
2.  **Notification Hub ([notification_service.dart](file:///d:/Project_Ground/Flutter-water-intake-app/water_intake/lib/services/notification_service.dart))**
    *   Utilizes `flutter_local_notifications` for managing cross-platform native notification scheduling.
    *   Implements native channel settings for Android (with high-priority channel configurations) and Darwin configurations for iOS.
    *   Leverages `timezone` library integration to schedule exact-time periodic notifications that dynamically adjust across timezones.
3.  **UI & Widgets (`lib/screens` & `lib/widgets`)**
    *   **Home Screen ([home_screen.dart](file:///d:/Project_Ground/Flutter-water-intake-app/water_intake/lib/screens/home_screen.dart)):** Serves as the dashboard showing a beautiful gauge of progress, three shortcut keys, and a weekly chart.
    *   **Settings Screen ([settings_screen.dart](file:///d:/Project_Ground/Flutter-water-intake-app/water_intake/lib/screens/settings_screen.dart)):** Houses controls for configuring hydration targets (from 1500ml to 3000ml+), adjusting active notification hours, viewing computed metrics, and managing local storage.
    *   **Progress Chart ([progress_chart.dart](file:///d:/Project_Ground/Flutter-water-intake-app/water_intake/lib/widgets/progress_chart.dart)):** Custom-designed bar chart that scales dynamically based on the target intake or highest logged volume to prevent UI rendering overflows. It provides colorful visualization categories (Green = Goal Met, Orange = Close, Blue = Below).

---

## 📦 Technology Stack & Dependencies

The project relies on a carefully selected stack of modern Dart and Flutter libraries:

| Package | Version | Purpose |
| :--- | :--- | :--- |
| **Dart SDK** | `^3.8.1` | Modern programming language features (null safety, patterns). |
| **Provider** | `^6.1.5` | Dependency injection and reactive state management. |
| **Shared Preferences** | `^2.5.3` | Local persistent storage for offline entries and settings data. |
| **Flutter Local Notifications** | `^19.3.0` | Triggering scheduled timezone-aware and instant push notifications. |
| **FL Chart** | `^1.0.0` | Rich charting and graph assets (supports weekly dashboards). |
| **Intl** | `^0.17.0` | Date formatting and localized time display logic. |
| **Timezone & Flutter Timezone** | `^0.10.1` / `^4.1.1` | Syncing local device timezone database for notification scheduling. |
| **Permission Handler** | `^12.0.1` | Requesting and checking system-level notification permissions. |
| **Uuid** | `^4.5.1` | Generation of RFC4122 UUIDs for indexing intake history items. |
| **Lottie** | `^3.3.1` | Rendering high-quality vector animations. |

---

## ⚙️ Installation & Setup Guide

Ensure your development environment meets the prerequisites before getting started.

### 📋 Prerequisites

*   **Flutter SDK**: Version 3.10.x or higher (highly recommended version: matching Dart SDK constraints).
*   **Dart SDK**: Included automatically with Flutter.
*   **IDE**: [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio) with the Flutter and Dart plugins installed.
*   **Platform Tools**:
    *   **For Android development**: Android SDK, Command-line Tools, and Android Simulator or a physical device with USB debugging enabled.
    *   **For iOS development** (macOS required): Xcode, CocoaPods, and iOS Simulator or configured physical iOS device.

### 🚀 Step-by-Step Run Guide

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/karanks6/Flutter-water-intake-app.git
    cd Flutter-water-intake-app
    ```

2.  **Navigate to the Flutter Project Root**
    ```bash
    cd water_intake
    ```

3.  **Fetch Dependencies**
    Download all required packages specified in `pubspec.yaml`:
    ```bash
    flutter pub get
    ```

4.  **Launch a Simulator/Emulator**
    *   Start an Android Emulator via Android Studio or
    *   Open iOS Simulator:
        ```bash
        open -a Simulator
        ```

5.  **Verify Device Connection**
    List all available active devices:
    ```bash
    flutter devices
    ```

6.  **Run the Application**
    Launch the app in debug mode on your connected device:
    ```bash
    flutter run
    ```

---

## 🛠️ Production Build Instructions

When you are ready to bundle the app for testing or production deployment, compile binaries using these commands.

### Android
*   **Build APK (for testing & distribution)**:
    ```bash
    flutter build apk --release
    ```
    *The generated file will be located at `build/app/outputs/flutter-apk/app-release.apk`.*
*   **Build App Bundle (for Google Play Console submission)**:
    ```bash
    flutter build appbundle --release
    ```
    *The generated file will be located at `build/app/outputs/bundle/release/app-release.aab`.*

### iOS (Requires macOS & Xcode)
*   **Prepare dependencies and build archive**:
    ```bash
    flutter build ipa --release
    ```
    *The app archive will compile at `build/ios/archive/` and IPA bundles will be created at `build/ios/ipa/` ready for TestFlight uploading.*

---

## 🧪 Verification & Development Notes

*   **Linter Checks**: Run analyzer to ensure clean code architecture matches Flutter guidelines:
    ```bash
    flutter analyze
    ```
*   **Tests**: Run unit and widget test files:
    ```bash
    flutter test
    ```
*   **Notification Troubleshooting (Android 13+)**:
    Android 13 introduced runtime permissions for notifications. Upon initial launch, the app will request permission. If denied, reminders will not show. Enable them manually under **App Info > Notifications** in device settings.
*   **Timezone Sync**:
    If scheduling alerts fail, ensure that your simulator/device has correct system time, region, and network sync settings.