import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Modos de paleta oficiales de KADIR
enum KadirPaletteMode { aurora, orbita, prisma }

class KadirPaletteColors {
  final String id;
  final String name;
  final String modeBadge;
  final Color bgMain;
  final Color surface;
  final Color surfaceBorder;
  final Color primary;
  final Color primaryText;
  final Color secondary;
  final Color textMain;
  final Color textMuted;
  final Color accent;
  final bool isDark;
  final Color glassSurface;
  final Color glassBorder;
  final Alignment orbAlign;

  const KadirPaletteColors({
    required this.id,
    required this.name,
    required this.modeBadge,
    required this.bgMain,
    required this.surface,
    required this.surfaceBorder,
    required this.primary,
    required this.primaryText,
    required this.secondary,
    required this.textMain,
    required this.textMuted,
    required this.accent,
    required this.isDark,
    required this.glassSurface,
    required this.glassBorder,
    required this.orbAlign,
  });
}

const Map<KadirPaletteMode, KadirPaletteColors> kKadirPalettes = {
  KadirPaletteMode.aurora: KadirPaletteColors(
    id: 'aurora',
    name: 'Aurora',
    modeBadge: 'CLARO CRISTAL',
    bgMain: Color(0xFFF3FAFD),
    surface: Color(0xFFFFFFFF),
    surfaceBorder: Color(0xFFE1EDF2),
    primary: Color(0xFF047D8A),
    primaryText: Color(0xFFFFFFFF),
    secondary: Color(0xFF6F56D9),
    textMain: Color(0xFF172638),
    textMuted: Color(0xFF5C6E82),
    accent: Color(0xFFF3B76B),
    isDark: false,
    glassSurface: Color(0xD6FFFFFF),
    glassBorder: Color(0x29047D8A),
    orbAlign: Alignment(-0.55, -0.55),
  ),
  KadirPaletteMode.orbita: KadirPaletteColors(
    id: 'orbita',
    name: 'Órbita',
    modeBadge: 'OSCURO ABISAL',
    bgMain: Color(0xFF070B14),
    surface: Color(0xFF101726),
    surfaceBorder: Color(0xFF1E2B45),
    primary: Color(0xFF49E0D3),
    primaryText: Color(0xFF051014),
    secondary: Color(0xFFA88FFF),
    textMain: Color(0xFFF5F9FF),
    textMuted: Color(0xFF8CA2C0),
    accent: Color(0xFFF6C453),
    isDark: true,
    glassSurface: Color(0xAD0C1220),
    glassBorder: Color(0x24FFFFFF),
    orbAlign: Alignment(0.45, -0.20),
  ),
  KadirPaletteMode.prisma: KadirPaletteColors(
    id: 'prisma',
    name: 'Prisma',
    modeBadge: 'CÁLIDO EDITORIAL',
    bgMain: Color(0xFFFFF7F3),
    surface: Color(0xFFFFFFFF),
    surfaceBorder: Color(0xFFF2DFD7),
    primary: Color(0xFF9B325F),
    primaryText: Color(0xFFFFFFFF),
    secondary: Color(0xFF6653CD),
    textMain: Color(0xFF2B243E),
    textMuted: Color(0xFF716585),
    accent: Color(0xFFF6C453),
    isDark: false,
    glassSurface: Color(0xD9FFFFFF),
    glassBorder: Color(0x299B325F),
    orbAlign: Alignment(-0.40, 0.25),
  ),
};

