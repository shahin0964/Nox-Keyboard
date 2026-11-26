import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/preferences_helper.dart';
import '../../languages/language_manager.dart';
import '../../themes/theme_manager.dart';
import '../../services/ime_platform_bridge.dart';
import '../layouts/keyboard_layout.dart';
import '../layouts/english_layout.dart';
import '../layouts/bangla_layout.dart';
import '../layouts/hindi_layout.dart';
import '../layouts/arabic_layout.dart';
import '../layouts/urdu_layout.dart';
import '../layouts/symbols_layout.dart';
import '../layouts/number_row_layout.dart';
import '../suggestions/suggestion_engine.dart';
import '../suggestions/autocorrect_service.dart';
import 'haptic_sound_service.dart';
import 'bangla_phonetic_engine.dart';

enum KeyboardMode { letters, symbols, moreSymbols }
enum KeyboardPanel { none, emoji, clipboard, textEditing, themes, voice, toolsGrid }

class KeyboardEngine extends ChangeNotifier {
  static final KeyboardEngine _instance = KeyboardEngine._internal();
  factory KeyboardEngine() => _instance;
  KeyboardEngine._internal() {
    _init();
  }

  final ImePlatformBridge _bridge = ImePlatformBridge();
  final PreferencesHelper _prefs = PreferencesHelper();
  final LanguageManager _langManager = LanguageManager();
  final SuggestionEngine _suggestionEngine = SuggestionEngine();
  final AutocorrectService _autocorrectService = AutocorrectService();
  final HapticSoundService _hapticSound = HapticSoundService();
  final BanglaPhoneticEngine _banglaPhonetic = BanglaPhoneticEngine();

  // State
  KeyboardMode _mode = KeyboardMode.letters;
  KeyboardMode get mode => _mode;

  KeyboardPanel _activePanel = KeyboardPanel.none;
  KeyboardPanel get activePanel => _activePanel;

  bool _isShifted = false;
  bool get isShifted => _isShifted;

  bool _isCapsLock = false;
  bool get isCapsLock => _isCapsLock;

  DateTime? _lastShiftTapTime;

  String _composingWord = '';
  String get composingWord => _composingWord;

  String _contextBefore = '';
  String get contextBefore => _contextBefore;

  String _lastCommittedWord = '';

  List<SuggestionCandidate> _candidates = [];
  List<SuggestionCandidate> get candidates => _candidates;

  bool _isPassword = false;
  bool get isPassword => _isPassword;

  int _actionId = 0;
  String _actionLabel = 'ENTER';
  String get actionLabel => _actionLabel;

  bool _showNumberRow = false;
  bool get showNumberRow => _showNumberRow;

  String _oneHandedMode = 'none'; // 'none', 'left', 'right'
  String get oneHandedMode => _oneHandedMode;

  bool _isFloating = false;
  bool get isFloating => _isFloating;

  bool _isToolbarExpanded = false;
  bool get isToolbarExpanded => _isToolbarExpanded;

  bool _forceShowToolbar = false;
  bool get forceShowToolbar => _forceShowToolbar;

  void toggleForceShowToolbar() {
    _forceShowToolbar = !_forceShowToolbar;
    notifyListeners();
  }

  DateTime? _lastSpaceTapTime;

