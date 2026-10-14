import 'package:flutter/material.dart';

class InteractionButton extends StatelessWidget {
  const InteractionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: const Key('interact-button'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        minimumSize: const Size(180, 52),
        elevation: 4,
        shadowColor: const Color(0x662E7D32),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
