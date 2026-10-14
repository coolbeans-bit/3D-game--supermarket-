import 'package:vector_math/vector_math.dart';

import '../../data/catalog/product_catalog.dart';
import '../../data/models/product_definition.dart';
import '../world/supermarket/supermarket_layout.dart';
import 'shelf_slot.dart';
import 'shelf_unit.dart';

/// Where a stocked shelf face sits on a gondola. [side] is -1 or +1 in X.
class StoreShelfPlan {
  const StoreShelfPlan({
    required this.id,
    required this.gondolaName,
    required this.side,
    required this.centerZ,
    required this.slotsPerLevel,
    required this.productId,
    required this.quantity,
  });

  final String id;
  final String gondolaName;
  final int side;
  final double centerZ;
  final int slotsPerLevel;
  final String productId;
  final int quantity;

  static const plans = <StoreShelfPlan>[
    StoreShelfPlan(
      id: 'aisle-1-milk',
      gondolaName: 'gondola-a',
      side: 1,
      centerZ: SupermarketLayout.shelfCenterZ,
      slotsPerLevel: 4,
      productId: 'milk',
      quantity: 8,
    ),
    StoreShelfPlan(
      id: 'aisle-1-bread',
      gondolaName: 'gondola-b',
      side: -1,
      centerZ: SupermarketLayout.shelfCenterZ,
      slotsPerLevel: 4,
      productId: 'bread',
      quantity: 6,
    ),
    StoreShelfPlan(
      id: 'aisle-2-rice',
      gondolaName: 'gondola-b',
      side: 1,
      centerZ: SupermarketLayout.shelfCenterZ,
      slotsPerLevel: 4,
      productId: 'rice',
      quantity: 6,
    ),
    StoreShelfPlan(
      id: 'aisle-2-biscuits',
      gondolaName: 'gondola-c',
      side: -1,
      centerZ: 0.7,
      slotsPerLevel: 3,
      productId: 'biscuits',
      quantity: 5,
    ),
    StoreShelfPlan(
      id: 'aisle-2-chips',
      gondolaName: 'gondola-c',
      side: -1,
      centerZ: -2.3,
      slotsPerLevel: 3,
      productId: 'potato-chips',
      quantity: 5,
    ),
    StoreShelfPlan(
      id: 'aisle-3-soap',
      gondolaName: 'gondola-c',
      side: 1,
      centerZ: SupermarketLayout.shelfCenterZ,
      slotsPerLevel: 4,
      productId: 'soap',
      quantity: 6,
    ),
    StoreShelfPlan(
      id: 'aisle-3-shampoo',
      gondolaName: 'gondola-d',
      side: -1,
      centerZ: 0.7,
      slotsPerLevel: 3,
      productId: 'shampoo',
      quantity: 5,
    ),
    StoreShelfPlan(
      id: 'aisle-3-juice',
      gondolaName: 'gondola-d',
      side: -1,
      centerZ: -2.3,
      slotsPerLevel: 3,
      productId: 'orange-juice',
      quantity: 5,
    ),
    StoreShelfPlan(
      id: 'west-banana',
      gondolaName: 'gondola-a',
      side: -1,
      centerZ: 1.2,
      slotsPerLevel: 3,
      productId: 'banana',
      quantity: 4,
    ),
    StoreShelfPlan(
      id: 'west-onion',
      gondolaName: 'gondola-a',
      side: -1,
      centerZ: -1,
      slotsPerLevel: 3,
      productId: 'onion',
      quantity: 4,
    ),
    StoreShelfPlan(
      id: 'west-tomato',
      gondolaName: 'gondola-a',
      side: -1,
      centerZ: -3.2,
      slotsPerLevel: 3,
      productId: 'tomato',
      quantity: 4,
    ),
    StoreShelfPlan(
      id: 'east-chilli',
      gondolaName: 'gondola-d',
      side: 1,
      centerZ: 1.2,
      slotsPerLevel: 3,
      productId: 'chilli',
      quantity: 4,
    ),
    StoreShelfPlan(
      id: 'east-oil',
      gondolaName: 'gondola-d',
      side: 1,
      centerZ: -1,
      slotsPerLevel: 3,
      productId: 'oil',
      quantity: 4,
    ),
    StoreShelfPlan(
      id: 'east-tea',
      gondolaName: 'gondola-d',
      side: 1,
      centerZ: -3.2,
      slotsPerLevel: 3,
      productId: 'tea',
      quantity: 4,
    ),
    StoreShelfPlan(
      id: 'aisle-1-eggs',
      gondolaName: 'gondola-a',
      side: 1,
      centerZ: 1.25,
      slotsPerLevel: 3,
      productId: 'eggs',
      quantity: 4,
    ),
    StoreShelfPlan(
      id: 'aisle-1-butter',
      gondolaName: 'gondola-a',
      side: 1,
      centerZ: -3.25,
      slotsPerLevel: 3,
      productId: 'butter',
      quantity: 4,
    ),
    StoreShelfPlan(
      id: 'aisle-1-jam',
      gondolaName: 'gondola-b',
      side: -1,
      centerZ: 1.25,
      slotsPerLevel: 3,
      productId: 'jam',
      quantity: 4,
    ),
    StoreShelfPlan(
      id: 'aisle-1-jaggery',
      gondolaName: 'gondola-b',
      side: -1,
      centerZ: -3.25,
      slotsPerLevel: 3,
      productId: 'jaggery',
      quantity: 4,
    ),
    StoreShelfPlan(
      id: 'aisle-2-noodles',
      gondolaName: 'gondola-b',
      side: 1,
      centerZ: 1.25,
      slotsPerLevel: 3,
      productId: 'noodles',
      quantity: 4,
    ),
    StoreShelfPlan(
      id: 'aisle-2-chickpeas',
      gondolaName: 'gondola-b',
      side: 1,
      centerZ: -3.25,
      slotsPerLevel: 3,
      productId: 'chickpeas',
      quantity: 4,
    ),
    StoreShelfPlan(
      id: 'aisle-3-water',
      gondolaName: 'gondola-c',
      side: 1,
      centerZ: 1.25,
      slotsPerLevel: 3,
      productId: 'water',
      quantity: 4,
    ),
    StoreShelfPlan(
      id: 'aisle-3-mango',
      gondolaName: 'gondola-c',
      side: 1,
      centerZ: -3.25,
      slotsPerLevel: 3,
      productId: 'mango',
      quantity: 4,
    ),
  ];
}

