# زعمى ندوبل — Za3ma Ndoubel

A grade calculator for Tunisian 2nd year baccalaureate students in the Finance & Management stream. Built with Flutter.

---

## What it does

- Calculates module averages from sub-exam grades (contrôle, synthèse, oral, TP) with correct Tunisian coefficients
- Calculates the trimester average weighted by subject coefficients
- Saves grades per trimester locally — no data loss between sessions
- Calculates the annual average across all three trimesters (T1×1 + T2×2 + T3×2) / 5
- AI-powered grade analysis via Gemini — honest, contextual, Tunisian-flavoured academic advice
- Trilingual: French, Arabic (RTL), English
- Works fully offline except for the AI analysis feature

---

## Stack

- Flutter (Android)
- Provider for state management
- shared_preferences for local session persistence
- Google Fonts (Playfair Display, Lora, Amiri)
- Gemini 2.5 Flash API for AI analysis
- http for API calls
- flutter_svg for the splash screen
- flutter_launcher_icons for app icon generation

---

## Project structure
```
lib/
├── config/
│   └── secrets.dart          # API key — never committed
├── data/
│   └── finance_subjects.dart # Subject and coefficient definitions
├── l10n/
│   └── app_strings.dart      # All UI strings in FR, AR, EN
├── models/
│   └── subject.dart          # Subject and SubExam models
├── providers/
│   ├── locale_provider.dart  # Language state
│   └── trimester_provider.dart # Active trimester state
├── screens/
│   ├── splash_screen.dart
│   ├── calculator_screen.dart
│   ├── settings_screen.dart
│   ├── analysis_sheet.dart   # AI analysis bottom sheet
│   └── annual_average_sheet.dart
├── services/
│   ├── gemini_service.dart   # Gemini API prompt and call
│   └── session_service.dart  # shared_preferences read/write
└── utils/
    └── grade_calculator.dart # Pure calculation functions
```

---

## Setup

### 1. Clone and install dependencies
```bash
git clone https://github.com/Hiba-Hantous/Za3ma_Ndoubel.git
cd Za3ma_Ndoubel
flutter pub get
```

### 2. Add your Gemini API key

Create `lib/config/secrets.dart`:
```dart
const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
```

Get a free key at [aistudio.google.com](https://aistudio.google.com). This file is gitignored and never committed.

### 3. Run
```bash
flutter run
```

---

## Build APK
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Subject coefficients — Finance & Management

| Subject | Coefficient |
|---|---|
| Economics | 3 |
| Management | 3 |
| Maths | 2.5 |
| French | 2 |
| Arabic | 2 |
| English | 2 |
| IT | 1.5 |
| History | 1.5 |
| Geography | 1.5 |
| Civic Education | 1 |
| Islamic Education | 1 |
| Sports | 1 |

---

## Notes

- `lib/config/secrets.dart` is in `.gitignore` — never commit your API key
- The app is designed for local single-user use — no backend, no accounts, no sync
- AI analysis requires an internet connection and a valid Gemini API key
- Tested on Samsung SM-A705FN (Android)

---

## License

Personal project. Not affiliated with the Tunisian Ministry of Education.
