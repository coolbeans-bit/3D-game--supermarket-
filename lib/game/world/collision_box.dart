/// An axis-aligned footprint on the floor, in meters.
///
/// [minX] and the other edges are the blocked region for the player's
/// center, so callers expand solid geometry by the player radius first.
class CollisionBox {
  CollisionBox({
    required this.minX,
    required this.maxX,
    required this.minZ,
    required this.maxZ,
  });

  factory CollisionBox.padded({
    required double centerX,
    required double centerZ,
    required double sizeX,
    required double sizeZ,
    required double padding,
  }) {
    return CollisionBox(
      minX: centerX - sizeX / 2 - padding,
      maxX: centerX + sizeX / 2 + padding,
      minZ: centerZ - sizeZ / 2 - padding,
      maxZ: centerZ + sizeZ / 2 + padding,
    );
  }

  double minX;
  double maxX;
  double minZ;
  double maxZ;

  bool containsPoint(double x, double z) {
    return x >= minX && x <= maxX && z >= minZ && z <= maxZ;
  }

  void copyFrom(CollisionBox other) {
    minX = other.minX;
    maxX = other.maxX;
    minZ = other.minZ;
    maxZ = other.maxZ;
  }
}

/// Static walls plus doors that move. The player reads [boxes] every step.
class CollisionWorld {
  CollisionWorld({required this.limit});

  /// Safety bound in meters. Walls are the real boundary.
  final double limit;

  final List<CollisionBox> boxes = [];
}
