import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/screen/register_screen.dart';


class _OnboardingSlideData {
  final String step;
  final String tag;
  final String editorialHighlight;
  final String line2Bold;
  final Alignment orb1Align;
  final Alignment orb2Align;

  const _OnboardingSlideData({
    required this.step,
    required this.tag,
    required this.editorialHighlight,
    required this.line2Bold,
    required this.orb1Align,
    required this.orb2Align,
  });
}

const List<_OnboardingSlideData> _kSlides = [
  _OnboardingSlideData(
    step: '01',
    tag: 'COMPRENSIÓN',
    editorialHighlight: 'Transforma tu forma',
    line2Bold: 'de avanzar.',
    orb1Align: Alignment(-0.55, -0.55),
    orb2Align: Alignment(0.60, 0.55),
  ),
  _OnboardingSlideData(
    step: '02',
    tag: 'TU PROPIO RITMO',
    editorialHighlight: 'Encuentra el ritmo',
    line2Bold: 'ideal para ti.',
    orb1Align: Alignment(0.45, -0.25),
    orb2Align: Alignment(-0.35, 0.40),
  ),
  _OnboardingSlideData(
    step: '03',
    tag: 'PROGRESO REAL',
    editorialHighlight: 'Impulsa tu aprendizaje',
    line2Bold: 'con práctica real.',
    orb1Align: Alignment(-0.40, 0.15),
    orb2Align: Alignment(0.50, -0.35),
  ),
];

