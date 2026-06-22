# Connect Hub 📱💬

**Connect Hub** is a real-time messaging and calling app built with **Flutter** and **Firebase** — sign in with your phone number, chat instantly, and make voice/video calls, all from one clean, custom-themed app.

> _"The best Messaging and Chat App of the Country that makes you connect to people."_

**Version:** 1.0.0+1 &nbsp;|&nbsp; **Dart SDK:** ^3.11.5

---

## ✨ Features

- **Phone number sign-up / login** with OTP verification via Firebase Auth
- **Real-time one-on-one chat** powered by Cloud Firestore
- **Live contact search** — filter by name or phone number
- **Voice & video calling** using Zego UIKit Prebuilt Call
- **In-app incoming-call popups** with Accept/Decline, synced through Firestore so both ends stay in sync (e.g. the caller's screen auto-closes if the receiver declines)
- **Swipe-to-delete** messages
- **Local caching** with Hive for fast app startup and a persisted "current user"
- **Custom light theme** — warm cream/espresso color palette

## 🛠 Tech Stack

| Layer         | Package                    | Version          |
| ------------- | -------------------------- | ---------------- |
| Framework     | Flutter                    | Dart SDK ^3.11.5 |
| Auth          | `firebase_auth`            | ^6.5.3           |
| Database      | `cloud_firestore`          | ^6.6.0           |
| Firebase core | `firebase_core`            | ^4.11.0          |
| Calling       | `zego_uikit_prebuilt_call` | ^4.24.2          |
| Local storage | `hive` / `hive_flutter`    | ^2.2.3 / ^1.1.0  |
| Permissions   | `permission_handler`       | 12.0.3           |
| Icons         | `cupertino_icons`          | ^1.0.8           |

<details>
<summary>Dev dependencies</summary>

- `flutter_lints` ^6.0.0
- `hive_generator` ^2.0.1
- `build_runner` ^2.4.13
- `flutter_launcher_icons` ^0.14.4 — generates app icons across Android, iOS, web, macOS, windows, and linux from `assets/Connect Hub Logo with BG.png`

</details>

## 📁 Project Structure

```
lib/
├─ Call_Func/
│  ├─ calling_page.dart      # In-call screen (ZegoUIKitPrebuiltCall wrapper)
│  └─ constants.dart         # Zego AppID & AppSign (not included in repo)
├─ Data/
│  └─ LocalVariable.dart     # In-memory cache of the Users collection
├─ Pages/
│  ├─ SplashPage.dart        # Auth check + routing on launch
│  ├─ StartingPage.dart      # Onboarding screen
│  ├─ SignUpPage.dart        # Phone OTP sign-up/login
│  ├─ HomePage.dart          # Contact list, search, incoming-call listener
│  └─ ChatPage.dart          # Chat thread + call buttons
├─ Widgets/
│  ├─ ChatListBlock.dart     # Contact list tile/row
│  ├─ CustomTextFieldAuth.dart
│  ├─ CustomTextFieldProfile.dart
│  └─ MessageBlock.dart      # Chat bubble UI
├─ Theme/
│  └─ Theme.dart
├─ firebase_options.dart
└─ main.dart
```

## ⚙️ How It Works

- **Users collection** — each Firestore user document holds `name`, `PhNumber`, `uid`, an `isDualChat` flag, and an embedded `messages` array containing that user's full message history. A global in-memory `Users` list (`LocalVariable.dart`) is kept in sync via Firestore snapshot listeners.
- **Sending a message** appends the message to _both_ the sender's and receiver's Firestore documents using `arrayUnion`, so each user's doc is a self-contained log of their conversations.
- **Calling flow**:
  1. Tapping a call button requests camera/mic permissions, then creates a doc in the `Calls` collection with `status: "dialing"`.
  2. The receiver (listening on the Home/Chat page) sees an in-app banner with Accept/Decline.
  3. Accept → status becomes `"accepted"` and both sides open `CallingPage`, backed by `ZegoUIKitPrebuiltCall`.
  4. Decline → status becomes `"declined"`; a Firestore listener on the caller's `CallingPage` detects this and pops the screen automatically.
  5. The `Calls` document is cleaned up once the call ends or the call screen is disposed.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Dart ^3.11.5 or compatible)
