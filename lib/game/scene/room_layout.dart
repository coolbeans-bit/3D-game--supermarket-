/// Meters for the first-person test room. Shared by the scene and movement.
class RoomLayout {
  const RoomLayout._();

  /// Distance from the room center to the inner face of each wall.
  static const double innerHalf = 4.5;

  static const double wallThickness = 0.3;
  static const double wallHeight = 2.6;
  static const double playerRadius = 0.32;

  static const double eyeHeight = 1.6;

  /// How far the player's center may travel from the room center.
  static double get walkLimit => innerHalf - playerRadius;

  static double get outerHalf => innerHalf + wallThickness;

  /// Center of a wall slab whose inner face sits on [innerHalf].
  static double get wallCenter => innerHalf + wallThickness / 2;
}
