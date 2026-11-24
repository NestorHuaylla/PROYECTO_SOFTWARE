import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Reutiliza KadirPaletteMode, KadirPalette y KadirMascotId

/// ============================================================================
/// 1. CATÁLOGO DE MASCOTAS LOW-POLY Y UNIVERSOS FAVORITOS
/// ============================================================================

class KadirMascotMeta {
  final KadirMascotId id;
  final String name;
  final String species;
  final String tagline;

  const KadirMascotMeta({
    required this.id,
    required this.name,
    required this.species,
    required this.tagline,
  });

  static const List<KadirMascotMeta> all = [
    KadirMascotMeta(
      id: KadirMascotId.lumi,
      name: 'Lumi',
      species: 'Fantasma Low-Poly',
      tagline: 'Espíritu geométrico de luz y bruma.',
    ),
    KadirMascotMeta(
      id: KadirMascotId.kitsune,
      name: 'Kitsune',
      species: 'Zorrito Low-Poly',
      tagline: 'Astuto, ágil y cálido en tonos crema durazno.',
    ),
    KadirMascotMeta(
      id: KadirMascotId.yaka,
      name: 'Yaka',
      species: 'Carpintero Andino',
      tagline: 'Ave emblemática de los Andes en estilo low-poly.',
    ),
  ];

  static KadirMascotMeta byId(KadirMascotId id) {
    return all.firstWhere((m) => m.id == id, orElse: () => all.first);
  }
}

