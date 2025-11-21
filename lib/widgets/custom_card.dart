import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  // Optional vibrant shadow color for accent glow. If null, uses theme-based subtle shadow.
  final Color? shadowColor;
  // Optional multi-color shadows for a colorful glow around the card.
  final List<Color>? shadowColors;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.shadowColor,
    this.shadowColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    List<BoxShadow> _buildColorfulShadows(List<Color> colors) {
      // Layer multiple soft glows with subtle offsets to create a colorful aura
      final List<BoxShadow> shadows = [];
      for (int i = 0; i < colors.length; i++) {
        final c = colors[i];
        // Vary blur and offset to spread hues around the card
        shadows.add(
          BoxShadow(
            color: c.withValues(alpha: 0.35 - (i * 0.07).clamp(0.0, 0.25)),
            blurRadius: 18 + (i * 10),
            spreadRadius: -2 + i.toDouble(),
            offset: switch (i % 3) {
              0 => const Offset(-3, 8),
              1 => const Offset(6, 10),
              _ => const Offset(-6, -2),
            },
          ),
        );
      }
      return shadows;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? 
               (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Colorful multi-hue glow takes priority when provided.
          if (shadowColors != null && shadowColors!.isNotEmpty)
            ..._buildColorfulShadows(shadowColors!)
          // When a single vibrant shadowColor is provided, use a bigger, brighter glow.
          else if (shadowColor != null)
            BoxShadow(
              color: shadowColor!.withValues(alpha: 0.45),
              blurRadius: 24,
              spreadRadius: 1,
              offset: const Offset(0, 10),
            )
          else
            BoxShadow(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}