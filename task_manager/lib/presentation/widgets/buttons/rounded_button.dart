import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool hasCircle;
  final VoidCallback onPressed;
  final Color? backgroundColor; // Make this nullable
  final Color? textColor;
  final double borderRadius;

  const RoundedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.hasCircle = false,
    this.backgroundColor, // Nullable to ensure no default is applied internally
    this.textColor,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // backgroundColor: backgroundColor, // Only applied if provided
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: EdgeInsets.zero,
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasCircle)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: textColor,
                ),
              ),
            Text(
              text,
              style: TextStyle(
                color: textColor ?? Theme.of(context).textTheme.labelLarge!.color,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4.0),
              Icon(
                icon,
                color: textColor ?? Theme.of(context).textTheme.labelLarge!.color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
