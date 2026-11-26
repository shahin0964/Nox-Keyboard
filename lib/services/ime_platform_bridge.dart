import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';

typedef InputChangeCallback = void Function(Map<String, dynamic> data);

class ImePlatformBridge {
  static final ImePlatformBridge _instance = ImePlatformBridge._internal();
  factory ImePlatformBridge() => _instance;
  ImePlatformBridge._internal() {
    _initChannel();
  }

  final MethodChannel _imeChannel = const MethodChannel(AppConstants.imeChannel);
  final MethodChannel _appChannel = const MethodChannel(AppConstants.appChannel);

  InputChangeCallback? onStartInputCallback;
  VoidCallback? onFinishInputCallback;
  void Function(String text, bool isFinal)? onVoiceResultCallback;
  void Function(String error)? onVoiceErrorCallback;
  void Function(String state)? onVoiceStateCallback;
  void Function(String route)? onNavigateRouteCallback;

  // Mock input callback for in-app preview testing
  void Function(String text)? mockCommitCallback;
  void Function()? mockDeleteBackwardCallback;
  void Function(int action)? mockActionCallback;

  bool _isMockMode = false;
  bool get isMockMode => _isMockMode;
  void setMockMode(bool enabled) {
    _isMockMode = enabled;
  }

  double _navBarHeightDp = 36.0;
  double get navBarHeightDp => _navBarHeightDp;

