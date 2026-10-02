import 'package:flutter/material.dart';

class LucBranding extends StatelessWidget {
  final double logoSize;
  final bool compact;
  final bool dark;

  const LucBranding({
    super.key,
    this.logoSize = 58,
    this.compact = false,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = dark ? Colors.white : const Color(0xFF9E1B32);
    final secondary = dark ? Colors.white70 : const Color(0xFF4A4A4A);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(logoSize * .18),
            border: Border.all(color: const Color(0xFF9E1B32), width: 2),
          ),
          child: Center(
            child: Text(
              'L',
              style: TextStyle(
                color: const Color(0xFF9E1B32),
                fontSize: logoSize * .52,
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
              ),
            ),
          ),
        ),
        SizedBox(width: compact ? 10 : 14),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LINCOLN',
                style: TextStyle(
                  color: primary,
                  fontSize: compact ? 15 : 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: compact ? 1.2 : 1.8,
                ),
              ),
              Text(
                'UNIVERSITY COLLEGE',
                style: TextStyle(
                  color: secondary,
                  fontSize: compact ? 8.5 : 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: compact ? .8 : 1.1,
                ),
              ),
              if (!compact) const SizedBox(height: 3),
              if (!compact)
                Text(
                  'Student Portal',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class LucSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const LucSectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF202124),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ],
    );
  }
}
