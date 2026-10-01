import '../../data/catalog/product_catalog.dart';
import '../../data/models/product_definition.dart';
import '../../data/models/product_stock.dart';
import '../shelves/shelf_slot.dart';
import '../shelves/shelf_unit.dart';
import 'carry_controller.dart';

/// Moves one catalog product between a shelf and the player's hands.
///
/// Every product uses this path. The carried id is the catalog id.
class ProductCarry {
  ProductCarry({required this.carry, required this.catalog});

  final CarryController carry;
  final ProductCatalog catalog;

  ProductDefinition? get heldDefinition {
    final id = carry.held?.id;
    if (id == null) {
      return null;
    }
    return catalog.lookup(id);
  }

  bool canPlaceOn(ShelfUnit shelf) {
    final product = heldDefinition;
    if (product == null) {
      return false;
    }
    return shelf.canPlace(product);
  }

  /// Removes one unit from [slot]. False leaves the shelf and hands unchanged.
  bool pickup(ShelfUnit shelf, ShelfSlot slot) {
    if (carry.isHolding || !shelf.slots.contains(slot) || slot.isEmpty) {
      return false;
    }
    final id = slot.productId;
    if (id == null) {
      return false;
    }
    final product = catalog.lookup(id);
    if (product == null) {
      return false;
    }
    if (!shelf.takeFromSlot(slot)) {
      return false;
    }
    final held = carry.tryHold(
      CarriedItem(id: product.id, label: product.name, quantity: 1),
    );
    if (!held) {
      slot.productId = product.id;
      slot.quantity = 1;
      final count = shelf.slots.where((entry) => !entry.isEmpty).length;
      shelf.stock = ProductStock(productId: product.id, quantity: count);
      return false;
    }
    return true;
  }

  /// Puts the held product in the next open slot. Null when that is refused.
  ShelfSlot? place(ShelfUnit shelf) {
    final product = heldDefinition;
    if (product == null) {
      return null;
    }
    final slot = shelf.placeOne(product);
    if (slot == null) {
      return null;
    }
    carry.release();
    return slot;
  }
}