  void _init() {
    _prefs.init().then((_) {
      _showNumberRow = _prefs.showNumberRow;
      _oneHandedMode = _prefs.oneHandedMode;
      _isFloating = _prefs.isFloatingMode;
      notifyListeners();
    });

    _langManager.addListener(() {
      _updateSuggestions();
      notifyListeners();
    });

    _bridge.onStartInputCallback = (data) async {
      await _prefs.reload();
      await ThemeManager().init();
      await _langManager.init();
      _showNumberRow = _prefs.showNumberRow;
      _oneHandedMode = _prefs.oneHandedMode;
      _isFloating = _prefs.isFloatingMode;

      final clip = data['clipboardText'] as String? ?? '';
      if (clip.trim().isNotEmpty) {
        await _prefs.addClipboardItem(clip.trim());
      }
      final imgPath = data['clipboardImagePath'] as String? ?? '';
      if (imgPath.trim().isNotEmpty) {
        await _prefs.addImageClip(imgPath.trim());
      }

      _isPassword = data['isPassword'] as bool? ?? false;
      _actionId = data['actionId'] as int? ?? 0;
      final label = data['actionLabel'] as String? ?? '';
      _actionLabel = label.isNotEmpty ? label : _resolveActionLabel(_actionId);
      _contextBefore = data['textBeforeCursor'] as String? ?? '';
      _composingWord = '';
      _forceShowToolbar = false;
      _updateSuggestions();
      notifyListeners();
    };

    _bridge.onFinishInputCallback = () {
      _composingWord = '';
      _candidates.clear();
      _activePanel = KeyboardPanel.none;
      _forceShowToolbar = false;
      notifyListeners();
    };
  }

  String _resolveActionLabel(int actionId) {
    switch (actionId) {
      case 2: // IME_ACTION_GO
        return 'GO';
      case 3: // IME_ACTION_SEARCH
        return 'SEARCH';
      case 4: // IME_ACTION_SEND
        return 'SEND';
      case 5: // IME_ACTION_NEXT
        return 'NEXT';
      case 6: // IME_ACTION_DONE
        return 'DONE';
      default:
        return 'ENTER';
    }
  }

  bool get _isAvroActive {
    final code = _langManager.currentLanguage.code;
    return code == 'bn_avro' || (code == 'bn_BD' && _langManager.isBanglaPhonetic);
  }

  KeyboardPage get activePage {
    switch (_mode) {
      case KeyboardMode.symbols:
        return SymbolsLayout.getPage1();
      case KeyboardMode.moreSymbols:
        return SymbolsLayout.getPage2();
      case KeyboardMode.letters:
        final lang = _langManager.currentLanguage;
        switch (lang.code) {
          case 'bn_avro':
            return BanglaLayout.getPage(
              isPhonetic: true,
              isShifted: _isShifted,
              isCapsLock: _isCapsLock,
            );
          case 'bn_BD':
            return BanglaLayout.getPage(
              isPhonetic: _langManager.isBanglaPhonetic,
              isShifted: _isShifted,
              isCapsLock: _isCapsLock,
            );
          case 'hi':
            return HindiLayout.getPage(isShifted: _isShifted, isCapsLock: _isCapsLock);
          case 'ar':
            return ArabicLayout.getPage(isShifted: _isShifted, isCapsLock: _isCapsLock);
          case 'ur':
            return UrduLayout.getPage(isShifted: _isShifted, isCapsLock: _isCapsLock);
          case 'en_US':
          case 'en_UK':
          default:
            return EnglishLayout.getPage(isShifted: _isShifted, isCapsLock: _isCapsLock);
        }
    }
  }

  KeyboardRow? get numberRow {
    if (_showNumberRow && _mode == KeyboardMode.letters) {
      return NumberRowLayout.getRow();
    }
    return null;
  }

  void toggleNumberRow() {
    _showNumberRow = !_showNumberRow;
    _prefs.setShowNumberRow(_showNumberRow);
    notifyListeners();
  }

  void toggleToolbarExpanded() {
    _isToolbarExpanded = !_isToolbarExpanded;
    notifyListeners();
  }

  void setOneHandedMode(String mode) {
    _oneHandedMode = mode;
    _prefs.setOneHandedMode(mode);
    notifyListeners();
  }

  void toggleFloatingMode() {
    _isFloating = !_isFloating;
    _prefs.setIsFloatingMode(_isFloating);
    notifyListeners();
  }

  void openPanel(KeyboardPanel panel) {
    _activePanel = (_activePanel == panel) ? KeyboardPanel.none : panel;
    notifyListeners();
  }

  void closePanel() {
    _activePanel = KeyboardPanel.none;
    notifyListeners();
  }

