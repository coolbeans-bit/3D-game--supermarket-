import 'package:flutter/material.dart';

import '../game/interaction/interaction_system.dart';
import 'interaction_button.dart';
import 'price_label.dart';

/// Name and action for the object under the reticle. Empty when nothing is aimed.
class InteractionPrompt extends StatelessWidget {
  const InteractionPrompt({super.key, required this.system, this.refresh});

  final InteractionSystem system;

  /// Extra source, such as the carry controller, that can change the prompt
  /// text without changing which object is aimed.
  final Listenable? refresh;

  @override
  Widget build(BuildContext context) {
    final listenable = refresh == null
        ? system
        : Listenable.merge([system, refresh!]);
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        final aim = system.aim;
        if (aim == null) {
          return const SizedBox.shrink();
        }
        return Material(
          color: const Color(0xF7FFF6E8),
          elevation: 6,
          shadowColor: const Color(0x66000000),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  aim.target.displayName,
                  key: const Key('interaction-name'),
                  style: const TextStyle(
                    fontFamily: 'Nirmala UI',
                    fontFamilyFallback: [
                      'Segoe UI',
                      'Noto Sans Devanagari',
                      'Mangal',
                    ],
                    color: Color(0xFF1B5E20),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (aim.target.priceAmount != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    temporaryPriceLabel(aim.target.priceAmount!),
                    key: const Key('interaction-price'),
                    style: const TextStyle(
                      color: Color(0xFF6D4C41),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                InteractionButton(
                  label: aim.target.prompt,
                  onPressed: system.interact,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
