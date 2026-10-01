import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../interaction/interactable.dart';
import '../../interaction/interaction_system.dart';
import '../../world/collision_box.dart';
import '../../world/supermarket/supermarket_layout.dart';
import 'blockout_geometry.dart';

/// Entrance frame panels. "Open" slides them aside. No door motor yet.
void addSupermarketEntrance(
  Scene scene,
  InteractionSystem interactions,
  CollisionWorld world,
  BlockoutPalette palette,
) {
  final leftBox = SupermarketLayout.entrancePanelBox(
    SupermarketLayout.entranceClosedLeftX,
  );
  final rightBox = SupermarketLayout.entrancePanelBox(
    SupermarketLayout.entranceClosedRightX,
  );
  world.boxes.add(leftBox);
  world.boxes.add(rightBox);

  final left = _panel(
    scene,
    name: 'entrance-left',
    x: SupermarketLayout.entranceClosedLeftX,
    palette: palette,
  );
  final right = _panel(
    scene,
    name: 'entrance-right',
    x: SupermarketLayout.entranceClosedRightX,
    palette: palette,
  );

  var open = false;
  final door = BasicInteractable(
    id: 'entrance',
    displayName: 'Entrance',
    prompt: 'Open',
    onInteract: () {
      open = !open;
      _place(
        left,
        leftBox,
        open
            ? SupermarketLayout.entranceOpenLeftX
            : SupermarketLayout.entranceClosedLeftX,
      );
      _place(
        right,
        rightBox,
        open
            ? SupermarketLayout.entranceOpenRightX
            : SupermarketLayout.entranceClosedRightX,
      );
    },
  );
  interactions.bind(left, door);
  interactions.bind(right, door);
}

Node _panel(
  Scene scene, {
  required String name,
  required double x,
  required BlockoutPalette palette,
}) {
  return addBox(
    scene,
    name: name,
    center: Vector3(
      x,
      SupermarketLayout.doorHeight / 2,
      SupermarketLayout.entrancePanelZ,
    ),
    size: Vector3(
      SupermarketLayout.entrancePanelWidth,
      SupermarketLayout.doorHeight,
      SupermarketLayout.entrancePanelThickness,
    ),
    material: palette.door,
    shadowStatic: false,
  );
}

void _place(Node panel, CollisionBox box, double x) {
  panel.position = Vector3(
    x,
    SupermarketLayout.doorHeight / 2,
    SupermarketLayout.entrancePanelZ,
  );
  box.copyFrom(SupermarketLayout.entrancePanelBox(x));
}