- A Firebase project with **Phone** sign-in and **Firestore** enabled
- A [ZEGOCLOUD](https://www.zegocloud.com/) account (App ID + App Sign) for calling

### Setup

```bash
git clone <your-repo-url>
cd connect_hub
flutter pub get
```

1. Generate your own `firebase_options.dart` by running `flutterfire configure` — the version in this repo points to the original project's Firebase config and won't work for anyone else.
2. Create `lib/Call_Func/constants.dart` with your own Zego credentials:

   ```dart
   class AppInfo {
     static const int appId = YOUR_ZEGO_APP_ID;
     static const String appSign = 'YOUR_ZEGO_APP_SIGN';
   }
   ```

3. Make sure the `assets/` folder contains the app's image assets, including:
   - `Connect Hub Logo with BG.png` (used to generate app icons)
   - `Connect Hub Logo without BG.png` (splash/onboarding screens)
   - `Starting Page remove BG.png` (onboarding illustration)

   Then (re)generate the app icons:

   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. Run the app:

   ```bash
   flutter run
   ```

### Building the release APK

```bash
flutter build apk --release
```

## 📥 Download

The latest signed APK is available on the **[Releases](#)** page of this repository.
_(Replace this link with your actual GitHub release URL.)_

## 🔐 Permissions Used

- **Camera & Microphone** — required for voice/video calls
- **SMS / Phone state** — used for OTP auto-retrieval on Android

## 🧭 Known Limitations / Roadmap

- Messages live inside a `messages` array on each user doc rather than a dedicated subcollection — simple for now, but won't scale well to long histories or group chats
- No push notifications when the app is fully closed — incoming-call/message alerts only show while the app is running
- No media (image/file) sharing yet
- No read receipts or typing indicators

## GitHub Link

https://github.com/ronitagrawal2007/Connect-Hub.git

## App Link

## Image
<img src="https://github.com/user-attachments/assets/21eec341-4d51-45d0-8227-d5f2543baadf" alt="Screenshot 1" width="300" />
<img src="https://github.com/user-attachments/assets/843820d2-a286-488c-b11f-53c9a308855c" alt="Screenshot 2" width="300" />
<img src="https://github.com/user-attachments/assets/9caffb9e-e4f4-45bd-9ba5-beb08c7ed4a9" alt="Screenshot 3" width="300" />
<img src="https://github.com/user-attachments/assets/53414cfa-0822-472b-bf45-f7783eb30dc3" alt="Screenshot 4" width="300" />
<img src="https://github.com/user-attachments/assets/ba59806c-5df0-4e30-9e42-30345cfd6a45" alt="Screenshot 5" width="300" />
<img src="https://github.com/user-attachments/assets/9563f02b-6f52-4dba-b03f-dc137c150943" alt="Screenshot 6" width="300" />
<img src="https://github.com/user-attachments/assets/291a0a03-80e8-4251-ad7a-68133cd90c35" alt="Screenshot 7" width="300" />
<img src="https://github.com/user-attachments/assets/7ce7bfed-8396-4cee-ade3-7df1b9e3c54a" alt="Screenshot 8" width="300" />
<img src="https://github.com/user-attachments/assets/0d028308-d670-4146-84e5-f39632acedb7" alt="Screenshot 9" width="300" />
<img src="https://github.com/user-attachments/assets/cc9feb8d-c3e6-4eb9-9e20-cbdae540c442" alt="Screenshot 10" width="300" />
<img src="https://github.com/user-attachments/assets/1e1057ba-ccc5-4110-8f00-8f427f9ae27b" alt="Screenshot 11" width="300" />
<img src="https://github.com/user-attachments/assets/caf2755c-3ab3-402f-b070-bb3a7b15e9a5" alt="Screenshot 12" width="300" />
<img src="https://github.com/user-attachments/assets/53e86c4e-366e-4ef3-9602-c42a7c392610" alt="Screenshot 13" width="300" />

## Video


https://github.com/user-attachments/assets/eb862fd7-6d53-4cba-9441-9f6ab4035e03


## 🙌 Credits

Designed and built from scratch as a solo project.
