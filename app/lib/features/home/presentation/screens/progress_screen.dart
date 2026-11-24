import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'modes_screen.dart';

/// ============================================================================
/// 1. MODELO DE ACORDEÓN GUARDADO
/// ============================================================================

class KadirSavedAccordion {
  final String id;
  final KadirAreaId area;
  final String topic;
  final String universe;
  final String formalDefinition;
  final String formulaOrRule;

  const KadirSavedAccordion({
    required this.id,
    required this.area,
    required this.topic,
    required this.universe,
    required this.formalDefinition,
    required this.formulaOrRule,
  });
}

Color _prAlpha(Color color, double opacity) {
  return color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

List<Color> _areaBarColors(KadirPaletteMode mode, KadirAreaId area) {
  switch (mode) {
    case KadirPaletteMode.orbita:
      switch (area) {
        case KadirAreaId.logicoMatematico:
          return const [Color(0xFF49E0D3), Color(0xFF38BDF8)];
        case KadirAreaId.comprensionLectora:
          return const [Color(0xFFA88FFF), Color(0xFFC4B5FD)];
        case KadirAreaId.ciencias:
          return const [Color(0xFF2DD4BF), Color(0xFF49E0D3)];
      }
    case KadirPaletteMode.prisma:
      switch (area) {
        case KadirAreaId.logicoMatematico:
          return const [Color(0xFF9B325F), Color(0xFF6653CD)];
        case KadirAreaId.comprensionLectora:
          return const [Color(0xFF6653CD), Color(0xFF9B325F)];
        case KadirAreaId.ciencias:
          return const [Color(0xFFB45309), Color(0xFF9B325F)];
      }
    case KadirPaletteMode.aurora:
      switch (area) {
        case KadirAreaId.logicoMatematico:
          return const [Color(0xFF047D8A), Color(0xFF0EA5E9)];
        case KadirAreaId.comprensionLectora:
          return const [Color(0xFF6F56D9), Color(0xFF047D8A)];
        case KadirAreaId.ciencias:
          return const [Color(0xFF0D9488), Color(0xFF6F56D9)];
      }
  }
}

/// ============================================================================
/// 2. PANTALLA: PROGRESO & BITÁCORA (Sin desbordes ni errores con teclado)
/// ============================================================================

class KadirProgressScreen extends StatefulWidget {
  final KadirPaletteMode paletteMode;
  final String userAlias;
  final int userLevel;
  final int currentXp;
  final int maxXp;
  final int streakDays;
  final Map<KadirAreaId, int> areaProgress;
  final List<String> initialReflections;
  final List<KadirSavedAccordion> savedAccordions;

    final ValueChanged<String>? onSaveReflection;
  final VoidCallback? onOpenSkills;
  final VoidCallback? onBackToHome;
  final VoidCallback? onOpenProfile;

  const KadirProgressScreen({
    super.key,
    this.paletteMode = KadirPaletteMode.orbita,
    this.userAlias = 'Estudiante Kadir',
    this.userLevel = 4,
    this.currentXp = 380,
    this.maxXp = 500,
    this.streakDays = 3,
    this.areaProgress = const {
      KadirAreaId.logicoMatematico: 64,
      KadirAreaId.comprensionLectora: 72,
      KadirAreaId.ciencias: 58,
    },
    this.initialReflections = const [],
    this.savedAccordions = const [],
    this.onSaveReflection,
    this.onOpenSkills,
    this.onBackToHome,
    this.onOpenProfile,
  });

  @override
  State<KadirProgressScreen> createState() => _KadirProgressScreenState();
}

class _KadirProgressScreenState extends State<KadirProgressScreen> {
  int _activeTab = 0; // 0 = Bitácora, 1 = Acordeones
  late List<String> _reflections;
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reflections = List<String>.from(widget.initialReflections);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
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

  void _handleSaveNote() {
    final text = _noteCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _reflections.insert(0, text);
      _noteCtrl.clear();
    });
    widget.onSaveReflection?.call(text);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final palette = KadirPalette.fromMode(widget.paletteMode);

    return Scaffold(
      backgroundColor: palette.bgMain,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(child: _ProgressBackdrop(palette: palette)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 820;
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

                          // 2. TÍTULO + SELECTOR BITÁCORA / ACORDEONES (Wrap seguro)
                          Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Progreso & Bitácora',
                                style: TextStyle(
                                  fontSize: isWide ? 26 : 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.35,
                                  color: palette.textMain,
                                ),
                              ),
                              _buildSegmentedTabs(palette),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // 3. CONTENIDO PRINCIPAL (2 columnas en tablet/PC, apilado seguro en móvil)
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, bodyConstraints) {
                                final leftCard = _buildAreaMasteryCard(palette);
                                final rightCard = _activeTab == 0
                                    ? _buildReflectionCard(palette)
                                    : _buildAccordionsCard(palette);

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
                                              Expanded(flex: 5, child: leftCard),
                                              const SizedBox(width: 20),
                                              Expanded(flex: 7, child: rightCard),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              leftCard,
                                              const SizedBox(height: 14),
                                              rightCard,
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
        ? _prAlpha(palette.surface, 0.78)
        : _prAlpha(Colors.white, 0.84);

    return Row(
      children: [
        Flexible(
          child: _ProgressPill(
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
            _ProgressPill(
              onTap: null,
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
            _ProgressPill(
              onTap: widget.onOpenProfile,
              bgColor: pillBg,
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

  Widget _buildSegmentedTabs(KadirPalette palette) {
    final pillBg = palette.isDark
        ? _prAlpha(palette.surface, 0.78)
        : _prAlpha(Colors.white, 0.84);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tabItem(
            palette: palette,
            label: 'Bitácora',
            active: _activeTab == 0,
            onTap: () => setState(() => _activeTab = 0),
          ),
          const SizedBox(width: 4),
          _tabItem(
            palette: palette,
            icon: Icons.bookmark_outline_rounded,
            label: 'Acordeones (${widget.savedAccordions.length})',
            active: _activeTab == 1,
            onTap: () => setState(() => _activeTab = 1),
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required KadirPalette palette,
    required String label,
    required bool active,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: active
              ? LinearGradient(colors: [palette.primary, palette.secondary])
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: active ? Colors.white : palette.textMain,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : palette.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TARJETA IZQUIERDA: DOMINIO POR ÁREA
  Widget _buildAreaMasteryCard(KadirPalette palette) {
    return _ProgressGlassCard(
      palette: palette,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dominio por área',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: palette.textMain,
                  ),
                ),
              ),
              Text(
                'Nivel ${widget.userLevel.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...KadirAreaInfo.all.map((area) {
            final pct = (widget.areaProgress[area.id] ?? 50).clamp(0, 100);
            final colors = _areaBarColors(widget.paletteMode, area.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          area.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: palette.textMain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$pct%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: colors.first,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 8,
                      color: palette.isDark
                          ? _prAlpha(const Color(0xFF94C5FF), 0.14)
                          : _prAlpha(colors.first, 0.14),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: pct / 100.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: LinearGradient(colors: colors),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.glassBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Racha activa · ${widget.streakDays} días',
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
                  '${widget.currentXp} / ${widget.maxXp} XP',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: palette.primary,
                  ),
                ),
                          if (widget.onOpenSkills != null) ...[
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onOpenSkills,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: palette.glassBorder, width: 1.2),
                    gradient: LinearGradient(
                      colors: palette.primaryBtnGradient,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.hub_rounded,
                        size: 18,
                        color: palette.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Explorar Mapa de Habilidades',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: palette.textMain,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 17,
                        color: palette.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// TARJETA DERECHA (TAB 0): BITÁCORA DE NOTAS RÁPIDAS
  Widget _buildReflectionCard(KadirPalette palette) {
    final inputBg = palette.isDark
        ? _prAlpha(palette.surface, 0.72)
        : _prAlpha(Colors.white, 0.85);

    return _ProgressGlassCard(
      palette: palette,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Nota rápida de aprendizaje',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: palette.textMain,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            minLines: 3,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: palette.textMain,
            ),
            decoration: InputDecoration(
              hintText: 'Escribe una idea clave que descubriste hoy...',
              hintStyle: TextStyle(
                fontSize: 12.5,
                color: _prAlpha(palette.textMuted, 0.8),
              ),
              filled: true,
              fillColor: inputBg,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: palette.glassBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: palette.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: palette.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: LinearGradient(
                  colors: [palette.primary, palette.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _prAlpha(palette.primary, 0.26),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleSaveNote,
                  borderRadius: BorderRadius.circular(13),
                  child: const Center(
                    child: Text(
                      'Guardar en mi bitácora',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_reflections.isNotEmpty) ...[
            const SizedBox(height: 14),
            ..._reflections.take(3).map(
                  (note) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: palette.glassBorder),
                    ),
                    child: Text(
                      '“$note”',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: palette.textMuted,
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  /// TARJETA DERECHA (TAB 1): ACORDEONES GUARDADOS
  Widget _buildAccordionsCard(KadirPalette palette) {
    final cardBg = palette.isDark
        ? _prAlpha(palette.surface, 0.72)
        : _prAlpha(Colors.white, 0.85);

    return _ProgressGlassCard(
      palette: palette,
      padding: const EdgeInsets.all(20),
      child: widget.savedAccordions.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 30,
                    color: palette.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Aún no guardas ningún Acordeón',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: palette.textMain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Completa una ruta en Analogía IA y toca “Guardar acordeón” en la Fase 4 para consultar aquí tus fórmulas clave.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: widget.savedAccordions.map((acc) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showAccordionDetail(palette, acc),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.glassBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  acc.topic,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: palette.textMain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                acc.universe,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: palette.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            acc.formulaOrRule,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: palette.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  void _showAccordionDetail(KadirPalette palette, KadirSavedAccordion acc) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                acc.universe.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: palette.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                acc.topic,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: palette.textMain,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                acc.formalDefinition,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: palette.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _prAlpha(palette.primary, 0.12),
                  border: Border.all(color: _prAlpha(palette.primary, 0.35)),
                ),
                child: Text(
                  acc.formulaOrRule,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: palette.textMain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// 3. TARJETA CRISTALINA, PILL Y FONDO COMPARTIDOS
/// ============================================================================

class _ProgressGlassCard extends StatelessWidget {
  final KadirPalette palette;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _ProgressGlassCard({
    required this.palette,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette.cardGlassGradient,
            ),
            border: Border.all(color: palette.glassBorder, width: 1.3),
            boxShadow: [
              BoxShadow(
                color: _prAlpha(
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
                  height: 1.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _prAlpha(palette.primary, 0.7),
                        _prAlpha(palette.secondary, 0.7),
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

class _ProgressPill extends StatelessWidget {
  final VoidCallback? onTap;
  final Color bgColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _ProgressPill({
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

class _ProgressBackdrop extends StatelessWidget {
  final KadirPalette palette;

  const _ProgressBackdrop({required this.palette});

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
                  _prAlpha(palette.primary, palette.isDark ? 0.22 : 0.16),
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
                  _prAlpha(palette.secondary, palette.isDark ? 0.20 : 0.15),
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