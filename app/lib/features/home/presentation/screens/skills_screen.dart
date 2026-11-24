import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Reutiliza KadirPaletteMode y KadirPalette

/// ============================================================================
/// 1. MODELO DE NODO DE HABILIDAD
/// ============================================================================

class KadirSkillNode {
  final String id;
  final String title;
  final String category;
  final String description;
  final List<String> relations;
  final int level;
  final bool explored;
  final double x; // 0.0 .. 1.0 dentro del lienzo del grafo
  final double y; // 0.0 .. 1.0 dentro del lienzo del grafo

  const KadirSkillNode({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.relations,
    required this.level,
    required this.explored,
    required this.x,
    required this.y,
  });

  KadirSkillNode copyWith({bool? explored}) {
    return KadirSkillNode(
      id: id,
      title: title,
      category: category,
      description: description,
      relations: relations,
      level: level,
      explored: explored ?? this.explored,
      x: x,
      y: y,
    );
  }

  static const List<KadirSkillNode> defaults = [
    KadirSkillNode(
      id: 's1',
      title: 'Observación Empírica',
      category: 'Capacidad · Nivel 1',
      description:
          'Aísla variables clave sin sesgos previos y registra patrones con claridad.',
      relations: ['s2', 's3'],
      level: 1,
      explored: true,
      x: 0.24,
      y: 0.26,
    ),
    KadirSkillNode(
      id: 's2',
      title: 'Modelado de Sistemas',
      category: 'Estrategia · Nivel 2',
      description:
          'Transforma ideas complejas en esquemas visuales y relaciones causales simples.',
      relations: ['s1', 's4'],
      level: 2,
      explored: false,
      x: 0.76,
      y: 0.26,
    ),
    KadirSkillNode(
      id: 's3',
      title: 'Inferencia Causal',
      category: 'Modo · Nivel 3',
      description:
          'Distingue entre coincidencia y causa real mediante pruebas controladas.',
      relations: ['s1', 's4'],
      level: 3,
      explored: false,
      x: 0.26,
      y: 0.74,
    ),
    KadirSkillNode(
      id: 's4',
      title: 'Síntesis Sistémica',
      category: 'Ritmo · Nivel 4',
      description:
          'Conecta múltiples disciplinas para resolver problemas a tu propio ritmo.',
      relations: ['s2', 's3'],
      level: 4,
      explored: false,
      x: 0.74,
      y: 0.74,
    ),
  ];
}

Color _sAlpha(Color color, double opacity) {
  return color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}

/// ============================================================================
/// 2. PANTALLA: MAPA DE HABILIDADES (Sin desbordes ni recortes)
/// ============================================================================

class KadirSkillsScreen extends StatefulWidget {
  final KadirPaletteMode paletteMode;
  final String userAlias;
  final int streakDays;
  final List<KadirSkillNode>? initialSkills;

  final ValueChanged<KadirSkillNode>? onSkillExplored;
  final ValueChanged<KadirSkillNode>? onOpenPractice;
  final VoidCallback? onBackToHome;
  final VoidCallback? onOpenProgress;
  final VoidCallback? onOpenProfile;

  const KadirSkillsScreen({
    super.key,
    this.paletteMode = KadirPaletteMode.aurora,
    this.userAlias = 'Estudiante Kadir',
    this.streakDays = 3,
    this.initialSkills,
    this.onSkillExplored,
    this.onOpenPractice,
    this.onBackToHome,
    this.onOpenProgress,
    this.onOpenProfile,
  });

  @override
  State<KadirSkillsScreen> createState() => _KadirSkillsScreenState();
}

