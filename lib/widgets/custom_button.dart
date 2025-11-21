import 'package:flutter/material.dart';

enum CustomButtonStyle { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = CustomButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color getBackgroundColor() {
      if (onPressed == null) return Colors.grey.shade400;
      
      switch (style) {
        case CustomButtonStyle.primary:
          return theme.colorScheme.primary;
        case CustomButtonStyle.secondary:
          return isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);
        case CustomButtonStyle.outline:
        case CustomButtonStyle.text:
          return Colors.transparent;
      }
    }

    Color getTextColor() {
      if (onPressed == null) return Colors.grey.shade600;
      
      switch (style) {
        case CustomButtonStyle.primary:
          return Colors.white;
        case CustomButtonStyle.secondary:
          return theme.colorScheme.onSurface;
        case CustomButtonStyle.outline:
        case CustomButtonStyle.text:
          return theme.colorScheme.primary;
      }
    }

    BorderSide? getBorder() {
      switch (style) {
        case CustomButtonStyle.outline:
          return BorderSide(color: theme.colorScheme.primary, width: 1.5);
        default:
          return null;
      }
    }

    Widget buildContent() {
      if (isLoading) {
        return SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: getTextColor(),
          ),
        );
      }

      if (icon != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: getTextColor()),
            const SizedBox(width: 8),
            Text(
              text,
              style: theme.textTheme.labelLarge?.copyWith(
                color: getTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }

      return Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: getTextColor(),
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final border = getBorder();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: border != null ? Border.fromBorderSide(border) : null,
      ),
      child: Material(
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(child: buildContent()),
          ),
        ),
      ),
    );
  }
}