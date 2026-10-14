import 'dart:math';

import 'package:vector_math/vector_math.dart';

import '../world/collision_box.dart';
import '../world/supermarket/supermarket_layout.dart';

/// Body size used for walking and for keeping the player outside a shopper.
class CustomerMetrics {
  const CustomerMetrics._();

  static const double radius = 0.28;
  static const double arrival = 0.2;

  /// Floor box the player's center cannot enter.
  static CollisionBox playerBlock(Vector3 position) {
    return _square(position, radius + SupermarketLayout.playerRadius);
  }

  /// Floor box another customer's center cannot enter.
  static CollisionBox peerBlock(Vector3 position) {
    return _square(position, radius * 2);
  }

  static CollisionBox _square(Vector3 position, double reach) {
    return CollisionBox(
      minX: position.x - reach,
      maxX: position.x + reach,
      minZ: position.z - reach,
      maxZ: position.z + reach,
    );
  }

  static void writeReach(CollisionBox box, Vector3 position, double reach) {
    box.minX = position.x - reach;
    box.maxX = position.x + reach;
    box.minZ = position.z - reach;
    box.maxZ = position.z + reach;
  }
}

/// Moves [position] toward [target] on the floor.
///
/// Each axis is tried on its own, matching the player, so a shopper slides
/// along a wall. [position] is updated in place. The facing matches the
/// player's yaw: 0 looks toward -Z.
({bool arrived, double yaw}) stepToward({
  required Vector3 position,
  required Vector3 target,
  required double speed,
  required double dt,
  required double limit,
  List<CollisionBox> obstacles = const [],
  double arrival = CustomerMetrics.arrival,
}) {
  final dx = target.x - position.x;
  final dz = target.z - position.z;
  final distance = sqrt(dx * dx + dz * dz);
  // Same facing as the player: yaw 0 looks toward -Z, and positive yaw
  // turns toward -X. atan2(-dx, -dz) is that yaw for the step direction.
  final yaw = distance == 0 ? 0.0 : atan2(-dx, -dz);
  if (dt <= 0 || distance <= arrival) {
    final clear = _open(target.x, target.z, limit, obstacles);
    if (distance <= arrival && clear) {
      position.setFrom(target);
    }
    return (arrived: distance <= arrival && clear, yaw: yaw);
  }

  final step = min(speed * dt, distance);
  final dirX = dx / distance;
  final dirZ = dz / distance;
  final moveX = dirX * step;
  final moveZ = dirZ * step;
  if (_open(position.x + moveX, position.z, limit, obstacles)) {
    position.x += moveX;
  }
  if (_open(position.x, position.z + moveZ, limit, obstacles)) {
    position.z += moveZ;
  }
  final remaining =
      (target.x - position.x) * (target.x - position.x) +
      (target.z - position.z) * (target.z - position.z);
  if (remaining <= arrival * arrival &&
      _open(target.x, target.z, limit, obstacles)) {
    position.setFrom(target);
    return (arrived: true, yaw: yaw);
  }
  return (arrived: false, yaw: yaw);
}

bool _open(double x, double z, double limit, List<CollisionBox> obstacles) {
  if (x < -limit || x > limit || z < -limit || z > limit) {
    return false;
  }
  for (final box in obstacles) {
    if (box.containsPoint(x, z)) {
      return false;
    }
  }
  return true;
}
