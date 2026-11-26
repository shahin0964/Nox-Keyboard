import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../engine/keyboard_engine.dart';
import '../../services/ime_platform_bridge.dart';

class KeyboardToolSpec {
  final String id;
  final IconData icon;
  final String label;
  final bool Function(KeyboardEngine engine) isActive;
  final void Function(KeyboardEngine engine, {bool fromGrid}) onTrigger;

  const KeyboardToolSpec({
    required this.id,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTrigger,
  });

  static final Map<String, KeyboardToolSpec> registry = {
    'emoji': KeyboardToolSpec(
      id: 'emoji',
      icon: CupertinoIcons.smiley,
      label: 'Emoji',
      isActive: (e) => e.activePanel == KeyboardPanel.emoji,
      onTrigger: (e, {fromGrid = false}) => e.openPanel(KeyboardPanel.emoji),
    ),
    'clipboard': KeyboardToolSpec(
      id: 'clipboard',
      icon: CupertinoIcons.doc_on_clipboard,
      label: 'Clipboard',
      isActive: (e) => e.activePanel == KeyboardPanel.clipboard,
      onTrigger: (e, {fromGrid = false}) => e.openPanel(KeyboardPanel.clipboard),
    ),
    'keyMode': KeyboardToolSpec(
      id: 'keyMode',
      icon: CupertinoIcons.command,
      label: 'Key',
      isActive: (e) => e.isKeyCommandMode,
      onTrigger: (e, {fromGrid = false}) => e.toggleKeyCommandMode(),
    ),
    'textEditing': KeyboardToolSpec(
      id: 'textEditing',
      icon: CupertinoIcons.arrow_right_arrow_left,
      label: 'Text editing',
      isActive: (e) => e.activePanel == KeyboardPanel.textEditing,
      onTrigger: (e, {fromGrid = false}) => e.openPanel(KeyboardPanel.textEditing),
    ),
    'themes': KeyboardToolSpec(
      id: 'themes',
      icon: Icons.palette_outlined,
      label: 'Themes',
      isActive: (e) => e.activePanel == KeyboardPanel.themes,
      onTrigger: (e, {fromGrid = false}) => e.openPanel(KeyboardPanel.themes),
    ),
    'oneHanded': KeyboardToolSpec(
      id: 'oneHanded',
      icon: CupertinoIcons.hand_draw,
      label: 'One-handed',
      isActive: (e) => e.oneHandedMode != 'none',
      onTrigger: (e, {fromGrid = false}) {
        final next = e.oneHandedMode == 'none'
            ? 'right'
            : (e.oneHandedMode == 'right' ? 'left' : 'none');
        e.setOneHandedMode(next);
        if (fromGrid) e.closePanel();
      },
    ),
    'numbers': KeyboardToolSpec(
      id: 'numbers',
      icon: CupertinoIcons.number,
      label: 'Number row',
      isActive: (e) => e.showNumberRow,
      onTrigger: (e, {fromGrid = false}) {
        e.toggleNumberRow();
        if (fromGrid) e.closePanel();
      },
    ),
    'settings': KeyboardToolSpec(
      id: 'settings',
      icon: CupertinoIcons.settings,
      label: 'Settings',
      isActive: (_) => false,
      onTrigger: (e, {fromGrid = false}) {
        if (fromGrid) e.closePanel();
        ImePlatformBridge().openSettings();
      },
    ),
    'voice': KeyboardToolSpec(
      id: 'voice',
      icon: CupertinoIcons.mic,
      label: 'Voice',
      isActive: (e) => e.activePanel == KeyboardPanel.voice,
      onTrigger: (e, {fromGrid = false}) => e.openPanel(KeyboardPanel.voice),
    ),
  };
}
