import 'dart:math';

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
  /// Walking does not change it: the stick is read from this yaw, so turning
  /// the camera while she walks would curve the stick into a spin.
  double cameraYaw = 0;
  double pitch = 0;

  /// Boom length after walls shorten it. It eases back out so leaving a shelf
  /// does not pop the view.
  double _boom = thirdPersonDistance;

  final CollisionWorld _world;

  final double eyeHeight = RoomLayout.eyeHeight;

  /// A walking pace, matched to the walk cycle so her feet stay on the ground.
  final double moveSpeed = 1.55;
  final double lookSensitivity = 0.0032;

  /// Radians per second. The body faces the stick quickly. The step itself
  /// does not wait for that turn.
  static const double turnSpeed = 14;

  /// Meters per second the camera boom lengthens again after a wall.
  static const double boomEase = 5;

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

  /// The finger left the look area. The view stays where the drag put it.
  void endLook() {}

  /// Advances movement by [deltaSeconds]. Large stalls are capped so one
  /// slow frame cannot jump the player through a wall.
  ///
  /// The stick is the screen: up walks away from the camera, right walks to
  /// screen right. She steps that way at once and turns her body to match.
  /// The camera stays put, so the picture and the stick keep meaning the
  /// same direction.
  void tick(double deltaSeconds) {
    final dt = deltaSeconds.clamp(0.0, 0.05);
    final amount = moveAmount;
    var heading = yaw;
    if (amount > 0) {
      heading = headingForStick(cameraYaw: cameraYaw, stick: _move);
      yaw = turnToward(yaw: yaw, target: heading, maxStep: turnSpeed * dt);
    }
    position = movePlayer(
      position: position,
      yaw: heading,
      input: Vector2(0, amount),
      speed: moveSpeed,
      dt: dt,
      limit: _world.limit,
      obstacles: _world.boxes,
    );
    final cleared = cameraBoom(feet: position, yaw: cameraYaw);
    if (cleared < _boom) {
      _boom = cleared;
    } else {
      _boom = min(cleared, _boom + boomEase * dt);
    }
    notifyListeners();
  }

  PlayerViewpoint viewpoint() {
    return playerViewpoint(
      feet: position,
      eyeHeight: eyeHeight,
      yaw: cameraYaw,
      pitch: pitch,
      distance: _boom,
    );
  }
}
