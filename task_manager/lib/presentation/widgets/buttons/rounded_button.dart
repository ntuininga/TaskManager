import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool hasCircle;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final double? maxWidth; // Optional maxWidth for truncating text

  const RoundedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.hasCircle = false,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8.0,
    this.maxWidth, // Pass a maximum width if needed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity, // Constrain width if provided
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Added padding for better spacing
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min, // Ensures button size is minimized to content
          children: [
            if (hasCircle)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: textColor ?? Colors.grey, // Default color if textColor is null
                ),
              ),
            // Wrap the Text widget with a Flexible widget to ensure it takes available space up to maxWidth
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis, // Truncate text with ellipsis if it's too long
                maxLines: 1, // Ensure it's a single line
                style: TextStyle(
                  color: textColor ?? Theme.of(context).textTheme.labelLarge?.color ?? Colors.black, // Fallback color
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4.0),
              Icon(
                icon,
                color: textColor ?? Theme.of(context).textTheme.labelLarge?.color ?? Colors.black, // Fallback color
              ),
            ],
          ],
        ),
      ),
    );
  }
}
