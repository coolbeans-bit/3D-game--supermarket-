import 'dart:math';

import '../shelves/store_shelf_plan.dart';

/// Where a shopper stands to take one catalog product.
///
/// The spot is the walkable aisle beside that product's gondola, not a
/// point inside the shelf.
class ProductStand {
  const ProductStand({
    required this.x,
    required this.z,
    required this.faceYaw,
    required this.aisle,
    this.productId,
  });

  final double x;
  final double z;
  final double faceYaw;
  final String? productId;

  /// 0 is the west wall aisle. Even aisles are walked toward the back.
  final int aisle;
}

/// Aisle centers a person can occupy, west to east.
const List<double> shopperAisleX = [-4.85, -2.25, 0, 2.25];

/// The stand for [productId], or null when that product is not on a gondola.
ProductStand? standForProduct(String productId) {
  for (final plan in StoreShelfPlan.plans) {
    if (plan.productId != productId) {
      continue;
    }
    final spot = _spot(plan.gondolaName, plan.side);
    if (spot == null) {
      return null;
    }
    return ProductStand(
      x: spot.$1,
      z: plan.centerZ,
      faceYaw: spot.$2,
      aisle: spot.$3,
      productId: plan.productId,
    );
  }
  return null;
}

/// (x, facing yaw, aisle index). Facing matches the player: yaw 0 looks -Z.
(double, double, int)? _spot(String gondola, int side) {
  return switch ((gondola, side)) {
    ('gondola-a', -1) => (-4.85, -pi / 2, 0),
    ('gondola-a', 1) => (-2.25, pi / 2, 1),
    ('gondola-b', -1) => (-2.25, -pi / 2, 1),
    ('gondola-b', 1) => (0, pi / 2, 2),
    ('gondola-c', -1) => (0, -pi / 2, 2),
    ('gondola-c', 1) => (2.25, pi / 2, 3),
    ('gondola-d', -1) => (2.25, -pi / 2, 3),
    ('gondola-d', 1) => (2.25, -pi / 2, 3),
    _ => null,
  };
}
