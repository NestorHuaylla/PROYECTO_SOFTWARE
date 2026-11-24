import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Reutiliza KadirPaletteMode y KadirPalette

/// ============================================================================
/// 1. MODELOS DE ÁREAS ACADÉMICAS Y ESTILOS POR PALETA
/// ============================================================================

enum KadirAreaId {
  logicoMatematico,
  comprensionLectora,
  ciencias,
}

class KadirAreaInfo {
  final KadirAreaId id;
  final String indexLabel;
  final String name;
  final String description;

  const KadirAreaInfo({
    required this.id,
    required this.indexLabel,
    required this.name,
    required this.description,
  });

  static const List<KadirAreaInfo> all = [
    KadirAreaInfo(
      id: KadirAreaId.logicoMatematico,
      indexLabel: '01',
      name: 'Lógico Matemático',
      description:
          'Domina fracciones, ecuaciones lineales, proporcionalidad y geometría con analogías interactivas.',
    ),
    KadirAreaInfo(
      id: KadirAreaId.comprensionLectora,
      indexLabel: '02',
      name: 'Comprensión Lectora',
      description:
          'Identifica idea principal, intención del autor, inferencias y conectores lógicos sin lectura pasiva.',
    ),
    KadirAreaInfo(
      id: KadirAreaId.ciencias,
      indexLabel: '03',
      name: 'Ciencias',
      description:
          'Comprende reacciones, fuerzas, células y energía conectando causa y efecto con tus universos favoritos.',
    ),
  ];
}

class _AreaVisualColors {
  final Color primary;
  final Color secondary;

  const _AreaVisualColors({
    required this.primary,
    required this.secondary,
  });

  static _AreaVisualColors resolve(KadirPaletteMode mode, KadirAreaId area) {
    switch (mode) {
      case KadirPaletteMode.orbita:
        switch (area) {
          case KadirAreaId.logicoMatematico:
            return const _AreaVisualColors(
              primary: Color(0xFF49E0D3),
              secondary: Color(0xFF38BDF8),
            );
          case KadirAreaId.comprensionLectora:
            return const _AreaVisualColors(
              primary: Color(0xFFA88FFF),
              secondary: Color(0xFFC4B5FD),
            );
          case KadirAreaId.ciencias:
            return const _AreaVisualColors(
              primary: Color(0xFF2DD4BF),
              secondary: Color(0xFF49E0D3),
            );
        }
      case KadirPaletteMode.prisma:
        switch (area) {
          case KadirAreaId.logicoMatematico:
            return const _AreaVisualColors(
              primary: Color(0xFF9B325F),
              secondary: Color(0xFF6653CD),
            );
          case KadirAreaId.comprensionLectora:
            return const _AreaVisualColors(
              primary: Color(0xFF6653CD),
              secondary: Color(0xFF9B325F),
            );
          case KadirAreaId.ciencias:
            return const _AreaVisualColors(
              primary: Color(0xFFB45309),
              secondary: Color(0xFF9B325F),
            );
        }
      case KadirPaletteMode.aurora:
        switch (area) {
          case KadirAreaId.logicoMatematico:
            return const _AreaVisualColors(
              primary: Color(0xFF047D8A),
              secondary: Color(0xFF0EA5E9),
            );
          case KadirAreaId.comprensionLectora:
            return const _AreaVisualColors(
              primary: Color(0xFF6F56D9),
              secondary: Color(0xFF047D8A),
            );
          case KadirAreaId.ciencias:
            return const _AreaVisualColors(
              primary: Color(0xFF0D9488),
              secondary: Color(0xFF6F56D9),
            );
        }
    }
  }
}

