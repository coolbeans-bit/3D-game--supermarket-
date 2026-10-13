import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../world/supermarket/supermarket_layout.dart';

/// Shared flat colors for the supermarket blockout. No textures.
class BlockoutPalette {
  BlockoutPalette() {
    floor = _mat(0.9, 0.82, 0.66, 0.88);
    porch = _mat(0.84, 0.74, 0.58, 0.9);
    storageFloor = _mat(0.62, 0.64, 0.6, 0.9);
    staffFloor = _mat(0.55, 0.68, 0.52, 0.88);
    wall = _mat(0.97, 0.93, 0.86, 0.84);
    curb = _mat(0.72, 0.58, 0.42, 0.85);
    ceiling = _mat(0.98, 0.96, 0.9, 0.95);
    canopy = _mat(0.9, 0.38, 0.28, 0.5);
    canopyBand = _mat(0.95, 0.72, 0.22, 0.48);
    stripeCream = _mat(0.98, 0.94, 0.86, 0.55);
    dairySign = _mat(0.45, 0.72, 0.86, 0.5);
    grocerySign = _mat(0.93, 0.72, 0.22, 0.5);
    snackSign = _mat(0.9, 0.42, 0.28, 0.5);
    careSign = _mat(0.42, 0.7, 0.48, 0.5);
    produceSign = _mat(0.86, 0.32, 0.22, 0.5);
    basket = _mat(0.62, 0.42, 0.22, 0.75);
    mango = _mat(0.95, 0.72, 0.18, 0.55);
    tomato = _mat(0.82, 0.18, 0.16, 0.5);
    lime = _mat(0.55, 0.75, 0.22, 0.5);
    frame = _mat(0.62, 0.4, 0.26, 0.55);
    door = _mat(0.42, 0.62, 0.72, 0.32);
    shelfFrame = _mat(0.4, 0.42, 0.44, 0.55);
    shelfBoard = _mat(0.86, 0.72, 0.5, 0.58);
    counter = _mat(0.18, 0.4, 0.34, 0.45);
    scanner = _mat(0.12, 0.13, 0.15, 0.35);
    payment = _mat(0.76, 0.66, 0.32, 0.4);
    queue = _mat(0.28, 0.46, 0.7, 0.5);
    bench = _mat(0.46, 0.4, 0.32, 0.7);
    threshold = _mat(0.32, 0.33, 0.34, 0.85);
  }

  late final PhysicallyBasedMaterial floor;
  late final PhysicallyBasedMaterial porch;
  late final PhysicallyBasedMaterial storageFloor;
  late final PhysicallyBasedMaterial staffFloor;
  late final PhysicallyBasedMaterial wall;
  late final PhysicallyBasedMaterial curb;
  late final PhysicallyBasedMaterial ceiling;
  late final PhysicallyBasedMaterial canopy;
  late final PhysicallyBasedMaterial canopyBand;
  late final PhysicallyBasedMaterial stripeCream;
  late final PhysicallyBasedMaterial dairySign;
  late final PhysicallyBasedMaterial grocerySign;
  late final PhysicallyBasedMaterial snackSign;
  late final PhysicallyBasedMaterial careSign;
  late final PhysicallyBasedMaterial produceSign;
  late final PhysicallyBasedMaterial basket;
  late final PhysicallyBasedMaterial mango;
  late final PhysicallyBasedMaterial tomato;
  late final PhysicallyBasedMaterial lime;
  late final PhysicallyBasedMaterial frame;
  late final PhysicallyBasedMaterial door;
  late final PhysicallyBasedMaterial shelfFrame;
  late final PhysicallyBasedMaterial shelfBoard;
  late final PhysicallyBasedMaterial counter;
  late final PhysicallyBasedMaterial scanner;
  late final PhysicallyBasedMaterial payment;
  late final PhysicallyBasedMaterial queue;
  late final PhysicallyBasedMaterial bench;
  late final PhysicallyBasedMaterial threshold;

  static PhysicallyBasedMaterial flat(
    double r,
    double g,
    double b,
    double rough,
  ) {
    return _mat(r, g, b, rough);
  }

  static PhysicallyBasedMaterial _mat(
    double r,
    double g,
    double b,
    double rough,
  ) {
    return PhysicallyBasedMaterial()
      ..baseColorFactor = Vector4(r, g, b, 1)
      ..roughnessFactor = rough
      ..metallicFactor = 0.02;
  }
}

Node addBox(
  Scene scene, {
  required String name,
  required Vector3 center,
  required Vector3 size,
  required PhysicallyBasedMaterial material,
  bool shadowStatic = true,
  bool castsShadows = true,
}) {
  final node = Node(name: name, mesh: Mesh(CuboidGeometry(size), material))
    ..position = center
    ..shadowStatic = shadowStatic
    ..castsShadows = castsShadows;
  scene.add(node);
  return node;
}

void addSpan(
  Scene scene,
  BlockSpan span, {
  required String name,
  required PhysicallyBasedMaterial material,
}) {
  addBox(
    scene,
    name: name,
    center: Vector3(span.centerX, span.y, span.centerZ),
    size: Vector3(span.sizeX, span.sizeY, span.sizeZ),
    material: material,
  );
}

void addFloor(
  Scene scene, {
  required String name,
  required double width,
  required double depth,
  required Vector3 center,
  required PhysicallyBasedMaterial material,
}) {
  scene.add(
    Node(
        name: name,
        mesh: Mesh(PlaneGeometry(width: width, depth: depth), material),
      )
      ..position = center
      ..shadowStatic = true
      ..castsShadows = true,
  );
}