/// Helper para evitar el warning de .withOpacity()
Color _alpha(Color c, double opacity) {
  return c.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

class ThemeCustomizationScreen extends StatefulWidget {
  final KadirPaletteMode initialMode;
  final ValueChanged<KadirPaletteMode>? onThemeChanged;
  final VoidCallback? onConfirm;
  final VoidCallback? onBack;

  const ThemeCustomizationScreen({
    super.key,
    this.initialMode = KadirPaletteMode.aurora,
    this.onThemeChanged,
    this.onConfirm,
    this.onBack,
  });

  @override
  State<ThemeCustomizationScreen> createState() =>
      _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState extends State<ThemeCustomizationScreen>
    with SingleTickerProviderStateMixin {
  late KadirPaletteMode _selectedMode;
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
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

  void _selectPalette(KadirPaletteMode mode) {
    setState(() => _selectedMode = mode);
    widget.onThemeChanged?.call(mode);
  }

  @override
  Widget build(BuildContext context) {
    final colors = kKadirPalettes[_selectedMode]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      color: colors.bgMain,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. DESENFOQUE DINÁMICO QUE REACCIONA AL ELEGIR PALETA + PARTÍCULAS
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, _) {
                  final t = _ambientController.value * 2 * math.pi;
                  final dx1 = math.sin(t) * 0.12;
                  final dy1 = math.cos(t) * 0.10;
                  final dx2 = math.cos(t) * 0.12;
                  final dy2 = math.sin(t) * 0.10;

                  return Stack(
                    children: [
                      // Orbe Difuminado Primario
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment(
                          colors.orbAlign.x + dx1,
                          colors.orbAlign.y + dy1,
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

                      // Orbe Difuminado Secundario
                      Align(
                        alignment: Alignment(0.55 + dx2, 0.55 + dy2),
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

                      // Partículas suaves
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

            // 2. CONTENIDO PRINCIPAL EN FORMATO MÓVIL (maxWidth: 460)
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // CABECERA SUPERIOR LIMPIA (Botón Volver + Botón Omitir)
                        _buildTopHeader(colors),

                        // BLOQUE CENTRAL: TÍTULO + 3 TARJETAS DE PALETA
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTitleSection(colors),
                                  const SizedBox(height: 24),
                                  ...KadirPaletteMode.values.map((m) {
                                    final item = kKadirPalettes[m]!;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 14),
                                      child: _buildPaletteCard(
                                        mode: m,
                                        itemColors: item,
                                        activeColors: colors,
                                        isSelected: _selectedMode == m,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // PIE DE ACCIÓN EN GLASSMORPHISM
                        _buildContinueButton(colors),
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

  Widget _buildTopHeader(KadirPaletteColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.onBack != null)
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Material(
                color: colors.glassSurface,
                shape: CircleBorder(
                  side: BorderSide(color: colors.glassBorder, width: 1),
                ),
                child: InkWell(
                  onTap: widget.onBack,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 22,
                      color: colors.textMain,
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          const SizedBox(width: 38),

        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Material(
              color: colors.glassSurface,
              shape: StadiumBorder(
                side: BorderSide(color: colors.glassBorder, width: 1),
              ),
              child: InkWell(
                onTap: widget.onConfirm,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
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
        ),
      ],
    );
  }

  Widget _buildTitleSection(KadirPaletteColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(11, 11),
              painter: _FourPointStarPainter(color: colors.primary),
            ),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [colors.textMain, colors.primary, colors.secondary],
              ).createShader(bounds),
              child: const Text(
                'ATMÓSFERA VISUAL',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Título: "Elige tu propio" (cursiva con subrayado) + "espacio." (negrita)
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          runSpacing: 4,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [colors.secondary, colors.primary, colors.accent],
                  ).createShader(bounds),
                  child: const Text(
                    'Elige tu propio',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      height: 1.1,
                      letterSpacing: -0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 170,
                  height: 8,
                  child: CustomPaint(
                    painter: _EditorialUnderlinePainter(
                      primary: colors.primary,
                      accent: colors.accent,
                    ),
                  ),
                ),
              ],
            ),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [colors.textMain, colors.primary, colors.secondary],
                stops: const [0.10, 0.65, 1.0],
              ).createShader(bounds),
              child: const Text(
                'espacio.',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  letterSpacing: -1.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaletteCard({
    required KadirPaletteMode mode,
    required KadirPaletteColors itemColors,
    required KadirPaletteColors activeColors,
    required bool isSelected,
  }) {
    final cardBg = activeColors.isDark
        ? _alpha(const Color(0xFF101726), isSelected ? 0.84 : 0.60)
        : _alpha(Colors.white, isSelected ? 0.88 : 0.66);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? activeColors.primary : activeColors.glassBorder,
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _alpha(
                        activeColors.primary,
                        activeColors.isDark ? 0.22 : 0.12,
                      ),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectPalette(mode),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Izquierda: Mini-lienzo con esfera cromática + Nombre y Etiqueta
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: itemColors.bgMain,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: itemColors.surfaceBorder),
                          ),
                          child: Center(
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    itemColors.primary,
                                    itemColors.secondary,
                                    itemColors.accent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemColors.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: activeColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              itemColors.modeBadge,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: activeColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Derecha: 3 círculos de muestra + Check de selección
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 18,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: _buildColorDot(itemColors.primary),
                              ),
                              Positioned(
                                left: 11,
                                child: _buildColorDot(itemColors.secondary),
                              ),
                              Positioned(
                                left: 22,
                                child: _buildColorDot(itemColors.accent),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? activeColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? activeColors.primary
                                  : activeColors.glassBorder,
                              width: 1.4,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 15,
                                  color: activeColors.primaryText,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: _alpha(Colors.white, 0.70), width: 1.2),
      ),
    );
  }

  Widget _buildContinueButton(KadirPaletteColors colors) {
    final pillBg = colors.isDark
        ? _alpha(const Color(0xFF101726), 0.68)
        : _alpha(Colors.white, 0.78);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
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
                  : _selectedMode == KadirPaletteMode.prisma
                      ? [
                          _alpha(const Color(0xFFFFE7DF), 0.88),
                          _alpha(const Color(0xFFF3E8FF), 0.88),
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
                  : _alpha(colors.primary, 0.38),
              width: 1.2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onConfirm,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CONTINUAR CON ${colors.name.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: colors.isDark ? colors.textMain : colors.primary,
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
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CUSTOM PAINTERS (Partículas, Estrella de 4 Puntas y Subrayado Curvo)
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
      (0.12, 0.16, 3.0, true, 0.0),
      (0.86, 0.20, 3.5, false, 1.4),
      (0.15, 0.78, 3.2, false, 2.2),
      (0.84, 0.72, 3.5, true, 0.9),
    ];

    for (final s in specs) {
      final phase = (progress * 2 * math.pi) + s.$5;
      final dx = math.sin(phase) * 8;
      final dy = math.cos(phase) * 10;
      final paint = Paint()
        ..color = _alpha(s.$4 ? primary : secondary, 0.26)
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