Color _alpha(Color color, double opacity) {
  return color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

/// ============================================================================
/// 2. PANTALLA: MODOS DE APRENDIZAJE (3 Áreas Académicas sin overflow)
/// ============================================================================

class KadirModesScreen extends StatelessWidget {
  final KadirPaletteMode paletteMode;
  final String userAlias;
  final int streakDays;
  final KadirAreaId? selectedArea;
  final Map<KadirAreaId, int> areaProgress;

  final ValueChanged<KadirAreaId>? onSelectArea;
  final VoidCallback? onBackToHome;
  final VoidCallback? onOpenProgress;
  final VoidCallback? onOpenProfile;

  const KadirModesScreen({
    super.key,
    this.paletteMode = KadirPaletteMode.aurora,
    this.userAlias = 'Estudiante Kadir',
    this.streakDays = 3,
    this.selectedArea,
    this.areaProgress = const {
      KadirAreaId.logicoMatematico: 64,
      KadirAreaId.comprensionLectora: 72,
      KadirAreaId.ciencias: 58,
    },
    this.onSelectArea,
    this.onBackToHome,
    this.onOpenProgress,
    this.onOpenProfile,
  });

  String get _initials {
    final parts = userAlias
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'EK';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final palette = KadirPalette.fromMode(paletteMode);

    return Scaffold(
      backgroundColor: palette.bgMain,
      body: Stack(
        children: [
          // Capa 0: Fondo atmosférico sincronizado a la paleta global
          Positioned.fill(
            child: _ModesAmbientBackdrop(palette: palette),
          ),

          // Capa 1: Contenido seguro y 100% adaptable
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 820;
                final isCompactHeight = constraints.maxHeight < 660;
                final hPadding = isWide ? 32.0 : 16.0;
                final vPadding = isCompactHeight ? 10.0 : 16.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hPadding,
                        vertical: vPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. CABECERA UNIFICADA
                          _buildHeader(context, palette),

                          SizedBox(height: isCompactHeight ? 14 : 22),

                          // 2. TÍTULO LIMPIO DE LA SECCIÓN
                          Text(
                            'Elige tu Área Académica',
                            style: TextStyle(
                              fontSize: isWide ? 28 : 23,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              height: 1.15,
                              color: palette.textMain,
                            ),
                          ),

                          SizedBox(height: isCompactHeight ? 12 : 18),

                          // 3. TARJETAS DE LAS 3 ÁREAS (Horizontal en móvil / 3 columnas en tablet-PC)
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, bodyConstraints) {
                                if (isWide) {
                                  final cardHeight = bodyConstraints.maxHeight
                                      .clamp(380.0, 468.0);
                                  return SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: bodyConstraints.maxHeight,
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          height: cardHeight,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: List.generate(
                                              KadirAreaInfo.all.length,
                                              (i) {
                                                final area =
                                                    KadirAreaInfo.all[i];
                                                return Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      left: i == 0 ? 0 : 18,
                                                    ),
                                                    child: _AreaModeCard(
                                                      area: area,
                                                      paletteMode: paletteMode,
                                                      palette: palette,
                                                      progressPercent:
                                                          (areaProgress[area.id] ??
                                                                  50)
                                                              .clamp(0, 100),
                                                      isSelected:
                                                          selectedArea ==
                                                              area.id,
                                                      isVerticalLayout: true,
                                                      onTap: () => onSelectArea
                                                          ?.call(area.id),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                // Móvil: lista segura con altura mínima cómoda y scroll si la pantalla es muy pequeña
                                final double mobileCardHeight =
                                    ((bodyConstraints.maxHeight - 28) / 3)
                                        .clamp(148.0, 192.0);

                                return SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: bodyConstraints.maxHeight,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        KadirAreaInfo.all.length,
                                        (i) {
                                          final area = KadirAreaInfo.all[i];
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: i ==
                                                      KadirAreaInfo.all.length -
                                                          1
                                                  ? 4
                                                  : 12,
                                            ),
                                            child: SizedBox(
                                              height: mobileCardHeight,
                                              child: _AreaModeCard(
                                                area: area,
                                                paletteMode: paletteMode,
                                                palette: palette,
                                                progressPercent:
                                                    (areaProgress[area.id] ??
                                                            50)
                                                        .clamp(0, 100),
                                                isSelected:
                                                    selectedArea == area.id,
                                                isVerticalLayout: false,
                                                onTap: () => onSelectArea
                                                    ?.call(area.id),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, KadirPalette palette) {
    final pillBg = palette.isDark
        ? _alpha(palette.surface, 0.78)
        : _alpha(Colors.white, 0.84);

    return Row(
      children: [
        // Botón Volver al Inicio
        Flexible(
          child: _ModesGlassPill(
            onTap: onBackToHome ?? () => Navigator.maybePop(context),
            backgroundColor: pillBg,
            borderColor: palette.glassBorder,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 16,
                  color: palette.textMain,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Volver al Inicio',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: palette.textMain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Racha diaria + Perfil
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModesGlassPill(
              onTap: onOpenProgress,
              backgroundColor: pillBg,
              borderColor: palette.glassBorder,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 16,
                    color: palette.accent,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$streakDays días',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: palette.textMain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _ModesGlassPill(
              onTap: onOpenProfile,
              backgroundColor: pillBg,
              borderColor: palette.glassBorder,
              borderRadius: 999,
              padding: EdgeInsets.zero,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Text(
                    _initials,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: palette.textMain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ============================================================================
/// 3. TARJETA DE ÁREA (Cristal esmerilado + Ilustración + Progreso + CTA)
/// ============================================================================

class _AreaModeCard extends StatelessWidget {
  final KadirAreaInfo area;
  final KadirPaletteMode paletteMode;
  final KadirPalette palette;
  final int progressPercent;
  final bool isSelected;
  final bool isVerticalLayout;
  final VoidCallback? onTap;

  const _AreaModeCard({
    required this.area,
    required this.paletteMode,
    required this.palette,
    required this.progressPercent,
    required this.isSelected,
    required this.isVerticalLayout,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final areaColors = _AreaVisualColors.resolve(paletteMode, area.id);
    final radius = isVerticalLayout ? 24.0 : 20.0;

    final stageGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _alpha(areaColors.primary, palette.isDark ? 0.18 : 0.11),
        _alpha(areaColors.secondary, palette.isDark ? 0.12 : 0.08),
        palette.isDark
            ? _alpha(const Color(0xFF0B1223), 0.36)
            : _alpha(Colors.white, 0.38),
      ],
    );

    final stageBorderColor = palette.isDark
        ? _alpha(const Color(0xFF94C5FF), 0.14)
        : _alpha(areaColors.primary, 0.16);

    final artworkBox = Container(
      decoration: BoxDecoration(
        gradient: stageGradient,
        border: Border(
          right: isVerticalLayout
              ? BorderSide.none
              : BorderSide(color: stageBorderColor),
          bottom: isVerticalLayout
              ? BorderSide(color: stageBorderColor)
              : BorderSide.none,
        ),
      ),
      padding: EdgeInsets.all(isVerticalLayout ? 16 : 10),
      child: CustomPaint(
        painter: _AreaArtworkPainter(
          areaId: area.id,
          primary: areaColors.primary,
          secondary: areaColors.secondary,
          accent: palette.accent,
          isDark: palette.isDark,
        ),
        child: const SizedBox.expand(),
      ),
    );

    final contentBox = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isVerticalLayout ? 20 : 14,
        vertical: isVerticalLayout ? 18 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bloque superior: Índice + % dominio + Título + Descripción
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      area.indexLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: areaColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$progressPercent% dominio',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  area.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isVerticalLayout ? 18.5 : 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: palette.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    area.description,
                    maxLines: isVerticalLayout ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isVerticalLayout ? 12.5 : 11.5,
                      height: 1.35,
                      color: palette.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Bloque inferior: Barra de dominio + CTA "Entrar a estudiar →"
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 6,
                  color: palette.isDark
                      ? _alpha(const Color(0xFF94C5FF), 0.14)
                      : _alpha(areaColors.primary, 0.14),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: (progressPercent / 100.0).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          colors: [areaColors.primary, areaColors.secondary],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Entrar a estudiar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: areaColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: areaColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette.cardGlassGradient,
                ),
                border: Border.all(
                  color: isSelected ? areaColors.primary : palette.glassBorder,
                  width: isSelected ? 1.8 : 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _alpha(
                      palette.isDark ? Colors.black : areaColors.primary,
                      palette.isDark ? 0.36 : 0.11,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  if (isVerticalLayout)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 52, child: artworkBox),
                        Expanded(flex: 48, child: contentBox),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: 118, child: artworkBox),
                        Expanded(child: contentBox),
                      ],
                    ),

                  // Arista superior cromática
                  Positioned(
                    top: 0,
                    left: 24,
                    right: 24,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            areaColors.primary,
                            areaColors.secondary,
                            Colors.transparent,
                          ],
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
    );
  }
}

/// ============================================================================
/// 4. ILUSTRACIONES GEOMÉTRICAS LOW-POLY NATIVAS (Sin assets externos)
/// ============================================================================

class _AreaArtworkPainter extends CustomPainter {
  final KadirAreaId areaId;
  final Color primary;
  final Color secondary;
  final Color accent;
  final bool isDark;

  const _AreaArtworkPainter({
    required this.areaId,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.5, size.height * 0.52);
    final unit = math.min(size.width, size.height) * 0.42;

    // Sombra suave base
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy + unit * 0.85),
        width: unit * 1.45,
        height: unit * 0.28,
      ),
      Paint()..color = _alpha(primary, isDark ? 0.22 : 0.14),
    );

    switch (areaId) {
      case KadirAreaId.logicoMatematico:
        _paintMathPolyhedron(canvas, c, unit);
        break;
      case KadirAreaId.comprensionLectora:
        _paintReadingBook(canvas, c, unit);
        break;
      case KadirAreaId.ciencias:
        _paintScienceFlask(canvas, c, unit);
        break;
    }
  }

  void _paintMathPolyhedron(Canvas canvas, Offset c, double u) {
    // Cuadrícula sutil y curva f(x)
    final gridPaint = Paint()
      ..color = _alpha(primary, isDark ? 0.22 : 0.16)
      ..strokeWidth = 1.0;
    for (int i = -2; i <= 2; i++) {
      final dy = c.dy + i * (u * 0.36);
      canvas.drawLine(Offset(c.dx - u * 1.05, dy), Offset(c.dx + u * 1.05, dy), gridPaint);
      final dx = c.dx + i * (u * 0.45);
      canvas.drawLine(Offset(dx, c.dy - u * 0.85), Offset(dx, c.dy + u * 0.85), gridPaint);
    }

    final curve = Path()
      ..moveTo(c.dx - u * 1.0, c.dy + u * 0.58)
      ..quadraticBezierTo(c.dx - u * 0.1, c.dy - u * 0.55, c.dx + u * 1.0, c.dy - u * 0.48);
    canvas.drawPath(
      curve,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = _alpha(accent, 0.85),
    );

    // Poliedro facetado central
    final poly = Path()
      ..moveTo(c.dx, c.dy - u * 0.78)
      ..lineTo(c.dx + u * 0.64, c.dy - u * 0.24)
      ..lineTo(c.dx + u * 0.46, c.dy + u * 0.54)
      ..lineTo(c.dx, c.dy + u * 0.72)
      ..lineTo(c.dx - u * 0.46, c.dy + u * 0.54)
      ..lineTo(c.dx - u * 0.64, c.dy - u * 0.24)
      ..close();

    canvas.drawPath(
      poly,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [secondary, primary],
        ).createShader(Rect.fromCircle(center: c, radius: u)),
    );

    // Aristas cristalinas
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = _alpha(Colors.white, 0.82);
    canvas.drawPath(poly, edgePaint);
    canvas.drawLine(Offset(c.dx, c.dy - u * 0.78), Offset(c.dx, c.dy + u * 0.72), edgePaint);
    canvas.drawLine(Offset(c.dx - u * 0.64, c.dy - u * 0.24), Offset(c.dx + u * 0.64, c.dy - u * 0.24), edgePaint);

    // Nodo acento
    canvas.drawCircle(Offset(c.dx + u * 0.78, c.dy - u * 0.38), u * 0.11, Paint()..color = accent);
  }

  void _paintReadingBook(Canvas canvas, Offset c, double u) {
    // Nodos flotantes de ideas conectadas
    final p1 = Offset(c.dx - u * 0.55, c.dy - u * 0.45);
    final p2 = Offset(c.dx, c.dy - u * 0.74);
    final p3 = Offset(c.dx + u * 0.55, c.dy - u * 0.45);
    final linkPaint = Paint()
      ..color = _alpha(accent, 0.72)
      ..strokeWidth = 1.6;
    canvas.drawLine(p1, p2, linkPaint);
    canvas.drawLine(p2, p3, linkPaint);

    for (final pt in [p1, p2, p3]) {
      final d = pt == p2 ? u * 0.17 : u * 0.12;
      final diamond = Path()
        ..moveTo(pt.dx, pt.dy - d)
        ..lineTo(pt.dx + d * 0.85, pt.dy)
        ..lineTo(pt.dx, pt.dy + d)
        ..lineTo(pt.dx - d * 0.85, pt.dy)
        ..close();
      canvas.drawPath(
        diamond,
        Paint()..color = pt == p2 ? accent : secondary,
      );
    }

    // Libro abierto isométrico
    final leftPage = Path()
      ..moveTo(c.dx, c.dy + u * 0.12)
      ..lineTo(c.dx - u * 0.86, c.dy - u * 0.08)
      ..lineTo(c.dx - u * 0.70, c.dy + u * 0.58)
      ..lineTo(c.dx, c.dy + u * 0.74)
      ..close();

    final rightPage = Path()
      ..moveTo(c.dx, c.dy + u * 0.12)
      ..lineTo(c.dx + u * 0.86, c.dy - u * 0.08)
      ..lineTo(c.dx + u * 0.70, c.dy + u * 0.58)
      ..lineTo(c.dx, c.dy + u * 0.74)
      ..close();

    canvas.drawPath(
      leftPage,
      Paint()..color = isDark ? const Color(0xFF1F2A44) : Colors.white,
    );
    canvas.drawPath(
      rightPage,
      Paint()..color = isDark ? const Color(0xFF283554) : const Color(0xFFF6F8FC),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = primary;
    canvas.drawPath(leftPage, borderPaint);
    canvas.drawPath(rightPage, borderPaint);

    // Marcador de lectura
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(c.dx + u * 0.05, c.dy + u * 0.68),
          width: u * 0.16,
          height: u * 0.34,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = accent,
    );
  }

  void _paintScienceFlask(Canvas canvas, Offset c, double u) {
    // Órbitas atómicas detrás del matraz
    for (final angle in [-0.45, 0.45]) {
      canvas.save();
      canvas.translate(c.dx, c.dy - u * 0.02);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: u * 1.95, height: u * 0.72),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = _alpha(primary, 0.55),
      );
      canvas.restore();
    }

    // Matraz Erlenmeyer
    final flask = Path()
      ..moveTo(c.dx - u * 0.22, c.dy - u * 0.74)
      ..lineTo(c.dx + u * 0.22, c.dy - u * 0.74)
      ..lineTo(c.dx + u * 0.22, c.dy - u * 0.28)
      ..lineTo(c.dx + u * 0.66, c.dy + u * 0.62)
      ..quadraticBezierTo(c.dx + u * 0.70, c.dy + u * 0.74, c.dx + u * 0.54, c.dy + u * 0.74)
      ..lineTo(c.dx - u * 0.54, c.dy + u * 0.74)
      ..quadraticBezierTo(c.dx - u * 0.70, c.dy + u * 0.74, c.dx - u * 0.66, c.dy + u * 0.62)
      ..lineTo(c.dx - u * 0.22, c.dy - u * 0.28)
      ..close();

    canvas.drawPath(
      flask,
      Paint()..color = isDark ? _alpha(Colors.white, 0.10) : _alpha(Colors.white, 0.78),
    );

    // Líquido energético dentro del matraz
    final liquid = Path()
      ..moveTo(c.dx - u * 0.34, c.dy + u * 0.06)
      ..lineTo(c.dx + u * 0.34, c.dy + u * 0.06)
      ..lineTo(c.dx + u * 0.60, c.dy + u * 0.62)
      ..quadraticBezierTo(c.dx + u * 0.62, c.dy + u * 0.70, c.dx + u * 0.50, c.dy + u * 0.70)
      ..lineTo(c.dx - u * 0.50, c.dy + u * 0.70)
      ..quadraticBezierTo(c.dx - u * 0.62, c.dy + u * 0.70, c.dx - u * 0.60, c.dy + u * 0.62)
      ..close();

    canvas.drawPath(
      liquid,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primary, secondary],
        ).createShader(Rect.fromCircle(center: c, radius: u)),
    );

    // Borde del matraz
    canvas.drawPath(
      flask,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = primary,
    );

    // Burbujas / partículas
    canvas.drawCircle(Offset(c.dx - u * 0.12, c.dy + u * 0.36), u * 0.08, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(c.dx + u * 0.16, c.dy + u * 0.46), u * 0.06, Paint()..color = accent);
    canvas.drawCircle(Offset(c.dx + u * 0.04, c.dy - u * 0.90), u * 0.07, Paint()..color = primary);
  }

  @override
  bool shouldRepaint(covariant _AreaArtworkPainter oldDelegate) {
    return oldDelegate.areaId != areaId ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.isDark != isDark;
  }
}

/// ============================================================================
/// 5. FONDO ATMOSFÉRICO Y BOTONES DE CABECERA EN CRISTAL
/// ============================================================================

class _ModesAmbientBackdrop extends StatelessWidget {
  final KadirPalette palette;

  const _ModesAmbientBackdrop({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -90,
          left: -70,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _alpha(palette.primary, palette.isDark ? 0.22 : 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -60,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _alpha(palette.secondary, palette.isDark ? 0.22 : 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModesGlassPill extends StatelessWidget {
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _ModesGlassPill({
    required this.onTap,
    required this.backgroundColor,
    required this.borderColor,
    required this.padding,
    required this.child,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}