/// Helper para evitar el warning de .withOpacity() en versiones nuevas de Flutter
Color _alpha(Color c, double opacity) {
  return c.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  final KadirPaletteMode initialPalette;

  const OnboardingScreen({
    super.key,
    this.onComplete,
    this.onSkip,
    this.initialPalette = KadirPaletteMode.aurora,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }
    void _finishOnboarding() {
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    }
  }

  void _handleNext() {
    if (_currentStep < _kSlides.length - 1) {
      setState(() => _currentStep++);
    } else {
      _finishOnboarding();
    }
  }
  void _handleBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.fromMode(widget.initialPalette);
    final slide = _kSlides[_currentStep];

    return Scaffold(
      backgroundColor: colors.bgMain,
      body: Stack(
        children: [
          // 1. CAPA DE DESENFOQUE DINÁMICO Y PARTÍCULAS SUAVES EN SEGUNDO PLANO
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, _) {
                final t = _ambientController.value * 2 * math.pi;
                final dx1 = math.sin(t) * 0.14;
                final dy1 = math.cos(t) * 0.10;
                final dx2 = math.cos(t) * 0.14;
                final dy2 = math.sin(t) * 0.12;

                return Stack(
                  children: [
                    // Orbe Difuminado Primario (Reacciona al paso + movimiento continuo)
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment(
                        slide.orb1Align.x + dx1,
                        slide.orb1Align.y + dy1,
                      ),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 52, sigmaY: 52),
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _alpha(colors.primary, 0.22),
                                _alpha(colors.primary, 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Orbe Difuminado Secundario (Violeta/Lavanda)
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment(
                        slide.orb2Align.x + dx2,
                        slide.orb2Align.y + dy2,
                      ),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 56, sigmaY: 56),
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _alpha(colors.secondary, 0.20),
                                _alpha(colors.secondary, 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 5 Partículas suaves en suspensión
                    CustomPaint(
                      size: Size.infinite,
                      painter: _SimpleParticlesPainter(
                        progress: _ambientController.value,
                        primary: colors.primary,
                        secondary: colors.secondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 2. CONTENIDO PRINCIPAL CON SAFEAREA
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // CABECERA SUPERIOR LIMPIA (Solo botón Omitir a la derecha)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildSkipButton(colors),
                        ],
                      ),

                      // PANEL CENTRAL EN GLASSMORPHISM CON TRANSICIÓN DE ENFOQUE
                      Expanded(
                        child: Center(
                          child: _buildGlassStageCard(colors, slide),
                        ),
                      ),

                      // PIE DE NAVEGACIÓN: INDICADORES + BOTONES GLASSMORPHISM
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStepIndicators(colors),
                          const SizedBox(height: 16),
                          _buildBottomNavigation(colors),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton(AppColors colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: colors.glassSurface,
          shape: StadiumBorder(
            side: BorderSide(color: colors.glassBorder, width: 1),
          ),
          child: InkWell(
            onTap: () {
        if (widget.onSkip != null) {
          widget.onSkip!();
              } else {
            _finishOnboarding();
               }
                },  
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              child: Text(
                'OMITIR',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: _alpha(colors.textMain, 0.80),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassStageCard(
    AppColors colors,
    _OnboardingSlideData slide,
  ) {
    final stageBg = colors.isDark
        ? _alpha(const Color(0xFF101726), 0.72)
        : _alpha(Colors.white, 0.76);

    final pillBg = colors.isDark
        ? _alpha(const Color(0xFF101726), 0.68)
        : _alpha(Colors.white, 0.78);

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: stageBg,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: colors.glassBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: _alpha(colors.primary, colors.isDark ? 0.22 : 0.10),
                blurRadius: 38,
                offset: const Offset(0, 18),
              ),
            ],
            gradient: RadialGradient(
              center: const Alignment(0.0, -0.3),
              radius: 1.1,
              colors: colors.isDark
                  ? [
                      _alpha(const Color(0xFF132036), 0.55),
                      _alpha(const Color(0xFF101726), 0.75),
                    ]
                  : widget.initialPalette == KadirPaletteMode.prisma
                      ? [
                          _alpha(const Color(0xFFFFEAE2), 0.55),
                          _alpha(Colors.white, 0.78),
                        ]
                      : [
                          _alpha(const Color(0xFFE1F6F5), 0.55),
                          _alpha(Colors.white, 0.78),
                        ],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Aros orbitales suaves en las esquinas internas del cristal
              Positioned(
                top: -50,
                right: -50,
                child: AnimatedBuilder(
                  animation: _ambientController,
                  builder: (context, _) {
                    return Transform.rotate(
                      angle: _ambientController.value * 2 * math.pi,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _alpha(colors.primary, 0.14),
                            width: 3.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Contenido con transición suave al cambiar de paso
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.04),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  key: ValueKey<String>(slide.step),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila Superior: Icono Geométrico + Cabezal con Diamante
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: pillBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colors.glassBorder),
                          ),
                          child: Center(
                            child: CustomPaint(
                              size: const Size(32, 32),
                              painter: _StepIconPainter(
                                stepIndex: _currentStep,
                                primary: colors.primary,
                                secondary: colors.secondary,
                              ),
                            ),
                          ),
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomPaint(
                              size: const Size(11, 11),
                              painter: _FourPointStarPainter(
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 7),
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  colors.textMain,
                                  colors.primary,
                                  colors.secondary,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                slide.tag,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.4,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Frase Principal Directa y Concisa (Mismo estilo que WelcomeScreen)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Parte 1: Cursiva con degradado (secondary -> primary -> accent)
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.secondary,
                              colors.primary,
                              colors.accent,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            slide.editorialHighlight,
                            style: const TextStyle(
                              fontSize: 33,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              height: 1.12,
                              letterSpacing: -0.4,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Subrayado curvo con diamante central
                        SizedBox(
                          width: 175,
                          height: 8,
                          child: CustomPaint(
                            painter: _EditorialUnderlinePainter(
                              primary: colors.primary,
                              accent: colors.accent,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Parte 2: Negrita con degradado (textMain -> primary -> secondary)
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              colors.textMain,
                              colors.primary,
                              colors.secondary,
                            ],
                            stops: const [0.10, 0.65, 1.0],
                          ).createShader(bounds),
                          child: Text(
                            slide.line2Bold,
                            style: const TextStyle(
                              fontSize: 33,
                              fontWeight: FontWeight.w900,
                              height: 1.12,
                              letterSpacing: -1.0,
                              color: Colors.white,
                            ),
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
      ),
    );
  }

  Widget _buildStepIndicators(AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_kSlides.length, (index) {
        final isActive = index == _currentStep;
        return GestureDetector(
          onTap: () => setState(() => _currentStep = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: isActive ? 34 : 9,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: isActive
                  ? LinearGradient(colors: [colors.primary, colors.secondary])
                  : null,
              color: isActive
                  ? null
                  : colors.isDark
                      ? _alpha(Colors.white, 0.20)
                      : _alpha(const Color(0xFF172638), 0.18),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomNavigation(AppColors colors) {
    final pillBg = colors.isDark
        ? _alpha(const Color(0xFF101726), 0.68)
        : _alpha(Colors.white, 0.78);

    return Row(
      children: [
        if (_currentStep > 0) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: SizedBox(
                width: 112,
                height: 54,
                child: OutlinedButton(
                  onPressed: _handleBack,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colors.glassSurface,
                    side: BorderSide(color: colors.glassBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Atrás',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textMain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],

        // Botón Siguiente Paso / Comenzar Ahora en Glassmorphism Lavanda-Cristal
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors.isDark
                        ? [
                            _alpha(const Color(0xFFA88FFF), 0.22),
                            _alpha(const Color(0xFF49E0D3), 0.18),
                          ]
                        : [
                            _alpha(const Color(0xFFF3E8FF), 0.85),
                            _alpha(const Color(0xFFE1F6F5), 0.85),
                            _alpha(const Color(0xFFFCE7F3), 0.85),
                          ],
                  ),
                  border: Border.all(
                    color: colors.isDark
                        ? _alpha(const Color(0xFFA88FFF), 0.45)
                        : _alpha(const Color(0xFF6F56D9), 0.38),
                    width: 1.2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleNext,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _currentStep == _kSlides.length - 1
                                ? 'COMENZAR AHORA'
                                : 'SIGUIENTE PASO',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              color: colors.isDark
                                  ? colors.textMain
                                  : const Color(0xFF3B1D7A),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: pillBg,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(color: colors.glassBorder),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 17,
                              color: colors.isDark
                                  ? colors.primary
                                  : const Color(0xFF4C1D95),
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
      ],
    );
  }
}

// =============================================================================
// CUSTOM PAINTERS (Partículas, Iconos Geométricos, Estrella y Subrayado)
// =============================================================================

class _SimpleParticlesPainter extends CustomPainter {
  final double progress;
  final Color primary;
  final Color secondary;

  _SimpleParticlesPainter({
    required this.progress,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final specs = [
      (0.14, 0.18, 3.2, true, 0.0),
      (0.85, 0.22, 3.6, false, 1.4),
      (0.16, 0.76, 3.4, false, 2.2),
      (0.83, 0.70, 3.8, true, 0.9),
      (0.52, 0.13, 2.8, false, 1.8),
    ];

    for (final s in specs) {
      final phase = (progress * 2 * math.pi) + s.$5;
      final dx = math.sin(phase) * 8;
      final dy = math.cos(phase) * 10;
      final paint = Paint()
        ..color = _alpha(s.$4 ? primary : secondary, 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

      canvas.drawCircle(
        Offset(size.width * s.$1 + dx, size.height * s.$2 + dy),
        s.$3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _StepIconPainter extends CustomPainter {
  final int stepIndex;
  final Color primary;
  final Color secondary;

  _StepIconPainter({
    required this.stepIndex,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokePrimary = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final strokeSecondary = Paint()
      ..color = secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPrimary = Paint()
      ..color = _alpha(primary, 0.15)
      ..style = PaintingStyle.fill;

    if (stepIndex == 0) {
      // Cubo isométrico (Comprensión)
      final hex = Path()
        ..moveTo(w * 0.5, h * 0.12)
        ..lineTo(w * 0.85, h * 0.31)
        ..lineTo(w * 0.85, h * 0.69)
        ..lineTo(w * 0.5, h * 0.88)
        ..lineTo(w * 0.15, h * 0.69)
        ..lineTo(w * 0.15, h * 0.31)
        ..close();
      canvas.drawPath(hex, fillPrimary);
      canvas.drawPath(hex, strokePrimary);
      canvas.drawLine(
        Offset(w * 0.15, h * 0.31),
        Offset(w * 0.5, h * 0.5),
        strokePrimary,
      );
      canvas.drawLine(
        Offset(w * 0.85, h * 0.31),
        Offset(w * 0.5, h * 0.5),
        strokePrimary,
      );
      canvas.drawLine(
        Offset(w * 0.5, h * 0.5),
        Offset(w * 0.5, h * 0.88),
        strokeSecondary,
      );
      canvas.drawCircle(
        Offset(w * 0.5, h * 0.5),
        2.5,
        Paint()..color = primary,
      );
    } else if (stepIndex == 1) {
      // Brújula de ritmo (Tu propio ritmo)
      final center = Offset(w * 0.5, h * 0.5);
      final radius = w * 0.36;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = _alpha(primary, 0.32)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 1.35,
        false,
        strokePrimary..strokeWidth = 2.4,
      );
      canvas.drawLine(center, Offset(w * 0.72, h * 0.28), strokeSecondary);
      canvas.drawCircle(center, 3.0, Paint()..color = primary);
    } else {
      // Capas ascendentes (Progreso real)
      void drawLayer(double cy, Color color, double alpha) {
        final path = Path()
          ..moveTo(w * 0.5, cy - h * 0.15)
          ..lineTo(w * 0.85, cy)
          ..lineTo(w * 0.5, cy + h * 0.15)
          ..lineTo(w * 0.15, cy)
          ..close();
        canvas.drawPath(path, Paint()..color = _alpha(color, alpha));
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
      }

      drawLayer(h * 0.72, secondary, 0.14);
      drawLayer(h * 0.52, primary, 0.16);
      drawLayer(h * 0.32, primary, 0.24);
    }
  }

  @override
  bool shouldRepaint(covariant _StepIconPainter oldDelegate) =>
      oldDelegate.stepIndex != stepIndex;
}

class _FourPointStarPainter extends CustomPainter {
  final Color color;
  _FourPointStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.64, h * 0.36)
      ..lineTo(w, h * 0.5)
      ..lineTo(w * 0.64, h * 0.64)
      ..lineTo(w * 0.5, h)
      ..lineTo(w * 0.36, h * 0.64)
      ..lineTo(0, h * 0.5)
      ..lineTo(w * 0.36, h * 0.36)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EditorialUnderlinePainter extends CustomPainter {
  final Color primary;
  final Color accent;

  _EditorialUnderlinePainter({required this.primary, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final curve = Path()
      ..moveTo(2, h * 0.75)
      ..cubicTo(w * 0.28, h * 0.15, w * 0.72, h * 0.15, w - 2, h * 0.75);

    canvas.drawPath(
      curve,
      Paint()
        ..color = _alpha(primary, 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    final diamond = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.5 + 3.5, h * 0.42)
      ..lineTo(w * 0.5, h * 0.84)
      ..lineTo(w * 0.5 - 3.5, h * 0.42)
      ..close();

    canvas.drawPath(diamond, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}