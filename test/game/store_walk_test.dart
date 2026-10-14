import 'dart:math';

import 'package:asmitra_game/game/player/player_controller.dart';
import 'package:asmitra_game/game/world/supermarket/supermarket_layout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  test('she spawns with the camera a full step behind her', () {
    final player = PlayerController(
      start: SupermarketLayout.playerStart,
      world: SupermarketLayout.createWorld(),
    );
    final view = player.viewpoint();
    final dx = view.eye.x - player.position.x;
    final dz = view.eye.z - player.position.z;

    expect(sqrt(dx * dx + dz * dz), greaterThan(2.2));
    expect(view.eye.y, closeTo(1.62, 0.05));
    expect(view.target.y, closeTo(1.5, 0.05));
  });

  test('an open door lets her walk the center aisle in a straight line', () {
    final world = SupermarketLayout.createWorld();
    world.boxes.add(
      SupermarketLayout.entrancePanelBox(SupermarketLayout.entranceOpenLeftX),
    );
    world.boxes.add(
      SupermarketLayout.entrancePanelBox(SupermarketLayout.entranceOpenRightX),
    );
    final player = PlayerController(
      start: SupermarketLayout.playerStart,
      world: world,
    );
    player.setMove(Vector2(0, 1));

    var slowest = 99.0;
    for (var i = 0; i < 140; i++) {
      final before = player.position.clone();
      player.tick(0.05);
      final speed = player.position.distanceTo(before) / 0.05;
      if (i > 5) {
        slowest = min(slowest, speed);
      }
      expect(
        _blocked(player.position),
        isFalse,
        reason: 'stuck inside a solid at ${player.position}',
      );
      expect(player.cameraYaw, closeTo(0, 1e-6));
    }

    expect(player.position.z, lessThan(0));
    expect(player.position.x.abs(), lessThan(0.35));
    expect(slowest, greaterThan(1.2));
    expect(player.cameraYaw, closeTo(0, 1e-6));
  });

  test('a closed door stops her on the porch', () {
    final world = SupermarketLayout.createWorld();
    world.boxes.add(
      SupermarketLayout.entrancePanelBox(SupermarketLayout.entranceClosedLeftX),
    );
    world.boxes.add(
      SupermarketLayout.entrancePanelBox(
        SupermarketLayout.entranceClosedRightX,
      ),
    );
    final player = PlayerController(
      start: SupermarketLayout.playerStart,
      world: world,
    );
    player.setMove(Vector2(0, 1));
    for (var i = 0; i < 80; i++) {
      player.tick(0.05);
    }

    expect(player.position.z, greaterThan(7.2));
  });
}

bool _blocked(Vector3 position) {
  for (final box in SupermarketLayout.staticObstacles()) {
    if (box.containsPoint(position.x, position.z)) {
      return true;
    }
  }
  return false;
}
