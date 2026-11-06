import 'package:flutter/material.dart';

enum KadirPaletteMode { aurora, orbita, prisma }

class KadirPaletteColors {
  final String name;
  final Color bgMain;
  final Color surface;
  final Color surfaceBorder;
  final Color surfaceSoft;
  final Color primary;
  final Color secondary;
  final Color textMain;
  final Color textMuted;
  final Color accent;
  final bool isDark;

  // Tokens Glassmorphism (Sección 3.5)
  final Color glassSurface;
  final Color glassSpecularBorder;
  final Color glassShardSurface;

  const KadirPaletteColors({
    required this.name,
    required this.bgMain,
    required this.surface,
    required this.surfaceBorder,
    required this.surfaceSoft,
    required this.primary,
    required this.secondary,
    required this.textMain,
    required this.textMuted,
    required this.accent,
    required this.isDark,
    required this.glassSurface,
    required this.glassSpecularBorder,
    required this.glassShardSurface,
  });

  // 1. ESTILO AURORA (Claridad y Descubrimiento - Predeterminado)
  static const aurora = KadirPaletteColors(
    name: 'Aurora',
    bgMain: Color(0xFFF3FAFD),
    surface: Color(0xFFFFFFFF),
    surfaceBorder: Color(0xFFE1EDF2),
    surfaceSoft: Color(0xFFD5F3F0),
    primary: Color(0xFF047D8A),
    secondary: Color(0xFF6F56D9),
    textMain: Color(0xFF172638),
    textMuted: Color(0xFF5C6E82),
    accent: Color(0xFFF3B76B),
    isDark: false,
    glassSurface: Color(0x94FFFFFF),        // Blanco cristal 58%
    glassSpecularBorder: Color(0xC7FFFFFF), // Bisel blanco 78%
    glassShardSurface: Color(0x94FFFFFF),
  );

  // 2. ESTILO ÓRBITA (Profundidad Abisal - Oscuro Mejorado)
  static const orbita = KadirPaletteColors(
    name: 'Órbita',
    bgMain: Color(0xFF070B14),              // Azul abisal profundo
    surface: Color(0xFF101726),             // Obsidiana nocturna
    surfaceBorder: Color(0xFF1E2B45),
    surfaceSoft: Color(0xFF19253D),
    primary: Color(0xFF49E0D3),             // Turquesa luminoso
    secondary: Color(0xFFA88FFF),           // Lavanda
    textMain: Color(0xFFF5F9FF),
    textMuted: Color(0xFF8CA2C0),
    accent: Color(0xFFF6C453),              // Amarillo solar
    isDark: true,
    glassSurface: Color(0xA30A0F1C),        // Cristal ahumado oscuro 64%
    glassSpecularBorder: Color(0x24FFFFFF), // Bisel especular sutil 14%
    glassShardSurface: Color(0x1749E0D3),
  );

  // 3. ESTILO PRISMA (Creatividad y Expresión - Cálido)
  static const prisma = KadirPaletteColors(
    name: 'Prisma',
    bgMain: Color(0xFFFFF7F3),
    surface: Color(0xFFFFFFFF),
    surfaceBorder: Color(0xFFF2DFD7),
    surfaceSoft: Color(0xFFFFE7DF),
    primary: Color(0xFF9B325F),             // Ciruela intenso
    secondary: Color(0xFF6653CD),           // Violeta profundo
    textMain: Color(0xFF2B243E),
    textMuted: Color(0xFF716585),
    accent: Color(0xFFF6C453),
    isDark: false,
    glassSurface: Color(0x99FFFFFF),        // Blanco cálido cristal 60%
    glassSpecularBorder: Color(0xD1FFFFFF), // Bisel blanco 82%
    glassShardSurface: Color(0x94FFFFFF),
  );

  static KadirPaletteColors fromMode(KadirPaletteMode mode) {
    switch (mode) {
      case KadirPaletteMode.aurora:
        return aurora;
      case KadirPaletteMode.orbita:
        return orbita;
      case KadirPaletteMode.prisma:
        return prisma;
    }
  }
}