import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../data/preferences_helper.dart';
import '../../../themes/theme_manager.dart';
import '../../../languages/language_manager.dart';
import '../../../keyboard/suggestions/dictionary_service.dart';
import '../../../services/ime_platform_bridge.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final String? pendingRoute;

  const SplashScreen({super.key, this.pendingRoute});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _spinnerController;
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  String _statusText = 'Initializing...';
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();

    _initializeAndNavigate();
  }

  @override
  void dispose() {
    _spinnerController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndNavigate() async {
    final startMs = DateTime.now().millisecondsSinceEpoch;
    final bridge = ImePlatformBridge();
    String? extraRoute = widget.pendingRoute;

    try {
      await PreferencesHelper().reload();
      await ThemeManager().init();
      await LanguageManager().init();
      if (mounted) {
        setState(() => _statusText = 'Loading dictionaries...');
      }
      await DictionaryService().ensureLoaded(
        LanguageManager().currentLanguage.code,
      );
      if (extraRoute == null || extraRoute.isEmpty) {
        extraRoute = await bridge.getInitialRouteExtra();
      }
      if (mounted) {
        setState(() => _statusText = 'Ready');
      }
    } catch (_) {}

    final elapsed = DateTime.now().millisecondsSinceEpoch - startMs;
    const minDisplayMs = 1550;
    if (elapsed < minDisplayMs) {
      await Future.delayed(Duration(milliseconds: minDisplayMs - elapsed));
    }

    if (!mounted || _navigated) return;
    _navigated = true;

    final nextScreen = PreferencesHelper().onboardingCompleted
        ? const DashboardScreen()
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );

    if (extraRoute != null && extraRoute.isNotEmpty) {
      final target = extraRoute;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushNamed(target);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03081C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Matching cosmic blue/purple waves & perspective faint dark keybed backdrop
          const CustomPaint(
            painter: _SplashBackdropPainter(),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Center glowing emblem + Nox Keyboard branding
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 176,
                          height: 176,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(38),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D2FF).withValues(alpha: 0.28),
                                blurRadius: 42,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: const Color(0xFFA855F7).withValues(alpha: 0.22),
                                blurRadius: 56,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(36),
                            child: Image.asset(
                              'assets/icons/nox_logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.keyboard_rounded,
                                size: 92,
                                color: Color(0xFF00E5FF),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Type Smarter, Live Better',
                          style: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Exact Cyan-to-Magenta Gradient Ring Loader + Status
                RotationTransition(
                  turns: _spinnerController,
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: CustomPaint(
                      painter: _GradientSpinnerPainter(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    _statusText,
                    key: ValueKey<String>(_statusText),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientSpinnerPainter extends CustomPainter {
  const _GradientSpinnerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 3.5;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Subtle dark track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawOval(rect, trackPaint);

    // Glowing cyan -> indigo -> magenta sweep arc
    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: [
          Color(0x0000E5FF),
          Color(0xFF00E5FF),
          Color(0xFF6366F1),
          Color(0xFFEC4899),
        ],
        stops: [0.0, 0.35, 0.72, 1.0],
      ).createShader(rect);

    canvas.drawArc(rect, 0.25, math.pi * 1.65, false, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SplashBackdropPainter extends CustomPainter {
  const _SplashBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Deep cosmic background gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF02071A),
          Color(0xFF050F2E),
          Color(0xFF090728),
          Color(0xFF030616),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Top-left glowing electric blue wave
    final topWave = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.65, 0)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.14,
        0,
        size.height * 0.32,
      )
      ..close();
    canvas.drawPath(
      topWave,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0088FF).withValues(alpha: 0.42),
            const Color(0xFF00E5FF).withValues(alpha: 0.06),
          ],
        ).createShader(Offset.zero & size),
    );

    // Bottom-right vibrant purple/magenta wave
    final bottomWave = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width * 0.2, size.height)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.87,
        size.width,
        size.height * 0.72,
      )
      ..close();
    canvas.drawPath(
      bottomWave,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            const Color(0xFFD946EF).withValues(alpha: 0.36),
            const Color(0xFF4F46E5).withValues(alpha: 0.05),
          ],
        ).createShader(Offset.zero & size),
    );

    // Subtle perspective keyboard key silhouettes at the bottom (matches mockup)
    const rows = [
      ['Q', 'W', 'E', 'R', 'T'],
      ['A', 'S', 'D', 'F', 'G'],
      ['Z', 'X', 'C', 'V', 'B'],
    ];
    final keyFill = Paint()..color = const Color(0xFF0A1438).withValues(alpha: 0.55);
    final keyStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.14);

    canvas.save();
    canvas.translate(size.width * 0.04, size.height * 0.77);
    canvas.rotate(-0.22);
    for (int r = 0; r < rows.length; r++) {
      for (int c = 0; c < rows[r].length; c++) {
        final kx = c * (size.width * 0.21) + r * 26.0;
        final ky = r * 54.0;
        final kRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(kx, ky, size.width * 0.17, 42),
          const Radius.circular(9),
        );
        canvas.drawRRect(kRect, keyFill);
        canvas.drawRRect(kRect, keyStroke);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
