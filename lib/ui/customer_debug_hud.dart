import 'package:flutter/material.dart';

import '../game/customers/customer_manager.dart';

/// Temporary shopper count. Remove this widget when the customer HUD is designed.
class CustomerDebugHud extends StatelessWidget {
  const CustomerDebugHud({super.key, required this.customers});

  final CustomerManager customers;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: customers,
      builder: (context, _) {
        final lines = <String>['Active Customers: ${customers.activeCount}'];
        for (final customer in customers.active) {
          final x = customer.position.x.toStringAsFixed(2);
          final z = customer.position.z.toStringAsFixed(2);
          lines.add('${customer.stateLabel}  X $x  Z $z');
        }
        return Material(
          color: const Color(0xCC111111),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              lines.join('\n'),
              key: const Key('customer-debug-hud'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ),
        );
      },
    );
  }
}
