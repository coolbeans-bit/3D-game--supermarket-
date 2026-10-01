import 'package:vector_math/vector_math.dart';

import 'waypoint.dart';

/// The first customer loop: porch, doorway, one aisle pause, then back out.
///
/// Entering and leaving use opposite sides of the open doorway so two
/// shoppers can pass. Product search and the checkout queue come later.
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
}