class _KadirSkillsScreenState extends State<KadirSkillsScreen> {
  late List<KadirSkillNode> _skills;
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _skills = List<KadirSkillNode>.from(
      widget.initialSkills ?? KadirSkillNode.defaults,
    );
    _selectedId = _skills.length > 1 ? _skills[1].id : _skills.first.id;
  }

  KadirSkillNode get _selectedSkill => _skills.firstWhere(
        (s) => s.id == _selectedId,
        orElse: () => _skills.first,
      );

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

  void _markSelectedExplored() {
    final idx = _skills.indexWhere((s) => s.id == _selectedId);
    if (idx == -1) return;
    if (_skills[idx].explored) return;

    final updated = _skills[idx].copyWith(explored: true);
    setState(() {
      _skills[idx] = updated;
    });
    widget.onSkillExplored?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    final palette = KadirPalette.fromMode(widget.paletteMode);
    final selected = _selectedSkill;

    return Scaffold(
      backgroundColor: palette.bgMain,
      body: Stack(
        children: [
          Positioned.fill(child: _SkillsBackdrop(palette: palette)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 820;
                final isCompactHeight = constraints.maxHeight < 650;
                final hPadding = isWide ? 32.0 : 16.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hPadding,
                        vertical: isCompactHeight ? 10 : 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. CABECERA SUPERIOR UNIFICADA
                          _buildHeader(context, palette),

                          SizedBox(height: isCompactHeight ? 14 : 22),

                          // 2. TÍTULO LIMPIO
                          Text(
                            'Mapa de Habilidades',
                            style: TextStyle(
                              fontSize: isWide ? 26 : 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.35,
                              color: palette.textMain,
                            ),
                          ),

                          SizedBox(height: isCompactHeight ? 12 : 18),

                          // 3. GRAFO + TARJETA DE DETALLE (Adaptativo sin overflow)
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, bodyConstraints) {
                                final graphHeight = isWide
                                    ? bodyConstraints.maxHeight
                                        .clamp(300.0, 380.0)
                                    : (bodyConstraints.maxHeight * 0.44)
                                        .clamp(210.0, 270.0);

                                final graphCard = SizedBox(
                                  height: graphHeight,
                                  child: _buildSkillGraphCard(palette, selected),
                                );

                                final detailCard = _buildSkillDetailCard(
                                  palette,
                                  selected,
                                  minHeight: isWide ? graphHeight : null,
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
                                                flex: 7,
                                                child: graphCard,
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                flex: 5,
                                                child: detailCard,
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              graphCard,
                                              const SizedBox(height: 14),
                                              detailCard,
                                              const SizedBox(height: 8),
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
        ? _sAlpha(palette.surface, 0.78)
        : _sAlpha(Colors.white, 0.84);

    return Row(
      children: [
        Flexible(
          child: _SkillsGlassPill(
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
            _SkillsGlassPill(
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
            _SkillsGlassPill(
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

  /// LIENZO DEL GRAFO DE NODOS (Sin recortes en pantallas angostas)
  Widget _buildSkillGraphCard(KadirPalette palette, KadirSkillNode selected) {
    return _SkillsGlassCard(
      palette: palette,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, box) {
          // Zona segura interna para que las etiquetas nunca toquen los bordes
          const padX = 56.0;
          const padY = 34.0;
          final usableW = (box.maxWidth - padX * 2).clamp(40.0, double.infinity);
          final usableH = (box.maxHeight - padY * 2).clamp(40.0, double.infinity);

          Offset nodeCenter(KadirSkillNode n) {
            return Offset(padX + n.x * usableW, padY + n.y * usableH);
          }

          return Stack(
            children: [
              // Conexiones entre nodos
              Positioned.fill(
                child: CustomPaint(
                  painter: _SkillEdgesPainter(
                    skills: _skills,
                    selectedId: selected.id,
                    palette: palette,
                    centerResolver: nodeCenter,
                  ),
                ),
              ),

              // Nodos interactivos centrados sobre sus coordenadas exactas
              ..._skills.map((node) {
                final isSelected = node.id == selected.id;
                final center = nodeCenter(node);
                final shortWord = node.title.split(' ').first;

                final bgColor = isSelected
                    ? palette.primary
                    : (node.explored
                        ? palette.secondary
                        : (palette.isDark
                            ? _sAlpha(palette.surface, 0.92)
                            : _sAlpha(Colors.white, 0.92)));
                final fgColor = (isSelected || node.explored)
                    ? Colors.white
                    : palette.textMain;

                return Positioned(
                  left: center.dx,
                  top: center.dy,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      scale: isSelected ? 1.07 : 1.0,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _selectedId = node.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : palette.glassBorder,
                                width: isSelected ? 1.8 : 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _sAlpha(
                                    isSelected
                                        ? palette.primary
                                        : Colors.black,
                                    isSelected ? 0.28 : 0.10,
                                  ),
                                  blurRadius: isSelected ? 14 : 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  node.explored ? '✓' : 'N${node.level}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: fgColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  shortWord,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: fgColor,
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
              }),
            ],
          );
        },
      ),
    );
  }

  /// TARJETA DE DETALLE DEL NODO SELECCIONADO
  Widget _buildSkillDetailCard(
    KadirPalette palette,
    KadirSkillNode selected, {
    double? minHeight,
  }) {
    final pillBg = palette.isDark
        ? _sAlpha(palette.surface, 0.78)
        : _sAlpha(Colors.white, 0.84);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      child: _SkillsGlassCard(
        palette: palette,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selected.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                          color: palette.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selected.explored ? '✓ Completado' : 'En curso',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: selected.explored
                            ? const Color(0xFF0D9488)
                            : palette.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  selected.title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: palette.textMain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selected.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Botones de acción separados por línea sutil
            Container(
              padding: const EdgeInsets.only(top: 14),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: palette.glassBorder),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _markSelectedExplored,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: palette.glassBorder),
                        ),
                        child: Center(
                          child: Text(
                            selected.explored
                                ? 'Nodo dominado ✓'
                                : 'Marcar explorado',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: palette.textMain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [palette.primary, palette.secondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _sAlpha(palette.primary, 0.26),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => widget.onOpenPractice?.call(selected),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          child: Center(
                            child: Text(
                              'Ir a Práctica →',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// 3. PINTOR DE CONEXIONES DEL GRAFO (Líneas sólidas activas y punteadas)
/// ============================================================================

class _SkillEdgesPainter extends CustomPainter {
  final List<KadirSkillNode> skills;
  final String selectedId;
  final KadirPalette palette;
  final Offset Function(KadirSkillNode) centerResolver;

  const _SkillEdgesPainter({
    required this.skills,
    required this.selectedId,
    required this.palette,
    required this.centerResolver,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final drawnPairs = <String>{};

    for (final source in skills) {
      for (final targetId in source.relations) {
        final key = source.id.compareTo(targetId) < 0
            ? '${source.id}-$targetId'
            : '$targetId-${source.id}';
        if (drawnPairs.contains(key)) continue;
        drawnPairs.add(key);

        final targetIdx = skills.indexWhere((s) => s.id == targetId);
        if (targetIdx == -1) continue;
        final target = skills[targetIdx];

        final p1 = centerResolver(source);
        final p2 = centerResolver(target);
        final active = source.id == selectedId || target.id == selectedId;

        if (active) {
          canvas.drawLine(
            p1,
            p2,
            Paint()
              ..color = _sAlpha(palette.primary, 0.82)
              ..strokeWidth = 2.4
              ..strokeCap = StrokeCap.round,
          );
        } else {
          _drawDashedLine(
            canvas,
            p1,
            p2,
            Paint()
              ..color = _sAlpha(palette.textMuted, 0.34)
              ..strokeWidth = 1.4
              ..strokeCap = StrokeCap.round,
          );
        }
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashLen = 6.0;
    const gapLen = 5.0;
    final total = (p2 - p1).distance;
    if (total <= 0) return;
    final dir = (p2 - p1) / total;
    double dist = 0;
    while (dist < total) {
      final end = (dist + dashLen).clamp(0.0, total);
      canvas.drawLine(p1 + dir * dist, p1 + dir * end, paint);
      dist += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(covariant _SkillEdgesPainter oldDelegate) {
    return oldDelegate.selectedId != selectedId ||
        oldDelegate.palette.name != palette.name ||
        oldDelegate.skills != skills;
  }
}

/// ============================================================================
/// 4. TARJETA CRISTALINA, PILL Y FONDO COMPARTIDOS
/// ============================================================================

class _SkillsGlassCard extends StatelessWidget {
  final KadirPalette palette;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _SkillsGlassCard({
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
                color: _sAlpha(
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
                        _sAlpha(palette.primary, 0.7),
                        _sAlpha(palette.secondary, 0.7),
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

class _SkillsGlassPill extends StatelessWidget {
  final VoidCallback? onTap;
  final Color bgColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _SkillsGlassPill({
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

class _SkillsBackdrop extends StatelessWidget {
  final KadirPalette palette;

  const _SkillsBackdrop({required this.palette});

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
                  _sAlpha(palette.primary, palette.isDark ? 0.22 : 0.16),
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
                  _sAlpha(palette.secondary, palette.isDark ? 0.20 : 0.15),
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