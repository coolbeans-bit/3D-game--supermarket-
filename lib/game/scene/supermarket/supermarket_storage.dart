import 'dart:math';

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../interaction/interactable.dart';
import '../../interaction/interaction_system.dart';
import '../../world/collision_box.dart';
import '../../world/supermarket/supermarket_layout.dart';
import 'blockout_geometry.dart';

/// Back room, staff bench, and the door from the shopping floor.
///
/// "Open" swings the door into storage. Inventory is not implemented.
void addSupermarketStorage(
  Scene scene,
  InteractionSystem interactions,
  CollisionWorld world,
  BlockoutPalette palette,
) {
  for (final span in SupermarketLayout.solids) {
    if (span.role == SpanRole.bench) {
      addSpan(scene, span, name: 'staff-bench', material: palette.bench);
    }
  }

  final box = SupermarketLayout.storageDoorClosedBox();
  world.boxes.add(box);

  final pivot = Node(name: 'storage-door-pivot')
    ..position = Vector3(
      SupermarketLayout.storageHingeX,
      0,
      SupermarketLayout.storageDoorZ,
    );
  scene.add(pivot);
  final panel =
      Node(
          name: 'storage-door',
          mesh: Mesh(
            CuboidGeometry(
              Vector3(
                SupermarketLayout.storageDoorWidth,
                SupermarketLayout.doorHeight,
                SupermarketLayout.storageDoorThickness,
              ),
            ),
            palette.door,
          ),
        )
        ..position = Vector3(
          SupermarketLayout.storageDoorWidth / 2,
          SupermarketLayout.doorHeight / 2,
          0,
        )
        ..shadowStatic = false;
  pivot.add(panel);

  var open = false;
  interactions.bind(
    panel,
    BasicInteractable(
      id: 'storage-door',
      displayName: 'Storage Door',
      prompt: 'Open',
      onInteract: () {
        open = !open;
        pivot.rotation = Quaternion.axisAngle(
          Vector3(0, 1, 0),
          open ? pi / 2 : 0,
        );
        box.copyFrom(
          open
              ? SupermarketLayout.storageDoorOpenBox()
              : SupermarketLayout.storageDoorClosedBox(),
        );
      },
    ),
  );
}
