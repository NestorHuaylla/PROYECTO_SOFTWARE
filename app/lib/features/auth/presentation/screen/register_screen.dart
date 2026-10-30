
import 'package:flutter/material.dart';
import '../../data/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _identifierController = TextEditingController();
  final _aliasController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color background = Color(0xFF171A2B);
  static const Color primary = Color(0xFF22CFC3);
  static const Color fieldColor = Color(0xFF24283D);
  static const Color textColor = Color(0xFFF7F8FC);
  static const Color secondaryText = Color(0xFFAEB4C7);

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService().register(
        _identifierController.text.trim(),
        _aliasController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta creada correctamente'),
          backgroundColor: Color(0xFF168B7D),
        ),
      );

      _formKey.currentState!.reset();
      _identifierController.clear();
      _aliasController.clear();
      _passwordController.clear();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo registrar: $error'),
          backgroundColor: Color(0xFFD95858),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _aliasController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          style: const TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: secondaryText),
            prefixIcon: Icon(icon, color: secondaryText),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: secondaryText,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: fieldColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF41465C)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: primary, width: 1.5),
            ),
            errorMaxLines: 2,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Este campo es obligatorio';
            }

            if (isPassword && value.length < 8) {
              return 'La contraseña debe tener al menos 8 caracteres';
            }

            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 26,
            vertical: 30,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 34),

                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.hub_outlined,
                    color: primary,
                    size: 35,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Empieza a descubrir.',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 31,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.8,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Crea tu espacio para desarrollar nuevas habilidades.',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 36),

                _inputField(
                  label: 'Identificador único',
                  hint: 'Ej. estudiante2026',
                  controller: _identifierController,
                  icon: Icons.alternate_email_rounded,
                ),

                const SizedBox(height: 22),

                _inputField(
                  label: 'Alias',
                  hint: '¿Cómo quieres que te llamemos?',
                  controller: _aliasController,
                  icon: Icons.person_outline_rounded,
                ),

                const SizedBox(height: 22),

                _inputField(
                  label: 'Contraseña',
                  hint: 'Mínimo 8 caracteres',
                  controller: _passwordController,
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),

                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: background,
                      disabledBackgroundColor: primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: background,
                            ),
                          )
                        : const Text(
                            'Crear cuenta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 28),

                Center(
                  child: TextButton(
                    onPressed: () {
                      // Aquí conectaremos la pantalla de login.
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: '¿Ya tienes una cuenta? ',
                        style: TextStyle(color: secondaryText),
                        children: [
                          TextSpan(
                            text: 'Iniciar sesión',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }
}
