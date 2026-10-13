import 'dart:math';

import 'package:vector_math/vector_math.dart';

import '../../data/catalog/product_catalog.dart';
import 'customer.dart';
import 'customer_id_sequence.dart';
import 'customer_type.dart';
import 'shopping_list.dart';
import 'store_customer_route.dart';

/// Creates shoppers at the porch while the active limit has room.
class CustomerSpawner {
  CustomerSpawner({
    required this.catalog,
    required this.config,
    required this.route,
    Random? random,
    List<CustomerType>? types,
  }) : _random = random ?? Random(1),
       _types = types ?? CustomerType.roster;

  final ProductCatalog catalog;
  final CustomerSpawnConfig config;
  final StoreCustomerRoute route;
  final Random _random;
  final List<CustomerType> _types;
  final CustomerIdSequence _ids = CustomerIdSequence();

  /// The next shopper, or null when the store is already full or the porch
  /// spawn is occupied.
  Customer? trySpawn({
    required int activeCount,
    required Iterable<Vector3> occupied,
  }) {
    if (activeCount >= config.maxActive) {
      return null;
    }
    if (_types.isEmpty) {
      return null;
    }
    for (final position in occupied) {
      final dx = position.x - route.spawn.x;
      final dz = position.z - route.spawn.z;
      if (dx * dx + dz * dz < config.spawnClearance * config.spawnClearance) {
        return null;
      }
    }
    final issued = _ids.next();
    final type = _types[(issued.number - 1) % _types.length];
    return Customer(
      id: issued.id,
      type: type,
      shoppingList: generateShoppingList(
        catalog: catalog,
        random: _random,
        limits: config.listLimits,
      ),
      position: route.spawn,
      enteringPath: route.entering,
      leavingPath: route.leaving,
    );
  }
}

/// Tunable limits for how many shoppers exist and what they intend to buy.
class CustomerSpawnConfig {
  const CustomerSpawnConfig({
    this.maxActive = 3,
    this.spawnInterval = 4,
    this.initialDelay = 0.8,
    this.spawnClearance = 0.85,
    this.listLimits = const ShoppingListLimits(),
  });

  final int maxActive;
  final double spawnInterval;
  final double initialDelay;

  /// Meters. A new shopper waits while someone is still standing on the porch.
  final double spawnClearance;
  final ShoppingListLimits listLimits;
}
