import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/auth_service.dart';
import 'register_screen.dart';

/// Alias para que WelcomeScreen y RegisterScreen funcionen con ambos nombres
typedef LoginScreen = KadirLoginScreen;

class KadirLoginScreen extends StatefulWidget {
  final KadirPaletteMode paletteMode;
  final VoidCallback? onBack;
  final VoidCallback? onGoToRegister;
  final VoidCallback? onGoogleContinue;
  final VoidCallback? onLoginSuccess;
  final Future<bool> Function(String usuario, String contrasena)? onBackendAuth;
  final String? initialIdentifier;
  const KadirLoginScreen({
    super.key,
    this.paletteMode = KadirPaletteMode.orbita,
    this.onBack,
    this.onGoToRegister,
    this.onGoogleContinue,
    this.onLoginSuccess,
    this.initialIdentifier,
    this.onBackendAuth,
  });

  @override
  State<KadirLoginScreen> createState() => _KadirLoginScreenState();
}

enum _FeedbackType { none, warning, error, success }

class _KadirLoginScreenState extends State<KadirLoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  late final AnimationController _ambientController;

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String _mensajeResultado = '';
  _FeedbackType _tipoMensaje = _FeedbackType.none;

  @override
  void initState() {
    super.initState();
    if (widget.initialIdentifier != null &&
    widget.initialIdentifier!.isNotEmpty) {
  _userController.text = widget.initialIdentifier!;
}
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);

    _userFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _userFocus.removeListener(_onFocusChange);
    _passwordFocus.removeListener(_onFocusChange);
    _userFocus.dispose();
    _passwordFocus.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleGoToRegister() {
    if (widget.onGoToRegister != null) {
      widget.onGoToRegister!();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RegisterScreen(initialPalette: widget.paletteMode),
      ),
    );
  }

  Future<void> _procesarInicioSesion() async {
    FocusScope.of(context).unfocus();

    final usuarioIngresado = _userController.text.trim();
    final contrasenaIngresada = _passwordController.text;

    if (usuarioIngresado.isEmpty || contrasenaIngresada.isEmpty) {
      setState(() {
        _mensajeResultado = 'Error: Los campos no pueden estar vacíos.';
        _tipoMensaje = _FeedbackType.warning;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _mensajeResultado = '';
      _tipoMensaje = _FeedbackType.none;
    });

    try {
      final esValido = widget.onBackendAuth != null
          ? await widget.onBackendAuth!(usuarioIngresado, contrasenaIngresada)
          : await AuthService().login(usuarioIngresado, contrasenaIngresada);

      if (!mounted) return;

      if (!esValido) {
        setState(() {
          _isSubmitting = false;
          _mensajeResultado = 'Usuario o contraseña incorrecta';
          _tipoMensaje = _FeedbackType.error;
        });
        return;
      }

      setState(() {
        _isSubmitting = false;
        _mensajeResultado = 'Inicio de sesión exitoso';
        _tipoMensaje = _FeedbackType.success;
      });

      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      widget.onLoginSuccess?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _mensajeResultado = 'Sin conexión con el servidor AWS (3.18.3.0:8000).';
        _tipoMensaje = _FeedbackType.error;
      });
    }
  }

  Future<void> _handleGoogleTap() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();

    if (widget.onGoogleContinue != null) {
      widget.onGoogleContinue!();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _mensajeResultado = '';
      _tipoMensaje = _FeedbackType.none;
    });

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _mensajeResultado = 'Conectado con Google correctamente';
      _tipoMensaje = _FeedbackType.success;
    });

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    widget.onLoginSuccess?.call();
  }
  @override
  Widget build(BuildContext context) {
    final tokens = _KadirLoginTokens.fromMode(widget.paletteMode);

    return Scaffold(
      backgroundColor: tokens.canvasBg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Atmósfera óptica animada (Orbes + Aros + 2 Cristales 3D)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, _) {
                return _KadirLoginAtmosphere(
                  tokens: tokens,
                  progress: _ambientController.value,
                );
              },
            ),
          ),

          // 2. Contenido seguro contra márgenes, notch y teclado
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding =
                    constraints.maxWidth >= 600 ? 32.0 : 20.0;

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 14,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(0, constraints.maxHeight - 28),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Cabecera en cristal
                              _buildHeader(tokens),

                              const Spacer(),
                              const SizedBox(height: 18),

                              // Título editorial
                              _buildTitleBlock(tokens),

                              // Alerta semántica (si existe)
                              if (_tipoMensaje != _FeedbackType.none &&
                                  _mensajeResultado.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                _buildFeedbackBanner(tokens),
                              ],

                              const SizedBox(height: 16),

                              // Tarjeta de formulario en cristal óptico
                              _buildGlassFormCard(tokens),

                              const SizedBox(height: 18),

                              // Círculo flotante de Google
                              Center(child: _buildGoogleCircleButton(tokens)),

                              const SizedBox(height: 18),
                              const Spacer(),

                              // CTA inferior en cristal óptico
                              _buildSubmitCta(tokens),
                            ],
                          ),
                        ),
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

  Widget _buildHeader(_KadirLoginTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botón Volver circular
        _GlassPillSurface(
          tokens: tokens,
          borderRadius: 999,
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: widget.onBack ?? () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.chevron_left_rounded,
                size: 22,
                color: tokens.textMain,
              ),
            ),
          ),
        ),

        // Pill cambiar a Registro
        _GlassPillSurface(
          tokens: tokens,
          borderRadius: 999,
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: _handleGoToRegister,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Text(
                'CREAR CUENTA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: tokens.cleanAccentText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleBlock(_KadirLoginTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 13,
              color: tokens.primary,
            ),
            const SizedBox(width: 7),
            Text(
              'INICIO DE SESIÓN',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.3,
                color: tokens.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 31,
              height: 1.14,
              letterSpacing: -0.7,
              color: tokens.textMain,
            ),
            children: [
              const TextSpan(
                text: 'Inicia tu ',
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
              TextSpan(
                text: 'sesión',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: tokens.cleanAccentText,
                ),
              ),
              const TextSpan(
                text: ' estudiantil.',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Retoma tu progreso y tus sesiones activas en Kadir.',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: tokens.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackBanner(_KadirLoginTokens tokens) {
    late final Color bg;
    late final Color border;
    late final Color textColor;
    late final IconData icon;

    switch (_tipoMensaje) {
      case _FeedbackType.success:
        bg = tokens.successSoft;
        border = tokens.success;
        textColor = tokens.success;
        icon = Icons.check_circle_outline_rounded;
        break;
      case _FeedbackType.warning:
        bg = tokens.warningSoft;
        border = tokens.warning;
        textColor = tokens.warning;
        icon = Icons.error_outline_rounded;
        break;
      case _FeedbackType.error:
      case _FeedbackType.none:
        bg = tokens.errorSoft;
        border = tokens.error;
        textColor = tokens.error;
        icon = Icons.error_outline_rounded;
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _mensajeResultado,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassFormCard(_KadirLoginTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: tokens.cardShadowColor,
            blurRadius: 38,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: tokens.cardGradientColors,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: tokens.glassBorder, width: 1.4),
            ),
            child: Stack(
              children: [
                // Arista superior especular
                Positioned(
                  top: 0,
                  left: 24,
                  right: 24,
                  child: Container(
                    height: 1.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: tokens.specularEdgeColors,
                      ),
                    ),
                  ),
                ),

                // Contenido del formulario
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo Usuario
                      _buildFieldLabel('USUARIO', tokens),
                      const SizedBox(height: 7),
                      _buildGlassTextField(
                        tokens: tokens,
                        controller: _userController,
                        focusNode: _userFocus,
                        hintText: 'Tu usuario de estudiante',
                        prefixIcon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),

                      const SizedBox(height: 16),

                      // Campo Contraseña
                      _buildFieldLabel('CONTRASEÑA', tokens),
                      const SizedBox(height: 7),
                      _buildGlassTextField(
                        tokens: tokens,
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        hintText: 'Ingresa tu contraseña',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _procesarInicioSesion(),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 19,
                            color: tokens.textMuted,
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
      ),
    );
  }

  Widget _buildFieldLabel(String text, _KadirLoginTokens tokens) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: tokens.textMuted,
      ),
    );
  }

  Widget _buildGlassTextField({
    required _KadirLoginTokens tokens,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
    Widget? suffixIcon,
  }) {
    final isFocused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isFocused ? tokens.inputFocusedBg : tokens.inputGlassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? tokens.primary : tokens.glassBorder,
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: tokens.primary.withAlpha(tokens.isDark ? 48 : 34),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: tokens.textMain,
        ),
        cursorColor: tokens.primary,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: tokens.textMuted.withAlpha(185),
          ),
          prefixIcon: Icon(
            prefixIcon,
            size: 19,
            color: tokens.primary,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleCircleButton(_KadirLoginTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: tokens.cardShadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _GlassPillSurface(
        tokens: tokens,
        borderRadius: 999,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: _isSubmitting ? null : _handleGoogleTap,
          borderRadius: BorderRadius.circular(999),
          child: const SizedBox(
            width: 50,
            height: 50,
            child: Center(
              child: CustomPaint(
                size: Size(22, 22),
                painter: _GoogleLogoPainter(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitCta(_KadirLoginTokens tokens) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: tokens.cardShadowColor,
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isSubmitting ? null : _procesarInicioSesion,
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: tokens.ctaGradientColors,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tokens.glassBorder, width: 1.3),
                ),
                child: Stack(
                  children: [
                    // Arista superior especular
                    Positioned(
                      top: 0,
                      left: 28,
                      right: 28,
                      child: Container(
                        height: 1.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: tokens.specularEdgeColors,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isSubmitting ? 'VALIDANDO...' : 'INICIAR SESIÓN',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                              color: tokens.ctaText,
                            ),
                          ),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: tokens.pillGlassBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: tokens.glassBorder,
                                width: 1,
                              ),
                            ),
                            child: _isSubmitting
                                ? Padding(
                                    padding: const EdgeInsets.all(8.5),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        tokens.cleanAccentText,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: tokens.cleanAccentText,
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
      ),
    );
  }
}

// =============================================================================
// SUPERFICIE DE CRISTAL PARA CABECERA Y BOTÓN GOOGLE
// =============================================================================
class _GlassPillSurface extends StatelessWidget {
  final _KadirLoginTokens tokens;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _GlassPillSurface({
    required this.tokens,
    required this.borderRadius,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: tokens.pillGlassBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: tokens.glassBorder, width: 1.1),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ATMÓSFERA ÓPTICA (ORBES + AROS EXPANSIVOS + 2 CRISTALES 3D)
// =============================================================================
class _KadirLoginAtmosphere extends StatelessWidget {
  final _KadirLoginTokens tokens;
  final double progress;

  const _KadirLoginAtmosphere({
    required this.tokens,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final wave = math.sin(progress * math.pi * 2);
    final floatY = wave * 7.0;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Orbe superior-izquierdo
          Positioned(
            top: -70 + floatY,
            left: -70,
            child: _SoftOrb(
              size: 320,
              innerColor: tokens.orb1Inner,
              outerColor: tokens.orb1Outer,
            ),
          ),

          // Orbe inferior-derecho
          Positioned(
            bottom: -90 - floatY,
            right: -70,
            child: _SoftOrb(
              size: 330,
              innerColor: tokens.orb2Inner,
              outerColor: tokens.orb2Outer,
            ),
          ),

          // Aros de cristal centrados detrás de la tarjeta
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _SoftOrb(
                  size: 260,
                  innerColor: tokens.coreGlowInner,
                  outerColor: tokens.coreGlowOuter,
                ),
                Container(
                  width: 300 + (progress * 18),
                  height: 300 + (progress * 18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tokens.halo1Border,
                      width: 1.4,
                    ),
                  ),
                ),
                Container(
                  width: 245 + ((1 - progress) * 20),
                  height: 245 + ((1 - progress) * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tokens.halo2Border,
                      width: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cristal 1 (Octaedro superior-derecho)
          Align(
            alignment: const Alignment(0.72, -0.46),
            child: Transform.translate(
              offset: Offset(0, floatY),
              child: CustomPaint(
                size: const Size(88, 88),
                painter: _OctahedronCrystalPainter(tokens: tokens),
              ),
            ),
          ),

          // Cristal 2 (Gema hexagonal inferior-izquierda)
          Align(
            alignment: const Alignment(-0.74, 0.50),
            child: Transform.translate(
              offset: Offset(0, -floatY),
              child: CustomPaint(
                size: const Size(80, 80),
                painter: _HexCrystalPainter(tokens: tokens),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftOrb extends StatelessWidget {
  final double size;
  final Color innerColor;
  final Color outerColor;

  const _SoftOrb({
    required this.size,
    required this.innerColor,
    required this.outerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            innerColor,
            outerColor,
            outerColor.withAlpha(0),
          ],
          stops: const [0.0, 0.52, 1.0],
        ),
      ),
    );
  }
}

class _OctahedronCrystalPainter extends CustomPainter {
  final _KadirLoginTokens tokens;

  const _OctahedronCrystalPainter({required this.tokens});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final top = Offset(w * 0.50, h * 0.06);
    final right = Offset(w * 0.87, h * 0.40);
    final left = Offset(w * 0.13, h * 0.40);
    final center = Offset(w * 0.50, h * 0.54);
    final bottom = Offset(w * 0.50, h * 0.94);

    void drawFacet(List<Offset> pts, Color color) {
      final path = Path()..addPolygon(pts, true);
      canvas.drawPath(path, Paint()..color = color);
    }

    drawFacet([top, right, center], tokens.crystalTop);
    drawFacet([top, left, center], tokens.crystalSide);
    drawFacet([left, bottom, center], tokens.crystalBottom);
    drawFacet([right, bottom, center], tokens.crystalDarkFacet);

    final edgePaint = Paint()
      ..color = Colors.white.withAlpha(175)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final outline = Path()..addPolygon([top, right, bottom, left], true);
    canvas.drawPath(outline, edgePaint);
    canvas.drawLine(top, bottom, edgePaint);
    canvas.drawLine(left, center, edgePaint);
    canvas.drawLine(right, center, edgePaint);

    canvas.drawCircle(center, 2.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _OctahedronCrystalPainter oldDelegate) =>
      oldDelegate.tokens != tokens;
}

class _HexCrystalPainter extends CustomPainter {
  final _KadirLoginTokens tokens;

  const _HexCrystalPainter({required this.tokens});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pTop = Offset(w * 0.50, h * 0.09);
    final pTR = Offset(w * 0.87, h * 0.29);
    final pBR = Offset(w * 0.87, h * 0.68);
    final pBottom = Offset(w * 0.50, h * 0.89);
    final pBL = Offset(w * 0.13, h * 0.68);
    final pTL = Offset(w * 0.13, h * 0.29);
    final pCenter = Offset(w * 0.50, h * 0.49);

    void drawFacet(List<Offset> pts, Color color) {
      final path = Path()..addPolygon(pts, true);
      canvas.drawPath(path, Paint()..color = color);
    }

    drawFacet([pTop, pTR, pCenter, pTL], tokens.crystal2Top);
    drawFacet([pTL, pCenter, pBottom, pBL], tokens.crystal2Left);
    drawFacet([pTR, pCenter, pBottom, pBR], tokens.crystal2Right);

    final edgePaint = Paint()
      ..color = Colors.white.withAlpha(175)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final outline = Path()
      ..addPolygon([pTop, pTR, pBR, pBottom, pBL, pTL], true);
    canvas.drawPath(outline, edgePaint);
    canvas.drawLine(pTL, pCenter, edgePaint);
    canvas.drawLine(pTR, pCenter, edgePaint);
    canvas.drawLine(pCenter, pBottom, edgePaint);

    canvas.drawCircle(pCenter, 2.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _HexCrystalPainter oldDelegate) =>
      oldDelegate.tokens != tokens;
}

// =============================================================================
// LOGO OFICIAL DE GOOGLE EN VECTOR (SIN DEPENDENCIAS EXTERNAS)
// =============================================================================
class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.21;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - stroke) / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Rojo (arriba)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.55, 1.85, false, paint);

    // Amarillo (izquierda)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.40, 1.35, false, paint);

    // Verde (abajo)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.72, 1.72, false, paint);

    // Azul (derecha + barra horizontal)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.05, 0.84, false, paint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.50,
          size.height * 0.41,
          size.width * 0.45,
          stroke * 0.92,
        ),
        const Radius.circular(2),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// TOKENS DE LAS 3 PALETAS GLOBALES (AURORA, ÓRBITA, PRISMA)
// =============================================================================
class _KadirLoginTokens {
  final bool isDark;
  final Color canvasBg;
  final Color primary;
  final Color textMain;
  final Color textMuted;
  final Color cleanAccentText;
  final Color ctaText;
  final Color glassBorder;
  final Color pillGlassBg;
  final Color inputGlassBg;
  final Color inputFocusedBg;
  final Color cardShadowColor;
  final List<Color> cardGradientColors;
  final List<Color> ctaGradientColors;
  final List<Color> specularEdgeColors;

  final Color orb1Inner;
  final Color orb1Outer;
  final Color orb2Inner;
  final Color orb2Outer;
  final Color coreGlowInner;
  final Color coreGlowOuter;
  final Color halo1Border;
  final Color halo2Border;

  final Color crystalTop;
  final Color crystalSide;
  final Color crystalBottom;
  final Color crystalDarkFacet;
  final Color crystal2Top;
  final Color crystal2Left;
  final Color crystal2Right;

  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color error;
  final Color errorSoft;

  const _KadirLoginTokens({
    required this.isDark,
    required this.canvasBg,
    required this.primary,
    required this.textMain,
    required this.textMuted,
    required this.cleanAccentText,
    required this.ctaText,
    required this.glassBorder,
    required this.pillGlassBg,
    required this.inputGlassBg,
    required this.inputFocusedBg,
    required this.cardShadowColor,
    required this.cardGradientColors,
    required this.ctaGradientColors,
    required this.specularEdgeColors,
    required this.orb1Inner,
    required this.orb1Outer,
    required this.orb2Inner,
    required this.orb2Outer,
    required this.coreGlowInner,
    required this.coreGlowOuter,
    required this.halo1Border,
    required this.halo2Border,
    required this.crystalTop,
    required this.crystalSide,
    required this.crystalBottom,
    required this.crystalDarkFacet,
    required this.crystal2Top,
    required this.crystal2Left,
    required this.crystal2Right,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.error,
    required this.errorSoft,
  });

  factory _KadirLoginTokens.fromMode(KadirPaletteMode mode) {
    switch (mode) {
      case KadirPaletteMode.orbita:
        return const _KadirLoginTokens(
          isDark: true,
          canvasBg: Color(0xFF070B14),
          primary: Color(0xFF49E0D3),
          textMain: Color(0xFFF5F9FF),
          textMuted: Color(0xFF8CA2C0),
          cleanAccentText: Color(0xFF7EF2E8),
          ctaText: Color(0xFFF5F9FF),
          glassBorder: Color(0x3394C5FF),
          pillGlassBg: Color(0xB30E172A),
          inputGlassBg: Color(0x8F0B1223),
          inputFocusedBg: Color(0xC2101A30),
          cardShadowColor: Color(0x80000000),
          cardGradientColors: [
            Color(0xC7101A30),
            Color(0xB30B1223),
            Color(0xB8171534),
          ],
          ctaGradientColors: [
            Color(0xAD143444),
            Color(0xA3182244),
            Color(0xAD2C2152),
          ],
          specularEdgeColors: [
            Color(0x0049E0D3),
            Color(0xFF49E0D3),
            Color(0xFFA88FFF),
            Color(0x00A88FFF),
          ],
          orb1Inner: Color(0x5249E0D3),
          orb1Outer: Color(0x240E7490),
          orb2Inner: Color(0x47A88FFF),
          orb2Outer: Color(0x1F38BDF8),
          coreGlowInner: Color(0x3649E0D3),
          coreGlowOuter: Color(0x1FA88FFF),
          halo1Border: Color(0x4049E0D3),
          halo2Border: Color(0x38A88FFF),
          crystalTop: Color(0xFF49E0D3),
          crystalSide: Color(0xFF8B72EE),
          crystalBottom: Color(0xFF2DD4BF),
          crystalDarkFacet: Color(0xFF164E63),
          crystal2Top: Color(0xFF99F6E4),
          crystal2Left: Color(0xFF0D9488),
          crystal2Right: Color(0xFF7C3AED),
          success: Color(0xFF2DD4BF),
          successSoft: Color(0x262DD4BF),
          warning: Color(0xFFFBBF24),
          warningSoft: Color(0x26FBBF24),
          error: Color(0xFFFB7185),
          errorSoft: Color(0x26FB7185),
        );

      case KadirPaletteMode.prisma:
        return const _KadirLoginTokens(
          isDark: false,
          canvasBg: Color(0xFFFFF7F3),
          primary: Color(0xFF9B325F),
          textMain: Color(0xFF2B243E),
          textMuted: Color(0xFF716585),
          cleanAccentText: Color(0xFF82264D),
          ctaText: Color(0xFF82264D),
          glassBorder: Color(0x389B325F),
          pillGlassBg: Color(0xC7FFFBF9),
          inputGlassBg: Color(0xA3FFFFFF),
          inputFocusedBg: Color(0xE0FFFFFF),
          cardShadowColor: Color(0x249B325F),
          cardGradientColors: [
            Color(0xCCFFFDFC),
            Color(0xA3FFEFEA),
            Color(0xADF3ECFF),
          ],
          ctaGradientColors: [
            Color(0xD6FFFCFA),
            Color(0xADFFE7DF),
            Color(0xB8F0E8FF),
          ],
          specularEdgeColors: [
            Color(0x009B325F),
            Color(0xFF9B325F),
            Color(0xFF6653CD),
            Color(0xFFF6C453),
            Color(0x00F6C453),
          ],
          orb1Inner: Color(0x47F472B6),
          orb1Outer: Color(0x1F9B325F),
          orb2Inner: Color(0x3D6653CD),
          orb2Outer: Color(0x1FF6C453),
          coreGlowInner: Color(0x3DFBCFE8),
          coreGlowOuter: Color(0x1F6653CD),
          halo1Border: Color(0x389B325F),
          halo2Border: Color(0x336653CD),
          crystalTop: Color(0xFFF472B6),
          crystalSide: Color(0xFFFDE68A),
          crystalBottom: Color(0xFF9B325F),
          crystalDarkFacet: Color(0xFF82264D),
          crystal2Top: Color(0xFFFFE7DF),
          crystal2Left: Color(0xFF9B325F),
          crystal2Right: Color(0xFF6653CD),
          success: Color(0xFF0D9488),
          successSoft: Color(0xFFCCFBF1),
          warning: Color(0xFFD97706),
          warningSoft: Color(0xFFFEF3C7),
          error: Color(0xFFE11D48),
          errorSoft: Color(0xFFFFE4E6),
        );

      case KadirPaletteMode.aurora:
        return const _KadirLoginTokens(
          isDark: false,
          canvasBg: Color(0xFFF3FAFD),
          primary: Color(0xFF047D8A),
          textMain: Color(0xFF172638),
          textMuted: Color(0xFF5C6E82),
          cleanAccentText: Color(0xFF03636E),
          ctaText: Color(0xFF03636E),
          glassBorder: Color(0x3D047D8A),
          pillGlassBg: Color(0xBDFFFFFF),
          inputGlassBg: Color(0xA3FFFFFF),
          inputFocusedBg: Color(0xE0FFFFFF),
          cardShadowColor: Color(0x24047D8A),
          cardGradientColors: [
            Color(0xC7FFFFFF),
            Color(0x9EEAF9FB),
            Color(0xA8F0EEFF),
          ],
          ctaGradientColors: [
            Color(0xCCFFFFFF),
            Color(0x9ED5F3F0),
            Color(0xA8ECE9FE),
          ],
          specularEdgeColors: [
            Color(0x00047D8A),
            Color(0xFF047D8A),
            Color(0xFF6F56D9),
            Color(0x006F56D9),
          ],
          orb1Inner: Color(0x522DD4BF),
          orb1Outer: Color(0x24047D8A),
          orb2Inner: Color(0x426F56D9),
          orb2Outer: Color(0x1F14B8A6),
          coreGlowInner: Color(0x3D5EEAD4),
          coreGlowOuter: Color(0x1F8B5CF6),
          halo1Border: Color(0x3B047D8A),
          halo2Border: Color(0x336F56D9),
          crystalTop: Color(0xFF5EEAD4),
          crystalSide: Color(0xFFCCFBF1),
          crystalBottom: Color(0xFF6F56D9),
          crystalDarkFacet: Color(0xFF0F766E),
          crystal2Top: Color(0xFFCCFBF1),
          crystal2Left: Color(0xFF14B8A6),
          crystal2Right: Color(0xFF6F56D9),
          success: Color(0xFF0D9488),
          successSoft: Color(0xFFCCFBF1),
          warning: Color(0xFFD97706),
          warningSoft: Color(0xFFFEF3C7),
          error: Color(0xFFE11D48),
          errorSoft: Color(0xFFFFE4E6),
        );
    }
  }
}