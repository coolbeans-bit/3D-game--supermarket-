import 'dart:math';

import 'package:asmitra_game/data/catalog/product_catalog.dart';
import 'package:asmitra_game/game/customers/customer.dart';
import 'package:asmitra_game/game/customers/customer_manager.dart';
import 'package:asmitra_game/game/customers/customer_movement.dart';
import 'package:asmitra_game/game/customers/customer_spawner.dart';
import 'package:asmitra_game/game/customers/customer_type.dart';
import 'package:asmitra_game/game/customers/shopping_list.dart';
import 'package:asmitra_game/game/customers/store_customer_route.dart';
import 'package:asmitra_game/game/customers/waypoint.dart';
import 'package:asmitra_game/game/player/player_movement.dart';
import 'package:asmitra_game/game/world/collision_box.dart';
import 'package:asmitra_game/game/world/supermarket/supermarket_layout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  test('a customer has a unique id', () {
    final manager = _manager();
    _fill(manager);
    final ids = manager.active.map((customer) => customer.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    expect(ids, containsAll(['customer-001', 'customer-002', 'customer-003']));
  });

  test('customer type configuration is valid', () {
    final ids = CustomerType.roster.map((type) => type.id).toSet();
    expect(ids, hasLength(CustomerType.roster.length));
    for (final type in CustomerType.roster) {
      expect(type.label, isNotEmpty);
      expect(type.speed, greaterThan(0));
      expect(type.patience, greaterThan(0));
    }
  });

  test('customer speed follows the type configuration', () {
    expect(
      CustomerType.quickShopper.speed,
      greaterThan(CustomerType.regular.speed),
    );
    expect(
      CustomerType.regular.speed,
      greaterThan(CustomerType.slowShopper.speed),
    );
    final manager = _manager();
    _fill(manager);
    for (final customer in manager.active) {
      expect(customer.speed, customer.type.speed);
    }
    expect(manager.active.first.type.id, 'regular');
    expect(manager.active.elementAt(1).type.id, 'quick-shopper');
    expect(manager.active.elementAt(2).type.id, 'slow-shopper');
  });

  test('a shopping list contains valid product ids', () {
    final catalog = ProductCatalog.starter;
    final list = generateShoppingList(catalog: catalog, random: Random(4));
    expect(list, isNotEmpty);
    for (final entry in list) {
      expect(catalog.lookup(entry.productId), isNotNull);
      expect(entry.quantity, greaterThan(0));
    }
    expect(
      list.map((entry) => entry.productId).toSet(),
      hasLength(list.length),
    );
  });

  test('shopping list size stays inside the configured limits', () {
    const limits = ShoppingListLimits();
    for (var seed = 0; seed < 20; seed++) {
      final list = generateShoppingList(
        catalog: ProductCatalog.starter,
        random: Random(seed),
        limits: limits,
      );
      expect(list.length, inInclusiveRange(limits.minLines, limits.maxLines));
      for (final entry in list) {
        expect(
          entry.quantity,
          inInclusiveRange(limits.minQuantity, limits.maxQuantity),
        );
      }
    }
  });

  test('a customer starts in the entering state', () {
    final manager = _manager();
    manager.tick(1, CollisionWorld(limit: 16));
    expect(manager.active.single.state, CustomerState.entering);
  });

  test('a customer changes from entering to shopping', () {
    final customer = _standingAtEndOf(StoreCustomerRoute.standard.entering);
    advanceCustomer(customer: customer, dt: 0.05, limit: 16);
    expect(customer.state, CustomerState.shopping);
  });

  test('a customer changes from shopping to leaving', () {
    final customer = _standingAtEndOf(StoreCustomerRoute.standard.entering);
    customer.state = CustomerState.shopping;
    customer.waitRemaining = 0.01;
    advanceCustomer(customer: customer, dt: 0.05, limit: 16);
    expect(customer.state, CustomerState.leaving);
  });

  test('a customer becomes exited at the exit and is removed', () {
    final manager = _manager(interval: 100);
    manager.tick(1, CollisionWorld(limit: 16));
    final customer = manager.active.single;
    customer.state = CustomerState.leaving;
    customer.legIndex = customer.leavingPath.length - 1;
    customer.position.setFrom(customer.leavingPath.last.position);
    manager.tick(0.05, CollisionWorld(limit: 16));
    expect(customer.state, CustomerState.exited);
    expect(manager.activeCount, 0);
  });

  test('the customer manager adds customers', () {
    final manager = _manager();
    expect(manager.activeCount, 0);
    manager.tick(1, CollisionWorld(limit: 16));
    expect(manager.activeCount, 1);
  });

  test('the active customer limit is respected', () {
    final manager = _manager(maxActive: 3, clearance: 0);
    final world = CollisionWorld(limit: 16);
    for (var i = 0; i < 6; i++) {
      manager.tick(5, world);
    }
    expect(manager.activeCount, 3);
  });

  test('waypoint movement reaches its target', () {
    final position = Vector3(0, 0, 9.6);
    final target = StoreCustomerRoute.standard.entering.last.position;
    var arrived = false;
    for (var i = 0; i < 80 && !arrived; i++) {
      arrived = stepToward(
        position: position,
        target: target,
        speed: 1.2,
        dt: 0.2,
        limit: 16,
      ).arrived;
    }
    expect(arrived, isTrue);
    expect(position.x, closeTo(target.x, 0.001));
    expect(position.z, closeTo(target.z, 0.001));
  });

  test('the store waypoints stay on walkable floor', () {
    final route = StoreCustomerRoute.standard;
    final points = [
      route.spawn,
      for (final waypoint in route.entering) waypoint.position,
      for (final waypoint in route.leaving) waypoint.position,
    ];
    for (final point in points) {
      expect(
        SupermarketLayout.occupied(point.x, point.z),
        isFalse,
        reason: '${point.x}, ${point.z}',
      );
    }
    expect(route.entering.first.nextId, route.entering[1].id);
    expect(route.entering[1].nextId, route.entering[2].id);
  });

  test('a customer waits instead of standing inside another shopper', () {
    final leader = Vector3(-0.35, 0, 8.4);
    final follower = Vector3(-0.35, 0, 8.55);
    final block = CustomerMetrics.peerBlock(leader);
    final step = stepToward(
      position: follower,
      target: leader,
      speed: 1,
      dt: 0.05,
      limit: 16,
      obstacles: [block],
    );
    expect(step.arrived, isFalse);
    expect(follower.z, closeTo(8.55, 0.001));
  });

  test('a solid stops a customer short of the target', () {
    final position = Vector3(0, 0, 4);
    final wall = CollisionBox(minX: -1, maxX: 1, minZ: 1, maxZ: 1.4);
    var arrived = false;
    for (var i = 0; i < 30; i++) {
      arrived = stepToward(
        position: position,
        target: Vector3(0, 0, 0),
        speed: 1,
        dt: 0.2,
        limit: 16,
        obstacles: [wall],
      ).arrived;
    }
    expect(arrived, isFalse);
    expect(position.z, greaterThan(1.4));
  });

  test('a customer footprint blocks the player', () {
    final block = CustomerMetrics.playerBlock(Vector3(0, 0, 2));
    final moved = movePlayer(
      position: Vector3(0, 0, 4),
      yaw: 0,
      input: Vector2(0, 1),
      speed: 2,
      dt: 1,
      limit: 20,
      obstacles: [block],
    );
    expect(moved.z, greaterThan(2.5));
  });

  test('an open entrance lets a customer shop and leave', () {
    final world = SupermarketLayout.createWorld();
    final left = SupermarketLayout.entrancePanelBox(
      SupermarketLayout.entranceClosedLeftX,
    );
    final right = SupermarketLayout.entrancePanelBox(
      SupermarketLayout.entranceClosedRightX,
    );
    world.boxes.add(left);
    world.boxes.add(right);
    final manager = CustomerManager(
      catalog: ProductCatalog.starter,
      config: const CustomerSpawnConfig(
        maxActive: 1,
        spawnInterval: 30,
        initialDelay: 0,
        spawnClearance: 0.85,
      ),
    );
    manager.tick(0.05, world);
    for (var i = 0; i < 160; i++) {
      manager.tick(0.05, world);
    }
    final waiting = manager.active.single;
    expect(waiting.state, CustomerState.entering);
    expect(waiting.position.z, greaterThan(7.4));

    left.copyFrom(
      SupermarketLayout.entrancePanelBox(SupermarketLayout.entranceOpenLeftX),
    );
    right.copyFrom(
      SupermarketLayout.entrancePanelBox(SupermarketLayout.entranceOpenRightX),
    );
    var sawShopping = false;
    var sawLeaving = false;
    for (var i = 0; i < 900 && manager.activeCount > 0; i++) {
      manager.tick(0.05, world);
      if (manager.active.isEmpty) {
        break;
      }
      if (manager.active.first.state == CustomerState.shopping) {
        sawShopping = true;
      }
      if (manager.active.first.state == CustomerState.leaving) {
        sawLeaving = true;
      }
    }
    expect(sawShopping, isTrue);
    expect(sawLeaving, isTrue);
    expect(manager.activeCount, 0);
  });

  test('three customers pass each other and leave', () {
    final world = SupermarketLayout.createWorld();
    world.boxes.add(
      SupermarketLayout.entrancePanelBox(SupermarketLayout.entranceOpenLeftX),
    );
    world.boxes.add(
      SupermarketLayout.entrancePanelBox(SupermarketLayout.entranceOpenRightX),
    );
    final manager = CustomerManager(
      catalog: ProductCatalog.starter,
      config: const CustomerSpawnConfig(
        maxActive: 3,
        spawnInterval: 4,
        initialDelay: 0,
        spawnClearance: 0.85,
      ),
    );
    var finished = 0;
    for (var i = 0; i < 2400; i++) {
      final before = manager.active.map((customer) => customer.id).toSet();
      manager.tick(0.05, world);
      final after = manager.active.toList();
      finished += before
          .difference(after.map((customer) => customer.id).toSet())
          .length;
      expect(after.length, lessThanOrEqualTo(3));
      for (var a = 0; a < after.length; a++) {
        for (var b = a + 1; b < after.length; b++) {
          final dx = after[a].position.x - after[b].position.x;
          final dz = after[a].position.z - after[b].position.z;
          expect(dx * dx + dz * dz, greaterThan(0.5 * 0.5));
        }
      }
    }
    expect(finished, greaterThan(2));
  });

  test('customer ids stay unique after shoppers leave', () {
    final manager = _manager(maxActive: 2, clearance: 0, interval: 0.1);
    final world = CollisionWorld(limit: 16);
    final seen = <String>{};
    for (var i = 0; i < 4; i++) {
      manager.tick(1, world);
      for (final customer in manager.active) {
        seen.add(customer.id);
        customer.state = CustomerState.exited;
      }
      manager.tick(0.05, world);
    }
    expect(seen.length, greaterThan(3));
    expect(seen, containsAll(['customer-001', 'customer-002', 'customer-003']));
  });
}

CustomerManager _manager({
  int maxActive = 3,
  double clearance = 0,
  double interval = 0.1,
}) {
  final config = CustomerSpawnConfig(
    maxActive: maxActive,
    spawnInterval: interval,
    initialDelay: 0,
    spawnClearance: clearance,
  );
  return CustomerManager(
    config: config,
    spawner: CustomerSpawner(
      catalog: ProductCatalog.starter,
      config: config,
      route: StoreCustomerRoute.standard,
      random: Random(1),
    ),
  );
}

void _fill(CustomerManager manager) {
  final world = CollisionWorld(limit: 16);
  for (var i = 0; i < 5; i++) {
    manager.tick(1, world);
    for (final customer in manager.active) {
      customer.position.setValues(customer.position.x, 0, -2);
    }
  }
}

Customer _standingAtEndOf(List<Waypoint> path) {
  final route = StoreCustomerRoute.standard;
  final customer = Customer(
    id: 'customer-001',
    type: CustomerType.regular,
    shoppingList: const [ShoppingListEntry(productId: 'milk', quantity: 1)],
    position: path.last.position,
    enteringPath: route.entering,
    leavingPath: route.leaving,
  );
  customer.legIndex = path.length - 1;
  return customer;
}
