import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';

import '../scene/room_layout.dart';
import '../world/collision_box.dart';
import 'player_camera.dart';
import 'player_movement.dart';

/// Player state for the third-person view. Widgets only forward input.
class PlayerController extends ChangeNotifier {
  PlayerController({Vector3? start, CollisionWorld? world})
    : position = start ?? Vector3(0, 0, 1.6),
      _world = world ?? CollisionWorld(limit: RoomLayout.walkLimit);

  Vector3 position;

  /// Direction her body faces. She turns toward where she is walking.
  double yaw = 0;

  /// Direction the camera looks. Dragging the view changes this, not her body.
  double cameraYaw = 0;
  double pitch = 0;

  final CollisionWorld _world;

  final double eyeHeight = RoomLayout.eyeHeight;

  /// A walking pace, matched to the walk cycle so her feet stay on the ground.
  final double moveSpeed = 1.35;
  final double lookSensitivity = 0.0032;

  /// Radians per second. A quarter turn takes about a quarter of a second.
  static const double turnSpeed = 6.5;

  static const double maxPitch = 0.72;

  Vector2 _move = Vector2.zero();

  /// Stick length from 0 to 1. Zero when she is standing.
  double get moveAmount {
    final length = _move.length;
    return length > 1 ? 1 : length;
  }

  /// True while the stick is pushed, including when a wall stops the step.
  bool get isMoving => moveAmount > 0.05;

  void setMove(Vector2 input) {
    _move = input;
  }

  void addLook(double dx, double dy) {
    final look = applyLook(
      yaw: cameraYaw,
      pitch: pitch,
      dx: dx,
      dy: dy,
      sensitivity: lookSensitivity,
      maxPitch: maxPitch,
    );
    cameraYaw = look.yaw;
    pitch = look.pitch;
  }

  /// Advances movement by [deltaSeconds]. Large stalls are capped so one
  /// slow frame cannot jump the player through a wall.
  ///
  /// She walks along her facing and turns toward the stick, so a sidestep
  /// becomes a turn instead of a slide.
  void tick(double deltaSeconds) {
    final dt = deltaSeconds.clamp(0.0, 0.05);
    final amount = moveAmount;
    if (amount > 0) {
      yaw = turnToward(
        yaw: yaw,
        target: headingForStick(cameraYaw: cameraYaw, stick: _move),
        maxStep: turnSpeed * dt,
      );
    }
    position = movePlayer(
      position: position,
      yaw: yaw,
      input: Vector2(0, amount),
      speed: moveSpeed,
      dt: dt,
      limit: _world.limit,
      obstacles: _world.boxes,
    );
    notifyListeners();
  }

  PlayerViewpoint viewpoint() {
    return playerViewpoint(
      feet: position,
      eyeHeight: eyeHeight,
      yaw: cameraYaw,
      pitch: pitch,
    );
  }
}
