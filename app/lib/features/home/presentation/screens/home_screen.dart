import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
export '../../../../core/theme/app_colors.dart' show KadirPaletteMode;

/// ============================================================================
/// 1. MODELOS DE TEMA Y MASCOTA (Sincronizados con Aurora / Órbita / Prisma)
/// ============================================================================


enum KadirMascotId { lumi, kitsune, yaka }

class KadirPalette {
  final String name;
  final bool isDark;
  final Color bgMain;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color textMain;
  final Color textMuted;
  final Color glassBorder;
  final List<Color> cardGlassGradient;
  final List<Color> primaryBtnGradient;
  final List<Color> secondaryBtnGradient;

  const KadirPalette({
    required this.name,
    required this.isDark,
    required this.bgMain,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.textMain,
    required this.textMuted,
    required this.glassBorder,
    required this.cardGlassGradient,
    required this.primaryBtnGradient,
    required this.secondaryBtnGradient,
  });

  static KadirPalette fromMode(KadirPaletteMode mode) {
    switch (mode) {
      case KadirPaletteMode.orbita:
        return const KadirPalette(
          name: 'Órbita',
          isDark: true,
          bgMain: Color(0xFF070B14),
          surface: Color(0xFF101726),
          primary: Color(0xFF49E0D3),
          secondary: Color(0xFFA88FFF),
          accent: Color(0xFFF6C453),
          textMain: Color(0xFFF5F9FF),
          textMuted: Color(0xFF8CA2C0),
          glassBorder: Color(0x4D49E0D3),
          cardGlassGradient: [
            Color(0xD9101A2E),
            Color(0xCC0D1426),
          ],
          primaryBtnGradient: [
            Color(0x4049E0D3),
            Color(0x40A88FFF),
          ],
          secondaryBtnGradient: [
            Color(0xCC101A2E),
            Color(0xBF141F36),
          ],
        );
      case KadirPaletteMode.prisma:
        return const KadirPalette(
          name: 'Prisma',
          isDark: false,
          bgMain: Color(0xFFFFF7F3),
          surface: Color(0xFFFFFFFF),
          primary: Color(0xFF9B325F),
          secondary: Color(0xFF6653CD),
          accent: Color(0xFFF6C453),
          textMain: Color(0xFF2B243E),
          textMuted: Color(0xFF716585),
          glassBorder: Color(0x479B325F),
          cardGlassGradient: [
            Color(0xE8FFFFFF),
            Color(0xDCFFF1EB),
          ],
          primaryBtnGradient: [
            Color(0xB8FFE0D6),
            Color(0xB8E9DFFF),
          ],
          secondaryBtnGradient: [
            Color(0xDEFFFFFF),
            Color(0xD4FFF3EE),
          ],
        );
      case KadirPaletteMode.aurora:
        return const KadirPalette(
          name: 'Aurora',
          isDark: false,
          bgMain: Color(0xFFF3FAFD),
          surface: Color(0xFFFFFFFF),
          primary: Color(0xFF047D8A),
          secondary: Color(0xFF6F56D9),
          accent: Color(0xFFF3B76B),
          textMain: Color(0xFF172638),
          textMuted: Color(0xFF5C6E82),
          glassBorder: Color(0x47047D8A),
          cardGlassGradient: [
            Color(0xE8FFFFFF),
            Color(0xDCEAF7FB),
          ],
          primaryBtnGradient: [
            Color(0xB5CCFBF1),
            Color(0xB5E9D5FF),
          ],
          secondaryBtnGradient: [
            Color(0xE0FFFFFF),
            Color(0xD6F0F9FF),
          ],
        );
    }
  }
}

Color _withOpacitySafe(Color color, double opacity) {
  final alpha = (opacity.clamp(0.0, 1.0) * 255).round();
  return color.withAlpha(alpha);
}

/// ============================================================================
/// 2. PANTALLA PRINCIPAL: HOME SCREEN (Sin desbordes ni errores de márgenes)
/// ============================================================================

