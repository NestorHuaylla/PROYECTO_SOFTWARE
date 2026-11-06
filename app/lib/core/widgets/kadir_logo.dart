import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class KadirLogo extends StatelessWidget {
  final KadirPaletteColors colors;
  final double size;

  const KadirLogo({
    super.key,
    required this.colors,
    this.size = 102,
  });

  String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final p = _hex(colors.primary);
    final s = _hex(colors.secondary);
    final a = _hex(colors.accent);
    final bg0 = colors.isDark ? '#101829' : '#FFFFFF';
    final bg1 = colors.isDark ? '#050811' : '#DFF4F7';
    final pedOpacity = colors.isDark ? '0.05' : '0.45';

    final svgCode = '''
<svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="isoBg" x1="0" y1="0" x2="64" y2="64" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="$bg0" />
      <stop offset="100%" stop-color="$bg1" />
    </linearGradient>
    <linearGradient id="isoCol" x1="13" y1="11" x2="29" y2="53" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="$p" />
      <stop offset="100%" stop-color="$s" />
    </linearGradient>
  </defs>
  <rect x="2" y="2" width="60" height="60" rx="18" fill="url(#isoBg)" stroke="$p" stroke-opacity="0.32" stroke-width="1.5" />
  <polygon points="32,7 54,19 54,45 32,57 10,45 10,19" fill="#FFFFFF" fill-opacity="$pedOpacity" stroke="#FFFFFF" stroke-opacity="0.35" stroke-width="0.9" />
  <polygon points="21,11 29,15 29,49 21,53 13,49 13,15" fill="url(#isoCol)" />
  <polygon points="21,11 29,15 21,19 13,15" fill="#FFFFFF" fill-opacity="0.55" />
  <polygon points="13,15 21,19 21,53 13,49" fill="#000000" fill-opacity="0.16" />
  <polygon points="26,30 44,13 51,17 33,34" fill="$s" fill-opacity="0.92" />
  <polygon points="26,30 44,13 44,21 26,38" fill="$p" fill-opacity="0.82" />
  <polygon points="28,28 51,45 44,51 23,34" fill="$a" fill-opacity="0.95" />
  <polygon points="26,25 34,32 26,39 18,32" fill="#FFFFFF" fill-opacity="0.96" />
  <polygon points="26,28 30,32 26,36 22,32" fill="$p" fill-opacity="0.85" />
</svg>
''';

    return SvgPicture.string(
      svgCode,
      width: size,
      height: size,
    );
  }
}