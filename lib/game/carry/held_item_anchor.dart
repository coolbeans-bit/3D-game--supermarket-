import 'dart:math';

import 'package:vector_math/vector_math.dart';

/// Where a carried mesh sits in the character's right hand.
///
/// [forwardMeters] is ahead of the feet along the facing. [rightMeters] is
/// toward the character's right. [heightMeters] is above the floor.
/// [visualScale] only affects the carried mesh.
class HeldItemAnchor {
  const HeldItemAnchor({
    this.forwardMeters = 0.38,
    this.rightMeters = 0.22,
    this.heightMeters = 0.95,
    this.visualScale = 0.65,
  });

  final double forwardMeters;
  final double rightMeters;
  final double heightMeters;
  final double visualScale;

  Vector3 worldPosition({required Vector3 feet, required double yaw}) {
    final forwardX = -sin(yaw);
    final forwardZ = -cos(yaw);
    final rightX = -cos(yaw);
    final rightZ = sin(yaw);
    return Vector3(
      feet.x + forwardX * forwardMeters + rightX * rightMeters,
      feet.y + heightMeters,
      feet.z + forwardZ * forwardMeters + rightZ * rightMeters,
    );
  }
}
