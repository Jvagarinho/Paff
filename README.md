# Paff - Sticky Notes App

> **And it's noted.**

A modern, cross-platform sticky notes application built with Flutter, inspired by Windows Sticky Notes, with a focus on performance, reliability, and user experience.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Status](https://img.shields.io/badge/Status-Production%20Ready-success.svg)

## 📸 Screenshots

*Coming soon - Application screenshots*

## ✨ Features

### 📝 Rich Text Editor
- Support for **bold**, *italic*, <u>underline</u>
- Numbered and bulleted lists
- Headers and advanced formatting
- Emoji and special character support

### 🎨 Visual Customization
- **10 different colors** to categorize notes
- Clean and minimalist interface
- Smooth transparencies and shadows
- Light/dark theme support (in development)

### 📌 Organization
- **Pin important** notes to the top
- **Drag and drop** to reorganize
- Automatic sorting by modification date
- Filters by color and pin status

### 💾 Robust Persistence
- **Local** JSON storage
- **Auto-save** after each edit
- **Error recovery** with automatic rollback
- Automatic backup of corrupted data

### 🖥️ Cross-Platform
- ✅ **Windows** (x64)
- ✅ **Linux** (x64)
- ✅ **macOS** (Intel/Apple Silicon)
- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (experimental)

### 🔒 Single Instance (Desktop)
- Only **one instance** of the main manager
- Independent floating notes
- Lock system with PID tracking
- Automatic recovery of orphaned locks

## 🏗️ Architecture

The project follows **Clean Architecture** and **SOLID** principles:

```
lib/
├── main.dart              # Entry point and configuration
├── injection.dart         # Dependency injection (GetIt)
├── locator.dart           # Service Locator
├── models/                # Domain layer
│   └── note.dart         # Note entity
├── services/              # Data layer
│   ├── storage_service.dart           # Concrete implementation
│   ├── storage_service_interface.dart # Contract
│   ├── single_instance_service.dart   # Single instance
│   └── single_instance_service_interface.dart
├── providers/             # Presentation layer (State Management)
│   └── notes_provider.dart
├── screens/               # UI Widgets
│   ├── home_screen.dart
│   └── note_editor_screen.dart
├── widgets/               # Reusable components
│   ├── note_card.dart
│   └── color_picker.dart
├── logic/                 # Business logic
│   └── home_screen_logic.dart
└── utils/                # Utilities
    ├── constants.dart
    └── errors/          # Exception system
        ├── storage_exceptions.dart
        └── single_instance_exceptions.dart
```

### Design Patterns Used
- **Repository Pattern** - `StorageService`
- **Provider Pattern** - State management
- **Service Locator** - `GetIt` for dependency injection
- **Interface Segregation** - Responsibility-specific interfaces
- **Error Handling** - Custom exceptions with rollback

## 🚀 Como Começar

### Prerequisites

1. **Flutter SDK** (>=3.0.0)
   ```bash
   flutter --version
   ```

2. **Recommended Editor**
   - [VS Code](https://code.visualstudio.com/) + Flutter extension
   - Or [Android Studio](https://developer.android.com/studio)

3. **Build Tools** (for desktop)
   - **Windows**: Visual Studio 2022 with Desktop development with C++
   - **Linux**: `sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev`
   - **macOS**: Xcode Command Line Tools

### Quick Setup

```bash
# 1. Clone the repository
git clone https://github.com/Jvagarinho/Paff.git
cd Paff

# 2. Install dependencies
flutter pub get

# 3. Run in development
flutter run -d windows  # or linux, macos, chrome, etc.
```

### Production Build

#### Desktop
```bash
# Windows
flutter build windows --release

# Linux
flutter build linux --release

# macOS
flutter build macos --release
```

#### Mobile
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Google Play)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## 🧪 Testing

The project includes a comprehensive unit test suite:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Test Status
- ✅ **14/14 tests passing**
- ✅ Services and providers coverage
- ✅ `mocktail` for isolation

## 🔧 Configuration

### Debug Mode (Detailed Logs)

To enable detailed logs in services:

```dart
final storage = StorageService(debugMode: true);
```

Logs include:
- Read/write operations
- Errors and exceptions
- Single instance lifecycle
- Rollbacks on failure

### Environment Variables

No environment variables required. Storage uses:
- **Windows**: `%APPDATA%/Paff/notes.json`
- **macOS**: `~/Library/Application Support/Paff/notes.json`
- **Linux**: `~/.paff/notes.json`

## 🐛 Error Handling

The system implements **robust error handling**:

### Custom Exceptions
- `StorageException` - General storage errors
- `FileAccessException` - Permission/IO issues
- `JsonParseException` - Corrupted data
- `DirectoryCreationException` - Directory creation failure
- `LockAcquisitionException` - Single instance failure
- `LockReleaseException` - Lock release error

### Automatic Rollback
On error, local state is automatically reverted:
- `NotesProvider` maintains consistency
- `StorageService` leaves no orphaned data
- `SingleInstanceService` automatically cleans locks

### Logs
- **Debug mode**: Detailed console logs
- **Release mode**: Critical errors only
- **Files**: No file logging (can be added)

## 📊 Code Quality

### Static Analysis
```bash
flutter analyze --no-pub
```
✅ **No errors or warnings**

### Conventions
- **Dart Style Guide** strictly followed
- **Effective Dart** guidelines
- **Super parameters** for constructors
- Full **Null safety**

### Test Coverage
- Services: 100%
- Providers: 100%
- Logic: 100%

## 🤝 Contributing

Contributions are welcome! Please:

1. **Fork** the project
2. **Create a branch** for your feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

### Commit Standards
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` Formatting (no code change)
- `refactor:` Refactoring
- `test:` Tests
- `chore:` Build/CI

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- [Flutter Team](https://flutter.dev) - Amazing framework
- [Quill](https://quilljs.com) - Rich text editor
- [GetIt](https://pub.dev/packages/get_it) - Service Locator
- [Provider](https://pub.dev/packages/provider) - State Management

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/Jvagarinho/Paff/issues)
- **Documentation**: This README + [TESTING.md](TESTING.md)
- **Email**: [Your email here]

---

**Built with ❤️ and ☕ using Flutter**

[![GitHub stars](https://img.shields.io/github/stars/Jvagarinho/Paff?style=social)](https://github.com/Jvagarinho/Paff/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/Jvagarinho/Paff?style=social)](https://github.com/Jvagarinho/Paff/network)
