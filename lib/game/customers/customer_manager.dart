import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';

import '../../data/catalog/product_catalog.dart';
import '../world/collision_box.dart';
import '../world/supermarket/supermarket_layout.dart';
import 'customer.dart';
import 'customer_movement.dart';
import 'customer_spawner.dart';
import 'store_customer_route.dart';

/// Spawns, moves, and retires shoppers.
///
/// The scene only copies their positions onto nodes. Checkout, shelf pickup,
/// and pathfinding are not part of this manager; a later state in
/// [advanceCustomer] can add them.
class CustomerManager extends ChangeNotifier {
  CustomerManager({
    ProductCatalog? catalog,
    this.config = const CustomerSpawnConfig(),
    CustomerSpawner? spawner,
    StoreCustomerRoute? route,
  }) : _spawner =
           spawner ??
           CustomerSpawner(
             catalog: catalog ?? ProductCatalog.starter,
             config: config,
             route: route ?? StoreCustomerRoute.standard,
           ),
       _wait = config.initialDelay;

  final CustomerSpawnConfig config;
  final CustomerSpawner _spawner;
  final List<Customer> _active = [];
  final List<CollisionBox> _obstacles = [];
  final Map<String, CollisionBox> _playerBlocks = {};
  final Map<String, CollisionBox> _peerBlocks = {};
  CollisionWorld? _world;
  double _wait;

  Iterable<Customer> get active => _active;

  int get activeCount => _active.length;

  /// Moves shoppers and refreshes the boxes that keep the player outside them.
  void tick(double dt, CollisionWorld world, {Vector3? avoid}) {
    _world = world;
    final step = dt.clamp(0.0, 0.05);
    var changed = false;
    _wait -= step;
    if (_wait <= 0) {
      if (_spawn(avoid)) {
        changed = true;
      }
      _wait = config.spawnInterval;
    }
    for (final customer in _active) {
      final before = customer.state;
      _obstacles.clear();
      for (final box in world.boxes) {
        if (!_playerBlocks.containsValue(box)) {
          _obstacles.add(box);
        }
      }
      for (final other in _active) {
        if (other != customer) {
          _obstacles.add(_peerBlock(other));
        }
      }
      advanceCustomer(
        customer: customer,
        dt: step,
        limit: world.limit,
        obstacles: _obstacles,
      );
      if (customer.state != before) {
        changed = true;
      }
    }
    final removed = _active.length;
    _active.removeWhere((customer) => customer.state == CustomerState.exited);
    if (_active.length != removed) {
      changed = true;
    }
    _syncPlayerBlocks(world);
    if (changed) {
      notifyListeners();
    }
  }

  CollisionBox _peerBlock(Customer other) {
    final box = _peerBlocks.putIfAbsent(
      other.id,
      () => CollisionBox(minX: 0, maxX: 0, minZ: 0, maxZ: 0),
    );
    CustomerMetrics.writeReach(box, other.position, CustomerMetrics.radius * 2);
    return box;
  }

  bool _spawn(Vector3? avoid) {
    final occupied = <Vector3>[
      for (final customer in _active) customer.position,
      ?avoid,
    ];
    final customer = _spawner.trySpawn(
      activeCount: _active.length,
      occupied: occupied,
    );
    if (customer == null) {
      return false;
    }
    _active.add(customer);
    return true;
  }

  void _syncPlayerBlocks(CollisionWorld world) {
    final live = <String>{};
    for (final customer in _active) {
      live.add(customer.id);
      final box = _playerBlocks.putIfAbsent(customer.id, () {
        final created = CollisionBox(minX: 0, maxX: 0, minZ: 0, maxZ: 0);
        world.boxes.add(created);
        return created;
      });
      CustomerMetrics.writeReach(
        box,
        customer.position,
        CustomerMetrics.radius + SupermarketLayout.playerRadius,
      );
    }
    final gone = [
      for (final id in _playerBlocks.keys)
        if (!live.contains(id)) id,
    ];
    for (final id in gone) {
      world.boxes.remove(_playerBlocks.remove(id));
      _peerBlocks.remove(id);
    }
  }

  @override
  void dispose() {
    final world = _world;
    if (world != null) {
      for (final box in _playerBlocks.values) {
        world.boxes.remove(box);
      }
    }
    _active.clear();
    _playerBlocks.clear();
    _peerBlocks.clear();
    super.dispose();
  }
}