  void onKeyPress(KeyboardKey key) {
    _hapticSound.onKeyFeedback();

    switch (key.action) {
      case KeyAction.character:
        _handleCharacter(key.primary);
        break;
      case KeyAction.shift:
        _handleShift();
        break;
      case KeyAction.backspace:
        _handleBackspace();
        break;
      case KeyAction.space:
        _handleSpace();
        break;
      case KeyAction.enter:
        _handleEnter();
        break;
      case KeyAction.switchSymbols:
        _mode = KeyboardMode.symbols;
        notifyListeners();
        break;
      case KeyAction.switchMoreSymbols:
        _mode = KeyboardMode.moreSymbols;
        notifyListeners();
      case KeyAction.switchLetters:
        _mode = KeyboardMode.letters;
        notifyListeners();
        break;
      case KeyAction.switchLanguage:
        _langManager.cycleNextLanguage();
        break;
      case KeyAction.emoji:
        openPanel(KeyboardPanel.emoji);
        break;
    }
  }

  void _learnCommittedWord(String word) {
    if (_isPassword) return;
    final clean = word.trim();
    if (clean.length < 2) return;
    _prefs.recordLearnedWord(clean);
    if (_lastCommittedWord.isNotEmpty) {
      _prefs.recordLearnedBigram(_lastCommittedWord, clean);
    }
    _lastCommittedWord = clean;
  }

  void _handleCharacter(String char) {
    _forceShowToolbar = false;

    if (_isAvroActive && _mode == KeyboardMode.letters) {
      // In Bangla Avro Phonetic: accumulate roman characters and compute phonetic output
      _composingWord += char;
      _updateSuggestions();
    } else {
      // Commit text first for instant zero-lag appearance in active field
      _bridge.commitText(char);
      _contextBefore += char;
      final isLetter = RegExp(r'[a-zA-Z]').hasMatch(char);
      if (isLetter && _mode == KeyboardMode.letters) {
        _composingWord += char;
      } else {
        if (_composingWord.isNotEmpty) {
          _learnCommittedWord(_composingWord);
          _composingWord = '';
        }
      }
      _updateSuggestions();
    }

    // Auto unshift after single shift tap
    if (_isShifted && !_isCapsLock) {
      _isShifted = false;
    }
    notifyListeners();
  }

  void _handleShift() {
    final now = DateTime.now();
    if (_lastShiftTapTime != null && now.difference(_lastShiftTapTime!).inMilliseconds < 400) {
      // Double tap -> Caps Lock
      _isCapsLock = !_isCapsLock;
      _isShifted = _isCapsLock;
      _lastShiftTapTime = null;
    } else {
      _isCapsLock = false;
      _isShifted = !_isShifted;
      _lastShiftTapTime = now;
    }
    notifyListeners();
  }

  void _handleBackspace() {
    // Check if we should undo autocorrection
    final lastAuto = _autocorrectService.lastAutocorrection;
    if (lastAuto != null && _composingWord.isEmpty) {
      final original = lastAuto['original']!;
      final corrected = lastAuto['corrected']!;
      // Delete the corrected word + space and restore original
      for (int i = 0; i <= corrected.length; i++) {
        _bridge.deleteBackward();
      }
      _bridge.commitText(original);
      _autocorrectService.clearLastAutocorrect();
      _composingWord = original;
      _updateSuggestions();
      notifyListeners();
      return;
    }

    if (_composingWord.isNotEmpty) {
      _composingWord = _composingWord.substring(0, _composingWord.length - 1);
      if (!_isAvroActive) {
        _bridge.deleteBackward();
      }
      _updateSuggestions();
    } else {
      _bridge.deleteBackward();
      if (_contextBefore.isNotEmpty) {
        _contextBefore = _contextBefore.substring(0, _contextBefore.length - 1);
      }
      _updateSuggestions();
    }
    notifyListeners();
  }

  void handleSwipeDelete() {
    _bridge.deleteWordBackward();
    _composingWord = '';
    _updateSuggestions();
    notifyListeners();
  }

