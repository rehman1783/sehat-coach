import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../onboarding/domain/models/onboarding_state.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  AppLanguage _selectedLanguage = AppLanguage.romanUrdu;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _startOnboarding() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OnboardingScreen(initialLanguage: _selectedLanguage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3), // Off-white warm background
      body: Stack(
        children: [
          // Background organic shapes matching reference design
          Positioned.fill(
            child: CustomPaint(painter: _SplashOrganicBackgroundPainter()),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, viewport) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewport.maxHeight),
                  child: IntrinsicHeight(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28.0,
                            vertical: 20.0,
                          ),
                          child: Column(
                            children: [
                              const Spacer(flex: 3),

                              // Original Logo Icon with Entry Scale Animation
                              ScaleTransition(
                                scale: _scaleAnim,
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                  },
                                  child: Image.asset(
                                    'assets/icon/Layer 1 (2) copy.png',
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              Text(
                                'SEHAT COACH',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.delaGothicOne(
                                  fontSize: 28,
                                  color: const Color(0xFF14532D),
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Subtitle & Language Selector Fade In
                              FadeTransition(
                                opacity: _fadeAnim,
                                child: Column(
                                  children: [
                                    Text(
                                      'Your Desi Life & Health Assistant',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF526070),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    Container(
                                      height: 44,
                                      width: 180,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: const Color(0xFFD7E2DA),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.06,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          AnimatedAlign(
                                            duration: const Duration(
                                              milliseconds: 320,
                                            ),
                                            curve: Curves.easeOutBack,
                                            alignment:
                                                _selectedLanguage ==
                                                    AppLanguage.romanUrdu
                                                ? Alignment.centerLeft
                                                : Alignment.centerRight,
                                            child: FractionallySizedBox(
                                              widthFactor: 0.5,
                                              heightFactor: 1,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFE5F0E8,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFBDD3C4,
                                                    ),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFF14532D,
                                                      ).withValues(alpha: 0.12),
                                                      blurRadius: 7,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _LanguageOptionPill(
                                                  label: 'URDU',
                                                  isSelected:
                                                      _selectedLanguage ==
                                                      AppLanguage.romanUrdu,
                                                  onTap: () {
                                                    HapticFeedback.selectionClick();
                                                    setState(
                                                      () => _selectedLanguage =
                                                          AppLanguage.romanUrdu,
                                                    );
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                child: _LanguageOptionPill(
                                                  label: 'ENGLISH',
                                                  isSelected:
                                                      _selectedLanguage ==
                                                      AppLanguage.english,
                                                  onTap: () {
                                                    HapticFeedback.selectionClick();
                                                    setState(
                                                      () => _selectedLanguage =
                                                          AppLanguage.english,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Spacer(flex: 4),

                              // Bottom Action Button & Footer Text
                              FadeTransition(
                                opacity: _fadeAnim,
                                child: Column(
                                  children: [
                                    // Start Onboarding CTA
                                    SizedBox(
                                      width: double.infinity,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minHeight: 56,
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _startOnboarding,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF14532D,
                                            ),
                                            foregroundColor: Colors.white,
                                            elevation: 6,
                                            shadowColor: const Color(0xFF14532D)
                                                .withValues(alpha: 0.35),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'CONTINUE',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 1.0,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.arrow_forward,
                                                  color: Color(0xFFEAA918),
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Footer Tagline (Hybrid Health)
                                    const Text(
                                      'POWERED BY AI • BUILT FOR PAKISTAN',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF475569),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label language',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            scale: isSelected ? 1.04 : 0.96,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF14532D)
                    : const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashOrganicBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Top-Left Yellow Organic Blob
    final Paint yellowBlobPaint = Paint()
      ..color = const Color(0xFFF6ECD7)
      ..style = PaintingStyle.fill;

    final Path yellowBlobPath = Path();
    yellowBlobPath.moveTo(0, 0);
    yellowBlobPath.lineTo(w * 0.28, 0);
    yellowBlobPath.cubicTo(w * 0.28, h * 0.12, w * 0.16, h * 0.18, 0, h * 0.16);
    yellowBlobPath.close();
    canvas.drawPath(yellowBlobPath, yellowBlobPaint);

    // 2. Large Translucent Sage Green Leaf Contour (Top-Left Background)
    final Paint leafBgPaint = Paint()
      ..color = const Color(0xFFE2EBE0)
      ..style = PaintingStyle.fill;

    final Path leafBgPath = Path();
    leafBgPath.moveTo(0, h * 0.08);
    leafBgPath.cubicTo(w * 0.55, h * 0.05, w * 0.65, h * 0.35, 0, h * 0.45);
    leafBgPath.close();
    canvas.drawPath(leafBgPath, leafBgPaint);

    // 3. Bottom-Right Cream/Yellow Rounded Block Structure
    final Paint bottomStructPaint = Paint()
      ..color = const Color(0xFFF5EBD4)
      ..style = PaintingStyle.fill;

    final Path bottomPath = Path();
    final double brTop = h * 0.52;
    bottomPath.moveTo(w, brTop);
    bottomPath.cubicTo(w * 0.45, brTop, w * 0.42, brTop + 60, w * 0.40, h);
    bottomPath.lineTo(w, h);
    bottomPath.close();
    canvas.drawPath(bottomPath, bottomStructPaint);

    // Inner White Cutout Circle/Oval in Bottom-Right structure
    final Paint whiteCutoutPaint = Paint()
      ..color = const Color(0xFFFAF8F3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.72, h * 0.62), w * 0.14, whiteCutoutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
