import 'dart:math';

import 'package:vector_math/vector_math.dart';

import '../world/collision_box.dart';

/// Moves [position] on the floor from a joystick [input].
///
/// [input.x] is strafe toward the right side of the screen and [input.y] is
/// forward, both in the range -1 to 1. [yaw] 0 looks toward -Z, and a
/// positive yaw turns toward -X, matching the Flutter Scene view. [dt] is
/// seconds. The result stays inside ±[limit] and outside
/// [obstacles]. Each axis is applied on its own so the player slides along a
/// wall instead of stopping dead.
/// Body heading for a camera-relative stick.
///
/// [cameraYaw] 0 looks toward -Z. [stick.x] is screen-right and [stick.y] is
/// forward. The result is the yaw the body should face to walk that way.
double headingForStick({required double cameraYaw, required Vector2 stick}) {
  final forwardX = -sin(cameraYaw);
  final forwardZ = -cos(cameraYaw);
  final rightX = -cos(cameraYaw);
  final rightZ = sin(cameraYaw);
  final dirX = rightX * stick.x + forwardX * stick.y;
  final dirZ = rightZ * stick.x + forwardZ * stick.y;
  return atan2(-dirX, -dirZ);
}

/// Turns [yaw] toward [target] by at most [maxStep] radians, the short way.
double turnToward({
  required double yaw,
  required double target,
  required double maxStep,
}) {
  var delta = target - yaw;
  while (delta > pi) {
    delta -= 2 * pi;
  }
  while (delta < -pi) {
    delta += 2 * pi;
  }
  if (delta.abs() <= maxStep) {
    return target;
  }
  return yaw + maxStep * delta.sign;
}

Vector3 movePlayer({
  required Vector3 position,
  required double yaw,
  required Vector2 input,
  required double speed,
  required double dt,
  required double limit,
  List<CollisionBox> obstacles = const [],
}) {
  if (dt <= 0 || input.length2 == 0) {
    return _clamp(position, limit);
  }

  final stick = input.length2 > 1 ? input.normalized() : input;
  final distance = speed * dt;
  final forwardX = -sin(yaw);
  final forwardZ = -cos(yaw);
  final rightX = -cos(yaw);
  final rightZ = sin(yaw);
  final dx = (rightX * stick.x + forwardX * stick.y) * distance;
  final dz = (rightZ * stick.x + forwardZ * stick.y) * distance;

  var x = position.x;
  var z = position.z;
  if (_allowed(x + dx, z, limit, obstacles)) {
    x += dx;
  }
  if (_allowed(x, z + dz, limit, obstacles)) {
    z += dz;
  }
  return Vector3(x, 0, z);
}

bool _allowed(double x, double z, double limit, List<CollisionBox> obstacles) {
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

Vector3 _clamp(Vector3 position, double limit) {
  return Vector3(
    position.x.clamp(-limit, limit),
    0,
    position.z.clamp(-limit, limit),
  );
}
