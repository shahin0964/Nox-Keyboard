import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  }

  @override
  void dispose() {
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
