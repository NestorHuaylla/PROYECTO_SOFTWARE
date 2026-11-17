import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_service.dart';
import 'login_screen.dart';

Color _alpha(Color c, double opacity) =>
    c.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());

class RegisterScreen extends StatefulWidget {
  final KadirPaletteMode initialPalette;
  final bool isDarkMode;
  final VoidCallback? onBack;
  final VoidCallback? onGoToLogin;
  final void Function(String identifier, String alias)? onRegisterSuccess;

  const RegisterScreen({
    super.key,
    this.initialPalette = KadirPaletteMode.aurora,
    this.isDarkMode = false,
    this.onBack,
    this.onGoToLogin,
    this.onRegisterSuccess,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  // Controladores de animación
  late final AnimationController _ambientController;
  late final AnimationController _haloController;
  late final AnimationController _crystal3DController;
  late final AnimationController _causticController;
  late final AnimationController _enterController;

  // Controladores de texto y foco
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _idFocus = FocusNode();
  final FocusNode _aliasFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  String? _focusedField;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();

    // 1. Ondas líquidas de fondo (15s)
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // 2. Ondas expansivas de Halo de Cristal detrás del cuadro (9s)
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();

    // 3. Rotación 3D giroscópica + refracción por facetas + láser en aristas (9s)
    _crystal3DController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();

    // 4. Barrido cáustico continuo de extremo a extremo sobre el cuadro (8.5s)
    _causticController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8500),
    )..repeat();

    // 5. Entrada escalonada suave al abrir la pantalla
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();

