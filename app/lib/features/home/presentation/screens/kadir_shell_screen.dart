import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../auth/data/auth_service.dart';
import '../../../settings/presentation/screens/theme_customization_screen.dart';
import '../../../welcome/presentation/screens/welcome_screen.dart';
import 'home_screen.dart';
import 'modes_screen.dart';
import 'practice_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'skills_screen.dart';

enum _KadirSubView {
  home,
  modes,
  practice,
  progress,
  skills,
  profile,
}

class KadirShellScreen extends StatefulWidget {
  final KadirPaletteMode initialPalette;

  const KadirShellScreen({
    super.key,
    this.initialPalette = KadirPaletteMode.orbita,
  });

  @override
  State<KadirShellScreen> createState() => _KadirShellScreenState();
}

class _KadirShellScreenState extends State<KadirShellScreen> {
  final List<_KadirSubView> _navStack = <_KadirSubView>[_KadirSubView.home];

  late KadirPaletteMode _paletteMode;
  KadirMascotId _mascotId = KadirMascotId.lumi;
  String _favoriteUniverse = 'Minecraft';

  // Datos reales hidratados desde PostgreSQL (vía AuthService)
  String _userAlias = 'Estudiante Kadir';
  String _userIdentifier = '@estudiante';
  int _userLevel = 1;
  String _rankTitle = 'Guardián del Portal Óptico';
  int _currentXp = 0;
  int _streakDays = 1;

  // Estado académico compartido entre las 6 pantallas
  KadirAreaId _selectedArea = KadirAreaId.logicoMatematico;
  String _lastTopicCategory = 'Último tema · Lógico Matemático · Unidad 01';
  String _lastTopicTitle = 'Fracciones y proporciones';

  final Map<KadirAreaId, int> _areaProgress = <KadirAreaId, int>{
    KadirAreaId.logicoMatematico: 25,
    KadirAreaId.comprensionLectora: 25,
    KadirAreaId.ciencias: 25,
  };

  final Set<String> _completedTopicIds = <String>{};
  final List<KadirSavedAccordion> _savedAccordions = <KadirSavedAccordion>[];
  final List<String> _reflections = <String>[];
  final List<KadirSkillNode> _skills = List<KadirSkillNode>.from(
    KadirSkillNode.defaults,
  );

  _KadirSubView get _currentView => _navStack.last;
  int get _maxXp => (_userLevel * 200).clamp(200, 999999);

  @override
  void initState() {
    super.initState();
    _paletteMode = widget.initialPalette;
    _hydrateUser(AuthService.currentUser);
    _refreshProfileFromBackend();
  }

  Future<void> _refreshProfileFromBackend() async {
    try {
      final fresh = await AuthService().fetchMe();
      if (!mounted || fresh == null) return;
      setState(() => _hydrateUser(fresh));
    } catch (_) {
      // Mantiene los datos cacheados del login si hay microcorte de red
    }
  }

  void _hydrateUser(Map<String, dynamic>? user) {
    if (user == null) return;

    final alias = (user['alias'] as String?)?.trim();
    if (alias != null && alias.isNotEmpty) {
      _userAlias = alias;
    }

    final identificador = (user['identificador'] as String?)?.trim();
    if (identificador != null && identificador.isNotEmpty) {
      _userIdentifier = identificador.startsWith('@')
          ? identificador
          : '@$identificador';
    }

    final perfil = user['perfil'];
    if (perfil is Map<String, dynamic>) {
      final puntos = perfil['puntos_totales'];
      if (puntos is int) _currentXp = puntos;

      final racha = perfil['racha_actual_dias'];
      if (racha is int && racha > 0) _streakDays = racha;

      final intereses = (perfil['intereses_analogias'] as String?)?.trim();
      if (intereses != null && intereses.isNotEmpty) {
        _favoriteUniverse = intereses;
      }

      final nivel = perfil['nivel'];
      if (nivel is Map<String, dynamic>) {
        final numero = nivel['numero'];
        if (numero is int && numero > 0) _userLevel = numero;

        final rango = (nivel['nombre_rango'] as String?)?.trim();
        if (rango != null && rango.isNotEmpty) _rankTitle = rango;
      }
    }
  }

  void _navigateTo(_KadirSubView target) {
  if (_currentView == target) return;
  HapticFeedback.selectionClick();
  setState(() {
    _navStack.remove(target);
    _navStack.add(target);
  });
}

