import 'dart:math';

import 'package:vector_math/vector_math.dart';

import 'shelf_stand.dart';
import 'shopping_list.dart';
import 'waypoint.dart';

/// Paths shoppers can walk. [standard] is the short loop used by tests.
/// [planFor] sends a live shopper to the shelves that stock their list.
class StoreCustomerRoute {
  StoreCustomerRoute({
    required this.spawn,
    required this.entering,
    required this.leaving,
  });

  final Vector3 spawn;
  final List<Waypoint> entering;
  final List<Waypoint> leaving;

  static final standard = StoreCustomerRoute(
    spawn: Vector3(-0.4, 0, 9.6),
    entering: [
      Waypoint(id: 'doorway', x: -0.4, z: 8.4, nextId: 'inside'),
      Waypoint(id: 'inside', x: -0.4, z: 6.2, nextId: 'aisle'),
      Waypoint(id: 'aisle', x: -0.4, z: 0.6),
    ],
    leaving: [
      Waypoint(id: 'sidestep', x: 0.4, z: 0.6, nextId: 'leave-inside'),
      Waypoint(id: 'leave-inside', x: 0.4, z: 6.2, nextId: 'leave-door'),
      Waypoint(id: 'leave-door', x: 0.4, z: 8.4, nextId: 'porch'),
      Waypoint(id: 'porch', x: 0.4, z: 10.3),
    ],
  );

  /// A walk for the products on [list]: the aisle that stocks each one, then
  /// the checkout queue.
  ///
  /// Even aisles are walked toward the back and odd aisles toward the door,
  /// and every shopper uses that same rule, so two people do not meet head-on.
  /// [number] starts at 1 and only labels the stops.
  StoreTrip planFor(int number, List<ShoppingListEntry> list) {
    final laneX = enterLaneX;
    final byAisle = <int, List<ProductStand>>{};
    for (final line in list) {
      final stand = standForProduct(line.productId);
      if (stand == null) {
        continue;
      }
      byAisle.putIfAbsent(stand.aisle, () => []).add(stand);
    }
    if (byAisle.isEmpty) {
      byAisle[2] = [
        ProductStand(x: 0, z: -0.6, faceYaw: pi / 2, aisle: 2),
      ];
    }
    final first = byAisle.keys.reduce(min);
    final last = byAisle.keys.reduce(max);
    final shopping = <Waypoint>[];
    if (first.isOdd) {
      shopping.add(Waypoint(id: 'corridor-front', x: shopperAisleX[first - 1], z: _frontZ));
      shopping.add(Waypoint(id: 'corridor-back', x: shopperAisleX[first - 1], z: _backZ));
    }
    var endedAtFront = false;
    for (var aisle = first; aisle <= last; aisle++) {
      final x = shopperAisleX[aisle];
      final stops = List<ProductStand>.of(byAisle[aisle] ?? const []);
      if (aisle.isEven) {
        shopping.add(Waypoint(id: 'front-$aisle', x: x, z: _frontZ));
        stops.sort((a, b) => b.z.compareTo(a.z));
        for (final stop in stops) {
          shopping.add(_pick(number, stop));
        }
        shopping.add(Waypoint(id: 'back-$aisle', x: x, z: _backZ));
        endedAtFront = false;
      } else {
        shopping.add(Waypoint(id: 'back-$aisle', x: x, z: _backZ));
        stops.sort((a, b) => a.z.compareTo(b.z));
        for (final stop in stops) {
          shopping.add(_pick(number, stop));
        }
        shopping.add(Waypoint(id: 'front-$aisle', x: x, z: _frontZ));
        endedAtFront = true;
      }
    }
    if (endedAtFront) {
      // The front gap is the way out. Rejoin the center aisle, which is
      // only walked toward the back, then come up to the cashier.
      shopping.add(Waypoint(id: 'rejoin-front', x: 0, z: _frontZ));
      shopping.add(Waypoint(id: 'rejoin-back', x: 0, z: _backZ));
    }
    shopping.add(Waypoint(id: 'cashier-side', x: _sideX, z: _backZ));
    shopping.add(
      Waypoint(
        id: 'queue',
        x: _sideX,
        z: _queueZ,
        pause: 1.6,
        faceYaw: pi,
      ),
    );
    return StoreTrip(
      spawn: Vector3(laneX, 0, spawn.z),
      entering: [
        Waypoint(id: 'doorway', x: laneX, z: 8.2, nextId: 'inside'),
        Waypoint(id: 'inside', x: laneX, z: 5.2),
      ],
      shopping: shopping,
      leaving: [
        Waypoint(id: 'clear-queue', x: _sideX, z: _frontZ, nextId: 'past-counter'),
        Waypoint(id: 'past-counter', x: 3.05, z: _frontZ, nextId: 'foyer'),
        Waypoint(id: 'foyer', x: 3.05, z: 5.2, nextId: 'leave-lane'),
        Waypoint(id: 'leave-lane', x: leaveLaneX, z: 5.2, nextId: 'leave-door'),
        Waypoint(id: 'leave-door', x: leaveLaneX, z: 8.3, nextId: 'porch'),
        Waypoint(id: 'porch', x: leaveLaneX, z: 10.4),
      ],
    );
  }
}

Waypoint _pick(int number, ProductStand stand) {
  return Waypoint(
    id: 'pick-$number-${stand.x}-${stand.z}',
    x: stand.x,
    z: stand.z,
    pause: 1.1,
    faceYaw: stand.faceYaw,
    reach: true,
    productId: stand.productId,
  );
}

class StoreTrip {
  const StoreTrip({
    required this.spawn,
    required this.entering,
    required this.shopping,
    required this.leaving,
  });

  final Vector3 spawn;
  final List<Waypoint> entering;
  final List<Waypoint> shopping;
  final List<Waypoint> leaving;
}

/// In front of the gondolas and just short of the checkout counter.
const double _frontZ = 3.2;

/// Where the line stands, on the way up to the counter.
const double _queueZ = 3.05;

/// Behind the gondolas, still on the shopping floor.
const double _backZ = -5.0;

/// The open strip between the last gondola and the right wall.
const double _sideX = 4.55;

/// Right side of the doorway. Shoppers come in on this line.
const double enterLaneX = 0.5;

/// Left side of the doorway. Shoppers go out on this line.
const double leaveLaneX = -0.5;