Color _pfAlpha(Color color, double opacity) {
  return color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

/// ============================================================================
/// 2. PANTALLA: MI PERFIL (Sin desbordes ni errores de márgenes)
/// ============================================================================

class KadirProfileScreen extends StatefulWidget {
  final KadirPaletteMode paletteMode;
  final KadirMascotId initialMascotId;
  final String initialUniverse;
  final String userAlias;
  final String userIdentifier;
  final int userLevel;
  final int streakDays;

  final ValueChanged<KadirMascotId>? onChangeMascot;
  final ValueChanged<String>? onChangeUniverse;
  final ValueChanged<KadirPaletteMode>? onChangePalette;
  final VoidCallback? onOpenThemeSelector;
  final VoidCallback? onLogout;
  final VoidCallback? onBackToHome;
  final VoidCallback? onOpenProgress;

  const KadirProfileScreen({
    super.key,
    this.paletteMode = KadirPaletteMode.aurora,
    this.initialMascotId = KadirMascotId.lumi,
    this.initialUniverse = 'Minecraft',
    this.userAlias = 'Estudiante Kadir',
    this.userIdentifier = '@explorador2026',
    this.userLevel = 4,
    this.streakDays = 3,
    this.onChangeMascot,
    this.onChangeUniverse,
    this.onChangePalette,
    this.onOpenThemeSelector,
    this.onLogout,
    this.onBackToHome,
    this.onOpenProgress,
  });

  @override
  State<KadirProfileScreen> createState() => _KadirProfileScreenState();
}

class _KadirProfileScreenState extends State<KadirProfileScreen> {
  static const List<String> _universes = [
    'Minecraft',
    'Left 4 Dead',
    'Naruto',
    'Fútbol',
    'Brawl Stars',
    'Dragon Ball',
  ];

  late KadirMascotId _mascotId;
  late String _favoriteUniverse;
  late KadirPaletteMode _paletteMode;

  @override
  void initState() {
    super.initState();
    _mascotId = widget.initialMascotId;
    _favoriteUniverse = widget.initialUniverse;
    _paletteMode = widget.paletteMode;
  }

  @override
  void didUpdateWidget(covariant KadirProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paletteMode != widget.paletteMode) {
      _paletteMode = widget.paletteMode;
    }
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

  String get _avatarLetter {
    final trimmed = widget.userAlias.trim();
    return trimmed.isEmpty ? 'E' : trimmed[0].toUpperCase();
  }

  void _selectMascot(KadirMascotId id) {
    setState(() => _mascotId = id);
    widget.onChangeMascot?.call(id);
  }

  void _selectUniverse(String u) {
    setState(() => _favoriteUniverse = u);
    widget.onChangeUniverse?.call(u);
  }

  void _handleAppearanceTap(KadirPalette palette) {
    if (widget.onOpenThemeSelector != null) {
      widget.onOpenThemeSelector!.call();
      return;
    }

    // Selector modal integrado si aún no conectas tu pantalla de Paletas
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Apariencia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: palette.textMain,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: KadirPaletteMode.values.map((m) {
                  final p = KadirPalette.fromMode(m);
                  final active = m == _paletteMode;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: m == KadirPaletteMode.aurora ? 0 : 8,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          setState(() => _paletteMode = m);
                          widget.onChangePalette?.call(m);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: p.bgMain,
                            border: Border.all(
                              color: active ? p.primary : p.glassBorder,
                              width: active ? 2.0 : 1.2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [p.primary, p.secondary],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                p.name,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: p.textMain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = KadirPalette.fromMode(_paletteMode);
    final activeMascot = KadirMascotMeta.byId(_mascotId);

    return Scaffold(
      backgroundColor: palette.bgMain,
      body: Stack(
        children: [
          Positioned.fill(child: _ProfileBackdrop(palette: palette)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 840;
                final hPadding = isWide ? 32.0 : 16.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hPadding,
                        vertical: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. CABECERA SUPERIOR UNIFICADA
                          _buildHeader(context, palette),
                          const SizedBox(height: 18),

                          // 2. TÍTULO LIMPIO + SUBTÍTULO (Wrap seguro)
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Mi Perfil',
                                style: TextStyle(
                                  fontSize: isWide ? 26 : 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.35,
                                  color: palette.textMain,
                                ),
                              ),
                              Text(
                                'Mascota compañera, universo ancla y preferencias de cuenta',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: palette.textMuted,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // 3. CONTENIDO PRINCIPAL (2 columnas en tablet/PC, vertical fluido en móvil)
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, bodyConstraints) {
                                final leftColumn = Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildUserCard(palette, activeMascot),
                                    const SizedBox(height: 12),
                                    _buildUniverseCard(palette),
                                    const SizedBox(height: 12),
                                    _buildAccountActionsCard(palette),
                                  ],
                                );

                                final rightColumn = _buildMascotSelectorCard(
                                  palette,
                                  activeMascot,
                                  isWide: isWide,
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
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 5,
                                                child: leftColumn,
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                flex: 7,
                                                child: rightColumn,
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              leftColumn,
                                              const SizedBox(height: 14),
                                              rightColumn,
                                              const SizedBox(height: 10),
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

  Widget _buildHeader(BuildContext context, KadirPalette palette) {
    final pillBg = palette.isDark
        ? _pfAlpha(palette.surface, 0.78)
        : _pfAlpha(Colors.white, 0.84);

    return Row(
      children: [
        Flexible(
          child: _ProfilePill(
            onTap: widget.onBackToHome ?? () => Navigator.maybePop(context),
            bgColor: pillBg,
            borderColor: palette.glassBorder,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded, size: 16, color: palette.textMain),
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ProfilePill(
              onTap: widget.onOpenProgress,
              bgColor: pillBg,
              borderColor: palette.glassBorder,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      size: 16, color: palette.accent),
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
            _ProfilePill(
              onTap: null,
              bgColor: pillBg,
              borderColor: palette.primary,
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

  /// TARJETA 1: IDENTIDAD DEL ESTUDIANTE + MASCOTA ACTIVA (Limpio sin sufijo de paleta)
  Widget _buildUserCard(KadirPalette palette, KadirMascotMeta activeMascot) {
    return _ProfileGlassCard(
      palette: palette,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [palette.primary, palette.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: _pfAlpha(palette.primary, 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _avatarLetter,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userAlias,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: palette.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.userIdentifier} · Nivel ${widget.userLevel.toString().padLeft(2, '0')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Mascota activa',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: palette.textMuted,
                ),
              ),
              Text(
                activeMascot.name,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: palette.textMain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// TARJETA 2: UNIVERSO FAVORITO
  Widget _buildUniverseCard(KadirPalette palette) {
    final pillBg = palette.isDark
        ? _pfAlpha(palette.surface, 0.72)
        : _pfAlpha(Colors.white, 0.82);

    return _ProfileGlassCard(
      palette: palette,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.explore_outlined, size: 17, color: palette.primary),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Universo favorito',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: palette.textMain,
                  ),
                ),
              ),
              Text(
                _favoriteUniverse,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: palette.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _universes.map((u) {
              final active =
                  u.toLowerCase() == _favoriteUniverse.toLowerCase();
              return GestureDetector(
                onTap: () => _selectUniverse(u),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    gradient: active
                        ? LinearGradient(
                            colors: [palette.primary, palette.secondary],
                          )
                        : null,
                    color: active ? null : pillBg,
                    border: Border.all(
                      color: active ? Colors.transparent : palette.glassBorder,
                    ),
                  ),
                  child: Text(
                    u,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : palette.textMain,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// TARJETA 3: ACCIONES DE CUENTA (Apariencia + Cerrar sesión)
  Widget _buildAccountActionsCard(KadirPalette palette) {
    final pillBg = palette.isDark
        ? _pfAlpha(palette.surface, 0.72)
        : _pfAlpha(Colors.white, 0.84);

    return _ProfileGlassCard(
      palette: palette,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _handleAppearanceTap(palette),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.glassBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [palette.primary, palette.secondary],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Apariencia',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: palette.textMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: widget.onLogout,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.glassBorder),
                  ),
                  child: Center(
                    child: Text(
                      'Cerrar sesión',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: palette.textMain,
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

  /// TARJETA DERECHA: SELECTOR DE MASCOTA COMPAÑERA (Lumi / Kitsune / Yaka)
  Widget _buildMascotSelectorCard(
    KadirPalette palette,
    KadirMascotMeta activeMascot, {
    required bool isWide,
  }) {
    return _ProfileGlassCard(
      palette: palette,
      padding: EdgeInsets.all(isWide ? 22 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mascota compañera',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: palette.textMain,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            activeMascot.tagline,
            style: TextStyle(
              fontSize: 12.5,
              color: palette.textMuted,
            ),
          ),
          const SizedBox(height: 16),

          // 3 Tarjetas de Mascotas Low-Poly (Adaptables sin overflow)
          Row(
            children: List.generate(KadirMascotMeta.all.length, (i) {
              final m = KadirMascotMeta.all[i];
              final selected = m.id == _mascotId;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _selectMascot(m.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: selected
                              ? _pfAlpha(
                                  palette.primary,
                                  palette.isDark ? 0.16 : 0.08,
                                )
                              : (palette.isDark
                                  ? _pfAlpha(palette.surface, 0.55)
                                  : _pfAlpha(Colors.white, 0.72)),
                          border: Border.all(
                            color: selected
                                ? palette.primary
                                : palette.glassBorder,
                            width: selected ? 1.8 : 1.1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            if (selected)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: palette.secondary,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: CustomPaint(
                                    painter: _MascotBadgePainter(
                                      mascotId: m.id,
                                      palette: palette,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  m.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: palette.textMain,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    m.species,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: palette.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.glassBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Guía en el portal · ${activeMascot.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: palette.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  activeMascot.species,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: palette.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// 3. AVATARES LOW-POLY NATIVOS (Lumi, Kitsune y Yaka sin imágenes externas)
/// ============================================================================

class _MascotBadgePainter extends CustomPainter {
  final KadirMascotId mascotId;
  final KadirPalette palette;

  const _MascotBadgePainter({
    required this.mascotId,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.5, size.height * 0.54);
    final r = size.width * 0.38;

    // Sombra suave
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.92),
        width: r * 1.35,
        height: r * 0.28,
      ),
      Paint()..color = _pfAlpha(palette.primary, 0.14),
    );

    if (mascotId == KadirMascotId.lumi) {
      // Lumi: Fantasma geométrico
      final body = Path()
        ..moveTo(c.dx, c.dy - r * 0.95)
        ..lineTo(c.dx + r * 0.70, c.dy - r * 0.45)
        ..lineTo(c.dx + r * 0.78, c.dy + r * 0.55)
        ..lineTo(c.dx + r * 0.25, c.dy + r * 0.85)
        ..lineTo(c.dx - r * 0.25, c.dy + r * 0.85)
        ..lineTo(c.dx - r * 0.78, c.dy + r * 0.55)
        ..lineTo(c.dx - r * 0.70, c.dy - r * 0.45)
        ..close();

      canvas.drawPath(
        body,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, _pfAlpha(palette.secondary, 0.45)],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
      canvas.drawPath(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = _pfAlpha(palette.primary, 0.45),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(c.dx, c.dy - r * 0.08),
            width: r * 0.96,
            height: r * 0.48,
          ),
          Radius.circular(r * 0.18),
        ),
        Paint()..color = const Color(0xFF101829),
      );
      canvas.drawCircle(
        Offset(c.dx - r * 0.22, c.dy - r * 0.08),
        r * 0.09,
        Paint()..color = palette.accent,
      );
      canvas.drawCircle(
        Offset(c.dx + r * 0.22, c.dy - r * 0.08),
        r * 0.09,
        Paint()..color = palette.accent,
      );
    } else if (mascotId == KadirMascotId.kitsune) {
      // Kitsune: Zorrito Low-Poly
      final leftEar = Path()
        ..moveTo(c.dx - r * 0.62, c.dy - r * 0.25)
        ..lineTo(c.dx - r * 0.74, c.dy - r * 0.96)
        ..lineTo(c.dx - r * 0.18, c.dy - r * 0.58)
        ..close();
      final rightEar = Path()
        ..moveTo(c.dx + r * 0.62, c.dy - r * 0.25)
        ..lineTo(c.dx + r * 0.74, c.dy - r * 0.96)
        ..lineTo(c.dx + r * 0.18, c.dy - r * 0.58)
        ..close();

      canvas.drawPath(leftEar, Paint()..color = const Color(0xFFE9723D));
      canvas.drawPath(rightEar, Paint()..color = const Color(0xFFE9723D));

      final head = Path()
        ..moveTo(c.dx, c.dy - r * 0.62)
        ..lineTo(c.dx + r * 0.78, c.dy - r * 0.10)
        ..lineTo(c.dx + r * 0.45, c.dy + r * 0.76)
        ..lineTo(c.dx, c.dy + r * 0.88)
        ..lineTo(c.dx - r * 0.45, c.dy + r * 0.76)
        ..lineTo(c.dx - r * 0.78, c.dy - r * 0.10)
        ..close();

      canvas.drawPath(
        head,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB26B), Color(0xFFE9723D)],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );

      // Mejillas crema
      final cheeks = Path()
        ..moveTo(c.dx, c.dy + r * 0.14)
        ..lineTo(c.dx + r * 0.62, c.dy + r * 0.14)
        ..lineTo(c.dx, c.dy + r * 0.84)
        ..lineTo(c.dx - r * 0.62, c.dy + r * 0.14)
        ..close();
      canvas.drawPath(cheeks, Paint()..color = const Color(0xFFFFF4EA));

      // Ojos + nariz
      final dark = Paint()..color = const Color(0xFF1F2937);
      canvas.drawCircle(Offset(c.dx - r * 0.28, c.dy + r * 0.02), r * 0.09, dark);
      canvas.drawCircle(Offset(c.dx + r * 0.28, c.dy + r * 0.02), r * 0.09, dark);
      canvas.drawCircle(Offset(c.dx, c.dy + r * 0.34), r * 0.08, dark);
    } else {
      // Yaka: Carpintero Andino Low-Poly
      final body = Path()
        ..moveTo(c.dx, c.dy - r * 0.78)
        ..lineTo(c.dx + r * 0.56, c.dy - r * 0.18)
        ..lineTo(c.dx + r * 0.52, c.dy + r * 0.78)
        ..lineTo(c.dx - r * 0.44, c.dy + r * 0.78)
        ..lineTo(c.dx - r * 0.54, c.dy - r * 0.18)
        ..close();
      canvas.drawPath(body, Paint()..color = const Color(0xFF334155));

      // Pecho crema andino
      final chest = Path()
        ..moveTo(c.dx - r * 0.30, c.dy + r * 0.04)
        ..lineTo(c.dx + r * 0.32, c.dy + r * 0.04)
        ..lineTo(c.dx + r * 0.30, c.dy + r * 0.74)
        ..lineTo(c.dx - r * 0.28, c.dy + r * 0.74)
        ..close();
      canvas.drawPath(chest, Paint()..color = const Color(0xFFF3E5C8));

      // Cresta carmesí andina
      final crest = Path()
        ..moveTo(c.dx - r * 0.24, c.dy - r * 0.62)
        ..lineTo(c.dx + r * 0.12, c.dy - r * 0.98)
        ..lineTo(c.dx + r * 0.30, c.dy - r * 0.55)
        ..close();
      canvas.drawPath(crest, Paint()..color = const Color(0xFFB91C1C));

      // Pico geométrico
      final beak = Path()
        ..moveTo(c.dx - r * 0.44, c.dy - r * 0.36)
        ..lineTo(c.dx - r * 0.96, c.dy - r * 0.26)
        ..lineTo(c.dx - r * 0.44, c.dy - r * 0.14)
        ..close();
      canvas.drawPath(beak, Paint()..color = const Color(0xFFD97706));

      // Ojo
      canvas.drawCircle(
        Offset(c.dx - r * 0.14, c.dy - r * 0.32),
        r * 0.09,
        Paint()..color = const Color(0xFFF6C453),
      );
      canvas.drawCircle(
        Offset(c.dx - r * 0.14, c.dy - r * 0.32),
        r * 0.045,
        Paint()..color = const Color(0xFF0F172A),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MascotBadgePainter oldDelegate) {
    return oldDelegate.mascotId != mascotId ||
        oldDelegate.palette.name != palette.name;
  }
}

/// ============================================================================
/// 4. TARJETA CRISTALINA, PILL Y FONDO COMPARTIDOS
/// ============================================================================

class _ProfileGlassCard extends StatelessWidget {
  final KadirPalette palette;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _ProfileGlassCard({
    required this.palette,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette.cardGlassGradient,
            ),
            border: Border.all(color: palette.glassBorder, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: _pfAlpha(
                  palette.isDark ? Colors.black : palette.primary,
                  palette.isDark ? 0.34 : 0.10,
                ),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
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
                        _pfAlpha(palette.primary, 0.7),
                        _pfAlpha(palette.secondary, 0.7),
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

class _ProfilePill extends StatelessWidget {
  final VoidCallback? onTap;
  final Color bgColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _ProfilePill({
    required this.onTap,
    required this.bgColor,
    required this.borderColor,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
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
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ProfileBackdrop extends StatelessWidget {
  final KadirPalette palette;

  const _ProfileBackdrop({required this.palette});

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
                  _pfAlpha(palette.primary, palette.isDark ? 0.22 : 0.16),
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
                  _pfAlpha(palette.secondary, palette.isDark ? 0.20 : 0.15),
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