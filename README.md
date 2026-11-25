# Nox Keyboard (`com.Nox.Keyboard`)

[![Android Build & Release](https://github.com/shahin0964/Nox-Keyboard/actions/workflows/build_apk.yml/badge.svg)](https://github.com/shahin0964/Nox-Keyboard/actions/workflows/build_apk.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Framework: Flutter](https://img.shields.io/badge/Framework-Flutter%20%2F%20Dart-02569B.svg)](https://flutter.dev)

A complete, production-quality Android System Keyboard application inspired by the usability and functionality of Google Gboard. Built primarily in Flutter and Dart, with a high-performance Android `InputMethodService` native integration.

---

## 🌟 Key Features

### ⌨️ Comprehensive Keyboard Engine
- **Multilingual Support**: Bangla (Bangladesh), English (US), English (UK), Hindi (Devanagari), Arabic (RTL), and Urdu (RTL).
- **Bangla Phonetic Typing**: Intelligent Avro/Ridmik-style roman transliteration (`ami` → `আমি`, `bangla` → `বাংলা`, `kemon acho` → `কেমন আছো`, `dhonnobad` → `ধন্যবাদ`).
- **Bangla Script Layout**: Full Probhat/National Bengali keyboard layout with vowels, consonants, kar forms, and virama/hasant (`্`) conjunct composition.
- **Gesture Controls**:
  - **Spacebar Glide Typing**: Drag horizontally across the spacebar to smoothly slide the cursor left and right.
  - **Swipe Delete**: Swipe left from the Backspace key to delete entire words.
- **Key Press Feedback**: Dynamic key popup bubbles, customizable audio clicks, and adjustable tactile haptic vibrations.
- **Dedicated Number Row**: Toggleable 0-9 digits row directly above letter keys.
- **Symbols & Punctuations**: Two comprehensive symbol pages (`?123` and `=\<`) with mathematical operators, currency symbols (`৳`, `$`, `€`, `£`, `₹`), brackets, and typographic marks.

### 💡 Smart Typing & Suggestions
- **Smart Autocorrection**: Real-time typo detection using Levenshtein edit distance and common misspelling normalization (`teh` → `the`, `adn` → `and`, `dont` → `don't`).
- **Undo Autocorrect**: Tap backspace immediately after autocorrection to restore your original typed word.
- **Next-Word Prediction**: High-frequency context bigrams (`how are` → `you`, `thank` → `you`).
- **Personal Dictionary**: Save custom words, shortcuts, and slang that seamlessly integrate into the suggestion bar.
- **Auto-Capitalization**: Automatically capitalizes sentence beginnings and proper nouns.
- **Double-Space Period**: Automatically inserts `. ` when tapping space twice.

### 🎨 Material 3 Theme System
6 built-in professional themes:
1. **Nox Dark**: Sleek deep slate (`#13151B`) with neon cyan accent (`#00E5FF`).
2. **Nox Light**: Clean porcelain (`#ECEFF3`) with crisp white keys and indigo highlights.
3. **Midnight Blue**: Deep sapphire navy (`#0B132B`) with glowing electric blue accents.
4. **AMOLED Black**: True pure black (`#000000`) for maximum OLED battery savings with emerald green highlights.
5. **Ocean**: Deep teal gradient (`#0A192F`) with aqua highlights.
6. **Minimal White**: Ultra-clean minimalist styling with soft slate keys and warm accents.
- **Custom Theme Visual Editor**: Full visual builder with live keyboard preview. Customize background colors, key surface colors, text colors, corner radii (0-18dp), border widths, and margins.

### 🛠️ Expandable Toolbar & Panels
- **Emoji Palette**: Rich categorized emoji picker (Smileys, Gestures, Hearts, Animals, Food, Travel, Activities) with real-time search and recent history.
- **Clipboard History**: Pinned items, recent snippets, 1-tap paste, and unpinned clearing.
- **Text Editing Pad**: Dedicated cursor navigation pad with D-pad arrows (Up, Down, Left, Right), Select All, Cut, Copy, and Paste.
- **Voice Typing**: Live animated soundwave microphone panel with speech-to-text insertion.
- **One-Handed Mode**: Instant left or right hand shrinking for effortless single-handed typing on large screens.

### 🛡️ Privacy & Security First
- **100% Local-First**: No keystrokes, clipboard snippets, or personal dictionary words are ever transmitted over the network.
- **Secure Password Protection**: Android password and PIN fields automatically trigger Private Mode, disabling suggestions, learning, and autocorrection.
- **Zero Telemetry**: No hidden analytics or user tracking.

---

## 🏗️ Technical Architecture

```
lib/
├── app/                  # App initialization, routing & theme wiring
├── core/                 # Constants, base utilities & styling
├── data/                 # Local persistence (SharedPreferences, custom themes, clips)
├── features/
│   ├── clipboard/        # Clipboard manager panel & settings
│   ├── customization/    # Theme gallery & live custom theme builder
│   ├── dashboard/        # Main dashboard & interactive test playground
│   ├── emoji/            # Categorized emoji palette & recent tracker
│   ├── language/         # Language management & phonetic switches
│   ├── onboarding/       # 3-step system setup wizard (Enable, Default, Test)
│   ├── privacy/          # Privacy policy & local storage audit
│   ├── settings/         # Typing parameters, height sliders & dictionaries
│   └── voice/            # Voice typing interface with pulsing orb
├── keyboard/
│   ├── engine/           # Typing engine, phonetic transliterator & gestures
│   ├── layouts/          # QWERTY, Bangla, Hindi, Arabic, Urdu, Symbols
│   ├── suggestions/      # Trie search, n-gram predictor & autocorrect
│   └── widgets/          # KeyboardView, key widgets, popups & toolbar
├── languages/            # Dictionaries (en_US, bn_BD, hi, ar, ur)
├── services/             # MethodChannel platform bridge & mock engine
├── themes/               # Theme models, 6 built-in presets & theme manager
└── main.dart             # App & IME dual entrypoints

android/
└── app/src/main/
    ├── AndroidManifest.xml   # InputMethodService registration & permissions
    ├── kotlin/com/Nox/Keyboard/
    │   ├── MainActivity.kt           # Onboarding & settings platform channel
    │   └── NoxInputMethodService.kt   # Native Android IME bridge (~200 lines)
    └── res/xml/method.xml            # Input method subtypes (English & Bangla)
```

---

## 🚀 Building & Releasing

### Prerequisites
- Flutter SDK 3.19+
- Android SDK 35 (Platform Tools & Build Tools 34.0.0+)
- JDK 17 or 21

### Local Build
```bash
flutter pub get
flutter test
flutter build apk --release
```

### GitHub Actions CI/CD
The repository includes `.github/workflows/build_apk.yml` which automatically compiles release APKs and drafts GitHub releases upon pushing to `main`.
