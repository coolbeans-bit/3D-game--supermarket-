import 'dart:math';

import 'package:vector_math/vector_math.dart';

/// Camera position and the point it looks at.
class PlayerViewpoint {
  const PlayerViewpoint(this.eye, this.target);

  final Vector3 eye;
  final Vector3 target;
}

/// How far behind the character the camera sits, in meters.
const double thirdPersonDistance = 2.7;

/// A small shift so her shoulder does not fill the middle of the view.
const double thirdPersonShoulder = 0.22;

/// How far ahead of her feet the view aims, in meters.
const double thirdPersonLookAhead = 1.05;

/// Applies a touch drag. [dx] and [dy] are pixels, with positive [dy] downward.
///
/// Positive [dx] increases yaw. In this scene a positive yaw turns toward -X,
/// which is the right side of the view when yaw 0 looks down -Z.
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

/// Third-person view orbiting the character.
///
/// [yaw] is the camera yaw. 0 looks toward -Z. The camera stays just behind
/// her and aims a short way ahead, so she stays in frame while the aisles
/// remain in view. Positive [pitch] looks upward. [eyeHeight] is the camera
/// height above the feet when [pitch] is 0.
PlayerViewpoint playerViewpoint({
  required Vector3 feet,
  required double eyeHeight,
  required double yaw,
  required double pitch,
  double distance = thirdPersonDistance,
}) {
  final forwardX = -sin(yaw);
  final forwardZ = -cos(yaw);
  final rightX = -cos(yaw);
  final rightZ = sin(yaw);
  final lift = sin(pitch);
  final eye = Vector3(
    feet.x - forwardX * distance + rightX * thirdPersonShoulder,
    feet.y + eyeHeight + lift * 0.55,
    feet.z - forwardZ * distance + rightZ * thirdPersonShoulder,
  );
  final lookAt = Vector3(
    feet.x +
        forwardX * thirdPersonLookAhead +
        rightX * thirdPersonShoulder * 0.25,
    feet.y + eyeHeight * 0.78 + lift * 1.35,
    feet.z +
        forwardZ * thirdPersonLookAhead +
        rightZ * thirdPersonShoulder * 0.25,
  );
  return PlayerViewpoint(eye, lookAt);
}
