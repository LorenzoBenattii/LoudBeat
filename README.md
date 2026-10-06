# LoudBeat

LoudBeat is a personal music player built with Flutter and Dart for Android.

The application allows users to search for music, download audio for local playback, manage their music library and organize songs into playlists.

## Features

- Search for songs
- Download audio for local playback
- Local music library
- Playlist creation and management
- Album artwork and audio metadata
- Play, pause, previous and next controls
- Playback queue
- Background audio playback
- Android media controls and notifications
- Local SQLite database

## Technologies

- **Flutter / Dart** — Application framework
- **SQLite / sqflite** — Local database
- **just_audio** — Audio playback
- **audio_service** — Background playback and Android media controls
- **yt-dlp** — Audio extraction
- **youtube_results** — Music search
- **audio_metadata_reader** — Audio metadata
- **flutter_slidable** — Swipe actions
- **path_provider** — Local file storage

## Project Structure

```text
lib/
├── database/       # Database and data models
├── services/       # Audio, navigation and download services
├── widgets/        # Reusable UI components
└── ...

assets/             # Application assets
fonts/              # Application fonts

android/            # Android-specific configuration
ios/                # iOS-specific configuration
web/                # Web configuration
windows/             # Windows configuration
linux/               # Linux configuration
macos/               # macOS configuration
```

## Getting Started

### Requirements

- Flutter
- Dart
- Android Studio or an Android development environment
- An Android device or emulator

Verify your Flutter installation:

```bash
flutter doctor
```

### Installation

Clone the repository:

```bash
git clone https://github.com/LorenzoBenattii/LoudBeat.git
cd LoudBeat
```

Install the dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

To build a release APK:

```bash
flutter build apk --release
```

The APK will be generated in:

```text
build/app/outputs/flutter-apk/
```

## Development

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

If Flutter's generated files need to be regenerated:

```bash
flutter clean
flutter pub get
```

## Storage

LoudBeat stores its music library and playlist information in a local SQLite database.

Downloaded audio files are stored in the application's local storage. The database stores the information required to manage the library and associate songs with playlists.

## Legal Disclaimer

LoudBeat does not host or distribute music or other copyrighted content.

The application provides functionality for retrieving and playing audio from sources accessible to the user. Users are solely responsible for ensuring that their use of LoudBeat, and any content they download through it, complies with applicable laws, copyright regulations, and the terms of the services they access.

LoudBeat does not authorize, encourage, or endorse copyright infringement or the unauthorized downloading, distribution, or redistribution of copyrighted material.

The software is provided "as is", without warranty of any kind. The author is not responsible for claims, damages, losses, or legal consequences arising from the use or misuse of the software or content obtained through it.

## License

LoudBeat is licensed under the [MIT License](LICENSE).
