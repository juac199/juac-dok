import 'package:flutter/material.dart';

class Option3 {
  static const Color navy = Color(0xFF164A7B);
  static const Color navyDark = Color(0xFF0E3559);
  static const Color blue = Color(0xFF1769D1);
  static const Color blueLight = Color(0xFFEAF4FF);
  static const Color page = Color(0xFFF7FAFE);
  static const Color text = Color(0xFF17324D);
  static const Color muted = Color(0xFF71839A);
  static const Color border = Color(0xFFDCE8F4);
  static const Color white = Colors.white;

  static Color pageColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color textColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color mutedColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: .68);
  }

  static Color borderColor(BuildContext context) {
    return Theme.of(context).colorScheme.outlineVariant;
  }

  static Color blueColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color blueLightColor(BuildContext context) {
    return Theme.of(context).colorScheme.primaryContainer;
  }

  static Color cardColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static LinearGradient headerGradientFor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [scheme.primary, scheme.secondary],
    );
  }

  static LinearGradient softGradientFor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [scheme.surface, scheme.surfaceContainerHighest],
    );
  }

  static BoxDecoration themedCard(
    BuildContext context, {
    Color? color,
    double radius = 18,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: color ?? scheme.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: scheme.outlineVariant),
      boxShadow: [
        BoxShadow(
          color: scheme.shadow.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? .30 : .08,
          ),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF174C80), Color(0xFF246AA5)],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDFEFF), Color(0xFFEAF4FF)],
  );

  static BoxDecoration card({Color color = Colors.white, double radius = 18}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x120E3559),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
    );
  }

  static BoxDecoration softCard({double radius = 18}) {
    return BoxDecoration(
      gradient: softGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border),
    );
  }

  static TextStyle title({double size = 22}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: text,
      letterSpacing: -0.3,
    );
  }

  static TextStyle body({double size = 14}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: muted,
      height: 1.45,
    );
  }

  static TextStyle label({double size = 14}) {
    return TextStyle(fontSize: size, fontWeight: FontWeight.w600, color: text);
  }

  static Widget sectionTitle(
    String title, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Expanded(child: Text(title, style: label(size: 16))),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action,
              style: const TextStyle(color: blue, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  static Widget iconBox(
    IconData icon, {
    Color background = blueLight,
    Color foreground = blue,
    double size = 46,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: foreground, size: size * .48),
    );
  }

  static Widget serviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconBackground = blueLight,
    Color iconColor = blue,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: card(radius: 17),
          child: Row(
            children: [
              iconBox(
                icon,
                background: iconBackground,
                foreground: iconColor,
                size: 45,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: label()),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: body(size: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: muted),
            ],
          ),
        ),
      ),
    );
  }

  static Widget quickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color background = blueLight,
    Color foreground = blue,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              iconBox(
                icon,
                background: Colors.white.withValues(alpha: .82),
                foreground: foreground,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget pageBackground({required Widget child}) {
    return Container(
      color: page,
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blue.withValues(alpha: .045),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: navy.withValues(alpha: .035),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  static ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: page,
      colorScheme: ColorScheme.fromSeed(
        seedColor: navy,
        brightness: Brightness.light,
      ).copyWith(primary: navy, secondary: blue, surface: white),
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
      ),
    );
  }
}