class StockedShelf {
  StockedShelf(this.plan, this.unit);

  final StoreShelfPlan plan;
  final ShelfUnit unit;
}

/// Builds the starter shelves from the catalog. Rendering is separate.
List<StockedShelf> starterShelves(ProductCatalog catalog) {
  return [
    for (final plan in StoreShelfPlan.plans)
      StockedShelf(plan, _stock(plan, catalog)),
  ];
}

ShelfUnit _stock(StoreShelfPlan plan, ProductCatalog catalog) {
  final product = catalog.require(plan.productId);
  final unit = ShelfUnit.empty(
    id: plan.id,
    slotsPerLevel: plan.slotsPerLevel,
    shelfType: product.shelfType,
  );
  unit.stockProduct(product, plan.quantity);
  return unit;
}

/// World position of one occupied slot. [itemHeight] is the placeholder mesh.
Vector3 shelfSlotPosition({
  required StoreShelfPlan plan,
  required ShelfSlot slot,
  required double itemHeight,
}) {
  final gondola = SupermarketLayout.shelves.firstWhere(
    (shelf) => shelf.name == plan.gondolaName,
  );
  final along =
      (slot.index - (plan.slotsPerLevel - 1) / 2) * ShelfMetrics.slotPitch;
  final y =
      ShelfMetrics.boardY[slot.level] +
      ShelfMetrics.boardThickness / 2 +
      itemHeight / 2;
  return Vector3(
    gondola.centerX + plan.side * ShelfMetrics.sideOffset,
    y,
    plan.centerZ + along,
  );
}

double productHeight(ProductShape shape) {
  return switch (shape) {
    ProductShape.bottle => 0.22,
    ProductShape.box => 0.2,
    ProductShape.carton => 0.22,
    ProductShape.bag => 0.2,
  };
}
