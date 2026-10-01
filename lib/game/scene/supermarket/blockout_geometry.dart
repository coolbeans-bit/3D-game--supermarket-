import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../world/supermarket/supermarket_layout.dart';

/// Shared flat colors for the supermarket blockout. No textures.
class BlockoutPalette {
  BlockoutPalette() {
    floor = _mat(0.73, 0.67, 0.54, 0.92);
    porch = _mat(0.62, 0.63, 0.64, 0.95);
    storageFloor = _mat(0.52, 0.54, 0.56, 0.9);
    staffFloor = _mat(0.46, 0.55, 0.48, 0.9);
    wall = _mat(0.84, 0.83, 0.8, 0.88);
    curb = _mat(0.55, 0.56, 0.58, 0.9);
    ceiling = _mat(0.9, 0.9, 0.88, 0.95);
    canopy = _mat(0.22, 0.48, 0.32, 0.55);
    frame = _mat(0.32, 0.36, 0.38, 0.5);
    door = _mat(0.42, 0.62, 0.72, 0.32);
    shelfFrame = _mat(0.4, 0.42, 0.44, 0.55);
    shelfBoard = _mat(0.74, 0.71, 0.64, 0.62);
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