  void _initChannel() {
    _imeChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onStartInput':
          if (call.arguments is Map) {
            final map = Map<String, dynamic>.from(call.arguments as Map);
            if (map.containsKey('navBarHeightDp')) {
              final nav = (map['navBarHeightDp'] as num?)?.toDouble();
              if (nav != null && nav > 0) {
                _navBarHeightDp = nav;
              }
            }
            onStartInputCallback?.call(map);
          }
          break;
        case 'onFinishInput':
          onFinishInputCallback?.call();
          break;
        case 'onVoiceResult':
          if (call.arguments is Map) {
            final map = Map<String, dynamic>.from(call.arguments as Map);
            onVoiceResultCallback?.call(
              map['text'] as String? ?? '',
              map['isFinal'] as bool? ?? false,
            );
          }
          break;
        case 'onVoiceError':
          onVoiceErrorCallback?.call(call.arguments as String? ?? 'ERROR');
          break;
        case 'onVoiceState':
          onVoiceStateCallback?.call(call.arguments as String? ?? 'idle');
          break;
      }
    });

    _appChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onNavigateRoute':
          final route = call.arguments as String?;
          if (route != null && route.isNotEmpty) {
            onNavigateRouteCallback?.call(route);
          }
          break;
      }
    });
  }

  Future<void> updateKeyboardDimensions({
    required double contentHeight,
    double? navBarHeight,
  }) async {
    if (_isMockMode) return;
    try {
      await _imeChannel.invokeMethod('updateKeyboardDimensions', {
        'contentHeight': contentHeight,
        if (navBarHeight != null) 'navBarHeight': navBarHeight,
      });
    } catch (_) {}
  }

  Future<void> updateKeyboardHeight(double height) async {
    if (_isMockMode) return;
    try {
      await _imeChannel.invokeMethod('updateKeyboardHeight', {'height': height});
    } catch (_) {}
  }

  Future<void> commitText(String text) async {
    if (_isMockMode) {
      mockCommitCallback?.call(text);
      return;
    }
    try {
      await _imeChannel.invokeMethod('commitText', {'text': text});
    } catch (_) {
      mockCommitCallback?.call(text);
    }
  }

  Future<void> deleteBackward() async {
    if (_isMockMode) {
      mockDeleteBackwardCallback?.call();
      return;
    }
    try {
      await _imeChannel.invokeMethod('deleteBackward');
    } catch (_) {
      mockDeleteBackwardCallback?.call();
    }
  }

  Future<void> deleteForward() async {
    if (_isMockMode) return;
    try {
      await _imeChannel.invokeMethod('deleteForward');
    } catch (_) {}
  }

  Future<void> deleteWordBackward() async {
    if (_isMockMode) {
      mockDeleteBackwardCallback?.call();
      return;
    }
    try {
      await _imeChannel.invokeMethod('deleteWordBackward');
    } catch (_) {
      mockDeleteBackwardCallback?.call();
    }
  }

  Future<void> performEditorAction(int action) async {
    if (_isMockMode) {
      mockActionCallback?.call(action);
      return;
    }
    try {
      await _imeChannel.invokeMethod('performEditorAction', {'action': action});
    } catch (_) {
      mockActionCallback?.call(action);
    }
  }

  Future<void> sendKeyEvent(int keyCode) async {
    if (_isMockMode) return;
    try {
      await _imeChannel.invokeMethod('sendKeyEvent', {'keyCode': keyCode});
    } catch (_) {}
  }

  Future<void> moveCursor(int delta) async {
    if (_isMockMode) return;
    try {
      await _imeChannel.invokeMethod('moveCursor', {'delta': delta});
    } catch (_) {}
  }

  Future<void> setSelection(int start, int end) async {
    if (_isMockMode) return;
    try {
      await _imeChannel.invokeMethod('setSelection', {'start': start, 'end': end});
    } catch (_) {}
  }

  Future<void> hideKeyboard() async {
    if (_isMockMode) return;
    try {
      await _imeChannel.invokeMethod('hideKeyboard');
    } catch (_) {}
  }

  Future<bool> switchToNextIme() async {
    if (_isMockMode) return false;
    try {
      final res = await _imeChannel.invokeMethod<bool>('switchToNextIme');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openSettings() async {
    try {
      await _imeChannel.invokeMethod('openSettings');
    } catch (_) {}
  }

  Future<String> getClipboardText() async {
    try {
      final text = await _imeChannel.invokeMethod<String>('getClipboardText');
      return text ?? '';
    } catch (_) {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text ?? '';
    }
  }

  Future<void> setClipboardText(String text) async {
    try {
      await _imeChannel.invokeMethod('setClipboardText', {'text': text});
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
    }
  }

  Future<void> playKeySound([int effect = 0]) async {
    try {
      await _imeChannel.invokeMethod('playKeySound', {'effect': effect});
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> performHaptic([int durationMs = 15]) async {
    try {
      await _imeChannel.invokeMethod('performHaptic', {'duration': durationMs});
    } catch (_) {
      HapticFeedback.lightImpact();
    }
  }

  Future<String> getTextBeforeCursor([int length = 100]) async {
    if (_isMockMode) return '';
    try {
      final res = await _imeChannel.invokeMethod<String>('getTextBeforeCursor', {'length': length});
      return res ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<String> getTextAfterCursor([int length = 100]) async {
    if (_isMockMode) return '';
    try {
      final res = await _imeChannel.invokeMethod<String>('getTextAfterCursor', {'length': length});
      return res ?? '';
    } catch (_) {
      return '';
    }
  }

  // App-level channel methods
  Future<bool> isKeyboardEnabled() async {
    try {
      final res = await _appChannel.invokeMethod<bool>('isKeyboardEnabled');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isKeyboardDefault() async {
    try {
      final res = await _appChannel.invokeMethod<bool>('isKeyboardDefault');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openInputMethodSettings() async {
    try {
      await _appChannel.invokeMethod('openInputMethodSettings');
    } catch (_) {}
  }

  Future<void> performContextMenuAction(int actionId) async {
    if (_isMockMode) return;
    try {
      await _imeChannel.invokeMethod('performContextMenuAction', {'actionId': actionId});
    } catch (_) {}
  }

  Future<bool> startVoiceRecognition(String languageCode) async {
    if (_isMockMode) return false;
    try {
      final res = await _imeChannel.invokeMethod<bool>('startVoiceRecognition', {'languageCode': languageCode});
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopVoiceRecognition() async {
    if (_isMockMode) return;
    try {
      await _imeChannel.invokeMethod('stopVoiceRecognition');
    } catch (_) {}
  }

  Future<void> requestAudioPermissionFromSettings() async {
    try {
      await _imeChannel.invokeMethod('requestAudioPermission');
    } catch (_) {}
  }

  Future<String?> getInitialRouteExtra() async {
    try {
      return await _appChannel.invokeMethod<String>('getInitialRouteExtra');
    } catch (_) {
      return null;
    }
  }

  Future<void> showInputMethodPicker() async {
    try {
      await _appChannel.invokeMethod('showInputMethodPicker');
    } catch (_) {}
  }
}
