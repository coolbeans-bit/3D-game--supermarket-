import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../carry/product_carry.dart';
import '../../interaction/interaction_system.dart';
import '../../shelves/shelf_slot.dart';
import '../../shelves/store_shelf_plan.dart';
import '../../world/supermarket/supermarket_layout.dart';
import '../products/held_product_presenter.dart';
import '../products/product_visual_factory.dart';
import 'blockout_geometry.dart';

/// Gondola frames plus the starter product stock on their slots.
HeldProductPresenter addSupermarketShelves(
  Scene scene,
  InteractionSystem interactions,
  BlockoutPalette palette,
  ProductCarry productCarry,
) {
  final presenter = HeldProductPresenter(
    scene: scene,
    interactions: interactions,
    productCarry: productCarry,
    factory: ProductVisualFactory(),
  );
  for (final shelf in SupermarketLayout.shelves) {
    presenter.registerFrame(shelf.name, _addFrame(scene, shelf, palette));
  }
  for (final stocked in starterShelves(productCarry.catalog)) {
    presenter.addFace(stocked);
  }
  return presenter;
}

List<Node> _addFrame(Scene scene, ShelfSpec shelf, BlockoutPalette palette) {
  final parts = <Node>[];
  final halfLength = shelf.length / 2;
  var part = 0;
  for (final end in [-halfLength + 0.04, halfLength - 0.04]) {
    parts.add(
      addBox(
        scene,
        name: '${shelf.name}-upright-$part',
        center: Vector3(shelf.centerX, shelf.height / 2, shelf.centerZ + end),
        size: Vector3(0.08, shelf.height, 0.08),
        material: palette.shelfFrame,
      ),
    );
    part++;
  }
  parts.add(
    addBox(
      scene,
      name: '${shelf.name}-spine',
      center: Vector3(shelf.centerX, shelf.height / 2, shelf.centerZ),
      size: Vector3(0.05, shelf.height, shelf.length - 0.16),
      material: palette.shelfFrame,
    ),
  );
  for (var level = 0; level < ShelfMetrics.boardY.length; level++) {
    final boardY = ShelfMetrics.boardY[level];
    if (boardY >= shelf.height) {
      continue;
    }
    parts.add(
      addBox(
        scene,
        name: '${shelf.name}-board-$level',
        center: Vector3(shelf.centerX, boardY, shelf.centerZ),
        size: Vector3(
          shelf.depth - 0.04,
          ShelfMetrics.boardThickness,
          shelf.length - 0.16,
        ),
        material: palette.shelfBoard,
        castsShadows: false,
      ),
    );
  }
  return parts;
}
