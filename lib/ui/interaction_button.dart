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
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
