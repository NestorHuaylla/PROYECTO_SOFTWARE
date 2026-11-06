import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/kadir_logo.dart';
import '../../../onboarding/presentation/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  final KadirPaletteMode initialMode;

  const SplashScreen({
    super.key,
    this.initialMode = KadirPaletteMode.aurora,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ambientController;
  late final AnimationController _loadController;

  @override
  void initState() {
    super.initState();

    // Controlador para las formas que giran y flotan detrás del cristal
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // Controlador para la barra de carga automática (1.8 segundos) y entrada
    _loadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _loadController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, animation, __) => FadeTransition(
              opacity: animation,
              child: const WelcomeScreen(),
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = KadirPaletteColors.fromMode(widget.initialMode);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colors.bgMain,
      body: AnimatedBuilder(
        animation: Listenable.merge([_ambientController, _loadController]),
        builder: (context, _) {
          final t = _ambientController.value * 2 * math.pi;
          final progress = Curves.easeOutCubic.transform(_loadController.value);

          return Stack(
            alignment: Alignment.center,
            children: [
              // ===============================================================
              // CAPA 0: FORMAS ANIMADAS DETRÁS DEL CRISTAL SEGÚN EL ESTILO
              // ===============================================================
              // Orbe 1 en trayectoria Lissajous
              Positioned(
                top: size.height * 0.16 + math.sin(t) * 28,
                left: size.width * 0.15 + math.cos(t) * 34,
                child: _BlurOrb(color: colors.primary, diameter: 260),
              ),
              // Orbe 2 en contrafase
              Positioned(
                bottom: size.height * 0.16 + math.cos(t) * 30,
                right: size.width * 0.15 + math.sin(t) * 32,
                child: _BlurOrb(color: colors.secondary, diameter: 240),
              ),

              // Anillo Giroscópico / Haz Prismático según la paleta
              if (widget.initialMode == KadirPaletteMode.prisma)
                Transform.rotate(
                  angle: -0.52 + math.sin(t) * 0.08,
                  child: Transform.translate(
                    offset: Offset(math.sin(t) * 35, math.cos(t) * 20),
                    child: Container(
                      width: 420,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        gradient: LinearGradient(
                          colors: [
                            colors.primary.withValues(alpha: 0.35),
                            colors.secondary.withValues(alpha: 0.35),
                            colors.accent.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                Transform.rotate(
                  angle: t,
                  child: Container(
                    width: 340,
                    height: widget.initialMode == KadirPaletteMode.orbita
                        ? 190
                        : 340,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(220),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.38),
                        width: widget.initialMode == KadirPaletteMode.orbita
                            ? 4.5
                            : 10,
                      ),
                    ),
                  ),
                ),

              // ===============================================================
              // CAPA 1: CRISTALES SATÉLITE EN LEVITACIÓN
              // ===============================================================
              Positioned(
                top: size.height * 0.25 + math.sin(t * 2) * 10,
                left: size.width * 0.10,
                child: Transform.rotate(
                  angle: -0.2,
                  child: _GlassShard(size: 76, colors: colors),
                ),
              ),
              Positioned(
                bottom: size.height * 0.25 - math.sin(t * 2) * 10,
                right: size.width * 0.10,
                child: Transform.rotate(
                  angle: 0.24,
                  child: _GlassShard(size: 84, colors: colors),
                ),
              ),

              // ===============================================================
              // CAPA 2: CUADRO FLOTANTE DE CRISTAL (LOGO + KADIR + BARRA)
              // ===============================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 320),
                      padding: const EdgeInsets.symmetric(
                        vertical: 46,
                        horizontal: 36,
                      ),
                      decoration: BoxDecoration(
                        color: colors.glassSurface,
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: colors.glassSpecularBorder,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.isDark
                                ? Colors.black.withValues(alpha: 0.72)
                                : colors.primary.withValues(alpha: 0.14),
                            blurRadius: 48,
                            offset: const Offset(0, 24),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Isotipo K Isométrica 3D
                          KadirLogo(colors: colors, size: 102),
                          const SizedBox(height: 24),

                          // 2. Wordmark KADIR minimalista con punto de luz en la I
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'KAD',
                                style: TextStyle(
                                  color: colors.textMain,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 9,
                                ),
                              ),
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.topCenter,
                                children: [
                                  Text(
                                    'I',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 9,
                                    ),
                                  ),
                                  Positioned(
                                    top: -5,
                                    right: 4.5,
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: colors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'R',
                                style: TextStyle(
                                  color: colors.textMain,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 9,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // 3. Línea minimalista de carga automática
                          Container(
                            width: 112,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colors.isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progress.clamp(0.05, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    colors: [
                                      colors.primary,
                                      colors.secondary,
                                      colors.accent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final Color color;
  final double diameter;

  const _BlurOrb({required this.color, required this.diameter});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.38),
        ),
      ),
    );
  }
}

class _GlassShard extends StatelessWidget {
  final double size;
  final KadirPaletteColors colors;

  const _GlassShard({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.glassShardSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.glassSpecularBorder,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}