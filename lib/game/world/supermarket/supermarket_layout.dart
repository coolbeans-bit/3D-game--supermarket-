import 'package:vector_math/vector_math.dart';

import '../collision_box.dart';

/// Meters for the neighborhood supermarket blockout.
///
/// The shopping floor runs from x -6..6 and z -7..7. +Z is the entrance.
/// Storage and the staff room continue from z -7 to z -12. Four gondolas
/// leave three aisles a player can walk. Y is up. The origin is the
/// center of the shopping floor.
class SupermarketLayout {
  const SupermarketLayout._();

  static const double wallThickness = 0.22;
  static const double wallHeight = 3.0;
  static const double playerRadius = 0.32;
  static const double bounds = 16;

  static const double shopMinX = -6;
  static const double shopMaxX = 6;
  static const double shopMinZ = -7;
  static const double shopMaxZ = 7;
  static const double storageMinZ = -12;

  static const double outerMinX = shopMinX - wallThickness;
  static const double outerMaxX = shopMaxX + wallThickness;
  static const double outerMinZ = storageMinZ - wallThickness;
  static const double outerMaxZ = shopMaxZ + wallThickness;

  static const double entranceHalfWidth = 1.2;
  static const double doorHeight = 2.2;

  static const double entrancePanelWidth = 1.2;
  static const double entrancePanelThickness = 0.06;
  static const double entrancePanelZ = 7.08;
  static const double entranceClosedLeftX = -0.6;
  static const double entranceClosedRightX = 0.6;
  static const double entranceOpenLeftX = -1.82;
  static const double entranceOpenRightX = 1.82;

  static const double storageDoorWidth = 1.6;
  static const double storageDoorThickness = 0.06;
  static const double storageHingeX = -4.3;
  static const double storageDoorZ = -7.11;
  static const double storageDoorClosedX = -3.5;

  static const double porchHalfWidth = 3.2;
  static const double porchOuterZ = 12.2;

  static const double shelfDepth = 0.75;
  static const double shelfLength = 6.4;
  static const double shelfHeight = 1.65;
  static const double shelfCenterZ = -1;

  static const double counterCenterX = 4.55;
  static const double counterCenterZ = 4.75;
  static const double counterSizeX = 1.9;
  static const double counterSizeZ = 1.5;
  static const double counterHeight = 1.05;

  static const double scannerCenterX = 4.25;
  static const double scannerCenterZ = 4.2;
  static const double scannerWidth = 0.16;
  static const double scannerHeight = 0.7;

  static const double paymentCenterX = 5.05;
  static const double paymentCenterZ = 4.45;

  /// Basket stand just inside the door, off the aisle customers walk.
  static const double basketX = -2.15;
  static const double basketZ = 6.35;

  /// On the porch, far enough from the outer curb that the camera can sit
  /// a full step behind her instead of inside her head.
  static Vector3 get playerStart => Vector3(0, 0, 9);

  static const List<FloorMark> queueMarks = [
    FloorMark(4.55, 3.15),
    FloorMark(4.55, 2.45),
    FloorMark(4.55, 1.75),
  ];

  static List<ShelfSpec> get shelves => [
    for (final entry in const <(String, double)>[
      ('gondola-a', -3.375),
      ('gondola-b', -1.125),
      ('gondola-c', 1.125),
      ('gondola-d', 3.375),
    ])
      ShelfSpec(
        name: entry.$1,
        centerX: entry.$2,
        centerZ: shelfCenterZ,
        depth: shelfDepth,
        length: shelfLength,
        height: shelfHeight,
      ),
    const ShelfSpec(
      name: 'storage-rack',
      centerX: -5.15,
      centerZ: -10,
      depth: 0.7,
      length: 3.2,
      height: 1.5,
    ),
  ];

