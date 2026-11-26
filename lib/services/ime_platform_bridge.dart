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
  void Function(int percent, int downloaded, int total)? onOtaProgressCallback;
  void Function(String status, String message)? onOtaCompleteCallback;

  // Mock input callback for in-app preview testing
  void Function(String text)? mockCommitCallback;
  void Function(String text)? mockComposingCallback;
  void Function()? mockDeleteBackwardCallback;
  void Function(int action)? mockActionCallback;
  Future<bool> Function(String command)? mockKeyCommandCallback;

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
        case 'onOtaProgress':
          if (call.arguments is Map) {
            final map = Map<String, dynamic>.from(call.arguments as Map);
            onOtaProgressCallback?.call(
              (map['percent'] as num?)?.toInt() ?? 0,
              (map['downloaded'] as num?)?.toInt() ?? 0,
              (map['total'] as num?)?.toInt() ?? 0,
            );
          }
          break;
        case 'onOtaComplete':
          if (call.arguments is Map) {
            final map = Map<String, dynamic>.from(call.arguments as Map);
            onOtaCompleteCallback?.call(
              map['status'] as String? ?? 'FAILED',
              map['message'] as String? ?? '',
            );
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

  Future<void> setComposingText(String text, {int newCursorPosition = 1}) async {
    if (_isMockMode) {
      mockComposingCallback?.call(text);
      return;
    }
    try {
      await _imeChannel.invokeMethod('setComposingText', {
        'text': text,
        'cursor': newCursorPosition,
      });
    } catch (_) {}
  }

  Future<void> finishComposingText() async {
    if (_isMockMode) {
      mockComposingCallback?.call('');
      return;
    }
    try {
      await _imeChannel.invokeMethod('finishComposingText');
    } catch (_) {}
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

  Future<void> playKeySound([int effect = 0, String style = 'soft', double volume = 0.7]) async {
    try {
      await _imeChannel.invokeMethod('playKeySound', {
        'effect': effect,
        'style': style,
        'volume': volume,
      });
    } catch (_) {
      try {
        await _appChannel.invokeMethod('playKeySound', {
          'effect': effect,
          'style': style,
          'volume': volume,
        });
      } catch (_) {
        SystemSound.play(SystemSoundType.click);
      }
    }
  }

  Future<void> performHaptic([int durationMs = 15]) async {
    try {
      await _imeChannel.invokeMethod('performHaptic', {'duration': durationMs});
    } catch (_) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> triggerKeyFeedback({
    required bool playSound,
    required int effect,
    required String style,
    required double volume,
    required bool vibrate,
    required int durationMs,
  }) async {
    if (!playSound && !vibrate) return;
    if (_isMockMode) {
      if (playSound) playKeySound(effect, style, volume);
      if (vibrate) HapticFeedback.lightImpact();
      return;
    }
    try {
      await _imeChannel.invokeMethod('triggerKeyFeedback', {
        'playSound': playSound,
        'effect': effect,
        'style': style,
        'volume': volume,
        'vibrate': vibrate,
        'duration': durationMs,
      });
    } catch (_) {
      if (playSound) playKeySound(effect, style, volume);
      if (vibrate) HapticFeedback.lightImpact();
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

  Future<bool> executeKeyCommand(String command) async {
    if (_isMockMode) {
      if (mockKeyCommandCallback != null) {
        return await mockKeyCommandCallback!(command);
      }
      return false;
    }
    try {
      final res = await _imeChannel.invokeMethod<bool>('executeKeyCommand', {'command': command});
      return res ?? false;
    } catch (_) {
      return false;
    }
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

  Future<Map<String, dynamic>> getMediaClipboardState() async {
    if (_isMockMode) return {};
    try {
      final res = await _imeChannel.invokeMethod<Map<dynamic, dynamic>>('getMediaClipboardState');
      if (res != null) {
        return Map<String, dynamic>.from(res);
      }
    } catch (_) {}
    return {};
  }

  Future<String> commitImage(String path) async {
    if (_isMockMode) return 'UNSUPPORTED';
    try {
      final res = await _imeChannel.invokeMethod<String>('commitImage', {'path': path});
      return res ?? 'FAILED';
    } catch (_) {
      return 'FAILED';
    }
  }

  Future<void> requestMediaPermissionFromSettings() async {
    try {
      await _imeChannel.invokeMethod('requestMediaPermission');
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

  // OTA App Update methods
  Future<String> getAppVersion() async {
    try {
      final res = await _appChannel.invokeMethod<String>('getAppVersion');
      return res ?? AppConstants.appVersion;
    } catch (_) {
      return AppConstants.appVersion;
    }
  }

  Future<Map<String, dynamic>> checkForUpdate({bool notify = false}) async {
    try {
      final res = await _appChannel.invokeMethod<Map<dynamic, dynamic>>('checkForUpdate', {'notify': notify});
      if (res != null) return Map<String, dynamic>.from(res);
    } catch (_) {}
    return {'success': false, 'error': 'Unable to check', 'hasUpdate': false};
  }

  Future<void> downloadAndInstallUpdate(String url, String tag) async {
    try {
      await _appChannel.invokeMethod('downloadAndInstallUpdate', {'url': url, 'tag': tag});
    } catch (_) {}
  }

  Future<bool> canRequestPackageInstalls() async {
    try {
      return await _appChannel.invokeMethod<bool>('canRequestPackageInstalls') ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> openInstallPermissionSettings() async {
    try {
      await _appChannel.invokeMethod('openInstallPermissionSettings');
    } catch (_) {}
  }

  Future<bool> hasNotificationPermission() async {
    try {
      return await _appChannel.invokeMethod<bool>('hasNotificationPermission') ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> requestNotificationPermission() async {
    try {
      await _appChannel.invokeMethod('requestNotificationPermission');
    } catch (_) {}
  }

  Future<bool> getAutoCheckUpdates() async {
    try {
      return await _appChannel.invokeMethod<bool>('getAutoCheckUpdates') ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> setAutoCheckUpdates(bool enabled) async {
    try {
      await _appChannel.invokeMethod('setAutoCheckUpdates', {'enabled': enabled});
    } catch (_) {}
  }
}
