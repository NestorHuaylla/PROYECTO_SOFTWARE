import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/screen/login_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../../../settings/presentation/screens/theme_customization_screen.dart';

/// Helper seguro para evitar el warning de `.withOpacity()` en Flutter 3.27+
Color _alpha(Color color, double opacity) {
  return color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

class _SatelliteNode {
  final String id;
  final String label;
  final double x; // 0.0 - 1.0
  final double y; // 0.0 - 1.0
  final double orb1Top;
  final double orb1Left;
  final double orb2Bottom;
  final double orb2Right;

  const _SatelliteNode({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.orb1Top,
    required this.orb1Left,
    required this.orb2Bottom,
    required this.orb2Right,
  });
}

const List<_SatelliteNode> _kSatelliteNodes = [
  _SatelliteNode(
    id: 'capacidad',
    label: 'CAPACIDAD',
    x: 0.18,
    y: 0.23,
    orb1Top: 0.18,
    orb1Left: 0.22,
    orb2Bottom: 0.18,
    orb2Right: 0.18,
  ),
  _SatelliteNode(
    id: 'modo',
    label: 'MODO',
    x: 0.82,
    y: 0.22,
    orb1Top: 0.24,
    orb1Left: 0.64,
    orb2Bottom: 0.26,
    orb2Right: 0.52,
  ),
  _SatelliteNode(
    id: 'ritmo',
    label: 'RITMO',
    x: 0.19,
    y: 0.78,
    orb1Top: 0.52,
    orb1Left: 0.24,
    orb2Bottom: 0.16,
    orb2Right: 0.26,
  ),
  _SatelliteNode(
    id: 'estrategia',
    label: 'ESTRATEGIA',
    x: 0.81,
    y: 0.77,
    orb1Top: 0.36,
    orb1Left: 0.56,
    orb2Bottom: 0.34,
    orb2Right: 0.20,
  ),
];

class WelcomeScreen extends StatefulWidget {
  final VoidCallback? onStart;
  final VoidCallback? onLogin;
  final VoidCallback? onSelectTheme;
  final KadirPaletteMode initialPalette;

  const WelcomeScreen({
    super.key,
    this.onStart,
    this.onLogin,
    this.onSelectTheme,
    this.initialPalette = KadirPaletteMode.orbita,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late KadirPaletteMode _mode;
  String _activeNodeId = 'capacidad';
  Offset _pointerOffset = Offset.zero;

  late final AnimationController _ambientController;
  late final AnimationController _orbitController;
  late final AnimationController _causticController;

  @override
  void initState() {
    super.initState();
  _mode = widget.initialPalette;

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();

    _causticController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _orbitController.dispose();
    _causticController.dispose();
    super.dispose();
  }

  _SatelliteNode get _currentNode => _kSatelliteNodes.firstWhere(
        (n) => n.id == _activeNodeId,
        orElse: () => _kSatelliteNodes.first,
      );

  void _handlePointerMove(PointerEvent event, Size screenSize) {
    if (screenSize.width <= 0 || screenSize.height <= 0) return;
    final normX = (event.localPosition.dx / screenSize.width - 0.5) * 2;
    final normY = (event.localPosition.dy / screenSize.height - 0.5) * 2;
    setState(() {
      _pointerOffset = Offset(normX * 20, normY * 16);
    });
  }
  void _handleStart() {
    if (widget.onStart != null) {
      widget.onStart!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingScreen(initialPalette: _mode),
      ),
    );
  }

  void _handleLogin() {
    if (widget.onLogin != null) {
      widget.onLogin!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _handleSelectTheme() {
    if (widget.onSelectTheme != null) {
      widget.onSelectTheme!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => ThemeCustomizationScreen(
          initialMode: _mode,
          onThemeChanged: (m) => setState(() => _mode = m),
          onConfirm: () => Navigator.of(routeContext).pop(),
          onBack: () => Navigator.of(routeContext).pop(),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.fromMode(_mode);
    final size = MediaQuery.sizeOf(context);
    final node = _currentNode;

    final glassBorder = colors.isDark
        ? _alpha(const Color(0xFF5EEAD4), 0.36)
        : _alpha(const Color(0xFF047D8A), 0.32);

    final pillGlassBg = colors.isDark
        ? _alpha(const Color(0xFF121E2E), 0.58)
        : _alpha(Colors.white, 0.72);

    final stageGlassBg = colors.isDark
        ? _alpha(const Color(0xFF0C1220), 0.64)
        : _alpha(Colors.white, 0.62);

    final cleanAccentText =
        colors.isDark ? const Color(0xFFC4B5FD) : const Color(0xFF4C1D95);

    return Scaffold(
      backgroundColor: colors.bgMain,
      body: Listener(
        onPointerHover: (e) => _handlePointerMove(e, size),
        onPointerMove: (e) => _handlePointerMove(e, size),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: colors.bgMain,
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // ===============================================================
              // CAPA DE ESTILO DESENFOCADO DINÁMICO (Dynamic Frosted Blur)
              // ===============================================================
              AnimatedBuilder(
                animation: _ambientController,
                builder: (context, _) {
                  final t = _ambientController.value * 2 * math.pi;
                  final float1X = math.sin(t) * 18.0 + _pointerOffset.dx;
                  final float1Y = math.cos(t * 0.8) * 14.0 + _pointerOffset.dy;

                  final float2X =
                      math.cos(t * 0.9) * -20.0 - _pointerOffset.dx * 0.85;
                  final float2Y =
                      math.sin(t * 1.1) * 16.0 - _pointerOffset.dy * 0.85;

                  final float3X =
                      math.sin(t * 0.7 + 1.2) * 14.0 + _pointerOffset.dx * 0.5;
                  final float3Y =
                      math.cos(t * 0.7 + 0.8) * -12.0 - _pointerOffset.dy * 0.5;

                  return Stack(
                    children: [
                      // Orbe Desenfocado 1 (Reacciona al nodo activo y al cursor)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 950),
                        curve: Curves.easeOutCubic,
                        top: size.height * node.orb1Top - 160 + float1Y,
                        left: size.width * node.orb1Left - 160 + float1X,
                        child: Container(
                          width: 320,
                          height: 320,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _alpha(colors.primary, 0.34),
                                _alpha(colors.primary, 0.0),
                              ],
                              stops: const [0.0, 0.74],
                            ),
                          ),
                        ),
                      ),

                      // Orbe Desenfocado 2 (Secundario en contra-fase suave)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 950),
                        curve: Curves.easeOutCubic,
                        bottom: size.height * node.orb2Bottom - 160 + float2Y,
                        right: size.width * node.orb2Right - 160 + float2X,
                        child: Container(
                          width: 320,
                          height: 320,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _alpha(colors.secondary, 0.30),
                                _alpha(colors.secondary, 0.0),
                              ],
                              stops: const [0.0, 0.74],
                            ),
                          ),
                        ),
                      ),

                      // Orbe Desenfocado Central detrás del Escenario Hero y Botones
                      Positioned(
                        top: size.height * 0.54 - 144 + float3Y,
                        left: size.width * 0.50 - 144 + float3X,
                        child: Container(
                          width: 288,
                          height: 288,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _alpha(colors.secondary, 0.24),
                                _alpha(colors.primary, 0.15),
                                _alpha(colors.primary, 0.0),
                              ],
                              stops: const [0.0, 0.60, 0.85],
                            ),
                          ),
                        ),
                      ),

                      // Velo atmosférico de desenfoque óptico (Frosted Bokeh Veil)
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                          child: Container(
                            color: colors.isDark
                                ? _alpha(const Color(0xFF070B14), 0.18)
                                : _alpha(const Color(0xFFF3FAFD), 0.22),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // ===============================================================
              // CONTENIDO PRINCIPAL
              // ===============================================================
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. CABECERA NEO-SWISS + SELECTOR DE PALETA EN CRISTAL
                          _buildHeader(colors),

                          // 2. ESCENARIO HERO + TÍTULO + BOTONES CRISTAL
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildHeroStage(colors, stageGlassBg),
                                      const SizedBox(height: 26),
                                      _buildEditorialHeadline(colors),
                                      const SizedBox(height: 28),
                                      _buildCrystalButtons(
                                        colors: colors,
                                        glassBorder: glassBorder,
                                        pillGlassBg: pillGlassBg,
                                        cleanAccentText: cleanAccentText,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 3. PIE DISCRETO
                          _buildFooter(colors),
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
    );
  }

  // ===========================================================================
  // 1. CABECERA NEO-SWISS
  // ===========================================================================
  Widget _buildHeader(AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo KADIR + Wordmark
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _KadirIsometricMark(
              size: 36,
              mode: _mode,
              colors: colors,
              animation: _ambientController,
            ),
            const SizedBox(width: 11),
            CustomPaint(
              size: const Size(110, 17),
              painter: _KadirWordmarkPainter(colors: colors),
            ),
          ],
        ),

        // Selector de Paleta en Cristal (Aurora / Órbita / Prisma)
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.glassSurface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: colors.glassSpecularBorder, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: KadirPaletteMode.values.map((p) {
                  final isSelected = _mode == p;
                  final pTokens = AppColors.fromMode(p);
                  return GestureDetector(
                    onTap: () => setState(() => _mode = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        pTokens.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? colors.primaryText
                              : _alpha(colors.textMain, 0.72),
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

  // ===========================================================================
  // 2. ESCENARIO HERO CON CRISTAL DESENFOCADO (Frosted Glass Blur)
  // ===========================================================================
  Widget _buildHeroStage(AppColors colors, Color stageGlassBg) {
    final radialInnerColors = _mode == KadirPaletteMode.orbita
        ? [
            _alpha(const Color(0xFF132036), 0.55),
            _alpha(const Color(0xFF0A0F1C), 0.68),
          ]
        : _mode == KadirPaletteMode.prisma
            ? [
                _alpha(const Color(0xFFFFEAE2), 0.52),
                _alpha(Colors.white, 0.66),
              ]
            : [
                _alpha(const Color(0xFFE1F6F5), 0.52),
                _alpha(Colors.white, 0.66),
              ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
        child: Container(
          width: double.infinity,
          height: 248,
          decoration: BoxDecoration(
            color: stageGlassBg,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: colors.glassSpecularBorder,
              width: 1.2,
            ),
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.85,
              colors: radialInnerColors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.isDark
                    ? _alpha(Colors.black, 0.55)
                    : _alpha(colors.primary, 0.12),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stageW = constraints.maxWidth;
              final stageH = constraints.maxHeight;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Halo desenfocado interno suave detrás del pedestal de la K
                  Container(
                    width: 176,
                    height: 176,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _alpha(colors.primary, 0.28),
                          _alpha(colors.secondary, 0.18),
                          _alpha(colors.secondary, 0.0),
                        ],
                        stops: const [0.0, 0.65, 1.0],
                      ),
                    ),
                  ),

                  // Anillos Orbitales Animados
                  AnimatedBuilder(
                    animation: _orbitController,
                    builder: (context, _) {
                      final angleCw = _orbitController.value * 2 * math.pi;
                      final angleCcw = -_orbitController.value * 2 * math.pi;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: angleCw,
                            child: Container(
                              width: 218,
                              height:
                                  _mode == KadirPaletteMode.orbita ? 148 : 218,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(220),
                                border: Border.all(
                                  color: _alpha(colors.primary, 0.20),
                                  width: 5,
                                ),
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: angleCcw,
                            child: CustomPaint(
                              size: const Size(158, 158),
                              painter: _DashedCirclePainter(
                                color: _alpha(colors.secondary, 0.26),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Líneas de red conectando los 4 satélites al núcleo KADIR
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _HeroNetworkLinesPainter(
                        nodes: _kSatelliteNodes,
                        activeNodeId: _activeNodeId,
                        primaryColor: colors.primary,
                        mutedColor: colors.textMuted,
                      ),
                    ),
                  ),

                  // 4 Píldoras Satélite Interactivas (CAPACIDAD, MODO, RITMO, ESTRATEGIA)
                  ..._kSatelliteNodes.map((node) {
                    final isSelected = _activeNodeId == node.id;
                    return Positioned(
                      left: stageW * node.x - 56,
                      top: stageH * node.y - 14,
                      child: SizedBox(
                        width: 112,
                        height: 28,
                        child: Center(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _activeNodeId = node.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary
                                    : colors.isDark
                                        ? _alpha(const Color(0xFF101726), 0.72)
                                        : _alpha(Colors.white, 0.78),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.glassSpecularBorder,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? _alpha(colors.primary, 0.28)
                                        : _alpha(Colors.black, 0.06),
                                    blurRadius: isSelected ? 10 : 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isSelected ? '✦' : '◇',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      color: isSelected
                                          ? colors.primaryText
                                          : _alpha(colors.textMain, 0.75),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    node.label,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 9.2,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.4,
                                      color: isSelected
                                          ? colors.primaryText
                                          : colors.textMain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Pedestal Central Esmerilado con la K Isométrica 3D
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.isDark
                              ? _alpha(const Color(0xFF0A101E), 0.66)
                              : _alpha(Colors.white, 0.68),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: colors.glassSpecularBorder,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.isDark
                                  ? _alpha(Colors.black, 0.5)
                                  : _alpha(colors.primary, 0.14),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // Bisel especular superior
                            Positioned(
                              top: 0,
                              left: 12,
                              right: 12,
                              child: Container(
                                height: 1.5,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white,
                                      colors.primary,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            _KadirIsometricMark(
                              size: 78,
                              mode: _mode,
                              colors: colors,
                              animation: _ambientController,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. BLOQUE TIPOGRÁFICO DE VANGUARDIA
  // ===========================================================================
  Widget _buildEditorialHeadline(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Cabezal Arquitectónico "WELCOME" con Geometría de Diamante
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(12, 12),
              painter: _FourPointStarPainter(color: colors.primary),
            ),
            const SizedBox(width: 6),
            Container(
              width: 24,
              height: 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: LinearGradient(
                  colors: [colors.primary, Colors.transparent],
                ),
              ),
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  colors.textMain,
                  colors.primary,
                  colors.secondary,
                ],
                stops: const [0.0, 0.55, 1.0],
              ).createShader(bounds),
              child: const Text(
                'WELCOME',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4.8,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 24,
              height: 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: LinearGradient(
                  colors: [Colors.transparent, colors.secondary],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Línea 1: "¿Listo para cambiar"
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 34,
              height: 1.10,
              color: colors.textMain,
              letterSpacing: -0.8,
            ),
            children: [
              TextSpan(
                text: '¿Listo para ',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: _alpha(colors.textMain, 0.90),
                ),
              ),
              TextSpan(
                text: 'cambiar',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      color: colors.isDark
                          ? _alpha(const Color(0xFF49E0D3), 0.18)
                          : _alpha(const Color(0xFF047D8A), 0.10),
                      blurRadius: 14,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),

        // Línea 2: "tu forma" (Serif Líquido + Filamento de cristal) + "de aprender?"
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.secondary,
                      colors.primary,
                      colors.accent,
                    ],
                    stops: const [0.0, 0.60, 1.0],
                  ).createShader(bounds),
                  child: const Text(
                    'tu forma',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      fontSize: 37,
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                CustomPaint(
                  size: const Size(138, 7),
                  painter: _CrystalUnderlinePainter(
                    primary: colors.primary,
                    accent: colors.accent,
                  ),
                ),
              ],
            ),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  colors.textMain,
                  colors.primary,
                  colors.secondary,
                ],
                stops: const [0.10, 0.65, 1.0],
              ).createShader(bounds),
              child: const Text(
                'de aprender?',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.10,
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

  // ===========================================================================
  // 4. SISTEMA CTA EN CRISTAL ÓPTICO (Estilo y Colores del Auth)
  // ===========================================================================
  Widget _buildCrystalButtons({
    required AppColors colors,
    required Color glassBorder,
    required Color pillGlassBg,
    required Color cleanAccentText,
  }) {
    return Column(
      children: [
        // 1. BOTÓN PRIMARIO ("Empezar ahora"): Cristal Óptico Verdoso-Aqua + Lavanda
        GestureDetector(
          onTap: _handleStart,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: glassBorder, width: 1.5),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors.isDark
                        ? [
                            _alpha(const Color(0xFF14B8A6), 0.24),
                            _alpha(const Color(0xFF6F56D9), 0.26),
                          ]
                        : [
                            _alpha(const Color(0xFFCCFBF1), 0.68),
                            _alpha(const Color(0xFFE9D5FF), 0.60),
                            _alpha(const Color(0xFFF3E8FF), 0.70),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.isDark
                          ? _alpha(Colors.black, 0.45)
                          : _alpha(const Color(0xFF047D8A), 0.15),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Arista de brillo especular bicolor (Verdoso-Aqua #5EEAD4 + Violeta #C084FC)
                    Positioned(
                      top: 0,
                      left: 32,
                      right: 32,
                      child: Container(
                        height: 1.6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFF5EEAD4),
                              _alpha(Colors.white, 0.96),
                              const Color(0xFFC084FC),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Barrido cáustico continuo de extremo a extremo cruzando el cristal
                    AnimatedBuilder(
                      animation: _causticController,
                      builder: (context, _) {
                        final progress = _causticController.value;
                        return FractionalTranslation(
                          translation: Offset(-1.6 + progress * 3.4, 0),
                          child: Transform.rotate(
                            angle: -0.32,
                            child: Container(
                              width: 96,
                              height: 90,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    _alpha(const Color(0xFFCCFBF1), 0.55),
                                    _alpha(Colors.white, 0.82),
                                    _alpha(const Color(0xFFE9D5FF), 0.52),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.32, 0.50, 0.70, 1.0],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Contenido del botón primario
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EMPEZAR AHORA',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.7,
                              color: colors.isDark
                                  ? colors.textMain
                                  : const Color(0xFF3B1D7A),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: pillGlassBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: glassBorder, width: 1),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 17,
                              color: cleanAccentText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 2. BOTÓN SECUNDARIO ("Ya tengo una cuenta"): Cristal Óptico Traslúcido estilo Tarjeta de Auth
        GestureDetector(
          onTap: _handleLogin,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: glassBorder, width: 1.4),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors.isDark
                        ? [
                            _alpha(const Color(0xFF10222E), 0.52),
                            _alpha(const Color(0xFF12182A), 0.40),
                            _alpha(const Color(0xFF141A30), 0.48),
                          ]
                        : [
                            _alpha(const Color(0xFFF0FDFA), 0.62),
                            _alpha(Colors.white, 0.56),
                            _alpha(const Color(0xFFF3E8FF), 0.52),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.isDark
                          ? _alpha(Colors.black, 0.38)
                          : _alpha(const Color(0xFF047D8A), 0.10),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Arista de brillo especular superior sutil
                    Positioned(
                      top: 0,
                      left: 40,
                      right: 40,
                      child: Container(
                        height: 1.4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFF5EEAD4),
                              _alpha(Colors.white, 0.92),
                              const Color(0xFFC084FC),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Ya tengo una cuenta',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: cleanAccentText,
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
  }

  // ===========================================================================
  // 5. PIE DISCRETO
  // ===========================================================================
  Widget _buildFooter(AppColors colors) {
    return GestureDetector(
      onTap: _handleSelectTheme,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Personalizar atmósfera visual · Aurora / Órbita / Prisma',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
            color: _alpha(colors.textMuted, 0.78),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// COMPONENTE LOGO K ISOMÉTRICA 3D CON ONDA DE LUZ Y BISEL LÁSER
// =============================================================================
class _KadirIsometricMark extends StatelessWidget {
  final double size;
  final KadirPaletteMode mode;
  final AppColors colors;
  final Animation<double> animation;

  const _KadirIsometricMark({
    required this.size,
    required this.mode,
    required this.colors,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(
          size: Size(size, size),
          painter: _KadirIsometricPainter(
            mode: mode,
            colors: colors,
            progress: animation.value,
          ),
        );
      },
    );
  }
}

class _KadirIsometricPainter extends CustomPainter {
  final KadirPaletteMode mode;
  final AppColors colors;
  final double progress;

  _KadirIsometricPainter({
    required this.mode,
    required this.colors,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64.0;
    canvas.save();
    canvas.scale(s, s);

    // 1. Base Squircle Esmerilada
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2, 2, 60, 60),
      const Radius.circular(18),
    );
    final bgStart = mode == KadirPaletteMode.orbita
        ? const Color(0xFF101829)
        : Colors.white;
    final bgEnd = mode == KadirPaletteMode.orbita
        ? const Color(0xFF050811)
        : mode == KadirPaletteMode.prisma
            ? const Color(0xFFFFE6DC)
            : const Color(0xFFDFF4F7);

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_alpha(bgStart, 0.96), _alpha(bgEnd, 0.92)],
      ).createShader(const Rect.fromLTWH(2, 2, 60, 60));
    canvas.drawRRect(rrect, bgPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = colors.isDark
          ? _alpha(Colors.white, 0.24)
          : _alpha(colors.primary, 0.32);
    canvas.drawRRect(rrect, borderPaint);

    // 2. Halo respirante detrás de la K
    final breathe = 0.92 + 0.12 * math.sin(progress * 2 * math.pi);
    canvas.drawCircle(
      const Offset(32, 32),
      20 * breathe,
      Paint()
        ..color = _alpha(colors.primary, colors.isDark ? 0.24 : 0.14),
    );

    // 3. Placa hexagonal interna
    final hexPath = Path()
      ..moveTo(32, 7)
      ..lineTo(54, 19)
      ..lineTo(54, 45)
      ..lineTo(32, 57)
      ..lineTo(10, 45)
      ..lineTo(10, 19)
      ..close();
    canvas.drawPath(
      hexPath,
      Paint()..color = _alpha(Colors.white, colors.isDark ? 0.05 : 0.45),
    );
    canvas.drawPath(
      hexPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = _alpha(Colors.white, colors.isDark ? 0.18 : 0.70),
    );

    // 4. Columna vertical 3D (Pilar de Capacidad)
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _alpha(colors.primary, 0.96),
            _alpha(colors.secondary, 0.88),
          ],
        ).createShader(const Rect.fromLTWH(13, 11, 16, 42)),
    );

    // Tapa superior iluminada
    final capPath = Path()
      ..moveTo(21, 11)
      ..lineTo(29, 15)
      ..lineTo(21, 19)
      ..lineTo(13, 15)
      ..close();
    canvas.drawPath(capPath, Paint()..color = _alpha(Colors.white, 0.55));

    // Faceta izquierda sombreada
    final leftShade = Path()
      ..moveTo(13, 15)
      ..lineTo(21, 19)
      ..lineTo(21, 53)
      ..lineTo(13, 49)
      ..close();
    canvas.drawPath(leftShade, Paint()..color = _alpha(Colors.black, 0.16));

    // 5. Prisma Superior (Modo)
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
          colors: [
            _alpha(colors.secondary, 0.95),
            _alpha(colors.primary, 0.78),
          ],
        ).createShader(const Rect.fromLTWH(26, 13, 25, 21)),
    );

    final topSide = Path()
      ..moveTo(26, 30)
      ..lineTo(44, 13)
      ..lineTo(44, 21)
      ..lineTo(26, 38)
      ..close();
    canvas.drawPath(topSide, Paint()..color = _alpha(colors.primary, 0.82));

    // 6. Prisma Inferior (Estrategia / Ritmo)
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
          colors: [
            _alpha(colors.accent, 0.96),
            _alpha(colors.primary, 0.86),
          ],
        ).createShader(const Rect.fromLTWH(23, 28, 28, 23)),
    );

    // 7. Vértice Diamante Central
    final coreOuter = Path()
      ..moveTo(26, 25)
      ..lineTo(34, 32)
      ..lineTo(26, 39)
      ..lineTo(18, 32)
      ..close();
    canvas.drawPath(coreOuter, Paint()..color = _alpha(Colors.white, 0.96));

    final coreInner = Path()
      ..moveTo(26, 28)
      ..lineTo(30, 32)
      ..lineTo(26, 36)
      ..lineTo(22, 32)
      ..close();
    canvas.drawPath(
      coreInner,
      Paint()..color = _alpha(colors.primary, 0.88),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _KadirIsometricPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.mode != mode;
  }
}

// =============================================================================
// WORDMARK GEOMÉTRICO "K A D I R"
// =============================================================================
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

    // K
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

    // A (Delta Λ + Diamante interno)
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

    // D
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

    // I + Estrella de 4 puntas
    final iPath = Path()
      ..moveTo(92.8, 7.2)
      ..lineTo(97.4, 5.4)
      ..lineTo(97.4, 21)
      ..lineTo(92.8, 21)
      ..close();
    canvas.drawPath(iPath, prismPaint);

    final starPath = Path()
      ..moveTo(95.1, -1.2)
      ..lineTo(96.3, 1.6)
      ..lineTo(99.1, 2.8)
      ..lineTo(96.3, 4.0)
      ..lineTo(95.1, 6.8)
      ..lineTo(93.9, 4.0)
      ..lineTo(91.1, 2.8)
      ..lineTo(93.9, 1.6)
      ..close();
    canvas.drawPath(starPath, Paint()..color = colors.accent);

    // R
    final rPath = Path()
      ..moveTo(109, 3)
      ..lineTo(120.2, 3)
      ..quadraticBezierTo(127.6, 3, 127.6, 9.1)
      ..quadraticBezierTo(127.6, 13.6, 122.4, 14.9)
      ..lineTo(128.8, 21)
      ..lineTo(123.2, 21)
      ..lineTo(117.4, 15.2)
      ..lineTo(113.6, 15.2)
      ..lineTo(113.6, 21)
      ..lineTo(109, 21)
      ..close();
    canvas.drawPath(rPath, mainPaint);

    // Micro-prisma final
    final dotDiamond = Path()
      ..moveTo(135, 17.5)
      ..lineTo(138, 14.5)
      ..lineTo(141, 17.5)
      ..lineTo(138, 20.5)
      ..close();
    canvas.drawPath(dotDiamond, Paint()..color = _alpha(colors.primary, 0.85));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _KadirWordmarkPainter oldDelegate) =>
      oldDelegate.colors != colors;
}

// =============================================================================
// PAINTERS AUXILIARES DEL HERO Y TIPOGRAFÍA
// =============================================================================
class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final radius = size.width / 2;
    final center = Offset(radius, radius);
    const int dashCount = 36;
    const double step = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * step,
        step * 0.55,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _HeroNetworkLinesPainter extends CustomPainter {
  final List<_SatelliteNode> nodes;
  final String activeNodeId;
  final Color primaryColor;
  final Color mutedColor;

  _HeroNetworkLinesPainter({
    required this.nodes,
    required this.activeNodeId,
    required this.primaryColor,
    required this.mutedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);

    for (final node in nodes) {
      final isSelected = node.id == activeNodeId;
      final start = Offset(size.width * node.x, size.height * node.y);

      final paint = Paint()
        ..color = isSelected
            ? _alpha(primaryColor, 0.75)
            : _alpha(mutedColor, 0.24)
        ..strokeWidth = isSelected ? 1.8 : 1.1
        ..style = PaintingStyle.stroke;

      if (isSelected) {
        canvas.drawLine(start, center, paint);
      } else {
        const int segments = 12;
        for (int i = 0; i < segments; i += 2) {
          final p1 = Offset.lerp(start, center, i / segments)!;
          final p2 = Offset.lerp(start, center, (i + 1) / segments)!;
          canvas.drawLine(p1, p2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeroNetworkLinesPainter oldDelegate) =>
      oldDelegate.activeNodeId != activeNodeId ||
      oldDelegate.primaryColor != primaryColor;
}

class _FourPointStarPainter extends CustomPainter {
  final Color color;

  _FourPointStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(6, 0)
      ..lineTo(7.6, 4.4)
      ..lineTo(12, 6)
      ..lineTo(7.6, 7.6)
      ..lineTo(6, 12)
      ..lineTo(4.4, 7.6)
      ..lineTo(0, 6)
      ..lineTo(4.4, 4.4)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _FourPointStarPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CrystalUnderlinePainter extends CustomPainter {
  final Color primary;
  final Color accent;

  _CrystalUnderlinePainter({required this.primary, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final curvePaint = Paint()
      ..color = _alpha(primary, 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(2, 5.5)
      ..cubicTo(
        size.width * 0.27,
        1.2,
        size.width * 0.70,
        1.2,
        size.width - 2,
        5.5,
      );
    canvas.drawPath(path, curvePaint);

    final midX = size.width * 0.5;
    final diamond = Path()
      ..moveTo(midX, 0.5)
      ..lineTo(midX + 3.5, 3.2)
      ..lineTo(midX, 5.9)
      ..lineTo(midX - 3.5, 3.2)
      ..close();
    canvas.drawPath(diamond, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _CrystalUnderlinePainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.accent != accent;
}