  void _goBack() {
    if (_navStack.length <= 1) return;
    setState(() => _navStack.removeLast());
  }

  void _goHome() {
    setState(() {
      _navStack
        ..clear()
        ..add(_KadirSubView.home);
    });
  }

  String _areaLabel(KadirAreaId area) {
    switch (area) {
      case KadirAreaId.logicoMatematico:
        return 'Lógico Matemático';
      case KadirAreaId.comprensionLectora:
        return 'Comprensión Lectora';
      case KadirAreaId.ciencias:
        return 'Ciencias';
    }
  }

  void _handleSelectArea(KadirAreaId area) {
    final syllabus = getKadirSyllabus(area);
    final nextTopic = syllabus.firstWhere(
      (t) => !_completedTopicIds.contains(t.id),
      orElse: () => syllabus.first,
    );

    setState(() {
      _selectedArea = area;
      _lastTopicCategory =
          'Último tema · ${_areaLabel(area)} · Unidad ${nextTopic.unitNumber}';
      _lastTopicTitle = nextTopic.title;
    });
    _navigateTo(_KadirSubView.practice);
  }

  void _handleTopicCompleted(String topicId) {
    if (_completedTopicIds.contains(topicId)) return;

    setState(() {
      _completedTopicIds.add(topicId);
      _currentXp += 50;
      if (_currentXp >= _maxXp) {
        _userLevel += 1;
      }

      final syllabus = getKadirSyllabus(_selectedArea);
      final doneCount =
          syllabus.where((t) => _completedTopicIds.contains(t.id)).length;
      final pct = ((doneCount / syllabus.length) * 100).round().clamp(25, 100);
      _areaProgress[_selectedArea] = pct;

      final completedTopic = syllabus.where((t) => t.id == topicId).firstOrNull;
      if (completedTopic != null) {
        _lastTopicCategory =
            'Completado · ${_areaLabel(_selectedArea)} · Unidad ${completedTopic.unitNumber}';
        _lastTopicTitle = completedTopic.title;
      }
    });
  }

  void _handleSaveAccordion(KadirAnalogyRoute route) {
    final id = '${_selectedArea.name}_${route.topic}_${route.universe}';
    final item = KadirSavedAccordion(
      id: id,
      area: _selectedArea,
      topic: route.topic,
      universe: route.universe,
      formalDefinition: route.formalDefinition,
      formulaOrRule: route.formulaOrRule,
    );

    setState(() {
      _savedAccordions.removeWhere((a) => a.id == id);
      _savedAccordions.insert(0, item);
    });
  }

  void _handleSaveReflection(String note) {
    final clean = note.trim();
    if (clean.isEmpty) return;
    setState(() => _reflections.insert(0, clean));
  }

  void _handleSkillExplored(KadirSkillNode updated) {
    setState(() {
      final idx = _skills.indexWhere((s) => s.id == updated.id);
      if (idx != -1) {
        _skills[idx] = updated;
      }
      _currentXp += 25;
      if (_currentXp >= _maxXp) {
        _userLevel += 1;
      }
    });
  }

  void _handleOpenPracticeFromSkill(KadirSkillNode skill) {
    setState(() {
      _lastTopicCategory = 'Habilidad · ${skill.category}';
      _lastTopicTitle = skill.title;
    });
    _navigateTo(_KadirSubView.practice);
  }

  void _handleOpenThemeSelector() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => ThemeCustomizationScreen(
          initialMode: _paletteMode,
          onThemeChanged: (mode) => setState(() => _paletteMode = mode),
          onConfirm: () => Navigator.of(routeContext).pop(),
          onBack: () => Navigator.of(routeContext).pop(),
        ),
      ),
    );
  }

  void _handleLogout() {
    AuthService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => WelcomeScreen(initialPalette: _paletteMode),
      ),
      (route) => false,
    );
  }

  @override
