import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void openNext(BuildContext context, String title, String description) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _NextScreenPlaceholder(
          title: title,
          description: description,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C16),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final visualHeight = constraints.maxHeight < 680 ? 205.0 : 265.0;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _BrandHeader(),
                          const SizedBox(height: 35),
                          _HeroIllustration(height: visualHeight),
                          const SizedBox(height: 28),
                          const Text(
                            'UNA NUEVA FORMA DE APRENDER',
                            style: TextStyle(
                              color: Color(0xFF64E0DB),
                              fontSize: 10,
                              letterSpacing: 2.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: 'Las ideas se conectan.\n'),
                                TextSpan(
                                  text: 'Tú las haces avanzar.',
                                  style: TextStyle(color: Color(0xFF78E7E4)),
                                ),
                              ],
                            ),
                            style: TextStyle(
                              color: Color(0xFFF5F9FF),
                              fontWeight: FontWeight.w700,
                              fontSize: 32,
                              height: 1.16,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Explora conceptos, experimenta con ideas y '
                            'construye conocimiento a tu manera.',
                            style: TextStyle(
                              color: Color(0xFFA4B4C8),
                              height: 1.55,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 34),
                          SizedBox(
                            height: 56,
                            child: FilledButton(
                              onPressed: () => openNext(
                                context,
                                'Onboarding',
                                'Aquí construiremos tu recorrido inicial de aprendizaje.',
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF55DCD5),
                                foregroundColor: const Color(0xFF071821),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Comenzar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => openNext(
                              context,
                              'Iniciar sesión',
                              'Aquí integraremos el acceso a tu cuenta.',
                            ),
                            child: const Text(
                              'Ya tengo una cuenta',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFDFEAF6),
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
          },
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: const LinearGradient(
              colors: [Color(0xFF3DCFCB), Color(0xFF8A77E9)],
            ),
          ),
          child: const Icon(Icons.hub_outlined, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 12),
        const Text(
          'NEXORA',
          style: TextStyle(
            color: Color(0xFFF1F6FC),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.8,
          ),
        ),
      ],
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const RadialGradient(
                  colors: [Color(0xFF193344), Color(0xFF080C16)],
                  radius: 0.85,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/images/gears_preview.webp',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, error, stackTrace) => const Icon(
                  Icons.settings,
                  color: Color(0xFF63DED9),
                  size: 100,
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xCC111A29),
                border: Border.all(color: const Color(0x665BDEE3)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'EXPLORA · CONECTA · CREA',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFFC6EDF0),
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextScreenPlaceholder extends StatelessWidget {
  const _NextScreenPlaceholder({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C16),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF080C16),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFCBD7E5), fontSize: 18),
          ),
        ),
      ),
    );
  }
}