  void _handleSpace() {
    // 1. If in Bangla Avro Phonetic mode, commit the top phonetic candidate or parsed word
    if (_isAvroActive && _composingWord.isNotEmpty) {
      final candidate = _candidates.isNotEmpty
          ? _candidates.first.text
          : _banglaPhonetic.parse(_composingWord);
      _bridge.commitText('$candidate ');
      _learnCommittedWord(candidate);
      _contextBefore += '$candidate ';
      _composingWord = '';
      _updateSuggestions();
      notifyListeners();
      return;
    }

    // 2. Autocorrect on Space in standard typing
    if (_prefs.autoCorrection && _composingWord.isNotEmpty && _candidates.isNotEmpty) {
      final center = _candidates.firstWhere((c) => c.isAutocorrect, orElse: () => _candidates.first);
      if (center.text != _composingWord) {
        // Replace composing word with autocorrected word
        for (int i = 0; i < _composingWord.length; i++) {
          _bridge.deleteBackward();
        }
        _bridge.commitText('${center.text} ');
        _learnCommittedWord(center.text);
        _autocorrectService.recordAutocorrect(_composingWord, center.text);
        _contextBefore += '${center.text} ';
        _composingWord = '';
        _updateSuggestions();
        notifyListeners();
        return;
      }
    }

    // Learn user's exact typed word before clearing composing buffer
    if (_composingWord.isNotEmpty) {
      _learnCommittedWord(_composingWord);
    }

    // 3. Double-space period shortcut
    final now = DateTime.now();
    if (_prefs.doubleSpacePeriod &&
        _lastSpaceTapTime != null &&
        now.difference(_lastSpaceTapTime!).inMilliseconds < 450 &&
        _contextBefore.endsWith(' ')) {
      _bridge.deleteBackward();
      _bridge.commitText('. ');
      _contextBefore = _contextBefore.substring(0, _contextBefore.length - 1) + '. ';
      _lastSpaceTapTime = null;
      _composingWord = '';
      _updateSuggestions();
      notifyListeners();
      return;
    }

    _lastSpaceTapTime = now;
    _bridge.commitText(' ');
    _contextBefore += ' ';
    _composingWord = '';
    _updateSuggestions();
    notifyListeners();
  }

  void _handleEnter() {
    if (_composingWord.isNotEmpty) {
      _learnCommittedWord(_composingWord);
    }
    _composingWord = '';
    _candidates.clear();
    _bridge.performEditorAction(_actionId);
    notifyListeners();
  }

  void selectSuggestion(SuggestionCandidate candidate) {
    _hapticSound.onKeyFeedback();

    if (_isAvroActive) {
      _bridge.commitText('${candidate.text} ');
      _contextBefore += '${candidate.text} ';
    } else {
      if (_composingWord.isNotEmpty) {
        for (int i = 0; i < _composingWord.length; i++) {
          _bridge.deleteBackward();
        }
      }
      _bridge.commitText('${candidate.text} ');
      _contextBefore += '${candidate.text} ';
    }

    _learnCommittedWord(candidate.text);
    _composingWord = '';
    _autocorrectService.clearLastAutocorrect();
    _updateSuggestions();
    notifyListeners();
  }

  void _updateSuggestions() {
    if (_isPassword || !_prefs.showSuggestionsBar) {
      _candidates = [];
      return;
    }

    _candidates = _suggestionEngine.getSuggestions(
      composingWord: _composingWord,
      contextBefore: _contextBefore,
      languageCode: _langManager.currentLanguage.code,
      isBanglaPhonetic: _langManager.isBanglaPhonetic,
      autocorrectEnabled: _prefs.autoCorrection,
      nextWordEnabled: _prefs.nextWordPrediction,
    );
  }

  // Cursor drag via spacebar
  double _dragAccumulator = 0;
  void onSpaceDragUpdate(DragUpdateDetails details) {
    _dragAccumulator += details.delta.dx;
    if (_dragAccumulator > 16) {
      _bridge.moveCursor(1);
      _dragAccumulator = 0;
      _hapticSound.performHaptic();
    } else if (_dragAccumulator < -16) {
      _bridge.moveCursor(-1);
      _dragAccumulator = 0;
      _hapticSound.performHaptic();
    }
  }

  void onSpaceDragEnd(DragEndDetails details) {
    _dragAccumulator = 0;
  }
}
