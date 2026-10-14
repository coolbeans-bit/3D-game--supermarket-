import 'dart:math';

import 'package:asmitra_game/game/player/player_camera.dart';
import 'package:asmitra_game/game/player/player_controller.dart';
import 'package:asmitra_game/game/player/player_movement.dart';
import 'package:asmitra_game/game/scene/room_layout.dart';
import 'package:asmitra_game/game/world/collision_box.dart';
import 'package:asmitra_game/game/world/supermarket/supermarket_layout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  test('forward movement follows the camera facing and delta time', () {
    final next = movePlayer(
      position: Vector3.zero(),
      yaw: 0,
      input: Vector2(0, 1),
      speed: 2,
      dt: 0.5,
      limit: 10,
    );

    expect(next.x, closeTo(0, 1e-6));
    expect(next.y, 0);
    expect(next.z, closeTo(-1, 1e-6));
  });

  test('strafe right moves along -X when facing -Z', () {
    final next = movePlayer(
      position: Vector3.zero(),
      yaw: 0,
      input: Vector2(1, 0),
      speed: 2,
      dt: 0.5,
      limit: 10,
    );

    expect(next.x, closeTo(-1, 1e-6));
    expect(next.z, closeTo(0, 1e-6));
  });

  test('a quarter turn makes forward movement go along -X', () {
    final next = movePlayer(
      position: Vector3.zero(),
      yaw: pi / 2,
      input: Vector2(0, 1),
      speed: 2,
      dt: 0.5,
      limit: 10,
    );

    expect(next.x, closeTo(-1, 1e-6));
    expect(next.z, closeTo(0, 1e-6));
  });

  test('the player slides along a wall instead of passing through it', () {
    final limit = RoomLayout.walkLimit;
    final next = movePlayer(
      position: Vector3(-limit, 0, 1),
      yaw: 0,
      input: Vector2(1, 1),
      speed: 2,
      dt: 0.5,
      limit: limit,
    );

    expect(next.x, closeTo(-limit, 1e-5));
    expect(next.z, lessThan(1));
  });

  test('an obstacle blocks one axis and the player slides along it', () {
    final next = movePlayer(
      position: Vector3(0, 0, 0.3),
      yaw: 0,
      input: Vector2(1, 1),
      speed: 2,
      dt: 0.5,
      limit: 10,
      obstacles: [CollisionBox(minX: -2, maxX: 2, minZ: -2, maxZ: 0.15)],
    );

    expect(next.x, lessThan(-0.4));
    expect(next.z, closeTo(0.3, 1e-6));
  });

  test('vertical look is clamped', () {
    final look = applyLook(
      yaw: 0,
      pitch: 0,
      dx: 0,
      dy: -10000,
      sensitivity: 0.01,
      maxPitch: PlayerController.maxPitch,
    );

    expect(look.pitch, PlayerController.maxPitch);
  });

  test('forward stick faces the same way as the camera', () {
    final yaw = headingForStick(cameraYaw: 0, stick: Vector2(0, 1));
    expect(yaw, closeTo(0, 1e-6));
  });

  test('a right stick turns her toward screen right', () {
    final yaw = headingForStick(cameraYaw: 0, stick: Vector2(1, 0));
    expect(yaw, closeTo(pi / 2, 1e-6));
  });

  test('a sideways body takes no step until she has turned', () {
    expect(facingAlignment(yaw: 0, target: pi / 2), closeTo(0, 1e-6));
    expect(facingAlignment(yaw: 0, target: 0), closeTo(1, 1e-6));
  });

  test('she turns the short way and does not snap', () {
    expect(turnToward(yaw: 0.2, target: -0.1, maxStep: 1), closeTo(-0.1, 1e-6));
    expect(turnToward(yaw: 0, target: 2, maxStep: 0.4), closeTo(0.4, 1e-6));
  });

  test('the camera sits behind the player and looks along the facing', () {
    final view = playerViewpoint(
      feet: Vector3(1, 0, 2),
      eyeHeight: RoomLayout.eyeHeight,
      yaw: 0,
      pitch: 0,
    );

    expect(view.eye.y, closeTo(thirdPersonHead + 0.12, 1e-5));
    expect(view.target.y, closeTo(thirdPersonHead, 1e-5));
    expect(view.eye.z, greaterThan(2));
    expect(view.target.z, lessThan(2));
    expect(view.target.z, lessThan(view.eye.z));

    final turned = playerViewpoint(
      feet: Vector3(1, 0, 2),
      eyeHeight: RoomLayout.eyeHeight,
      yaw: pi / 2,
      pitch: 0,
    );
    expect(turned.eye.x, greaterThan(1));
    expect(turned.target.x, lessThan(1));
    expect(turned.target.x, lessThan(turned.eye.x));

    final lookedUp = playerViewpoint(
      feet: Vector3(1, 0, 2),
      eyeHeight: RoomLayout.eyeHeight,
      yaw: 0,
      pitch: 0.72,
    );
    expect(lookedUp.target.y, greaterThan(lookedUp.eye.y));
  });

  test('the camera stays inside the store when she faces a wall', () {
    final view = playerViewpoint(
      feet: Vector3(5.2, 0, 0),
      eyeHeight: RoomLayout.eyeHeight,
      yaw: pi / 2,
      pitch: 0,
    );

    expect(view.eye.x, greaterThan(5.2 + 0.4));
    expect(view.eye.x, lessThan(SupermarketLayout.shopMaxX));
    expect(view.target.x, lessThan(view.eye.x));
  });

  test('a new direction steps at once and the camera does not spin', () {
    final player = PlayerController(
      start: Vector3(0, 0, 4),
      world: CollisionWorld(limit: 16),
    );
    player.setMove(Vector2(1, 0));
    final start = player.position.clone();
    for (var i = 0; i < 6; i++) {
      player.tick(0.05);
    }

    expect(player.position.distanceTo(start), greaterThan(0.35));
    expect(player.cameraYaw, closeTo(0, 1e-6));
    expect(player.position.z, closeTo(4, 0.05));

    for (var i = 0; i < 40; i++) {
      player.tick(0.05);
    }
    expect(player.yaw, closeTo(pi / 2, 0.05));
    expect(player.cameraYaw, closeTo(0, 1e-6));
    expect(player.position.x, lessThan(-2));
    expect(player.position.z, closeTo(4, 0.05));
  });
}
