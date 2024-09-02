import 'package:flutter/material.dart';

class BasicButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color? textColor;
  final double borderRadius;

  const BasicButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor = Colors.white70,
    this.textColor,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
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
            Text(
              text,
              style: TextStyle(
                  color: textColor ??
                      Theme.of(context).textTheme.labelLarge!.color),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4.0),
              Icon(icon, color: textColor ?? Theme.of(context).textTheme.labelLarge!.color),
            ],
          ],
        ),
      ),
    );
  }
}
