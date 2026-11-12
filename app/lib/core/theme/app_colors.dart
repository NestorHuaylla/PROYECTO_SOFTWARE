import 'package:flutter/material.dart';

enum KadirPaletteMode { aurora, orbita, prisma }

// Alias para compatibilidad con widgets existentes
typedef KadirPaletteColors = AppColors;

class AppColors {
  final String name;
  final bool isDark;
  final Color bgMain;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color textMain;
  final Color textMuted;
  final Color primaryText;
  final Color glassSurface;
  final Color glassBorder;

  const AppColors({
    required this.name,
    required this.isDark,
    required this.bgMain,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.textMain,
    required this.textMuted,
    required this.primaryText,
    required this.glassSurface,
    required this.glassBorder,
  });

  // Getters para compatibilidad con efectos Glassmorphism en Splash y Logo
  Color get glassSpecularBorder => glassBorder;
  Color get glassShardSurface => glassSurface;
  Color get surfaceBorder => glassBorder;
  Color get surfaceSoft => isDark ? const Color(0xFF19253D) : const Color(0xFFD5F3F0);

  // Obtener paleta por modo (Aurora, Órbita, Prisma)
  static AppColors fromMode(KadirPaletteMode mode) => palettes[mode]!;

  // Tokens oficiales de Cuarzo Pastel para botones CTA
  static const List<Color> pastelQuartzPrimaryGradient = [
    Color(0xFFF3E8FF),
    Color(0xFFE9D5FF),
    Color(0xFFF5D0FE),
    Color(0xFFFCE7F3),
  ];

  static const List<Color> pastelQuartzInkGradient = [
    Color(0xFF2E1065),
    Color(0xFF4C1D95),
    Color(0xFF581C87),
  ];

  // Las 3 paletas oficiales del documento de diseño VERSION-DISEÑO1.0.txt
  static const Map<KadirPaletteMode, AppColors> palettes = {
    KadirPaletteMode.aurora: AppColors(
      name: 'Aurora',
      isDark: false,
      bgMain: Color(0xFFF3FAFD),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF047D8A),
      secondary: Color(0xFF6F56D9),
      accent: Color(0xFFF3B76B),
      textMain: Color(0xFF172638),
      textMuted: Color(0xFF5A6B7C),
      primaryText: Color(0xFFFFFFFF),
      glassSurface: Color(0xB8FFFFFF),
      glassBorder: Color(0xCCFFFFFF),
    ),
    KadirPaletteMode.orbita: AppColors(
      name: 'Órbita',
      isDark: true,
      bgMain: Color(0xFF070B14),
      surface: Color(0xFF101726),
      primary: Color(0xFF49E0D3),
      secondary: Color(0xFFA88FFF),
      accent: Color(0xFFF6C453),
      textMain: Color(0xFFF5F9FF),
      textMuted: Color(0xFF94A3B8),
      primaryText: Color(0xFF06101E),
      glassSurface: Color(0xA3101726),
      glassBorder: Color(0x47FFFFFF),
    ),
    KadirPaletteMode.prisma: AppColors(
      name: 'Prisma',
      isDark: false,
      bgMain: Color(0xFFFFF7F3),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF9B325F),
      secondary: Color(0xFF6653CD),
      accent: Color(0xFFF6C453),
      textMain: Color(0xFF2B243E),
      textMuted: Color(0xFF6E627D),
      primaryText: Color(0xFFFFFFFF),
      glassSurface: Color(0xB8FFFFFF),
      glassBorder: Color(0xCCFFFFFF),
    ),
  };
}