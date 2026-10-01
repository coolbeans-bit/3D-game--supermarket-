import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';

import '../scene/room_layout.dart';
import '../world/collision_box.dart';
import 'player_camera.dart';
import 'player_movement.dart';

/// First-person player state. Widgets only forward input; this applies it.
class PlayerController extends ChangeNotifier {
  PlayerController({Vector3? start, CollisionWorld? world})
    : position = start ?? Vector3(0, 0, 1.6),
      _world = world ?? CollisionWorld(limit: RoomLayout.walkLimit);

  Vector3 position;
  double yaw = 0;
  double pitch = 0;

  final CollisionWorld _world;

  final double eyeHeight = RoomLayout.eyeHeight;
  final double moveSpeed = 2.5;
  final double lookSensitivity = 0.0038;

  static const double maxPitch = 1.15;

  Vector2 _move = Vector2.zero();

  void setMove(Vector2 input) {
    _move = input;
  }

  void addLook(double dx, double dy) {
    final look = applyLook(
      yaw: yaw,
      pitch: pitch,
      dx: dx,
      dy: dy,
      sensitivity: lookSensitivity,
      maxPitch: maxPitch,
    );
    yaw = look.yaw;
    pitch = look.pitch;
  }

  /// Advances movement by [deltaSeconds]. Large stalls are capped so one
  /// slow frame cannot jump the player through a wall.
  void tick(double deltaSeconds) {
    position = movePlayer(
      position: position,
      yaw: yaw,
      input: _move,
      speed: moveSpeed,
      dt: deltaSeconds.clamp(0.0, 0.05),
      limit: _world.limit,
      obstacles: _world.boxes,
    );
    notifyListeners();
  }

  PlayerViewpoint viewpoint() {
    return playerViewpoint(
      feet: position,
      eyeHeight: eyeHeight,
      yaw: yaw,
      pitch: pitch,
    );
  }
}
