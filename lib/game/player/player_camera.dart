import 'dart:math';

import 'package:vector_math/vector_math.dart';

import '../world/supermarket/supermarket_layout.dart';

/// Camera position and the point it looks at.
class PlayerViewpoint {
  const PlayerViewpoint(this.eye, this.target);

  final Vector3 eye;
  final Vector3 target;
}

/// How far behind the character the camera sits, in meters.
const double thirdPersonDistance = 2.85;

/// Shift to her right so the aim line passes beside her head, not through it.
const double thirdPersonShoulder = 0.28;

/// Eye line of the model. She is about 1.6 m tall, so her eyes sit just under that.
const double thirdPersonHead = 1.5;

/// How far ahead of her the view aims, in meters.
const double thirdPersonLookAhead = 0.85;

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

/// Third-person view from just behind the character's head.
///
/// [yaw] is the camera yaw. 0 looks toward -Z. At pitch 0 the camera sits on
/// her eye line and looks straight ahead, so the store is seen the way she
/// sees it. Dragging all the way up raises the aim above her head. Dragging
/// down looks toward the floor. The camera itself stays near her head.
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
  final rise = sin(pitch);
  final eye = _alongBoom(
    Vector3(
      feet.x - forwardX * distance + rightX * thirdPersonShoulder,
      feet.y + thirdPersonHead + 0.12 + rise * 0.15,
      feet.z - forwardZ * distance + rightZ * thirdPersonShoulder,
    ),
    feet,
  );
  final lookAt = Vector3(
    feet.x + forwardX * thirdPersonLookAhead + rightX * thirdPersonShoulder,
    feet.y + thirdPersonHead + rise * 1.7,
    feet.z + forwardZ * thirdPersonLookAhead + rightZ * thirdPersonShoulder,
  );
  return PlayerViewpoint(eye, lookAt);
}

/// How far behind her head the camera can sit before a wall or shelf.
double cameraBoom({
  required Vector3 feet,
  required double yaw,
  double distance = thirdPersonDistance,
}) {
  final forwardX = -sin(yaw);
  final forwardZ = -cos(yaw);
  final rightX = -cos(yaw);
  final rightZ = sin(yaw);
  final head = Vector3(feet.x, feet.y + thirdPersonHead + 0.12, feet.z);
  final eye = Vector3(
    feet.x - forwardX * distance + rightX * thirdPersonShoulder,
    head.y,
    feet.z - forwardZ * distance + rightZ * thirdPersonShoulder,
  );
  return _boomLength(eye, head);
}

/// Pulls the camera in along the line behind her head.
///
/// The spot stays inside the room. A wall stops the boom short of the wall
/// instead of leaving the camera outside the store.
Vector3 _alongBoom(Vector3 eye, Vector3 feet) {
  final head = Vector3(feet.x, eye.y, feet.z);
  final toEye = eye - head;
  final len = toEye.length;
  if (len < 0.001) {
    return eye;
  }
  final kept = _boomLength(eye, head);
  return head + toEye / len * kept;
}

double _boomLength(Vector3 eye, Vector3 head) {
  final toEye = eye - head;
  final len = toEye.length;
  if (len < 0.001) {
    return len;
  }
  final dir = toEye / len;
  var best = 0.55;
  for (var distance = len; distance >= 0.55; distance -= 0.08) {
    final sample = head + dir * distance;
    if (_cameraClear(sample.x, sample.z)) {
      best = distance;
      break;
    }
  }
  return best > len ? len : best;
}

bool _cameraClear(double x, double z) {
  const margin = 0.16;
  final insideShop =
      x >= SupermarketLayout.shopMinX + margin &&
      x <= SupermarketLayout.shopMaxX - margin &&
      z >= SupermarketLayout.storageMinZ + 0.4 &&
      z <= SupermarketLayout.shopMaxZ - margin;
  final onPorch =
      z >= SupermarketLayout.shopMaxZ - 0.2 &&
      z <= SupermarketLayout.porchOuterZ - 0.25 &&
      x.abs() <= SupermarketLayout.porchHalfWidth - 0.2;
  if (!insideShop && !onPorch) {
    return false;
  }
  const inset = SupermarketLayout.playerRadius - 0.08;
  for (final box in SupermarketLayout.staticObstacles()) {
    if (x >= box.minX + inset &&
        x <= box.maxX - inset &&
        z >= box.minZ + inset &&
        z <= box.maxZ - inset) {
      return false;
    }
  }
  return true;
}
