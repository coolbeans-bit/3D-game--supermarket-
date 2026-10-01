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
          color: const Color(0xCC111111),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  aim.target.displayName,
                  key: const Key('interaction-name'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (aim.target.priceAmount != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    temporaryPriceLabel(aim.target.priceAmount!),
                    key: const Key('interaction-price'),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 8),
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
