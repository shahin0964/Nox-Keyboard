import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Single-pass GPU CustomPainter rendering glowing Spider Web RGB veins
/// or reactive Black Spider Web shockwave ripples on keystrokes.
class SpiderWebPainter extends CustomPainter {
  final bool isRippleMode;
  final double animValue;
  final Offset? rippleOrigin; // Normalized 0..1 coordinates
  final double rippleProgress; // 0..1

  const SpiderWebPainter({
    required this.isRippleMode,
    required this.animValue,
    this.rippleOrigin,
    this.rippleProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.52, size.height * 0.48);
    final maxR = math.sqrt(size.width * size.width + size.height * size.height) * 0.65;

    final Paint basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..strokeCap = StrokeCap.round;

    if (!isRippleMode) {
      // Full cycling RGB rainbow spiderweb (Video 2)
      final hue = (animValue * 360.0) % 360.0;
      basePaint.shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          HSVColor.fromAHSV(0.92, hue, 0.95, 1.0).toColor(),
          HSVColor.fromAHSV(0.92, (hue + 75) % 360, 0.95, 1.0).toColor(),
          HSVColor.fromAHSV(0.92, (hue + 160) % 360, 0.95, 1.0).toColor(),
          HSVColor.fromAHSV(0.92, (hue + 255) % 360, 0.95, 1.0).toColor(),
          HSVColor.fromAHSV(0.92, hue, 0.95, 1.0).toColor(),
        ],
      ).createShader(Offset.zero & size);
      basePaint.strokeWidth = 1.3;
    } else {
      // Stealth dark idle web
      basePaint.color = Colors.white.withOpacity(0.065);
    }

    _drawWebGeometry(canvas, size, center, maxR, basePaint);

    // Reactive key-tap shockwave illuminating web strands outward (Video 3)
    if (isRippleMode && rippleOrigin != null && rippleProgress > 0.0 && rippleProgress < 1.0) {
      final originPx = Offset(rippleOrigin!.dx * size.width, rippleOrigin!.dy * size.height);
      final ringRadius = rippleProgress * maxR * 0.85;
      final fade = (1.0 - rippleProgress).clamp(0.0, 1.0);
      final bandWidth = maxR * 0.22;
      final hue = (rippleOrigin!.dx * 180.0 + rippleOrigin!.dy * 180.0) % 360.0;
      final rippleColor = HSVColor.fromAHSV(1.0, hue, 0.85, 1.0).toColor();

      final innerStop = ((ringRadius - bandWidth) / maxR).clamp(0.0, 1.0);
      final midStop = (ringRadius / maxR).clamp(0.0, 1.0);
      final outerStop = ((ringRadius + bandWidth * 0.6) / maxR).clamp(0.0, 1.0);

      final ripplePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.65
        ..strokeCap = StrokeCap.round
        ..shader = RadialGradient(
          center: Alignment(rippleOrigin!.dx * 2 - 1, rippleOrigin!.dy * 2 - 1),
          radius: 1.3,
          stops: [
            innerStop,
            midStop,
            outerStop,
          ],
          colors: [
            Colors.transparent,
            Color.lerp(Colors.white, rippleColor, 0.55)!.withOpacity(0.95 * fade),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size);

      _drawWebGeometry(canvas, size, center, maxR, ripplePaint);

      // Subtle glowing core spark at the pressed key
      final sparkPaint = Paint()
        ..color = rippleColor.withOpacity(0.28 * fade)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(originPx, 22.0 * (1.0 - rippleProgress * 0.4), sparkPaint);
    }
  }

  void _drawWebGeometry(Canvas canvas, Size size, Offset center, double maxR, Paint paint) {
    const int spokes = 14;
    const int rings = 7;

    // Draw radial spokes
    for (int i = 0; i < spokes; i++) {
      final angle = (i / spokes) * math.pi * 2 + 0.18;
      final end = Offset(
        center.dx + math.cos(angle) * maxR,
        center.dy + math.sin(angle) * maxR,
      );
      canvas.drawLine(center, end, paint);
    }

    // Draw slightly scalloped spiderweb concentric rings
    for (int rIdx = 1; rIdx <= rings; rIdx++) {
      final baseRadius = (rIdx / rings) * maxR * 0.88;
      final path = Path();
      for (int i = 0; i <= spokes; i++) {
        final a1 = (i / spokes) * math.pi * 2 + 0.18;
        final jitter1 = (i % 2 == 0 ? 1.0 : 0.94);
        final p1 = Offset(
          center.dx + math.cos(a1) * baseRadius * jitter1,
          center.dy + math.sin(a1) * baseRadius * jitter1,
        );
        if (i == 0) {
          path.moveTo(p1.dx, p1.dy);
        } else {
          final prevA = ((i - 1) / spokes) * math.pi * 2 + 0.18;
          final midA = (prevA + a1) * 0.5;
          final sag = baseRadius * 0.89;
          final ctrl = Offset(
            center.dx + math.cos(midA) * sag,
            center.dy + math.sin(midA) * sag,
          );
          path.quadraticBezierTo(ctrl.dx, ctrl.dy, p1.dx, p1.dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SpiderWebPainter oldDelegate) {
    if (!isRippleMode) {
      return oldDelegate.animValue != animValue || oldDelegate.isRippleMode != isRippleMode;
    }
    return oldDelegate.rippleProgress != rippleProgress ||
        oldDelegate.rippleOrigin != rippleOrigin ||
        oldDelegate.isRippleMode != isRippleMode;
  }
}
