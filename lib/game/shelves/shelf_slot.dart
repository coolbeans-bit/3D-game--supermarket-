/// One place a single product visual can stand.
class ShelfSlot {
  ShelfSlot({required this.level, required this.index});

  /// 0 is the lowest board.
  final int level;
  final int index;

  String? productId;
  int quantity = 0;

  bool get isEmpty => quantity == 0;

  void clear() {
    productId = null;
    quantity = 0;
  }
}

/// Shared board heights so meshes and product slots use the same shelves.
class ShelfMetrics {
  const ShelfMetrics._();

  static const boardY = <double>[0.4, 0.88, 1.42];
  static const boardThickness = 0.045;
  static const sideOffset = 0.2;
  static const slotPitch = 0.42;
}