class KadirHomeScreen extends StatefulWidget {
  final String userAlias;
  final int userLevel;
  final int currentXp;
  final int maxXp;
  final int streakDays;
  final String rankTitle;
  final String lastTopicCategory;
  final String lastTopicTitle;
  final KadirPaletteMode paletteMode;
  final KadirMascotId mascotId;

  final VoidCallback? onContinueLastTopic;
  final VoidCallback? onOpenModes;
  final VoidCallback? onOpenProgress;
  final VoidCallback? onOpenProfile;

  const KadirHomeScreen({
    super.key,
    this.userAlias = 'Estudiante Kadir',
    this.userLevel = 4,
    this.currentXp = 380,
    this.maxXp = 500,
    this.streakDays = 3,
    this.rankTitle = 'Guardián del Portal Óptico',
    this.lastTopicCategory = 'Último tema · Estrategia · Nivel 2',
    this.lastTopicTitle = 'Modelado de Sistemas',
    this.paletteMode = KadirPaletteMode.aurora,
    this.mascotId = KadirMascotId.lumi,
    this.onContinueLastTopic,
    this.onOpenModes,
    this.onOpenProgress,
    this.onOpenProfile,
  });

  @override
  State<KadirHomeScreen> createState() => _KadirHomeScreenState();
}

