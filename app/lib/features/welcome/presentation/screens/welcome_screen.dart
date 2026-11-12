import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/screen/login_screen.dart';
import '../../../auth/presentation/screen/register_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../../../settings/presentation/screens/theme_customization_screen.dart';
/// Función auxiliar compatible con todas las versiones de Flutter sin warnings de linter
Color _alpha(Color color, double opacity) {
  return color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

class _SatelliteNode {
  final String id;
  final String label;
  final double xFactor;
  final double yFactor;

  const _SatelliteNode({
    required this.id,
    required this.label,
    required this.xFactor,
    required this.yFactor,
  });
}

const List<_SatelliteNode> _kSatelliteNodes = [
  _SatelliteNode(id: 'capacidad', label: 'CAPACIDAD', xFactor: 0.18, yFactor: 0.23),
  _SatelliteNode(id: 'modo', label: 'MODO', xFactor: 0.82, yFactor: 0.22),
  _SatelliteNode(id: 'ritmo', label: 'RITMO', xFactor: 0.19, yFactor: 0.78),
  _SatelliteNode(id: 'estrategia', label: 'ESTRATEGIA', xFactor: 0.81, yFactor: 0.77),
];

class WelcomeScreen extends StatefulWidget {
  final VoidCallback? onStart;
  final VoidCallback? onLogin;
  final KadirPaletteMode initialPalette;

  const WelcomeScreen({
    super.key,
    this.onStart,
    this.onLogin,
    this.initialPalette = KadirPaletteMode.aurora,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late KadirPaletteMode _mode;
  String _activeNode = 'capacidad';

  late final AnimationController _ambientController;
  late final AnimationController _logoWaveController;
  late final AnimationController _particlesController;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialPalette;

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _logoWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _logoWaveController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  AppColors get _colors => AppColors.palettes[_mode]!;

    void _handleStart() {
    if (widget.onStart != null) {
      widget.onStart!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    }
  }

  void _handleLogin() {
    if (widget.onLogin != null) {
      widget.onLogin!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _cycleTheme() {
    setState(() {
      final values = KadirPaletteMode.values;
      _mode = values[(_mode.index + 1) % values.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors;

    return Scaffold(
      backgroundColor: c.bgMain,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        color: c.bgMain,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _ambientController,
              builder: (context, _) {
                final t = _ambientController.value * 2 * math.pi;
                return Stack(
                  children: [
                    Positioned(
                      top: -60 + math.sin(t) * 20,
                      right: -50 + math.cos(t) * 20,
                      child: _AmbientBlurOrb(
                        color: _alpha(c.primary, 0.18),
                        size: 320,
                      ),
                    ),
                    Positioned(
                      bottom: -50 + math.cos(t) * 22,
                      left: -50 + math.sin(t) * 18,
                      child: _AmbientBlurOrb(
                        color: _alpha(c.secondary, 0.15),
                        size: 290,
                      ),
                    ),
                  ],
                );
              },
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: 14.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTopHeader(c),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeroStage(c),
                              const SizedBox(height: 24),
                              _buildInnovativeTypographyBlock(c),
                              const SizedBox(height: 26),
                              _PastelQuartzPrimaryButton(
                                label: 'EMPEZAR AHORA',
                                animation: _particlesController,
                                onTap: _handleStart,
                              ),
                              const SizedBox(height: 14),
                              _PastelQuartzSecondaryButton(
                                label: 'Ya tengo una cuenta',
                                isDark: c.isDark,
                                animation: _particlesController,
                                onTap: _handleLogin,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _cycleTheme,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Personalizar atmósfera visual · Aurora / Órbita / Prisma',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                color: _alpha(c.textMuted, 0.78),
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
        ),
      ),
    );
  }

  Widget _buildTopHeader(AppColors c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: AnimatedBuilder(
                animation: _logoWaveController,
                builder: (context, _) => CustomPaint(
                  painter: _KadirIsometricLogoPainter(
                    colors: c,
                    mode: _mode,
                    progress: _logoWaveController.value,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 110,
              height: 17,
              child: CustomPaint(
                painter: _KadirWordmarkPainter(colors: c),
              ),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: c.glassSurface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: c.glassBorder, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: KadirPaletteMode.values.map((p) {
                  final isSelected = _mode == p;
                  final pColors = AppColors.palettes[p]!;
                  return GestureDetector(
                    onTap: () => setState(() => _mode = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? c.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        pColors.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? c.primaryText
                              : _alpha(c.textMain, 0.7),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroStage(AppColors c) {
    final gradientColors = _mode == KadirPaletteMode.orbita
        ? [const Color(0xFF132036), const Color(0xFF060913)]
        : _mode == KadirPaletteMode.prisma
            ? [const Color(0xFFFFEAE2), const Color(0xFFFFFFFF)]
            : [const Color(0xFFE1F6F5), const Color(0xFFFFFFFF)];

    return Container(
      height: 236,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: c.glassBorder, width: 1.2),
        gradient: RadialGradient(
          colors: gradientColors,
          radius: 0.85,
        ),
        boxShadow: [
          BoxShadow(
            color: c.isDark
                ? _alpha(Colors.black, 0.45)
                : _alpha(c.primary, 0.08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _ambientController,
                  builder: (context, _) => CustomPaint(
                    size: Size(w, h),
                    painter: _HeroNetworkStagePainter(
                      colors: c,
                      activeNodeId: _activeNode,
                      rotation: _ambientController.value * 2 * math.pi,
                    ),
                  ),
                ),
                ..._kSatelliteNodes.map((node) {
                  final isSelected = _activeNode == node.id;
                  return Positioned(
                    left: w * node.xFactor - 52,
                    top: h * node.yFactor - 14,
                    child: GestureDetector(
                      onTap: () => setState(() => _activeNode = node.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? c.primary
                              : (c.isDark
                                  ? const Color(0xAD101726)
                                  : const Color(0xCCFFFFFF)),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected ? c.primary : c.glassBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isSelected ? '✦ ' : '◇ ',
                              style: TextStyle(
                                fontSize: 8.5,
                                color: isSelected ? c.primaryText : c.textMain,
                              ),
                            ),
                            Text(
                              node.label,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9.2,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                                color: isSelected ? c.primaryText : c.textMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: c.isDark
                            ? const Color(0xA80A101E)
                            : const Color(0xB0FFFFFF),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: c.glassBorder, width: 1.5),
                      ),
                      child: SizedBox(
                        width: 76,
                        height: 76,
                        child: AnimatedBuilder(
                          animation: _logoWaveController,
                          builder: (context, _) => CustomPaint(
                            painter: _KadirIsometricLogoPainter(
                              colors: c,
                              mode: _mode,
                              progress: _logoWaveController.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInnovativeTypographyBlock(AppColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 13, color: c.primary),
            const SizedBox(width: 6),
            Container(
              width: 24,
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c.primary, Colors.transparent],
                ),
              ),
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [c.textMain, c.primary, c.secondary],
              ).createShader(bounds),
              child: const Text(
                'WELCOME',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 5.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '¿Listo para ',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  height: 1.1,
                  letterSpacing: -0.7,
                  color: _alpha(c.textMain, 0.92),
                ),
              ),
              TextSpan(
                text: 'cambiar',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -1.2,
                  color: c.textMain,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [c.secondary, c.primary, c.accent],
                  ).createShader(bounds),
                  child: const Text(
                    'tu forma',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 37,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      height: 1.05,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 136,
                  height: 7,
                  child: CustomPaint(
                    painter: _CrystalUnderlinePainter(
                      primary: c.primary,
                      accent: c.accent,
                    ),
                  ),
                ),
              ],
            ),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [c.textMain, c.primary, c.secondary],
              ).createShader(bounds),
              child: const Text(
                'de aprender?',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -1.1,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PastelQuartzPrimaryButton extends StatelessWidget {
  final String label;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _PastelQuartzPrimaryButton({
    required this.label,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.pastelQuartzPrimaryGradient,
          ),
          border: Border.all(
            color: const Color(0xB8A855F7),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x529333EA),
              blurRadius: 24,
              offset: Offset(0, 10),
              spreadRadius: -6,
            ),
            BoxShadow(
              color: Color(0x70D8B4FE),
              blurRadius: 12,
              offset: Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _QuartzCleavagePainter(isPrimary: true),
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) => CustomPaint(
                    painter: _QuartzShardsParticlePainter(
                      progress: animation.value,
                      isPrimary: true,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: RadialGradient(
                    colors: [
                      _alpha(const Color(0xFFFAF5FF), 0.76),
                      _alpha(const Color(0xFFFAF5FF), 0.0),
                    ],
                    radius: 1.4,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 13,
                      color: Color(0xFF581C87),
                    ),
                    const SizedBox(width: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: AppColors.pastelQuartzInkGradient,
                      ).createShader(bounds),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.3,
                          color: Colors.white,
                        ),
                      ),
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
}

class _PastelQuartzSecondaryButton extends StatelessWidget {
  final String label;
  final bool isDark;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _PastelQuartzSecondaryButton({
    required this.label,
    required this.isDark,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0x2EE9D5FF),
                        const Color(0x24F5D0FE),
                      ]
                    : [
                        const Color(0xEBFAF5FF),
                        const Color(0xDCF3E8FF),
                        const Color(0xE6FDF2F8),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? const Color(0x73D8B4FE)
                    : const Color(0xADC084FC),
                width: 1.1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _QuartzCleavagePainter(isPrimary: false),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) => CustomPaint(
                      painter: _QuartzShardsParticlePainter(
                        progress: animation.value,
                        isPrimary: false,
                      ),
                    ),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark
                        ? const Color(0xFFF3E8FF)
                        : const Color(0xFF4C1D95),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuartzCleavagePainter extends CustomPainter {
  final bool isPrimary;

  _QuartzCleavagePainter({required this.isPrimary});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final whiteFacet = Paint()
      ..color = _alpha(Colors.white, isPrimary ? 0.34 : 0.24)
      ..style = PaintingStyle.fill;

    final lilacFacet = Paint()
      ..color = _alpha(const Color(0xFFC084FC), isPrimary ? 0.24 : 0.16)
      ..style = PaintingStyle.fill;

    final amethystFacet = Paint()
      ..color = _alpha(const Color(0xFFA855F7), isPrimary ? 0.22 : 0.14)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(w * 0.17, 0)
        ..lineTo(w * 0.105, h * 0.56)
        ..lineTo(0, h * 0.40)
        ..close(),
      whiteFacet,
    );

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.17, 0)
        ..lineTo(w * 0.33, 0)
        ..lineTo(w * 0.26, h * 0.46)
        ..lineTo(w * 0.105, h * 0.56)
        ..close(),
      lilacFacet,
    );

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.74, 0)
        ..lineTo(w * 0.91, 0)
        ..lineTo(w * 0.84, h * 0.54)
        ..lineTo(w * 0.69, h * 0.40)
        ..close(),
      whiteFacet,
    );

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.84, h * 0.54)
        ..lineTo(w, h * 0.60)
        ..lineTo(w, h)
        ..lineTo(w * 0.78, h)
        ..close(),
      amethystFacet,
    );

    final ridgePaint = Paint()
      ..color = _alpha(Colors.white, isPrimary ? 0.75 : 0.55)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final cleavagePath = Path()
      ..moveTo(w * 0.17, 0)
      ..lineTo(w * 0.105, h * 0.56)
      ..lineTo(w * 0.065, h)
      ..moveTo(w * 0.105, h * 0.56)
      ..lineTo(w * 0.26, h * 0.46)
      ..lineTo(w * 0.33, 0)
      ..moveTo(w * 0.74, 0)
      ..lineTo(w * 0.69, h * 0.40)
      ..lineTo(w * 0.84, h * 0.54)
      ..lineTo(w * 0.91, 0)
      ..moveTo(w * 0.84, h * 0.54)
      ..lineTo(w * 0.78, h);

    canvas.drawPath(cleavagePath, ridgePaint);
  }

  @override
  bool shouldRepaint(covariant _QuartzCleavagePainter oldDelegate) => false;
}

class _QuartzShardsParticlePainter extends CustomPainter {
  final double progress;
  final bool isPrimary;

  _QuartzShardsParticlePainter({
    required this.progress,
    required this.isPrimary,
  });

  static const List<List<double>> _seeds = [
    [0.07, 0.65, 11.5, 1.0, 0.00, 0],
    [0.16, 0.36, 9.5, 1.0, 0.18, 1],
    [0.24, 0.72, 12.5, 1.0, 0.35, 0],
    [0.33, 0.50, 5.0, 1.0, 0.52, 2],
    [0.42, 0.70, 11.0, 1.0, 0.68, 0],
    [0.54, 0.30, 9.0, 1.0, 0.81, 1],
    [0.64, 0.72, 12.0, 1.0, 0.12, 0],
    [0.73, 0.44, 11.0, 1.0, 0.44, 0],
    [0.82, 0.66, 5.0, 1.0, 0.73, 2],
    [0.89, 0.38, 10.0, 1.0, 0.29, 1],
    [0.94, 0.68, 11.5, 1.0, 0.61, 0],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final count = isPrimary ? _seeds.length : 8;

    for (var i = 0; i < count; i++) {
      final s = _seeds[i];
      final localT = (progress * s[3] + s[4]) % 1.0;
      final opacity = math.sin(localT * math.pi).clamp(0.0, 1.0);

      final dx = size.width * s[0] + math.sin(localT * 2 * math.pi + i) * 10;
      final dy = size.height * s[1] - (localT * 24) + 8;
      final radius = s[2] * (0.75 + 0.35 * math.sin(localT * math.pi));
      final type = s[5].toInt();

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(localT * math.pi * (i.isEven ? 1 : -1));

      if (type == 0) {
        final r = radius * 0.55;
        final shardLight = Path()
          ..moveTo(0, -r)
          ..lineTo(r * 0.85, -r * 0.25)
          ..lineTo(r * 0.45, r)
          ..lineTo(-r * 0.6, r * 0.65)
          ..lineTo(-r * 0.85, -r * 0.25)
          ..close();

        final shardShade = Path()
          ..moveTo(0, -r)
          ..lineTo(r * 0.85, -r * 0.25)
          ..lineTo(r * 0.45, r)
          ..lineTo(0, r * 0.15)
          ..close();

        canvas.drawPath(
          shardLight,
          Paint()..color = _alpha(Colors.white, 0.92 * opacity),
        );
        canvas.drawPath(
          shardShade,
          Paint()..color = _alpha(const Color(0xFFA855F7), 0.80 * opacity),
        );
        canvas.drawPath(
          shardLight,
          Paint()
            ..color = _alpha(Colors.white, 0.95 * opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.85,
        );
      } else if (type == 1) {
        final r = radius * 0.52;
        final star = Path()
          ..moveTo(0, -r)
          ..lineTo(r * 0.28, -r * 0.28)
          ..lineTo(r, 0)
          ..lineTo(r * 0.28, r * 0.28)
          ..lineTo(0, r)
          ..lineTo(-r * 0.28, r * 0.28)
          ..lineTo(-r, 0)
          ..lineTo(-r * 0.28, -r * 0.28)
          ..close();

        canvas.drawPath(
          star,
          Paint()..color = _alpha(const Color(0xFF9333EA), 0.85 * opacity),
        );
      } else {
        canvas.drawCircle(
          Offset.zero,
          radius * 0.42,
          Paint()
            ..color = _alpha(const Color(0xFF9333EA), 0.75 * opacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _QuartzShardsParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _KadirWordmarkPainter extends CustomPainter {
  final AppColors colors;

  _KadirWordmarkPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 156.0;
    final sy = size.height / 24.0;
    canvas.save();
    canvas.scale(sx, sy);

    final mainPaint = Paint()
      ..shader = LinearGradient(
        colors: [colors.textMain, colors.textMain, colors.primary],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(const Rect.fromLTWH(0, 0, 156, 24));

    final prismPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colors.primary, colors.secondary],
      ).createShader(const Rect.fromLTWH(0, 0, 156, 24));

    final kPath = Path()
      ..addRect(const Rect.fromLTWH(2, 3, 4.6, 18))
      ..moveTo(8.4, 11.4)
      ..lineTo(17.2, 3)
      ..lineTo(22.8, 3)
      ..lineTo(13.2, 11.8)
      ..lineTo(23.4, 21)
      ..lineTo(17.6, 21)
      ..lineTo(8.4, 12.4)
      ..close();
    canvas.drawPath(kPath, mainPaint);

    final aPath = Path()
      ..moveTo(41.5, 2.4)
      ..lineTo(52.2, 21)
      ..lineTo(47.1, 21)
      ..lineTo(41.5, 10.6)
      ..lineTo(35.9, 21)
      ..lineTo(30.8, 21)
      ..close();
    canvas.drawPath(aPath, mainPaint);

    final aDiamond = Path()
      ..moveTo(41.5, 12.8)
      ..lineTo(44.3, 15.8)
      ..lineTo(41.5, 18.8)
      ..lineTo(38.7, 15.8)
      ..close();
    canvas.drawPath(aDiamond, prismPaint);

    final dPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(61, 3, 19.8, 18),
          topRight: const Radius.circular(9),
          bottomRight: const Radius.circular(9),
        ),
      )
      ..addRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(65.6, 6.8, 10.6, 10.4),
          topRight: const Radius.circular(5),
          bottomRight: const Radius.circular(5),
        ),
      );
    canvas.drawPath(dPath, mainPaint);

    final iPillar = Path()
      ..moveTo(92.8, 7.2)
      ..lineTo(97.4, 5.4)
      ..lineTo(97.4, 21)
      ..lineTo(92.8, 21)
      ..close();
    canvas.drawPath(iPillar, prismPaint);

    final iStar = Path()
      ..moveTo(95.1, -1.2)
      ..lineTo(96.3, 1.6)
      ..lineTo(99.1, 2.8)
      ..lineTo(96.3, 4.0)
      ..lineTo(95.1, 6.8)
      ..lineTo(93.9, 4.0)
      ..lineTo(91.1, 2.8)
      ..lineTo(93.9, 1.6)
      ..close();
    canvas.drawPath(iStar, Paint()..color = colors.accent);

    final rStem = Path()
      ..addRect(const Rect.fromLTWH(109, 3, 4.6, 18))
      ..moveTo(113.6, 3)
      ..lineTo(121, 3)
      ..arcToPoint(
        const Offset(121, 14.5),
        radius: const Radius.circular(5.7),
      )
      ..lineTo(128.5, 21)
      ..lineTo(122.8, 21)
      ..lineTo(116.5, 14.5)
      ..lineTo(113.6, 14.5)
      ..close();
    canvas.drawPath(rStem, mainPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _KadirWordmarkPainter oldDelegate) =>
      oldDelegate.colors != colors;
}

class _KadirIsometricLogoPainter extends CustomPainter {
  final AppColors colors;
  final KadirPaletteMode mode;
  final double progress;

  _KadirIsometricLogoPainter({
    required this.colors,
    required this.mode,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64.0;
    canvas.save();
    canvas.scale(s, s);

    final bgRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2, 2, 60, 60),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      bgRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: mode == KadirPaletteMode.orbita
              ? [const Color(0xFF101829), const Color(0xFF050811)]
              : [const Color(0xFFFFFFFF), const Color(0xFFDFF4F7)],
        ).createShader(const Rect.fromLTWH(2, 2, 60, 60)),
    );
    canvas.drawRRect(
      bgRect,
      Paint()
        ..color = _alpha(colors.isDark ? Colors.white : colors.primary, 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final colPath = Path()
      ..moveTo(21, 11)
      ..lineTo(29, 15)
      ..lineTo(29, 49)
      ..lineTo(21, 53)
      ..lineTo(13, 49)
      ..lineTo(13, 15)
      ..close();

    canvas.drawPath(
      colPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.primary, colors.secondary],
        ).createShader(const Rect.fromLTWH(13, 11, 16, 42)),
    );

    final topWing = Path()
      ..moveTo(26, 30)
      ..lineTo(44, 13)
      ..lineTo(51, 17)
      ..lineTo(33, 34)
      ..close();
    canvas.drawPath(
      topWing,
      Paint()
        ..shader = LinearGradient(
          colors: [colors.secondary, colors.primary],
        ).createShader(const Rect.fromLTWH(26, 13, 25, 21)),
    );

    final botWing = Path()
      ..moveTo(28, 28)
      ..lineTo(51, 45)
      ..lineTo(44, 51)
      ..lineTo(23, 34)
      ..close();
    canvas.drawPath(
      botWing,
      Paint()
        ..shader = LinearGradient(
          colors: [colors.accent, colors.primary],
        ).createShader(const Rect.fromLTWH(23, 28, 28, 23)),
    );

    canvas.save();
    final fullKClip = Path()
      ..addPath(colPath, Offset.zero)
      ..addPath(topWing, Offset.zero)
      ..addPath(botWing, Offset.zero);
    canvas.clipPath(fullKClip);

    final waveX = -32.0 + progress * 72.0;
    final waveY = 44.0 - progress * 72.0;
    canvas.translate(waveX, waveY);

    final silkWave = Path()
      ..moveTo(-20, 34)
      ..cubicTo(-2, 22, 16, 42, 36, 30)
      ..cubicTo(52, 20, 68, 38, 86, 26)
      ..lineTo(86, 40)
      ..cubicTo(68, 52, 52, 34, 36, 44)
      ..cubicTo(16, 56, -2, 36, -20, 48)
      ..close();

    canvas.drawPath(
      silkWave,
      Paint()..color = _alpha(Colors.white, 0.55),
    );
    canvas.restore();

    final coreDiamond = Path()
      ..moveTo(26, 25)
      ..lineTo(34, 32)
      ..lineTo(26, 39)
      ..lineTo(18, 32)
      ..close();
    canvas.drawPath(coreDiamond, Paint()..color = Colors.white);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _KadirIsometricLogoPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.mode != mode;
}

class _HeroNetworkStagePainter extends CustomPainter {
  final AppColors colors;
  final String activeNodeId;
  final double rotation;

  _HeroNetworkStagePainter({
    required this.colors,
    required this.activeNodeId,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.drawCircle(
      Offset.zero,
      98,
      Paint()
        ..color = _alpha(colors.primary, 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5,
    );
    canvas.restore();

    for (final node in _kSatelliteNodes) {
      final isSelected = node.id == activeNodeId;
      final p = Offset(size.width * node.xFactor, size.height * node.yFactor);
      canvas.drawLine(
        center,
        p,
        Paint()
          ..color = _alpha(
            isSelected ? colors.primary : colors.textMuted,
            isSelected ? 0.72 : 0.22,
          )
          ..strokeWidth = isSelected ? 1.6 : 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeroNetworkStagePainter oldDelegate) =>
      oldDelegate.rotation != rotation ||
      oldDelegate.activeNodeId != activeNodeId;
}

class _CrystalUnderlinePainter extends CustomPainter {
  final Color primary;
  final Color accent;

  _CrystalUnderlinePainter({required this.primary, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final arc = Path()
      ..moveTo(2, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.5,
        0,
        size.width - 2,
        size.height * 0.8,
      );
    canvas.drawPath(
      arc,
      Paint()
        ..color = _alpha(primary, 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    final mid = size.width * 0.5;
    final diamond = Path()
      ..moveTo(mid, 0)
      ..lineTo(mid + 3.5, 3)
      ..lineTo(mid, 6)
      ..lineTo(mid - 3.5, 3)
      ..close();
    canvas.drawPath(diamond, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _CrystalUnderlinePainter oldDelegate) => false;
}

class _AmbientBlurOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _AmbientBlurOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, _alpha(color, 0)],
          ),
        ),
      ),
    );
  }
}