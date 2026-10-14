import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../world/collision_box.dart';
import '../../world/supermarket/supermarket_layout.dart';
import 'blockout_geometry.dart';

/// Original produce island on the left as you enter.
///
/// Crates and piled fruit stand in for a market stall. This is not a copy of
/// a stock shelf model or of the printed boards in reference photos.
void addProduceMart(Scene scene, CollisionWorld world) {
  const x = -3.55;
  const z = 5.05;
  world.boxes.add(
    CollisionBox.padded(
      centerX: x,
      centerZ: z,
      sizeX: 4.35,
      sizeZ: 1.55,
      padding: SupermarketLayout.playerRadius,
    ),
  );
  addBox(
    scene,
    name: 'produce-base',
    center: Vector3(x, 0.26, z),
    size: Vector3(4.2, 0.52, 1.45),
    material: BlockoutPalette.flat(0.14, 0.12, 0.11, 0.7),
    shadowStatic: false,
    castsShadows: false,
  );
  addBox(
    scene,
    name: 'produce-top',
    center: Vector3(x, 0.56, z),
    size: Vector3(4.4, 0.08, 1.62),
    material: BlockoutPalette.flat(0.78, 0.62, 0.4, 0.65),
    shadowStatic: false,
    castsShadows: false,
  );
  addBox(
    scene,
    name: 'produce-rear',
    center: Vector3(x, 0.74, 4.55),
    size: Vector3(3.7, 0.28, 0.7),
    material: BlockoutPalette.flat(0.62, 0.46, 0.28, 0.7),
    shadowStatic: false,
    castsShadows: false,
  );

  const front = <(double, double, double, double)>[
    (-5.15, 0.82, 0.16, 0.14),
    (-4.25, 0.9, 0.2, 0.14),
    (-3.35, 0.96, 0.82, 0.18),
    (-2.45, 0.95, 0.62, 0.12),
    (-1.6, 0.93, 0.45, 0.1),
  ];
  for (final pile in front) {
    _crate(
      scene,
      Vector3(pile.$1, 0.62, 5.45),
      _heap(pile.$2, pile.$3, pile.$4),
    );
  }
  _crate(scene, Vector3(-4.7, 0.9, 4.55), _heap(0.28, 0.62, 0.22));
  _crate(scene, Vector3(-3.55, 0.9, 4.55), _heap(0.22, 0.1, 0.28));
  _crate(scene, Vector3(-2.4, 0.9, 4.55), _heap(0.62, 0.45, 0.28));
}

const _mound = <(double, double, double)>[
  (-0.16, 0.14, 0.08),
  (0.02, 0.13, 0.1),
  (0.16, 0.14, 0.05),
  (-0.08, 0.14, -0.08),
  (0.12, 0.13, -0.1),
  (-0.12, 0.26, 0),
  (0.12, 0.26, 0.02),
  (0, 0.36, 0),
];

void _crate(Scene scene, Vector3 at, List<Node> fill) {
  const width = 0.78;
  const depth = 0.58;
  const wall = 0.26;
  final root = Node(name: 'produce-crate')..position = at;
  final parts = <Node>[
    _wood(Vector3(0, 0.02, 0), Vector3(width, 0.04, depth), 0.76, 0.58, 0.36),
    _wood(
      Vector3(0, wall / 2, depth / 2),
      Vector3(width, wall, 0.04),
      0.58,
      0.4,
      0.22,
    ),
    _wood(
      Vector3(0, wall / 2, -depth / 2),
      Vector3(width, wall, 0.04),
      0.52,
      0.36,
      0.2,
    ),
    _wood(
      Vector3(-width / 2, wall / 2, 0),
      Vector3(0.04, wall, depth),
      0.62,
      0.44,
      0.26,
    ),
    _wood(
      Vector3(width / 2, wall / 2, 0),
      Vector3(0.04, wall, depth),
      0.62,
      0.44,
      0.26,
    ),
    ...fill,
  ];
  for (final part in parts) {
    part.castsShadows = false;
    part.shadowStatic = false;
    root.add(part);
  }
  root.castsShadows = false;
  root.shadowStatic = false;
  scene.add(root);
}

List<Node> _heap(double red, double green, double blue) {
  return [
    for (var i = 0; i < _mound.length; i++)
      Node(
        name: 'pile-$i',
        mesh: Mesh(
          SphereGeometry(radius: 0.09, segments: 10, rings: 7),
          BlockoutPalette.flat(red, green, blue, 0.45),
        ),
      )..position = Vector3(_mound[i].$1, _mound[i].$2, _mound[i].$3),
  ];
}

Node _wood(Vector3 at, Vector3 size, double red, double green, double blue) {
  return Node(
    name: 'crate-wood',
    mesh: Mesh(
      CuboidGeometry(size),
      BlockoutPalette.flat(red, green, blue, 0.72),
    ),
  )..position = at;
}