class _KadirHomeScreenState extends State<KadirHomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ambientCtrl;
  late final AnimationController _portalCtrl;
  String? _activeTransitionTarget; // 'practice' | 'modes'

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _portalCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1180),
    );
  }

  @override
  void dispose() {
    _ambientCtrl.dispose();
    _portalCtrl.dispose();
    super.dispose();
  }

  Future<void> _triggerPortalNavigation(String target) async {
    if (_activeTransitionTarget != null) return;
    setState(() => _activeTransitionTarget = target);

    _portalCtrl.reset();
    await _portalCtrl.forward();
    if (!mounted) return;

    if (target == 'practice') {
      widget.onContinueLastTopic?.call();
    } else {
      widget.onOpenModes?.call();
    }

    // Reinicia limpio al volver a Home
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;
      _portalCtrl.reset();
      setState(() => _activeTransitionTarget = null);
    }
  }

  String get _firstName {
    final trimmed = widget.userAlias.trim();
    if (trimmed.isEmpty) return 'Estudiante';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  String get _initials {
    final parts = widget.userAlias
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
    final palette = KadirPalette.fromMode(widget.paletteMode);
    final xpPercent = widget.maxXp > 0
        ? (widget.currentXp / widget.maxXp).clamp(0.0, 1.0)
        : 0.0;
    final activeDays = widget.streakDays.clamp(1, 7);

    return Scaffold(
      backgroundColor: palette.bgMain,
      body: Stack(
        children: [
          // Capa 0: Fondo atmosférico sincronizado con la paleta activa
          Positioned.fill(
            child: _KadirAmbientBackdrop(palette: palette),
          ),

          // Capa 1: Contenido protegido por SafeArea y LayoutBuilder (cero overflow)
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 780;
                final isCompactHeight = constraints.maxHeight < 660;
                final hPadding = isWide ? 32.0 : 18.0;
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
                        children: [
                          // 1. CABECERA LIMPIA (Logo + Hola, Nombre + Racha + Perfil)
                          _buildHeader(palette),

                          SizedBox(height: isCompactHeight ? 10 : 16),

                          // 2. CUERPO ADAPTATIVO (Sin desbordes en ningún tamaño)
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, bodyConstraints) {
                                final stageHeight = isWide
                                    ? bodyConstraints.maxHeight
                                        .clamp(280.0, 440.0)
                                    : (bodyConstraints.maxHeight * 0.42)
                                        .clamp(185.0, 290.0);

                                final stageWidget = _buildPortalMascotStage(
                                  palette: palette,
                                  height: stageHeight,
                                );

                                final panelWidget = _buildRightPanel(
                                  palette: palette,
                                  xpPercent: xpPercent,
                                  activeDays: activeDays,
                                  compact: isCompactHeight,
                                );

                                return SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: bodyConstraints.maxHeight,
                                    ),
                                    child: isWide
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 6,
                                                child: stageWidget,
                                              ),
                                              const SizedBox(width: 28),
                                              Expanded(
                                                flex: 6,
                                                child: panelWidget,
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              stageWidget,
                                              SizedBox(
                                                height:
                                                    isCompactHeight ? 12 : 18,
                                              ),
                                              panelWidget,
                                              const SizedBox(height: 6),
                                            ],
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

  /// CABECERA SUPERIOR (Versión final limpia)
  Widget _buildHeader(KadirPalette palette) {
    final pillBg = palette.isDark
        ? _withOpacitySafe(palette.surface, 0.78)
        : _withOpacitySafe(Colors.white, 0.82);

    return Row(
      children: [
        // Logo K + Saludo limpio
        Expanded(
          child: Row(
            children: [
              _KadirIsometricLogo(palette: palette, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hola, $_firstName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: palette.textMain,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Racha diaria
        _GlassTapPill(
          onTap: widget.onOpenProgress,
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
                '${widget.streakDays} días',
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

        // Botón Perfil (Iniciales)
        _GlassTapPill(
          onTap: widget.onOpenProfile,
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
    );
  }

  /// ESCENARIO DEL PORTAL VERTICAL MONUMENTAL + MASCOTA CON CAMINATA ALEGRE
  Widget _buildPortalMascotStage({
    required KadirPalette palette,
    required double height,
  }) {
    return GestureDetector(
      onTap: () => _triggerPortalNavigation('modes'),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: AnimatedBuilder(
          animation: Listenable.merge([_ambientCtrl, _portalCtrl]),
          builder: (context, _) {
            return CustomPaint(
              painter: _PortalAndMascotPainter(
                palette: palette,
                mascotId: widget.mascotId,
                ambientT: _ambientCtrl.value,
                walkT: _portalCtrl.value,
                isTransitioning: _activeTransitionTarget != null,
              ),
            );
          },
        ),
      ),
    );
  }

  /// COLUMNA DE PROGRESO + BOTONES DE ACCIÓN
  Widget _buildRightPanel({
    required KadirPalette palette,
    required double xpPercent,
    required int activeDays,
    required bool compact,
  }) {
    final isBusy = _activeTransitionTarget != null;
    final weekDays = const ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final pillBg = palette.isDark
        ? _withOpacitySafe(palette.surface, 0.80)
        : _withOpacitySafe(Colors.white, 0.84);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // A. TARJETA DE NIVEL, XP Y RITMO SEMANAL
        _GlassSurfaceCard(
          palette: palette,
          gradientColors: palette.cardGlassGradient,
          borderRadius: 24,
          padding: EdgeInsets.all(compact ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  // Emblema de Nivel
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: palette.glassBorder),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _withOpacitySafe(palette.primary, 0.18),
                          _withOpacitySafe(palette.secondary, 0.22),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 20,
                      color: palette.primary,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nivel + XP + Título
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Nivel ${widget.userLevel.toString().padLeft(2, '0')} · ${(xpPercent * 100).round()}%',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                  color: palette.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: pillBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: palette.glassBorder),
                              ),
                              child: Text(
                                '${widget.currentXp} / ${widget.maxXp} XP',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: palette.textMain,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.rankTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: palette.textMain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: compact ? 10 : 14),

              // Barra de XP
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 9,
                  color: palette.isDark
                      ? _withOpacitySafe(Colors.white, 0.08)
                      : _withOpacitySafe(palette.primary, 0.13),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: xpPercent,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          colors: [palette.primary, palette.secondary],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: compact ? 10 : 14),

              // Divisor + Ritmo Semanal (blindado contra overflow horizontal)
              Container(
                padding: EdgeInsets.only(top: compact ? 10 : 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: palette.isDark
                          ? _withOpacitySafe(Colors.white, 0.10)
                          : _withOpacitySafe(palette.primary, 0.16),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Ritmo semanal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: palette.textMuted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(weekDays.length, (i) {
                              final isDone = i < activeDays;
                              final isToday = i == activeDays - 1;
                              return Container(
                                width: 28,
                                height: 28,
                                margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: isDone
                                      ? LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            palette.primary,
                                            palette.secondary,
                                          ],
                                        )
                                      : null,
                                  color: isDone
                                      ? null
                                      : (palette.isDark
                                          ? _withOpacitySafe(Colors.white, 0.07)
                                          : _withOpacitySafe(
                                              palette.primary, 0.10)),
                                  border: isToday
                                      ? Border.all(
                                          color: palette.primary,
                                          width: 1.8,
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    weekDays[i],
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDone
                                          ? Colors.white
                                          : palette.textMuted,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: compact ? 10 : 12),

        // B. BOTÓN PRIMARIO: CONTINUAR CON EL ÚLTIMO TEMA
        Opacity(
          opacity: isBusy && _activeTransitionTarget != 'practice' ? 0.65 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: isBusy
                  ? null
                  : () => _triggerPortalNavigation('practice'),
              child: _GlassSurfaceCard(
                palette: palette,
                gradientColors: palette.primaryBtnGradient,
                borderRadius: 22,
                highlightBorder: _activeTransitionTarget == 'practice',
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 14 : 18,
                  vertical: compact ? 12 : 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: palette.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.lastTopicCategory.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.9,
                                    color: palette.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Continuar con',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: palette.isDark
                                      ? palette.textMain
                                      : palette.secondary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: palette.isDark
                                      ? _withOpacitySafe(palette.primary, 0.18)
                                      : _withOpacitySafe(Colors.white, 0.88),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color: _withOpacitySafe(
                                      palette.primary,
                                      palette.isDark ? 0.48 : 0.32,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '✦ ${widget.lastTopicTitle}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: palette.isDark
                                        ? Colors.white
                                        : palette.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: palette.glassBorder),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: palette.isDark
                            ? palette.primary
                            : palette.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: compact ? 8 : 10),

        // C. BOTÓN SECUNDARIO: MODOS DE APRENDIZAJE
        Opacity(
          opacity: isBusy && _activeTransitionTarget != 'modes' ? 0.65 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isBusy ? null : () => _triggerPortalNavigation('modes'),
              child: _GlassSurfaceCard(
                palette: palette,
                gradientColors: palette.secondaryBtnGradient,
                borderRadius: 20,
                highlightBorder: _activeTransitionTarget == 'modes',
                padding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: compact ? 13 : 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: 18,
                      color: palette.primary,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Modos de aprendizaje',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: palette.isDark
                              ? palette.textMain
                              : palette.secondary,
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
  }
}

/// ============================================================================
/// 3. COMPONENTES VISUALES DE CRISTAL Y FONDO ATMOSFÉRICO
/// ============================================================================

class _KadirAmbientBackdrop extends StatelessWidget {
  final KadirPalette palette;

  const _KadirAmbientBackdrop({required this.palette});

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
                  _withOpacitySafe(
                    palette.primary,
                    palette.isDark ? 0.24 : 0.18,
                  ),
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
                  _withOpacitySafe(
                    palette.secondary,
                    palette.isDark ? 0.22 : 0.16,
                  ),
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

class _GlassSurfaceCard extends StatelessWidget {
  final KadirPalette palette;
  final List<Color> gradientColors;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool highlightBorder;
  final Widget child;

  const _GlassSurfaceCard({
    required this.palette,
    required this.gradientColors,
    required this.borderRadius,
    required this.padding,
    required this.child,
    this.highlightBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            border: Border.all(
              color: highlightBorder ? palette.primary : palette.glassBorder,
              width: highlightBorder ? 1.8 : 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: _withOpacitySafe(
                  palette.isDark ? Colors.black : palette.primary,
                  palette.isDark ? 0.36 : 0.10,
                ),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Arista especular superior
              Positioned(
                top: 0,
                left: 24,
                right: 24,
                child: Container(
                  height: 1.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _withOpacitySafe(palette.primary, 0.7),
                        _withOpacitySafe(Colors.white, 0.9),
                        _withOpacitySafe(palette.secondary, 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassTapPill extends StatelessWidget {
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _GlassTapPill({
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

class _KadirIsometricLogo extends StatelessWidget {
  final KadirPalette palette;
  final double size;

  const _KadirIsometricLogo({required this.palette, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        color: palette.isDark
            ? _withOpacitySafe(palette.surface, 0.9)
            : Colors.white,
        border: Border.all(color: palette.glassBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _withOpacitySafe(palette.primary, 0.16),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [palette.primary, palette.secondary],
          ).createShader(bounds),
          child: Text(
            'K',
            style: TextStyle(
              fontSize: size * 0.54,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// 4. PORTAL VERTICAL MONUMENTAL + MASCOTA LOW-POLY CON CAMINATA ALEGRE
/// ============================================================================

class _PortalAndMascotPainter extends CustomPainter {
  final KadirPalette palette;
  final KadirMascotId mascotId;
  final double ambientT;
  final double walkT;
  final bool isTransitioning;

  const _PortalAndMascotPainter({
    required this.palette,
    required this.mascotId,
    required this.ambientT,
    required this.walkT,
    required this.isTransitioning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.52;
    final unit = math.min(size.width * 0.44, size.height * 0.46);

    final portalCenter = Offset(cx - unit * 0.48, cy - unit * 0.02);
    final portalW = unit * 0.86;
    final portalH = unit * 1.62;

    // 1. Anillos orbitales de fondo
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = _withOpacitySafe(palette.primary, palette.isDark ? 0.18 : 0.14);
    canvas.drawCircle(Offset(cx, cy), unit * 1.05, ringPaint);

    // 2. Portal Vertical Monumental (Arco monolítico + vórtice luminoso)
    _drawMonumentalPortal(canvas, portalCenter, portalW, portalH);

    // 3. Cálculo de pose de caminata alegre hacia el portal (cero estiramiento)
    final startX = cx + unit * 0.52;
    final targetX = portalCenter.dx + portalW * 0.06;
    final baseY = portalCenter.dy + portalH * 0.16;

    double mascotX = startX;
    double mascotY = baseY + math.sin(ambientT * math.pi * 2) * (unit * 0.045);
    double mascotScale = 1.0;
    double mascotOpacity = 1.0;
    double stridePhase = 0.0;
    bool excited = isTransitioning;

    if (isTransitioning) {
      if (walkT < 0.20) {
        // Fase 1: Salto breve de entusiasmo
        final p = walkT / 0.20;
        mascotY = baseY - math.sin(p * math.pi) * (unit * 0.11);
      } else if (walkT < 0.78) {
        // Fase 2: Caminata alegre con zancadas rítmicas hacia el portal
        final p = (walkT - 0.20) / 0.58;
        final eased = Curves.easeInOutCubic.transform(p);
        mascotX = lerpDouble(startX, targetX, eased)!;
        stridePhase = p * math.pi * 6;
        mascotY = baseY - (math.sin(stridePhase).abs() * (unit * 0.07));
        mascotScale = lerpDouble(1.0, 0.90, eased)!;
      } else {
        // Fase 3: Cruce limpio a través de la cortina de luz del portal
        final p = ((walkT - 0.78) / 0.22).clamp(0.0, 1.0);
        mascotX = lerpDouble(targetX, portalCenter.dx - portalW * 0.08, p)!;
        mascotY = baseY - unit * 0.03;
        mascotScale = lerpDouble(0.90, 0.68, p)!;
        mascotOpacity = (1.0 - p).clamp(0.0, 1.0);
      }
    }

    // 4. Dibuja la mascota activa
    if (mascotOpacity > 0.01) {
      canvas.save();
      canvas.translate(mascotX, mascotY);
      canvas.scale(mascotScale);
      _drawMascot(
        canvas,
        unit * 0.42,
        opacity: mascotOpacity,
        excited: excited,
        stridePhase: stridePhase,
      );
      canvas.restore();
    }

    // 5. Destello luminoso al cruzar el umbral
    if (isTransitioning && walkT >= 0.74) {
      final flashP = ((walkT - 0.74) / 0.26).clamp(0.0, 1.0);
      final flashIntensity = math.sin(flashP * math.pi);
      final flashPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            _withOpacitySafe(Colors.white, 0.85 * flashIntensity),
            _withOpacitySafe(palette.primary, 0.45 * flashIntensity),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: portalCenter, radius: portalH * 0.58),
        );
      canvas.drawCircle(portalCenter, portalH * 0.58, flashPaint);
    }
  }

  void _drawMonumentalPortal(
    Canvas canvas,
    Offset center,
    double w,
    double h,
  ) {
    final energyBoost = isTransitioning ? 1.0 + math.sin(walkT * math.pi) * 0.5 : 1.0;

    // Halo externo
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _withOpacitySafe(palette.primary, 0.30 * energyBoost),
          _withOpacitySafe(palette.secondary, 0.14 * energyBoost),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(center: center, width: w * 1.9, height: h * 1.35));
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 1.75, height: h * 1.22),
      haloPaint,
    );

    // Sombra / Pedestal base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + h * 0.49),
        width: w * 1.15,
        height: h * 0.085,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      baseRect,
      Paint()
        ..color = palette.isDark
            ? const Color(0xFF1A2540)
            : const Color(0xFF23324D),
    );

    // Marco monolítico vertical del portal
    final outerArch = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: h),
      Radius.circular(w * 0.48),
    );
    canvas.drawRRect(
      outerArch,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.isDark
              ? [const Color(0xFF1C2947), const Color(0xFF0E1629)]
              : [const Color(0xFF283A5C), const Color(0xFF19243B)],
        ).createShader(outerArch.outerRect),
    );

    // Borde energético interior
    final innerRect = Rect.fromCenter(
      center: center,
      width: w * 0.74,
      height: h * 0.84,
    );
    final innerArch = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(w * 0.37),
    );

    // Cortina de vórtice luminoso
    canvas.save();
    canvas.clipRRect(innerArch);

    canvas.drawRect(
      innerRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white,
            _withOpacitySafe(palette.primary, 0.85),
            _withOpacitySafe(palette.secondary, 0.78),
            palette.isDark ? const Color(0xFF091020) : const Color(0xFF172638),
          ],
          stops: const [0.0, 0.34, 0.72, 1.0],
        ).createShader(innerRect),
    );

    // Anillos concéntricos pulsantes dentro del portal
    for (int i = 0; i < 4; i++) {
      final phase = (ambientT + i * 0.25) % 1.0;
      final ringW = innerRect.width * (0.22 + phase * 0.88);
      final ringH = innerRect.height * (0.22 + phase * 0.88);
      final alpha = (1.0 - phase) * 0.55;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: ringW, height: ringH),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = _withOpacitySafe(Colors.white, alpha),
      );
    }

    canvas.restore();

    // Borde brillante del arco interno
    canvas.drawRRect(
      innerArch,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = _withOpacitySafe(palette.primary, 0.85),
    );

    // Gema superior del monolito
    final gemTop = Offset(center.dx, center.dy - h * 0.56);
    final gemSize = w * 0.12;
    final gemPath = Path()
      ..moveTo(gemTop.dx, gemTop.dy - gemSize)
      ..lineTo(gemTop.dx + gemSize * 0.75, gemTop.dy)
      ..lineTo(gemTop.dx, gemTop.dy + gemSize)
      ..lineTo(gemTop.dx - gemSize * 0.75, gemTop.dy)
      ..close();
    canvas.drawPath(
      gemPath,
      Paint()
        ..shader = LinearGradient(
          colors: [palette.accent, palette.primary, palette.secondary],
        ).createShader(Rect.fromCircle(center: gemTop, radius: gemSize)),
    );
  }

  void _drawMascot(
    Canvas canvas,
    double r, {
    required double opacity,
    required bool excited,
    required double stridePhase,
  }) {
    // Sombra bajo la mascota
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, r * 1.15),
        width: r * 1.35,
        height: r * 0.30,
      ),
      Paint()..color = _withOpacitySafe(palette.primary, 0.18 * opacity),
    );

    // Patitas animadas al caminar
    final leftStride = math.sin(stridePhase) * (r * 0.14);
    final rightStride = -leftStride;
    final footPaint = Paint()
      ..color = _withOpacitySafe(palette.secondary, 0.9 * opacity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(-r * 0.28 + leftStride, r * 0.92),
          width: r * 0.24,
          height: r * 0.22,
        ),
        Radius.circular(r * 0.1),
      ),
      footPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(r * 0.28 + rightStride, r * 0.92),
          width: r * 0.24,
          height: r * 0.22,
        ),
        Radius.circular(r * 0.1),
      ),
      footPaint,
    );

    // Cuerpo Low-Poly según mascota elegida
    Color bodyTop;
    Color bodyBottom;
    switch (mascotId) {
      case KadirMascotId.kitsune:
        bodyTop = const Color(0xFFFFB26B);
        bodyBottom = const Color(0xFFE96F3A);
        break;
      case KadirMascotId.yaka:
        bodyTop = const Color(0xFF475569);
        bodyBottom = const Color(0xFF1E293B);
        break;
      case KadirMascotId.lumi:
        bodyTop = Colors.white;
        bodyBottom = _withOpacitySafe(palette.secondary, 0.55);
        break;
    }

    final bodyPath = Path()
      ..moveTo(0, -r * 0.96)
      ..lineTo(r * 0.72, -r * 0.52)
      ..lineTo(r * 0.82, r * 0.48)
      ..lineTo(r * 0.34, r * 0.92)
      ..lineTo(-r * 0.34, r * 0.92)
      ..lineTo(-r * 0.82, r * 0.48)
      ..lineTo(-r * 0.72, -r * 0.52)
      ..close();

    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _withOpacitySafe(bodyTop, opacity),
            _withOpacitySafe(bodyBottom, opacity),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
    );

    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = _withOpacitySafe(palette.primary, 0.45 * opacity),
    );

    // Visor / Rostro
    final visorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, -r * 0.08),
        width: r * 1.05,
        height: r * 0.56,
      ),
      Radius.circular(r * 0.20),
    );
    canvas.drawRRect(
      visorRect,
      Paint()..color = _withOpacitySafe(const Color(0xFF101829), opacity),
    );

    // Ojos (alegres ^ ^ cuando camina hacia el portal, redondos brillantes en reposo)
    final eyePaint = Paint()
      ..color = _withOpacitySafe(palette.accent, opacity)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = excited ? PaintingStyle.stroke : PaintingStyle.fill;

    if (excited) {
      for (final dx in [-r * 0.24, r * 0.24]) {
        final arc = Path()
          ..moveTo(dx - r * 0.11, -r * 0.05)
          ..quadraticBezierTo(dx, -r * 0.22, dx + r * 0.11, -r * 0.05);
        canvas.drawPath(arc, eyePaint);
      }
    } else {
      canvas.drawCircle(Offset(-r * 0.24, -r * 0.08), r * 0.10, eyePaint);
      canvas.drawCircle(Offset(r * 0.24, -r * 0.08), r * 0.10, eyePaint);
    }

    // Aro orbital sutil alrededor de la mascota
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, r * 0.22),
        width: r * 2.15,
        height: r * 0.52,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = _withOpacitySafe(palette.primary, 0.72 * opacity),
    );
  }

  @override
  bool shouldRepaint(covariant _PortalAndMascotPainter oldDelegate) {
    return oldDelegate.ambientT != ambientT ||
        oldDelegate.walkT != walkT ||
        oldDelegate.isTransitioning != isTransitioning ||
        oldDelegate.palette.name != palette.name ||
        oldDelegate.mascotId != mascotId;
  }
}