  static List<BlockSpan> get solids => [
    _wall(centerX: -6.11, centerZ: -2.5, sizeX: wallThickness, sizeZ: 19.44),
    _wall(centerX: 6.11, centerZ: -2.5, sizeX: wallThickness, sizeZ: 19.44),
    _wall(centerX: 0, centerZ: -12.11, sizeX: 12.44, sizeZ: wallThickness),
    _wall(centerX: -3.71, centerZ: 7.11, sizeX: 5.02, sizeZ: wallThickness),
    _wall(centerX: 3.71, centerZ: 7.11, sizeX: 5.02, sizeZ: wallThickness),
    _wall(centerX: -5.26, centerZ: -7.11, sizeX: 1.92, sizeZ: wallThickness),
    _wall(centerX: 1.76, centerZ: -7.11, sizeX: 8.92, sizeZ: wallThickness),
    _wall(centerX: 1.5, centerZ: -11.06, sizeX: wallThickness, sizeZ: 2.32),
    _wall(centerX: 1.5, centerZ: -7.605, sizeX: wallThickness, sizeZ: 0.99),
    _curb(centerX: -3.2, centerZ: 9.71, sizeX: 0.18, sizeZ: 4.98),
    _curb(centerX: 3.2, centerZ: 9.71, sizeX: 0.18, sizeZ: 4.98),
    _curb(centerX: 0, centerZ: porchOuterZ, sizeX: 6.56, sizeZ: 0.18),
    const BlockSpan(
      role: SpanRole.counter,
      centerX: counterCenterX,
      centerZ: counterCenterZ,
      sizeX: counterSizeX,
      sizeZ: counterSizeZ,
      sizeY: counterHeight,
    ),
    const BlockSpan(
      role: SpanRole.bench,
      centerX: 4.3,
      centerZ: -11.15,
      sizeX: 2.2,
      sizeZ: 0.7,
      sizeY: 0.9,
    ),
  ];

  static CollisionWorld createWorld() {
    final world = CollisionWorld(limit: bounds);
    world.boxes.addAll(staticObstacles());
    return world;
  }

  static List<CollisionBox> staticObstacles() {
    return [
      for (final span in solids) _footprint(span),
      for (final shelf in shelves)
        CollisionBox.padded(
          centerX: shelf.centerX,
          centerZ: shelf.centerZ,
          sizeX: shelf.depth,
          sizeZ: shelf.length,
          padding: playerRadius,
        ),
    ];
  }

  static bool occupied(
    double x,
    double z, [
    List<CollisionBox> extra = const [],
  ]) {
    if (x.abs() > bounds || z.abs() > bounds) {
      return true;
    }
    for (final box in staticObstacles()) {
      if (box.containsPoint(x, z)) {
        return true;
      }
    }
    for (final box in extra) {
      if (box.containsPoint(x, z)) {
        return true;
      }
    }
    return false;
  }

  static CollisionBox entrancePanelBox(double centerX) {
    return CollisionBox.padded(
      centerX: centerX,
      centerZ: entrancePanelZ,
      sizeX: entrancePanelWidth,
      sizeZ: entrancePanelThickness,
      padding: playerRadius,
    );
  }

  static CollisionBox storageDoorClosedBox() {
    return CollisionBox.padded(
      centerX: storageDoorClosedX,
      centerZ: storageDoorZ,
      sizeX: storageDoorWidth,
      sizeZ: storageDoorThickness,
      padding: playerRadius,
    );
  }

  static CollisionBox storageDoorOpenBox() {
    return CollisionBox.padded(
      centerX: storageHingeX,
      centerZ: storageDoorZ - storageDoorWidth / 2,
      sizeX: storageDoorThickness,
      sizeZ: storageDoorWidth,
      padding: playerRadius,
    );
  }

  static CollisionBox _footprint(BlockSpan span) {
    return CollisionBox.padded(
      centerX: span.centerX,
      centerZ: span.centerZ,
      sizeX: span.sizeX,
      sizeZ: span.sizeZ,
      padding: playerRadius,
    );
  }

  static BlockSpan _wall({
    required double centerX,
    required double centerZ,
    required double sizeX,
    required double sizeZ,
  }) {
    return BlockSpan(
      role: SpanRole.wall,
      centerX: centerX,
      centerZ: centerZ,
      sizeX: sizeX,
      sizeZ: sizeZ,
      sizeY: wallHeight,
    );
  }

  static BlockSpan _curb({
    required double centerX,
    required double centerZ,
    required double sizeX,
    required double sizeZ,
  }) {
    return BlockSpan(
      role: SpanRole.curb,
      centerX: centerX,
      centerZ: centerZ,
      sizeX: sizeX,
      sizeZ: sizeZ,
      sizeY: 0.9,
    );
  }
}

enum SpanRole { wall, curb, counter, bench }

class BlockSpan {
  const BlockSpan({
    required this.role,
    required this.centerX,
    required this.centerZ,
    required this.sizeX,
    required this.sizeZ,
    required this.sizeY,
    this.centerY,
  });

  final SpanRole role;
  final double centerX;
  final double centerZ;
  final double sizeX;
  final double sizeZ;
  final double sizeY;
  final double? centerY;

  double get y => centerY ?? sizeY / 2;
}

class ShelfSpec {
  const ShelfSpec({
    required this.name,
    required this.centerX,
    required this.centerZ,
    required this.depth,
    required this.length,
    required this.height,
  });

  final String name;
  final double centerX;
  final double centerZ;
  final double depth;
  final double length;
  final double height;
}

class FloorMark {
  const FloorMark(this.x, this.z);

  final double x;
  final double z;
}
