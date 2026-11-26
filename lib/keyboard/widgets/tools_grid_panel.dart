import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../themes/theme_model.dart';
import '../../services/ime_platform_bridge.dart';
import '../engine/keyboard_engine.dart';
import 'toolbar_tools.dart';

class ToolsGridPanel extends StatefulWidget {
  final NoxKeyboardTheme theme;
  final KeyboardEngine engine;

  const ToolsGridPanel({
    super.key,
    required this.theme,
    required this.engine,
  });

  @override
  State<ToolsGridPanel> createState() => _ToolsGridPanelState();
}

class _ToolsGridPanelState extends State<ToolsGridPanel> {
  bool _isEditOrderMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final engine = widget.engine;
    final orderedIds = engine.toolbarOrder
        .where((id) => KeyboardToolSpec.registry.containsKey(id))
        .toList();

    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        children: [
          // Header with Close, Reorder toggle, and hint
          Row(
            children: [
              InkWell(
                onTap: () => engine.closePanel(),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(theme.isDark ? 0.08 : 0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.clear, size: 13, color: theme.textColor),
                      const SizedBox(width: 4),
                      Text(
                        'Close',
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => setState(() => _isEditOrderMode = !_isEditOrderMode),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isEditOrderMode
                        ? theme.accentColor.withOpacity(0.25)
                        : Colors.white.withOpacity(theme.isDark ? 0.08 : 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: _isEditOrderMode
                        ? Border.all(color: theme.accentColor.withOpacity(0.8), width: 1)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isEditOrderMode ? CupertinoIcons.checkmark_alt : CupertinoIcons.arrow_up_arrow_down,
                        size: 13,
                        color: _isEditOrderMode ? theme.accentColor : theme.textColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isEditOrderMode ? 'Done' : 'Move / Order',
                        style: TextStyle(
                          color: _isEditOrderMode ? theme.accentColor : theme.textColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _isEditOrderMode ? 'Drag or tap ← first' : 'Hold & drag to move',
                style: TextStyle(
                  color: theme.secondaryTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 4-column Drag-and-Drop / Reorderable Grid of tools
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.25,
              ),
              itemCount: orderedIds.length,
              itemBuilder: (context, index) {
                final id = orderedIds[index];
                final spec = KeyboardToolSpec.registry[id]!;
                final isActive = spec.isActive(engine);

                return DragTarget<int>(
                  onWillAcceptWithDetails: (details) => details.data != index,
                  onAcceptWithDetails: (details) {
                    ImePlatformBridge().performHaptic(15);
                    engine.moveToolbarTool(details.data, index);
                  },
                  builder: (ctx, candidateData, rejectedData) {
                    final isHovered = candidateData.isNotEmpty;
                    final tile = _buildTileContent(spec, index, isActive, isHovered);

                    final feedback = Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: 82,
                        height: 66,
                        child: _buildTileContent(spec, index, true, true),
                      ),
                    );

                    final childWhenDragging = Opacity(
                      opacity: 0.35,
                      child: tile,
                    );

                    if (_isEditOrderMode) {
                      return Draggable<int>(
                        data: index,
                        feedback: feedback,
                        childWhenDragging: childWhenDragging,
                        child: tile,
                      );
                    }

                    return LongPressDraggable<int>(
                      data: index,
                      delay: const Duration(milliseconds: 220),
                      onDragStarted: () => ImePlatformBridge().performHaptic(15),
                      feedback: feedback,
                      childWhenDragging: childWhenDragging,
                      child: tile,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileContent(KeyboardToolSpec spec, int index, bool isActive, bool isHighlighted) {
    final theme = widget.theme;
    final engine = widget.engine;

    return InkWell(
      onTap: () {
        if (_isEditOrderMode) {
          // In Move / Order mode, tapping moves tool to front (toolbar slot #1)
          ImePlatformBridge().performHaptic(15);
          engine.moveToolbarTool(index, 0);
        } else {
          spec.onTrigger(engine, fromGrid: true);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isHighlighted
              ? theme.accentColor.withOpacity(0.32)
              : (isActive
                  ? theme.accentColor.withOpacity(0.24)
                  : Colors.white.withOpacity(theme.isDark ? 0.05 : 0.22)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isHighlighted || isActive || _isEditOrderMode)
                ? theme.accentColor.withOpacity(isHighlighted ? 0.95 : (isActive ? 0.7 : 0.35))
                : Colors.white.withOpacity(theme.isDark ? 0.08 : 0.18),
            width: isHighlighted ? 1.6 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    spec.icon,
                    size: 21,
                    color: (isActive || isHighlighted) ? theme.accentColor : theme.textColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spec.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: (isActive || isHighlighted) ? theme.accentColor : theme.secondaryTextColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_isEditOrderMode)
              Positioned(
                top: 3,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