    _idFocus.addListener(_updateFocus);
    _aliasFocus.addListener(_updateFocus);
    _passFocus.addListener(_updateFocus);
  }

  void _updateFocus() {
    if (!mounted) return;
    setState(() {
      if (_idFocus.hasFocus) {
        _focusedField = 'id';
      } else if (_aliasFocus.hasFocus) {
        _focusedField = 'alias';
      } else if (_passFocus.hasFocus) {
        _focusedField = 'pass';
      } else {
        _focusedField = null;
      }
    });
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _haloController.dispose();
    _crystal3DController.dispose();
    _causticController.dispose();
    _enterController.dispose();
    _identifierController.dispose();
    _aliasController.dispose();
    _passwordController.dispose();
    _idFocus.dispose();
    _aliasFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _goToLogin() {
    if (widget.onGoToLogin != null) {
      widget.onGoToLogin!();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _handleRegisterSubmit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = '';
      _successMessage = '';
    });

    final cleanId = _identifierController.text.trim();
    final cleanAlias = _aliasController.text.trim();
    final pass = _passwordController.text;

    if (cleanId.isEmpty) {
      setState(() => _errorMessage = 'El identificador es obligatorio');
      return;
    }
    if (cleanAlias.isEmpty) {
      setState(() => _errorMessage = 'El alias es obligatorio');
      return;
    }
    if (pass.isEmpty) {
      setState(() => _errorMessage = 'La contraseña es obligatoria');
      return;
    }
    if (pass.length < 6) {
      setState(
        () => _errorMessage = 'La contraseña debe tener al menos 6 caracteres',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final formattedId = cleanId.startsWith('@') ? cleanId : '@$cleanId';
      await AuthService().register(formattedId, cleanAlias, pass);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _successMessage = 'Cuenta creada correctamente';
      });

      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        if (widget.onRegisterSuccess != null) {
          widget.onRegisterSuccess!(formattedId, cleanAlias);
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'No se pudo crear la cuenta: $error';
      });
    }
  }

  void _handleGoogleContinue() {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _successMessage = 'Conectado con Google correctamente';
      });

      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        if (widget.onRegisterSuccess != null) {
          widget.onRegisterSuccess!(
            '@estudiante_google',
            'Estudiante Kadir',
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.fromMode(widget.initialPalette);
    final isDark = widget.isDarkMode || palette.isDark;

    // Paleta limpia integrando AppColors + el matiz Verdoso-Aqua y Amatista
    final bgMain = isDark ? const Color(0xFF070B14) : palette.bgMain;
    final textMain = isDark ? const Color(0xFFF5F9FF) : palette.textMain;
    final textMuted = isDark ? const Color(0xFF8CA2C0) : palette.textMuted;

    // Letras sobrias y limpias (Pizarra oscura / Amatista, sin letras verdes)
    final cleanAccentText =
        isDark ? const Color(0xFFC4B5FD) : const Color(0xFF4C1D95);
    final cleanLabelText =
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
    final cleanIconColor =
        isDark ? const Color(0xFFA88FFF) : const Color(0xFF5B43C5);

    // Bordes y superficies de cristal con matiz verdoso-aqua + lavanda
    final glassBorder = isDark
        ? _alpha(const Color(0xFF5EEAD4), 0.34)
        : _alpha(const Color(0xFF047D8A), 0.30);

    final pillGlassBg = isDark
        ? _alpha(const Color(0xFF121E2E), 0.58)
        : _alpha(Colors.white, 0.72);

    final inputGlassBg = isDark
        ? _alpha(const Color(0xFF0C1622), 0.48)
        : _alpha(Colors.white, 0.60);

    final inputFocusedBg = isDark
        ? _alpha(const Color(0xFF101E2E), 0.68)
        : _alpha(Colors.white, 0.82);

    return Scaffold(
      backgroundColor: bgMain,
      body: Stack(
        children: [
          // ===================================================================
          // 1. FONDO CON ONDAS LÍQUIDAS (VERDOSO-AQUA + VIOLETA), HALOS
          //    EXPANSIVOS Y 2 CRISTALES 3D CON ROTACIÓN GIROSCÓPICA
          // ===================================================================
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _ambientController,
                  _haloController,
                  _crystal3DController,
                ]),
                builder: (context, _) {
                  final tAmb = _ambientController.value * 2 * math.pi;
                  final tCrys = _crystal3DController.value;
                  final angleCrys = tCrys * 2 * math.pi;

                  return Stack(
                    children: [
                      // Onda Líquida Superior-Izquierda (Tono Verdoso-Aqua KADIR)
                      Align(
                        alignment: const Alignment(-0.68, -0.72),
                        child: Transform.translate(
                          offset: Offset(
                            math.sin(tAmb) * 32,
                            math.cos(tAmb * 1.2) * 22,
                          ),
                          child: Container(
                            width: 340,
                            height: 290,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _alpha(const Color(0xFF2DD4BF), 0.40),
                                  _alpha(const Color(0xFF047D8A), 0.22),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.55, 0.82],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Onda Líquida Inferior-Derecha (Tono Verdoso-Aqua + Violeta)
                      Align(
                        alignment: const Alignment(0.72, 0.68),
                        child: Transform.translate(
                          offset: Offset(
                            math.cos(tAmb) * -36,
                            math.sin(tAmb) * -26,
                          ),
                          child: Container(
                            width: 330,
                            height: 290,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _alpha(const Color(0xFF14B8A6), 0.34),
                                  _alpha(const Color(0xFF7C3AED), 0.24),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.58, 0.82],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Núcleo central respirando + 2 Ondas de Halo Expansivas
                      Align(
                        alignment: const Alignment(0.0, -0.04),
                        child: SizedBox(
                          width: 380,
                          height: 380,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Núcleo luminoso central (Verdoso-Aqua + Lavanda)
                              Transform.scale(
                                scale: 0.96 + 0.10 * math.sin(tAmb * 2),
                                child: Container(
                                  width: 240,
                                  height: 240,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        _alpha(const Color(0xFF5EEAD4), 0.34),
                                        _alpha(const Color(0xFFA855F7), 0.22),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.62, 0.85],
                                    ),
                                  ),
                                ),
                              ),

                              // Onda de Cristal Expansiva 1 (Verdoso-Aqua)
                              _buildHaloRipple(
                                progress: _haloController.value,
                                color: isDark
                                    ? const Color(0xFF5EEAD4)
                                    : const Color(0xFF0D9488),
                              ),

                              // Onda de Cristal Expansiva 2 (Violeta desfasada 50%)
                              _buildHaloRipple(
                                progress: (_haloController.value + 0.5) % 1.0,
                                color: isDark
                                    ? const Color(0xFFC4B5FD)
                                    : const Color(0xFF8B5CF6),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // CRISTAL 1 (Arriba-Derecha): Prisma Octaedro con Rotación 3D
                      Align(
                        alignment: const Alignment(0.84, -0.58),
                        child: _build3DCrystalWrapper(
                          angle: angleCrys,
                          isUpper: true,
                          glowColor: const Color(0xFF2DD4BF),
                          child: CustomPaint(
                            size: const Size(116, 116),
                            painter: _OctahedronCrystal3DPainter(
                              progress: tCrys,
                            ),
                          ),
                        ),
                      ),

                      // CRISTAL 2 (Abajo-Izquierda): Gema Hexagonal con Rotación 3D
                      Align(
                        alignment: const Alignment(-0.86, 0.56),
                        child: _build3DCrystalWrapper(
                          angle: angleCrys,
                          isUpper: false,
                          glowColor: const Color(0xFF14B8A6),
                          child: CustomPaint(
                            size: const Size(106, 106),
                            painter: _HexGemCrystal3DPainter(
                              progress: (tCrys + 0.35) % 1.0,
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

          // ===================================================================
          // 2. CONTENIDO PRINCIPAL EN CRISTAL ÓPTICO
          // ===================================================================
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
                      // 1. CABECERA SUPERIOR
                      _buildStaggeredEnter(
                        intervalStart: 0.0,
                        intervalEnd: 0.55,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildGlassIconButton(
                              icon: Icons.chevron_left_rounded,
                              onTap: () {
                                if (widget.onBack != null) {
                                  widget.onBack!();
                                } else {
                                  Navigator.of(context).maybePop();
                                }
                              },
                              bg: pillGlassBg,
                              border: glassBorder,
                              iconColor: textMain,
                            ),
                            _buildGlassPillButton(
                              label: 'INICIAR SESIÓN',
                              onTap: _goToLogin,
                              bg: pillGlassBg,
                              border: glassBorder,
                              textColor: cleanAccentText,
                            ),
                          ],
                        ),
                      ),

                      // 2. BLOQUE CENTRAL: TÍTULO + FORMULARIO + CÍRCULO DE GOOGLE DEBAJO
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Etiqueta + Título Sobrio
                                _buildStaggeredEnter(
                                  intervalStart: 0.10,
                                  intervalEnd: 0.68,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.auto_awesome,
                                            size: 12,
                                            color: cleanIconColor,
                                          ),
                                          const SizedBox(width: 7),
                                          Text(
                                            'NUEVA CUENTA',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 2.4,
                                              color: cleanLabelText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 32,
                                            height: 1.12,
                                            letterSpacing: -0.8,
                                            color: textMain,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: 'Crea tu ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'cuenta ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.italic,
                                                color: cleanAccentText,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: 'personal.',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Alertas de validación
                                if (_successMessage.isNotEmpty)
                                  _buildStatusBanner(
                                    message: _successMessage,
                                    color: const Color(0xFF0D9488),
                                    bg: isDark
                                        ? _alpha(const Color(0xFF2DD4BF), 0.16)
                                        : const Color(0xFFCCFBF1),
                                    icon: Icons.check_circle_outline_rounded,
                                  ),
                                if (_errorMessage.isNotEmpty)
                                  _buildStatusBanner(
                                    message: _errorMessage,
                                    color: const Color(0xFFE11D48),
                                    bg: isDark
                                        ? _alpha(const Color(0xFFFB7185), 0.16)
                                        : const Color(0xFFFFE4E6),
                                    icon: Icons.error_outline_rounded,
                                  ),

                                // CUADRO DE CRISTAL ÓPTICO CON BARRIDO CÁUSTICO CONTINUO
                                _buildStaggeredEnter(
                                  intervalStart: 0.20,
                                  intervalEnd: 0.82,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 26,
                                        sigmaY: 26,
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(22),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              border: Border.all(
                                                color: glassBorder,
                                                width: 1.5,
                                              ),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: isDark
                                                    ? [
                                                        _alpha(
                                                          const Color(
                                                            0xFF10222E,
                                                          ),
                                                          0.54,
                                                        ),
                                                        _alpha(
                                                          const Color(
                                                            0xFF12182A,
                                                          ),
                                                          0.40,
                                                        ),
                                                        _alpha(
                                                          const Color(
                                                            0xFF141A30,
                                                          ),
                                                          0.48,
                                                        ),
                                                      ]
                                                    : [
                                                        _alpha(
                                                          const Color(
                                                            0xFFF0FDFA,
                                                          ),
                                                          0.58,
                                                        ),
                                                        _alpha(
                                                          Colors.white,
                                                          0.50,
                                                        ),
                                                        _alpha(
                                                          const Color(
                                                            0xFFF3E8FF,
                                                          ),
                                                          0.46,
                                                        ),
                                                      ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: isDark
                                                      ? _alpha(
                                                          Colors.black,
                                                          0.46,
                                                        )
                                                      : _alpha(
                                                          const Color(
                                                            0xFF047D8A,
                                                          ),
                                                          0.12,
                                                        ),
                                                  blurRadius: 38,
                                                  offset: const Offset(0, 18),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Campo 1: Identificador único
                                                _buildCrystalTextField(
                                                  label: 'IDENTIFICADOR ÚNICO',
                                                  hint: 'estudiante2026',
                                                  controller:
                                                      _identifierController,
                                                  focusNode: _idFocus,
                                                  isFocused:
                                                      _focusedField == 'id',
                                                  labelColor: cleanLabelText,
                                                  textColor: textMain,
                                                  mutedColor: textMuted,
                                                  fillColor:
                                                      _focusedField == 'id'
                                                          ? inputFocusedBg
                                                          : inputGlassBg,
                                                  borderColor:
                                                      _focusedField == 'id'
                                                          ? cleanIconColor
                                                          : glassBorder,
                                                  prefixWidget: Text(
                                                    '@',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontFamily: 'monospace',
                                                      color: cleanIconColor,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 14),

                                                // Campo 2: Alias
                                                _buildCrystalTextField(
                                                  label: 'ALIAS',
                                                  hint:
                                                      '¿Cómo quieres que te llamemos?',
                                                  controller: _aliasController,
                                                  focusNode: _aliasFocus,
                                                  isFocused:
                                                      _focusedField == 'alias',
                                                  labelColor: cleanLabelText,
                                                  textColor: textMain,
                                                  mutedColor: textMuted,
                                                  fillColor:
                                                      _focusedField == 'alias'
                                                          ? inputFocusedBg
                                                          : inputGlassBg,
                                                  borderColor:
                                                      _focusedField == 'alias'
                                                          ? cleanIconColor
                                                          : glassBorder,
                                                  prefixWidget: Icon(
                                                    Icons.person_outline_rounded,
                                                    size: 18,
                                                    color: cleanIconColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 14),

                                                // Campo 3: Contraseña
                                                _buildCrystalTextField(
                                                  label: 'CONTRASEÑA',
                                                  hint: 'Mínimo 6 caracteres',
                                                  controller:
                                                      _passwordController,
                                                  focusNode: _passFocus,
                                                  isFocused:
                                                      _focusedField == 'pass',
                                                  obscureText: _obscurePassword,
                                                  labelColor: cleanLabelText,
                                                  textColor: textMain,
                                                  mutedColor: textMuted,
                                                  fillColor:
                                                      _focusedField == 'pass'
                                                          ? inputFocusedBg
                                                          : inputGlassBg,
                                                  borderColor:
                                                      _focusedField == 'pass'
                                                          ? cleanIconColor
                                                          : glassBorder,
                                                  prefixWidget: Icon(
                                                    Icons.lock_outline_rounded,
                                                    size: 18,
                                                    color: cleanIconColor,
                                                  ),
                                                  suffixWidget: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _obscurePassword =
                                                            !_obscurePassword;
                                                      });
                                                    },
                                                    icon: Icon(
                                                      _obscurePassword
                                                          ? Icons
                                                              .visibility_off_outlined
                                                          : Icons
                                                              .visibility_outlined,
                                                      size: 18,
                                                      color: textMuted,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Arista de brillo especular bicolor (Verdoso-Aqua + Violeta)
                                          Positioned(
                                            top: 0,
                                            left: 24,
                                            right: 24,
                                            child: IgnorePointer(
                                              child: Container(
                                                height: 1.8,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.transparent,
                                                      const Color(0xFF5EEAD4),
                                                      _alpha(
                                                        Colors.white,
                                                        0.98,
                                                      ),
                                                      const Color(0xFFC084FC),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Barrido cáustico continuo de extremo a extremo
                                          Positioned.fill(
                                            child: IgnorePointer(
                                              child: AnimatedBuilder(
                                                animation: _causticController,
                                                builder: (context, _) {
                                                  final xSlide = -1.8 +
                                                      (_causticController
                                                              .value *
                                                          3.8);
                                                  return FractionalTranslation(
                                                    translation:
                                                        Offset(xSlide, 0),
                                                    child: Transform.rotate(
                                                      angle: -0.40,
                                                      child: Container(
                                                        width: 95,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors
                                                                  .transparent,
                                                              _alpha(
                                                                const Color(
                                                                  0xFFCCFBF1,
                                                                ),
                                                                0.32,
                                                              ),
                                                              _alpha(
                                                                Colors.white,
                                                                0.52,
                                                              ),
                                                              _alpha(
                                                                const Color(
                                                                  0xFFE9D5FF,
                                                                ),
                                                                0.30,
                                                              ),
                                                              Colors
                                                                  .transparent,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // CÍRCULO DE GOOGLE FUERA Y DEBAJO DEL CUADRO DE CRISTAL
                                // (Solo logo oficial de Google, con respiración suave)
                                _buildStaggeredEnter(
                                  intervalStart: 0.35,
                                  intervalEnd: 0.95,
                                  child: Center(
                                    child: AnimatedBuilder(
                                      animation: _ambientController,
                                      builder: (context, child) {
                                        final dy = math.sin(
                                              _ambientController.value *
                                                  2 *
                                                  math.pi *
                                                  3,
                                            ) *
                                            2.5;
                                        return Transform.translate(
                                          offset: Offset(0, dy),
                                          child: child,
                                        );
                                      },
                                      child: GestureDetector(
                                        onTap: _isLoading
                                            ? null
                                            : _handleGoogleContinue,
                                        child: ClipOval(
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 18,
                                              sigmaY: 18,
                                            ),
                                            child: Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: pillGlassBg,
                                                border: Border.all(
                                                  color: glassBorder,
                                                  width: 1.4,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: isDark
                                                        ? _alpha(
                                                            Colors.black,
                                                            0.35,
                                                          )
                                                        : _alpha(
                                                            const Color(
                                                              0xFF047D8A,
                                                            ),
                                                            0.14,
                                                          ),
                                                    blurRadius: 18,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              child: const CustomPaint(
                                                size: Size(21, 21),
                                                painter: _GoogleLogoPainter(),
                                              ),
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
                        ),
                      ),

                      // 3. BOTÓN FINAL: "Crear cuenta"
                      _buildStaggeredEnter(
                        intervalStart: 0.40,
                        intervalEnd: 1.0,
                        child: GestureDetector(
                          onTap: _isLoading ? null : _handleRegisterSubmit,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                              child: Container(
                                width: double.infinity,
                                height: 54,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 22),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: glassBorder,
                                    width: 1.4,
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isDark
                                        ? [
                                            _alpha(
                                              const Color(0xFF14B8A6),
                                              0.22,
                                            ),
                                            _alpha(
                                              const Color(0xFF6F56D9),
                                              0.24,
                                            ),
                                          ]
                                        : [
                                            _alpha(
                                              const Color(0xFFCCFBF1),
                                              0.68,
                                            ),
                                            _alpha(
                                              const Color(0xFFE9D5FF),
                                              0.58,
                                            ),
                                            _alpha(
                                              const Color(0xFFF3E8FF),
                                              0.68,
                                            ),
                                          ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _isLoading
                                          ? 'PROCESANDO...'
                                          : 'CREAR CUENTA',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                        color: isDark
                                            ? textMain
                                            : const Color(0xFF3B1D7A),
                                      ),
                                    ),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: pillGlassBg,
                                        borderRadius: BorderRadius.circular(11),
                                        border: Border.all(color: glassBorder),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 17,
                                        color: cleanAccentText,
                                      ),
                                    ),
                                  ],
                                ),
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
      ),
    );
  }

  // Onda de cristal expansiva (Breathing Halo Ripple)
  Widget _buildHaloRipple({required double progress, required Color color}) {
    final scale = 0.84 + (progress * 0.44);
    final opacity = progress < 0.35
        ? (progress / 0.35) * 0.38
        : (1.0 - ((progress - 0.35) / 0.65)) * 0.38;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _alpha(color, opacity.clamp(0.0, 1.0)),
            width: 1.6,
          ),
        ),
      ),
    );
  }

  // Envoltorio de Rotación 3D con perspectiva real para los 2 cristales
  Widget _build3DCrystalWrapper({
    required double angle,
    required bool isUpper,
    required Color glowColor,
    required Widget child,
  }) {
    final dir = isUpper ? 1.0 : -1.0;
    final dx = math.sin(angle) * 14.0 * dir;
    final dy = math.cos(angle * 2) * -18.0 * dir;
    final rotY = math.sin(angle) * 0.44 * dir;
    final rotX = math.cos(angle) * 0.22 * dir;
    final rotZ = math.sin(angle) * 0.16 * dir;

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0016)
      ..rotateY(rotY)
      ..rotateX(rotX)
      ..rotateZ(rotZ);

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform(
        alignment: Alignment.center,
        transform: matrix,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _alpha(glowColor, 0.34),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  // Entrada escalonada suave
  Widget _buildStaggeredEnter({
    required double intervalStart,
    required double intervalEnd,
    required Widget child,
  }) {
    final curve = CurvedAnimation(
      parent: _enterController,
      curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (context, _) {
        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, (1.0 - curve.value) * 16),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color bg,
    required Color border,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: border),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassPillButton({
    required String label,
    required VoidCallback onTap,
    required Color bg,
    required Color border,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: border),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner({
    required String message,
    required Color color,
    required Color bg,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrystalTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required Color labelColor,
    required Color textColor,
    required Color mutedColor,
    required Color fillColor,
    required Color borderColor,
    required Widget prefixWidget,
    Widget? suffixWidget,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          transform: Matrix4.translationValues(0, isFocused ? -1.5 : 0, 0),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isFocused ? 1.5 : 1.0,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: _alpha(mutedColor, 0.72),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: prefixWidget,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              suffixIcon: suffixWidget,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// PINTOR 1: LOGO OFICIAL DE GOOGLE "G" EN 4 COLORES (SOLO ÍCONO)
// =============================================================================
class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.40;
    final strokeW = size.width * 0.19;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Rojo superior
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.45, 1.65, false, paint);

    // Amarillo izquierdo
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.35, 1.35, false, paint);

    // Verde inferior
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.65, 1.70, false, paint);

    // Azul derecho + barra horizontal
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.12, 0.82, false, paint);

    final barPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - strokeW * 0.46,
        radius + strokeW * 0.45,
        strokeW * 0.92,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// PINTOR 2: CRISTAL SUPERIOR 3D (PRISMA OCTAEDRO VERDOSO-AQUA + AMATISTA
//           CON REFRACCIÓN ENTRE CARAS Y DESTELLO LÁSER EN ARISTAS)
// =============================================================================
class _OctahedronCrystal3DPainter extends CustomPainter {
  final double progress;
  const _OctahedronCrystal3DPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final top = Offset(w * 0.50, h * 0.07);
    final right = Offset(w * 0.87, h * 0.40);
    final bottom = Offset(w * 0.50, h * 0.93);
    final left = Offset(w * 0.13, h * 0.40);
    final mid = Offset(w * 0.50, h * 0.53);

    // Alternancia de luz entre facetas izquierda y derecha al girar en 3D
    final wave = 0.5 + 0.5 * math.sin(progress * 2 * math.pi * 2);
    final alphaA = 0.56 + (0.38 * wave);
    final alphaB = 0.56 + (0.38 * (1.0 - wave));

    // Faceta superior derecha (Verdoso-Aqua luminoso)
    final p1 = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(mid.dx, mid.dy)
      ..close();
    canvas.drawPath(
      p1,
      Paint()..color = _alpha(const Color(0xFF5EEAD4), alphaA),
    );

    // Faceta superior izquierda (Aqua claro + Amatista)
    final p2 = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(mid.dx, mid.dy)
      ..close();
    canvas.drawPath(
      p2,
      Paint()..color = _alpha(const Color(0xFF99F6E4), alphaB),
    );

    // Faceta inferior izquierda (Amatista/Teal)
    final p3 = Path()
      ..moveTo(left.dx, left.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(mid.dx, mid.dy)
      ..close();
    canvas.drawPath(
      p3,
      Paint()..color = _alpha(const Color(0xFF6D28D9), alphaA),
    );

    // Faceta inferior derecha (Teal profundo)
    final p4 = Path()
      ..moveTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(mid.dx, mid.dy)
      ..close();
    canvas.drawPath(
      p4,
      Paint()..color = _alpha(const Color(0xFF0F766E), alphaB),
    );

    // Aristas base
    final baseStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = _alpha(Colors.white, 0.65);

    final outer = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();
    canvas.drawPath(outer, baseStroke);
    canvas.drawLine(top, bottom, baseStroke);
    canvas.drawLine(left, mid, baseStroke);
    canvas.drawLine(right, mid, baseStroke);

    // Destello láser recorriendo el contorno del cristal
    _drawLaserEdge(canvas, outer, progress);

    // Destello estelar en el vértice central
    canvas.drawCircle(
      mid,
      2.4 + wave * 1.1,
      Paint()..color = _alpha(Colors.white, 0.92),
    );
  }

  @override
  bool shouldRepaint(covariant _OctahedronCrystal3DPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// =============================================================================
// PINTOR 3: CRISTAL INFERIOR 3D (GEMA HEXAGONAL VERDOSO-AQUA + AMATISTA)
// =============================================================================
class _HexGemCrystal3DPainter extends CustomPainter {
  final double progress;
  const _HexGemCrystal3DPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pTop = Offset(w * 0.50, h * 0.09);
    final pTopR = Offset(w * 0.87, h * 0.29);
    final pBotR = Offset(w * 0.87, h * 0.67);
    final pBot = Offset(w * 0.50, h * 0.89);
    final pBotL = Offset(w * 0.13, h * 0.67);
    final pTopL = Offset(w * 0.13, h * 0.29);
    final pMid = Offset(w * 0.50, h * 0.49);

    final wave = 0.5 + 0.5 * math.cos(progress * 2 * math.pi * 2);
    final alphaA = 0.58 + (0.36 * wave);
    final alphaB = 0.58 + (0.36 * (1.0 - wave));

    final topFace = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pTopR.dx, pTopR.dy)
      ..lineTo(pMid.dx, pMid.dy)
      ..lineTo(pTopL.dx, pTopL.dy)
      ..close();
    canvas.drawPath(
      topFace,
      Paint()..color = _alpha(const Color(0xFFCCFBF1), alphaB),
    );

    final leftFace = Path()
      ..moveTo(pTopL.dx, pTopL.dy)
      ..lineTo(pMid.dx, pMid.dy)
      ..lineTo(pBot.dx, pBot.dy)
      ..lineTo(pBotL.dx, pBotL.dy)
      ..close();
    canvas.drawPath(
      leftFace,
      Paint()..color = _alpha(const Color(0xFF14B8A6), alphaA),
    );

    final rightFace = Path()
      ..moveTo(pTopR.dx, pTopR.dy)
      ..lineTo(pMid.dx, pMid.dy)
      ..lineTo(pBot.dx, pBot.dy)
      ..lineTo(pBotR.dx, pBotR.dy)
      ..close();
    canvas.drawPath(
      rightFace,
      Paint()..color = _alpha(const Color(0xFF6D28D9), alphaB),
    );

    final baseStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = _alpha(Colors.white, 0.65);

    final hexOuter = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pTopR.dx, pTopR.dy)
      ..lineTo(pBotR.dx, pBotR.dy)
      ..lineTo(pBot.dx, pBot.dy)
      ..lineTo(pBotL.dx, pBotL.dy)
      ..lineTo(pTopL.dx, pTopL.dy)
      ..close();

    canvas.drawPath(hexOuter, baseStroke);
    canvas.drawLine(pTopL, pMid, baseStroke);
    canvas.drawLine(pTopR, pMid, baseStroke);
    canvas.drawLine(pMid, pBot, baseStroke);

    // Destello láser recorriendo las aristas
    _drawLaserEdge(canvas, hexOuter, progress);

    // Destello estelar en el vértice central
    canvas.drawCircle(
      pMid,
      2.3 + wave * 1.1,
      Paint()..color = _alpha(Colors.white, 0.92),
    );
  }

  @override
  bool shouldRepaint(covariant _HexGemCrystal3DPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Función auxiliar para dibujar el trazo láser luminoso recorriendo las aristas del cristal
void _drawLaserEdge(Canvas canvas, Path outerPath, double progress) {
  final metrics = outerPath.computeMetrics().toList();
  if (metrics.isEmpty) return;
  final metric = metrics.first;
  final totalLen = metric.length;
  final segLen = totalLen * 0.28;
  final start = (progress * 2.0 % 1.0) * totalLen;
  final end = start + segLen;

  final laserPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round
    ..color = Colors.white;

  if (end <= totalLen) {
    canvas.drawPath(metric.extractPath(start, end), laserPaint);
  } else {
    canvas.drawPath(metric.extractPath(start, totalLen), laserPaint);
    canvas.drawPath(metric.extractPath(0, end - totalLen), laserPaint);
  }
}