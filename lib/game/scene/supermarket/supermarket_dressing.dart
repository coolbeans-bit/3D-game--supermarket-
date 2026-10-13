import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../world/collision_box.dart';
import '../../world/supermarket/supermarket_layout.dart';
import 'blockout_geometry.dart';

/// Color on the existing store: awnings, department boards, and a produce table.
///
/// Nothing here is a product the player can pick up. The boards are color
/// marks, not copied sign lettering. The produce table is the only new solid.
void addSupermarketDressing(
  Scene scene,
  CollisionWorld world,
  BlockoutPalette palette,
) {
  final stripes = [palette.canopy, palette.stripeCream, palette.canopyBand];
  _stripes(
    scene,
    name: 'porch-stripe',
    center: Vector3(0, 2.76, 9.6),
    width: 6.0,
    depth: 3.4,
    count: 8,
    colors: stripes,
  );

  final gondolas = <(String, double, PhysicallyBasedMaterial)>[
    ('dairy', -3.375, palette.dairySign),
    ('grocery', -1.125, palette.grocerySign),
    ('snacks', 1.125, palette.snackSign),
    ('care', 3.375, palette.careSign),
  ];
  for (final gondola in gondolas) {
    _stripes(
      scene,
      name: '${gondola.$1}-awning',
      center: Vector3(gondola.$2, 2.15, 2.5),
      width: 1.2,
      depth: 0.55,
      count: 4,
      colors: stripes,
    );
    addBox(
      scene,
      name: '${gondola.$1}-sign',
      center: Vector3(gondola.$2, 1.95, 2.32),
      size: Vector3(0.95, 0.22, 0.05),
      material: gondola.$3,
      shadowStatic: false,
      castsShadows: false,
    );
  }

  _bunting(scene, palette);
  _produce(scene, world, palette);
}

void _stripes(
  Scene scene, {
  required String name,
  required Vector3 center,
  required double width,
  required double depth,
  required int count,
  required List<PhysicallyBasedMaterial> colors,
}) {
  final band = depth / count;
  final start = center.z - depth / 2 + band / 2;
  for (var i = 0; i < count; i++) {
    addBox(
      scene,
      name: '$name-$i',
      center: Vector3(center.x, center.y, start + band * i),
      size: Vector3(width, 0.035, band * 0.82),
      material: colors[i % colors.length],
      shadowStatic: false,
      castsShadows: false,
    );
  }
}

void _bunting(Scene scene, BlockoutPalette palette) {
  const colors = <int>[0, 1, 2];
  final materials = [palette.canopy, palette.canopyBand, palette.dairySign];
  for (var i = 0; i < 7; i++) {
    final x = -3.0 + i * 1.0;
    addBox(
      scene,
      name: 'bunting-$i',
      center: Vector3(x, 2.62, 5.2),
      size: Vector3(0.16, 0.16, 0.04),
      material: materials[colors[i % colors.length]],
      shadowStatic: false,
      castsShadows: false,
    );
    if (i.isEven) {
      _drop(scene, 'tassel-$i', Vector3(x, 2.42, 5.2), palette.canopyBand);
    }
  }
}

void _produce(Scene scene, CollisionWorld world, BlockoutPalette palette) {
  const x = -4.9;
  const z = 4.55;
  world.boxes.add(
    CollisionBox.padded(
      centerX: x,
      centerZ: z,
      sizeX: 1.15,
      sizeZ: 0.7,
      padding: SupermarketLayout.playerRadius,
    ),
  );
  addBox(
    scene,
    name: 'produce-table',
    center: Vector3(x, 0.42, z),
    size: Vector3(1.15, 0.84, 0.7),
    material: palette.frame,
    shadowStatic: false,
    castsShadows: false,
  );
  addBox(
    scene,
    name: 'produce-sign',
    center: Vector3(x, 1.7, z - 0.28),
    size: Vector3(0.7, 0.2, 0.05),
    material: palette.produceSign,
    shadowStatic: false,
    castsShadows: false,
  );
  const baskets = <(double, double)>[(-0.34, 0.12), (0.02, -0.08), (0.36, 0.1)];
  for (var i = 0; i < baskets.length; i++) {
    final spot = baskets[i];
    _basket(
      scene,
      'produce-$i',
      Vector3(x + spot.$1, 0.9, z + spot.$2),
      palette.basket,
    );
  }
}

void _basket(
  Scene scene,
  String name,
  Vector3 center,
  PhysicallyBasedMaterial basket,
) {
  scene.add(
    Node(
        name: name,
        mesh: Mesh(
          CylinderGeometry(
            bottomRadius: 0.16,
            topRadius: 0.2,
            height: 0.16,
            radialSegments: 8,
          ),
          basket,
        ),
      )
      ..position = center
      ..shadowStatic = false
      ..castsShadows = false,
  );
}

void _drop(
  Scene scene,
  String name,
  Vector3 center,
  PhysicallyBasedMaterial material,
) {
  scene.add(
    Node(
        name: name,
        mesh: Mesh(
          CylinderGeometry(
            bottomRadius: 0.025,
            topRadius: 0.025,
            height: 0.22,
            radialSegments: 6,
          ),
          material,
        ),
      )
      ..position = center
      ..shadowStatic = false
      ..castsShadows = false,
  );
}
