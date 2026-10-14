import 'package:flutter/material.dart';

import '../game/customers/customer_manager.dart';

/// Small shopper count. Hidden while the store is empty.
class CustomerDebugHud extends StatelessWidget {
  const CustomerDebugHud({super.key, required this.customers});

  final CustomerManager customers;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: customers,
      builder: (context, _) {
        if (customers.activeCount == 0) {
          return const SizedBox.shrink();
        }
        return Material(
          color: const Color(0xE6FFF6E8),
          elevation: 3,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'Shoppers ${customers.activeCount}',
              key: const Key('customer-debug-hud'),
              style: const TextStyle(
                color: Color(0xFF1B5E20),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      },
    );
  }
}
