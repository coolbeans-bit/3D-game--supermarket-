import 'package:flutter/material.dart';

import '../data/catalog/product_catalog.dart';
import '../game/carry/carry_controller.dart';
import '../game/carry/shopping_basket.dart';

/// What is in the basket, with a way to take one item out or put it down.
class BasketHud extends StatelessWidget {
  const BasketHud({
    super.key,
    required this.basket,
    required this.catalog,
    required this.carry,
    required this.onTakeOut,
    required this.onPutDown,
  });

  final ShoppingBasket basket;
  final ProductCatalog catalog;
  final CarryController carry;
  final bool Function(int index) onTakeOut;
  final VoidCallback onPutDown;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([basket, carry]),
      builder: (context, _) {
        if (!basket.carried) {
          return const SizedBox.shrink();
        }
        final busy = carry.isHolding;
        return Material(
          color: const Color(0xE6FFF6E8),
          elevation: 3,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Basket ${basket.count}/${ShoppingBasket.capacity}',
                  key: const Key('basket-count'),
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  busy
                      ? 'Place the item in your hands, then take another out.'
                      : 'Out puts one item in your hands. Put down leaves the basket where you stand.',
                  style: const TextStyle(
                    color: Color(0xFF6D4C41),
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
                for (var i = 0; i < basket.productIds.length; i++)
                  _BasketRow(
                    name:
                        catalog.lookup(basket.productIds[i])?.marathiName ??
                        basket.productIds[i],
                    enabled: !busy,
                    onPressed: () => onTakeOut(i),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: const Key('basket-put-down'),
                    onPressed: onPutDown,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6D4C41),
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Put basket down',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BasketRow extends StatelessWidget {
  const _BasketRow({
    required this.name,
    required this.enabled,
    required this.onPressed,
  });

  final String name;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Nirmala UI',
            fontFamilyFallback: ['Segoe UI', 'Noto Sans Devanagari', 'Mangal'],
            color: Color(0xFF3E2723),
            fontSize: 12,
            height: 1.2,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: enabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF1B5E20),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 28),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Out',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
