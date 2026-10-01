import 'dart:math';

import 'package:vector_math/vector_math.dart';

/// Eye position and the point the first-person camera looks at.
class PlayerViewpoint {
  const PlayerViewpoint(this.eye, this.target);

  final Vector3 eye;
  final Vector3 target;
}

/// Applies a touch drag. [dx] and [dy] are pixels, with positive [dy] downward.
/// Pitch stays within ±[maxPitch] radians so the view cannot flip.
({double yaw, double pitch}) applyLook({
  required double yaw,
  required double pitch,
  required double dx,
  required double dy,
  required double sensitivity,
  required double maxPitch,
}) {
  return (
    yaw: yaw + dx * sensitivity,
    pitch: (pitch - dy * sensitivity).clamp(-maxPitch, maxPitch),
  );
}

PlayerViewpoint playerViewpoint({
  required Vector3 feet,
  required double eyeHeight,
  required double yaw,
  required double pitch,
}) {
  final eye = Vector3(feet.x, feet.y + eyeHeight, feet.z);
  final forward = Vector3(
    sin(yaw) * cos(pitch),
    sin(pitch),
    -cos(yaw) * cos(pitch),
  );
  return PlayerViewpoint(eye, eye + forward);
}
