# Eval+ 📱

Flutter mobile application for teacher evaluation at UTS (Unidades Tecnológicas de Santander). Modern interface enabling students to assess teaching quality and provide academic feedback.

## ✨ Features

- **Teacher Evaluation**: Comprehensive assessment system for teaching quality
- **Academic Feedback**: Students can provide constructive feedback
- **User-Friendly Interface**: Clean and intuitive design
- **Cross-Platform**: Works on Android and iOS

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Pokaymon/UTS.git
cd UTS
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## 🛠️ Developer Commands

### Asset Generation

#### Generate App Icon
Genera el ícono de la aplicación para Android e iOS basado en la configuración en `pubspec.yaml`:
```bash
dart run flutter_launcher_icons
```
Este comando crea:
- Íconos adaptativos para Android con el color de fondo `#003C43`
- Íconos para iOS en todas las resoluciones necesarias
- Usa la imagen `assets/icon/uts_icon2.png` como base

#### Generate Splash Screen
Genera la pantalla de splash nativa para Android e iOS:
```bash
dart run flutter_native_splash:create
```
Este comando configura:
- Splash screen con color de fondo `#003C43`
- Logo centrado usando `assets/icon/uts_icon2.png`
- Soporte para Android 12+ con el nuevo sistema de splash screens

#### Regenerate All Assets
Para regenerar tanto el ícono como el splash screen en un solo paso:
```bash
dart run flutter_launcher_icons && dart run flutter_native_splash:create
```

### Build Commands

#### Build for Android (APK)
```bash
flutter build apk --release
```
El APK generado estará en: `build/app/outputs/flutter-apk/app-release.apk`

#### Build for Android (App Bundle)
```bash
flutter build appbundle --release
```
Recomendado para publicar en Google Play Store.

#### Build for iOS
```bash
flutter build ios --release
```
Requiere macOS y Xcode configurado.

### Development Commands

#### Run in Debug Mode
```bash
flutter run
```

#### Run with Hot Reload
El hot reload está activo por defecto en modo debug. Usa:
- `r` para hot reload
- `R` para hot restart
- `q` para salir

#### Clean Build Files
Limpia los archivos de build y caché:
```bash
flutter clean
```
Después de hacer clean, ejecuta:
```bash
flutter pub get
```

#### Analyze Code
Analiza el código en busca de problemas:
```bash
flutter analyze
```

#### Format Code
Formatea el código siguiendo las convenciones de Dart:
```bash
dart format .
```

#### Run Tests
```bash
flutter test
```

### Dependency Management

#### Update Dependencies
```bash
flutter pub upgrade
```

#### Check Outdated Packages
```bash
flutter pub outdated
```

## 📦 Dependencies

### Main Dependencies
- `cupertino_icons: ^1.0.8` - iOS style icons
- `flutter_native_splash: ^2.4.6` - Native splash screen generation
- `lottie: ^3.3.2` - Animation support
- `ms_undraw: ^4.1.1` - Illustration library
- `flutter_svg: ^2.2.1` - SVG rendering support

### Dev Dependencies
- `flutter_lints: ^5.0.0` - Recommended lints for Flutter
- `flutter_launcher_icons: ^0.14.4` - App icon generation

## 📱 Platforms

- Android
- iOS

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is developed for UTS (Unidades Tecnológicas de Santander).

## 📧 Contact

For questions or suggestions, please open an issue in the repository.

---

Made with ❤️ for UTS
