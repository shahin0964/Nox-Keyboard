import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/ime_platform_bridge.dart';
import '../../../keyboard/widgets/keyboard_view.dart';
import '../../../languages/language_manager.dart';

class KeyboardPreviewScreen extends StatefulWidget {
  const KeyboardPreviewScreen({super.key});

  @override
  State<KeyboardPreviewScreen> createState() => _KeyboardPreviewScreenState();
}

class _KeyboardPreviewScreenState extends State<KeyboardPreviewScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImePlatformBridge _bridge = ImePlatformBridge();
  final LanguageManager _langManager = LanguageManager();
  int _composingLen = 0;

  @override
  void initState() {
    super.initState();
    _bridge.setMockMode(true);

    _bridge.mockComposingCallback = (text) {
      final current = _controller.text;
      final end = current.length;
      final start = (end - _composingLen).clamp(0, end);
      final updated = current.replaceRange(start, end, text);
      _composingLen = text.length;
      _controller.value = TextEditingValue(
        text: updated,
        selection: TextSelection.collapsed(offset: updated.length),
      );
      if (mounted) setState(() {});
    };

    _bridge.mockCommitCallback = (text) {
      final current = _controller.text;
      if (_composingLen > 0) {
        final end = current.length;
        final start = (end - _composingLen).clamp(0, end);
        final newText = current.replaceRange(start, end, text);
        _composingLen = 0;
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      } else {
        final sel = _controller.selection;
        if (sel.isValid && sel.start >= 0 && sel.end >= sel.start) {
          final newText = current.replaceRange(sel.start, sel.end, text);
          _controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: sel.start + text.length),
          );
        } else {
          _controller.text = current + text;
          _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
        }
      }
      if (mounted) setState(() {});
    };

    _bridge.mockDeleteBackwardCallback = () {
      final current = _controller.text;
      if (current.isEmpty) return;
      final sel = _controller.selection;
      if (sel.isValid && sel.start > 0) {
        if (sel.start == sel.end) {
          final newText = current.replaceRange(sel.start - 1, sel.start, '');
          _controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: sel.start - 1),
          );
        } else {
          final newText = current.replaceRange(sel.start, sel.end, '');
          _controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: sel.start),
          );
        }
      } else {
        _controller.text = current.substring(0, current.length - 1);
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
      }
    };

    _bridge.mockActionCallback = (action) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action Triggered! (Enter / Done / Search)'), duration: Duration(seconds: 1)),
      );
    };

    _bridge.mockKeyCommandCallback = (cmd) async {
      final text = _controller.text;
      final sel = _controller.selection;
      final hasSel = sel.isValid && sel.start >= 0 && sel.end > sel.start;
      switch (cmd) {
        case 'selectAll':
          _controller.selection = TextSelection(baseOffset: 0, extentOffset: text.length);
          return text.isNotEmpty;
        case 'copyAll':
          if (text.isEmpty) return false;
          _controller.selection = TextSelection(baseOffset: 0, extentOffset: text.length);
          await Clipboard.setData(ClipboardData(text: text));
          return true;
        case 'copy':
          if (!hasSel) return false;
          await Clipboard.setData(ClipboardData(text: sel.textInside(text)));
          return true;
        case 'cut':
          if (!hasSel) return false;
          await Clipboard.setData(ClipboardData(text: sel.textInside(text)));
          final updated = text.replaceRange(sel.start, sel.end, '');
          _controller.value = TextEditingValue(
            text: updated,
            selection: TextSelection.collapsed(offset: sel.start),
          );
          return true;
        case 'paste':
          final data = await Clipboard.getData(Clipboard.kTextPlain);
          final clip = data?.text ?? '';
          if (clip.isEmpty) return false;
          final start = sel.isValid && sel.start >= 0 ? sel.start : text.length;
          final end = sel.isValid && sel.end >= start ? sel.end : start;
          final updated = text.replaceRange(start, end, clip);
          _controller.value = TextEditingValue(
            text: updated,
            selection: TextSelection.collapsed(offset: start + clip.length),
          );
          return true;
        case 'clearAll':
          _controller.clear();
          return true;
        case 'home':
          _controller.selection = const TextSelection.collapsed(offset: 0);
          return true;
        case 'end':
          _controller.selection = TextSelection.collapsed(offset: text.length);
          return true;
        case 'left':
          final posL = (sel.isValid ? sel.baseOffset - 1 : 0).clamp(0, text.length);
          _controller.selection = TextSelection.collapsed(offset: posL);
          return true;
        case 'right':
          final posR = (sel.isValid ? sel.extentOffset + 1 : text.length).clamp(0, text.length);
          _controller.selection = TextSelection.collapsed(offset: posR);
          return true;
        default:
          return false;
      }
    };
  }

  @override
  void dispose() {
    _bridge.mockKeyCommandCallback = null;
    _bridge.setMockMode(false);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Keyboard Playground', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.trash),
            onPressed: () => _controller.clear(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Playground text area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Language: ${_langManager.currentLanguage.name}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Chars: ${_controller.text.length}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _controller.text.isEmpty
                            ? 'Type on the keyboard below to test...\n\n• For Bangla Phonetic: Type "ami bangla bhalobashi" or "kemon acho"\n• Long-press keys for alternate symbols\n• Drag horizontally on Spacebar to glide cursor\n• Swipe left on Backspace to delete whole words\n• Tap 🌐 to switch language or 🎨 for themes'
                            : _controller.text,
                        style: TextStyle(
                          fontSize: 17,
                          color: _controller.text.isEmpty ? Colors.grey : null,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actual embedded keyboard view
          const NoxKeyboardView(isImeMode: false),
        ],
      ),
    );
  }
}