Widget build(BuildContext context) {
  final isDark = _paletteMode == KadirPaletteMode.orbita;
  final iconBrightness = isDark ? Brightness.light : Brightness.dark;

  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: iconBrightness,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: iconBrightness,
    ),
    child: PopScope(
      canPop: _navStack.length <= 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _navStack.length > 1) {
          _goBack();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _buildActiveScreen(),
      ),
    ),
  );
}
  Widget _buildActiveScreen() {
    switch (_currentView) {
      case _KadirSubView.home:
        return KadirHomeScreen(
          key: const ValueKey('kadir_sub_home'),
          paletteMode: _paletteMode,
          mascotId: _mascotId,
          userAlias: _userAlias,
          userLevel: _userLevel,
          currentXp: _currentXp,
          maxXp: _maxXp,
          streakDays: _streakDays,
          rankTitle: _rankTitle,
          lastTopicCategory: _lastTopicCategory,
          lastTopicTitle: _lastTopicTitle,
          onContinueLastTopic: () => _navigateTo(_KadirSubView.practice),
          onOpenModes: () => _navigateTo(_KadirSubView.modes),
          onOpenProgress: () => _navigateTo(_KadirSubView.progress),
          onOpenProfile: () => _navigateTo(_KadirSubView.profile),
        );

      case _KadirSubView.modes:
        return KadirModesScreen(
          key: const ValueKey('kadir_sub_modes'),
          paletteMode: _paletteMode,
          userAlias: _userAlias,
          streakDays: _streakDays,
          selectedArea: _selectedArea,
          areaProgress: _areaProgress,
          onSelectArea: _handleSelectArea,
          onBackToHome: _goHome,
          onOpenProgress: () => _navigateTo(_KadirSubView.progress),
          onOpenProfile: () => _navigateTo(_KadirSubView.profile),
        );

      case _KadirSubView.practice:
        return KadirPracticeScreen(
          key: ValueKey(
            'kadir_sub_practice_${_selectedArea.name}_$_favoriteUniverse',
          ),
          area: _selectedArea,
          paletteMode: _paletteMode,
          mascotId: _mascotId,
          userAlias: _userAlias,
          streakDays: _streakDays,
          initialUniverse: _favoriteUniverse,
          initialCompletedTopicIds: _completedTopicIds,
          onTopicCompleted: _handleTopicCompleted,
          onSaveAccordion: _handleSaveAccordion,
          onBackToModes: () => _navigateTo(_KadirSubView.modes),
          onBackToHome: _goHome,
          onOpenProgress: () => _navigateTo(_KadirSubView.progress),
          onOpenProfile: () => _navigateTo(_KadirSubView.profile),
        );

      case _KadirSubView.progress:
        return KadirProgressScreen(
          key: const ValueKey('kadir_sub_progress'),
          paletteMode: _paletteMode,
          userAlias: _userAlias,
          userLevel: _userLevel,
          currentXp: _currentXp,
          maxXp: _maxXp,
          streakDays: _streakDays,
          areaProgress: _areaProgress,
          initialReflections: _reflections,
          savedAccordions: _savedAccordions,
          onSaveReflection: _handleSaveReflection,
          onOpenSkills: () => _navigateTo(_KadirSubView.skills),
          onBackToHome: _goHome,
          onOpenProfile: () => _navigateTo(_KadirSubView.profile),
        );

      case _KadirSubView.skills:
        return KadirSkillsScreen(
          key: const ValueKey('kadir_sub_skills'),
          paletteMode: _paletteMode,
          userAlias: _userAlias,
          streakDays: _streakDays,
          initialSkills: _skills,
          onSkillExplored: _handleSkillExplored,
          onOpenPractice: _handleOpenPracticeFromSkill,
          onBackToHome: _goBack,
          onOpenProgress: () => _navigateTo(_KadirSubView.progress),
          onOpenProfile: () => _navigateTo(_KadirSubView.profile),
        );

      case _KadirSubView.profile:
        return KadirProfileScreen(
          key: const ValueKey('kadir_sub_profile'),
          paletteMode: _paletteMode,
          initialMascotId: _mascotId,
          initialUniverse: _favoriteUniverse,
          userAlias: _userAlias,
          userIdentifier: _userIdentifier,
          userLevel: _userLevel,
          streakDays: _streakDays,
          onChangeMascot: (id) => setState(() => _mascotId = id),
          onChangeUniverse: (u) => setState(() => _favoriteUniverse = u),
          onChangePalette: (mode) => setState(() => _paletteMode = mode),
          onOpenThemeSelector: _handleOpenThemeSelector,
          onLogout: _handleLogout,
          onBackToHome: _goHome,
          onOpenProgress: () => _navigateTo(_KadirSubView.progress),
        );
    }
  }
}