import '../../data/catalog/product_catalog.dart';
import '../shelves/shelf_slot.dart';
import '../shelves/store_shelf_plan.dart';

/// One unit put back on the shelf it came from.
class ShelfReturn {
  const ShelfReturn({required this.shelfId, required this.slot});

  final String shelfId;
  final ShelfSlot slot;
}

/// What a cancelled sale was able to put back.
class ReturnResult {
  const ReturnResult({required this.placed, required this.unplacedIds});

  final List<ShelfReturn> placed;
  final List<String> unplacedIds;
}

/// Puts each scanned id on the shelf that stocks that product.
///
/// A full shelf, or an unknown id, stays in [ReturnResult.unplacedIds].
ReturnResult returnScannedProducts({
  required List<String> productIds,
  required ProductCatalog catalog,
  required List<StockedShelf> shelves,
}) {
  final placed = <ShelfReturn>[];
  final unplacedIds = <String>[];
  for (final id in productIds) {
    final product = catalog.lookup(id);
    if (product == null) {
      unplacedIds.add(id);
      continue;
    }
    StockedShelf? home;
    for (final shelf in shelves) {
      if (shelf.plan.productId == id && shelf.unit.canPlace(product)) {
        home = shelf;
        break;
      }
    }
    final slot = home?.unit.placeOne(product);
    if (home == null || slot == null) {
      unplacedIds.add(id);
      continue;
    }
    placed.add(ShelfReturn(shelfId: home.plan.id, slot: slot));
  }
  return ReturnResult(placed: placed, unplacedIds: unplacedIds);
}
