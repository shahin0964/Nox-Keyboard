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
import '../suggestions/dictionary_service.dart';
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

  bool _isSensitive = false;
  String _currentAppPackage = '';
  String _sentenceBuffer = '';

  bool _isKeyCommandMode = false;
  bool get isKeyCommandMode => _isKeyCommandMode;

  String? _keyCommandFeedback;
  String? get keyCommandFeedback => _keyCommandFeedback;
  int _keyFeedbackToken = 0;

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

  int _gridRevision = 0;
  int get gridRevision => _gridRevision;

  static final RegExp _wordCharRegex = RegExp(
    r'[a-zA-Z\u0981-\u09DF\u0900-\u0963\u0966-\u097F\u0621-\u065F\u0670-\u06D3]',
  );

  static const Map<String, String> _banglaVowelToKar = {
    'আ': 'া',
    'ই': 'ি',
    'ঈ': 'ী',
    'উ': 'ু',
    'ঊ': 'ূ',
    'ঋ': 'ৃ',
    'এ': 'ে',
    'ঐ': 'ৈ',
    'ও': 'ো',
    'ঔ': 'ৌ',
  };

  static final RegExp _banglaConsonantEndRegex = RegExp(r'[\u0995-\u09B9\u09DC-\u09DF]$');

  List<String> _toolbarOrder = List<String>.from(PreferencesHelper.defaultToolbarOrder);
  List<String> get toolbarOrder => _toolbarOrder;

  void moveToolbarTool(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= _toolbarOrder.length) return;
    if (toIndex < 0 || toIndex >= _toolbarOrder.length) return;
    if (fromIndex == toIndex) return;
    final list = List<String>.from(_toolbarOrder);
    final item = list.removeAt(fromIndex);
    list.insert(toIndex, item);
    _toolbarOrder = list;
    _prefs.setToolbarOrder(list);
    _gridRevision++;
    notifyListeners();
  }

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
      _toolbarOrder = _prefs.toolbarOrder;
      DictionaryService().ensureLoaded(_langManager.currentLanguage.code);
      _gridRevision++;
      notifyListeners();
    });

    _langManager.addListener(() {
      DictionaryService().ensureLoaded(_langManager.currentLanguage.code).then((_) {
        _updateSuggestions();
        notifyListeners();
      });
      _gridRevision++;
      _updateSuggestions();
      notifyListeners();
    });

    _bridge.onStartInputCallback = (data) async {
      _flushSentenceHistory();
      await _prefs.reload();
      await ThemeManager().init();
      await _langManager.init();
      DictionaryService().ensureLoaded(_langManager.currentLanguage.code);
      _showNumberRow = _prefs.showNumberRow;
      _oneHandedMode = _prefs.oneHandedMode;
      _isFloating = _prefs.isFloatingMode;
      _toolbarOrder = _prefs.toolbarOrder;

      final clip = data['clipboardText'] as String? ?? '';
      if (clip.trim().isNotEmpty) {
        await _prefs.addClipboardItem(clip.trim());
      }
      final imgPath = data['clipboardImagePath'] as String? ?? '';
      if (imgPath.trim().isNotEmpty) {
        await _prefs.addImageClip(imgPath.trim());
      }

      _isPassword = data['isPassword'] as bool? ?? false;
      final isNumberField = data['isNumber'] as bool? ?? false;
      _isSensitive = _isPassword || (data['isSensitive'] as bool? ?? false) || isNumberField;
      _currentAppPackage = data['packageName'] as String? ?? '';
      _sentenceBuffer = '';
      if (_isPassword || _isSensitive) {
        _isKeyCommandMode = false;
      }

      _actionId = data['actionId'] as int? ?? 0;
      final label = data['actionLabel'] as String? ?? '';
      _actionLabel = label.isNotEmpty ? label : _resolveActionLabel(_actionId);
      _contextBefore = data['textBeforeCursor'] as String? ?? '';
      _composingWord = '';
      _forceShowToolbar = false;
      _gridRevision++;
      _updateSuggestions();
      notifyListeners();
    };

    _bridge.onFinishInputCallback = () {
      _flushSentenceHistory();
      _composingWord = '';
      _candidates.clear();
      _activePanel = KeyboardPanel.none;
      _forceShowToolbar = false;
      _isKeyCommandMode = false;
      _gridRevision++;
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
    return _langManager.currentLanguage.code == 'bn_avro';
  }

  KeyboardPage get activePage {
    if (_isKeyCommandMode && _mode == KeyboardMode.letters) {
      return EnglishLayout.getPage(isShifted: false, isCapsLock: false);
    }
    switch (_mode) {
      case KeyboardMode.symbols:
        return SymbolsLayout.getPage1(languageCode: _langManager.currentLanguage.code);
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
              isPhonetic: false,
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
    if (_showNumberRow &&
        _mode == KeyboardMode.letters &&
        _langManager.currentLanguage.code != 'bn_BD') {
      return NumberRowLayout.getRow(languageCode: _langManager.currentLanguage.code);
    }
    return null;
  }

  void toggleNumberRow() {
    _showNumberRow = !_showNumberRow;
    _prefs.setShowNumberRow(_showNumberRow);
    _gridRevision++;
    notifyListeners();
  }

  void toggleToolbarExpanded() {
    _isToolbarExpanded = !_isToolbarExpanded;
    notifyListeners();
  }

  void setOneHandedMode(String mode) {
    _oneHandedMode = mode;
    _prefs.setOneHandedMode(mode);
    _gridRevision++;
    notifyListeners();
  }

  void toggleFloatingMode() {
    _isFloating = !_isFloating;
    _prefs.setIsFloatingMode(_isFloating);
    _gridRevision++;
    notifyListeners();
  }

  void openPanel(KeyboardPanel panel) {
    _activePanel = (_activePanel == panel) ? KeyboardPanel.none : panel;
    _gridRevision++;
    notifyListeners();
  }

  void closePanel() {
    _activePanel = KeyboardPanel.none;
    _gridRevision++;
    notifyListeners();
  }

  void toggleKeyCommandMode() {
    _isKeyCommandMode = !_isKeyCommandMode;
    _activePanel = KeyboardPanel.none;
    if (_isKeyCommandMode) {
      _mode = KeyboardMode.letters;
    }
    _gridRevision++;
    notifyListeners();
  }

  static const Map<String, String> _actionShortLabels = {
    'action:copy': 'Copy',
    'action:paste': 'Paste',
    'action:cut': 'Cut',
    'action:selectAll': 'All',
    'action:undo': 'Undo',
    'action:redo': 'Redo',
    'action:deleteForward': 'Del →',
    'action:deleteWord': 'Del W',
    'action:clearAll': 'Clear',
    'action:copyAll': 'CpAll',
    'action:home': 'Home',
    'action:end': 'End',
    'action:tab': 'Tab',
    'action:escape': 'Esc',
    'action:left': '←',
    'action:right': '→',
    'action:up': '↑',
    'action:down': '↓',
    'action:selectLeft': 'Sel←',
    'action:selectRight': 'Sel→',
  };

  String? getCommandLabelForKey(String rawKey) {
    final clean = rawKey.trim().toLowerCase();
    if (clean.length != 1) return null;
    final mapping = _prefs.keyCommandsMap[clean];
    if (mapping == null || mapping.isEmpty) return null;
    if (_actionShortLabels.containsKey(mapping)) {
      return _actionShortLabels[mapping];
    }
    if (mapping.startsWith('text:')) {
      final t = mapping.substring(5).trim();
      return t.length > 5 ? '${t.substring(0, 4)}…' : t;
    }
    return null;
  }

  void _setKeyFeedback(String msg) {
    final token = ++_keyFeedbackToken;
    _keyCommandFeedback = msg;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (token == _keyFeedbackToken && _keyCommandFeedback != null) {
        _keyCommandFeedback = null;
        notifyListeners();
      }
    });
  }

  Future<void> _handleKeyCommand(String char) async {
    final clean = char.trim().toLowerCase();
    final mapping = _prefs.keyCommandsMap[clean];
    if (mapping == null || mapping.isEmpty) {
      return;
    }
    if (mapping.startsWith('action:')) {
      final cmd = mapping.substring(7);
      final ok = await _bridge.executeKeyCommand(cmd);
      if (cmd == 'copy' || cmd == 'cut' || cmd == 'copyAll') {
        if (ok) {
          final clip = await _bridge.getClipboardText();
          if (clip.trim().isNotEmpty) {
            await _prefs.addClipboardItem(clip.trim());
          }
          _setKeyFeedback(cmd == 'cut' ? '✓ Cut to clipboard' : '✓ Copied to clipboard');
        } else {
          _setKeyFeedback('Select text first to $cmd');
        }
      } else if (cmd == 'paste') {
        _setKeyFeedback(ok ? '✓ Pasted' : 'Clipboard empty');
      } else if (cmd == 'selectAll') {
        _setKeyFeedback(ok ? '✓ Selected all' : 'No text to select');
      } else {
        final label = _actionShortLabels[mapping] ?? cmd;
        _setKeyFeedback(ok ? '✓ $label' : '$label unavailable');
      }
    } else if (mapping.startsWith('text:')) {
      final txt = mapping.substring(5);
      if (txt.isNotEmpty) {
        await _bridge.commitText(txt);
        _appendToSentenceBuffer(txt);
        _setKeyFeedback('✓ Inserted snippet');
      }
    }
    if (!_prefs.keyModeStayActive) {
      _isKeyCommandMode = false;
      _keyCommandFeedback = null;
      _gridRevision++;
      notifyListeners();
    }
  }

  void _appendToSentenceBuffer(String text) {
    if (_isPassword || _isSensitive || !_prefs.isTypingHistoryEnabled) {
      _sentenceBuffer = '';
      return;
    }
    _sentenceBuffer += text;
  }

  void _trimSentenceBufferOne() {
    if (_sentenceBuffer.isNotEmpty) {
      _sentenceBuffer = _sentenceBuffer.substring(0, _sentenceBuffer.length - 1);
    }
  }

  static bool _isLikelyPinOrCard(String s) {
    final compact = s.replaceAll(RegExp(r'[\s\-]'), '');
    if (RegExp(r'^\d{4,20}$').hasMatch(compact)) return true;
    return false;
  }

  void _flushSentenceHistory() {
    final raw = _sentenceBuffer;
    _sentenceBuffer = '';
    if (_isPassword || _isSensitive || !_prefs.isTypingHistoryEnabled) return;
    final clean = raw.trim();
    if (clean.length < 2 || _isLikelyPinOrCard(clean)) return;
    _prefs.addTypingHistoryEntry(
      text: clean,
      language: _langManager.currentLanguage.nativeName,
      packageName: _currentAppPackage,
    );
  }

  void onKeyPress(
    KeyboardKey key, {
    bool skipFeedback = false,
    bool bypassAutoKar = false,
  }) {
    if (!skipFeedback) {
      _hapticSound.onKeyFeedback(
        key.action == KeyAction.space || key.action == KeyAction.backspace || key.action == KeyAction.enter ? 1 : 0,
      );
    }

    switch (key.action) {
      case KeyAction.character:
        _handleCharacter(key.primary, bypassAutoKar: bypassAutoKar);
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
        if (_isAvroActive && _composingWord.isNotEmpty) {
          _bridge.finishComposingText();
          _composingWord = '';
        }
        _mode = KeyboardMode.symbols;
        _gridRevision++;
        notifyListeners();
        break;
      case KeyAction.switchMoreSymbols:
        _mode = KeyboardMode.moreSymbols;
        _gridRevision++;
        notifyListeners();
        break;
      case KeyAction.switchLetters:
        _mode = KeyboardMode.letters;
        _gridRevision++;
        notifyListeners();
        break;
      case KeyAction.switchLanguage:
        if (_isAvroActive && _composingWord.isNotEmpty) {
          _bridge.finishComposingText();
          _composingWord = '';
        }
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

  void _handleCharacter(String char, {bool bypassAutoKar = false}) {
    _forceShowToolbar = false;

    if (_isKeyCommandMode && _mode == KeyboardMode.letters) {
      _handleKeyCommand(char);
      return;
    }

    if (!bypassAutoKar &&
        _mode == KeyboardMode.letters &&
        _langManager.currentLanguage.code == 'bn_BD') {
      final mappedKar = _banglaVowelToKar[char];
      if (mappedKar != null && _banglaConsonantEndRegex.hasMatch(_contextBefore)) {
        char = mappedKar;
      }
    }

    if (_isAvroActive && _mode == KeyboardMode.letters) {
      final isLetter = RegExp(r'[a-zA-Z]').hasMatch(char);
      if (isLetter) {
        // Live Avro Phonetic composing directly inside the target text box!
        _composingWord += char;
        _updateSuggestions();
        final liveBangla = _candidates.isNotEmpty
            ? _candidates.first.text
            : _banglaPhonetic.parse(_composingWord);
        _bridge.setComposingText(liveBangla);
      } else {
        // Punctuation/digit finalizes active Avro word first, then commits punctuation
        if (_composingWord.isNotEmpty) {
          final finalized = _candidates.isNotEmpty
              ? _candidates.first.text
              : _banglaPhonetic.parse(_composingWord);
          _bridge.commitText('$finalized$char');
          _learnCommittedWord(finalized);
          _appendToSentenceBuffer('$finalized$char');
          _contextBefore += '$finalized$char';
          _composingWord = '';
        } else {
          _bridge.commitText(char);
          _appendToSentenceBuffer(char);
          _contextBefore += char;
        }
        _updateSuggestions();
      }
    } else {
      // Commit text first for instant zero-lag appearance in active field
      _bridge.commitText(char);
      _appendToSentenceBuffer(char);
      _contextBefore += char;
      final isLetter = _wordCharRegex.hasMatch(char);
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
      _gridRevision++;
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
    _gridRevision++;
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
      _updateSuggestions();
      if (_isAvroActive) {
        if (_composingWord.isNotEmpty) {
          final liveBangla = _candidates.isNotEmpty
              ? _candidates.first.text
              : _banglaPhonetic.parse(_composingWord);
          _bridge.setComposingText(liveBangla);
        } else {
          _bridge.setComposingText('');
          _bridge.finishComposingText();
        }
      } else {
        _bridge.deleteBackward();
        _trimSentenceBufferOne();
      }
    } else {
      _bridge.deleteBackward();
      _trimSentenceBufferOne();
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
      _appendToSentenceBuffer('$candidate ');
      _contextBefore += '$candidate ';
      _composingWord = '';
      _updateSuggestions();
      notifyListeners();
      return;
    }

    // 2. Autocorrect on Space in English typing only (never overwrite Bangla/Indic/Arabic script words)
    if (_langManager.currentLanguage.code.startsWith('en') &&
        _prefs.autoCorrection &&
        _composingWord.isNotEmpty &&
        _candidates.isNotEmpty) {
      final center = _candidates.firstWhere((c) => c.isAutocorrect, orElse: () => _candidates.first);
      if (center.text != _composingWord) {
        // Replace composing word with autocorrected word
        for (int i = 0; i < _composingWord.length; i++) {
          _bridge.deleteBackward();
          _trimSentenceBufferOne();
        }
        _bridge.commitText('${center.text} ');
        _learnCommittedWord(center.text);
        _appendToSentenceBuffer('${center.text} ');
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
      _trimSentenceBufferOne();
      _bridge.commitText('. ');
      _appendToSentenceBuffer('. ');
      _contextBefore = _contextBefore.substring(0, _contextBefore.length - 1) + '. ';
      _lastSpaceTapTime = null;
      _composingWord = '';
      _updateSuggestions();
      notifyListeners();
      return;
    }

    _lastSpaceTapTime = now;
    _bridge.commitText(' ');
    _appendToSentenceBuffer(' ');
    _contextBefore += ' ';
    _composingWord = '';
    _updateSuggestions();
    notifyListeners();
  }

  void _handleEnter() {
    if (_composingWord.isNotEmpty) {
      if (_isAvroActive) {
        final finalized = _candidates.isNotEmpty
            ? _candidates.first.text
            : _banglaPhonetic.parse(_composingWord);
        _bridge.commitText(finalized);
        _learnCommittedWord(finalized);
        _appendToSentenceBuffer(finalized);
      } else {
        _learnCommittedWord(_composingWord);
      }
    }
    _flushSentenceHistory();
    _composingWord = '';
    _candidates.clear();
    _bridge.performEditorAction(_actionId);
    notifyListeners();
  }

  void selectSuggestion(SuggestionCandidate candidate) {
    _hapticSound.onKeyFeedback();

    if (_isAvroActive) {
      _bridge.commitText('${candidate.text} ');
      _appendToSentenceBuffer('${candidate.text} ');
      _contextBefore += '${candidate.text} ';
    } else {
      if (_composingWord.isNotEmpty) {
        for (int i = 0; i < _composingWord.length; i++) {
          _bridge.deleteBackward();
          _trimSentenceBufferOne();
        }
      }
      _bridge.commitText('${candidate.text} ');
      _appendToSentenceBuffer('${candidate.text} ');
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
      isBanglaPhonetic: _isAvroActive,
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
