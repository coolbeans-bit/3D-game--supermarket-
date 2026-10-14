import '../../data/catalog/product_catalog.dart';
import '../../data/models/product_definition.dart';
import '../../data/models/product_stock.dart';
import '../shelves/shelf_slot.dart';
import '../shelves/shelf_unit.dart';
import 'carry_controller.dart';
import 'shopping_basket.dart';

/// Moves one catalog product between a shelf and the player's hands.
///
/// Every product uses this path. The carried id is the catalog id.
class ProductCarry {
  ProductCarry({required this.carry, required this.catalog, this.basket});

  final CarryController carry;
  final ProductCatalog catalog;
  final ShoppingBasket? basket;
  bool _reachPending = false;

  /// How many products have been taken off a shelf. Taking one back out of
  /// the basket does not increase this, so the letter round is not scored twice.
  int shelfPickups = 0;

  /// True once after a product leaves the shelf, including when it goes
  /// straight into the basket and the hands are empty again.
  bool consumeReach() {
    final pending = _reachPending;
    _reachPending = false;
    return pending;
  }

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
    shelfPickups += 1;
    final held = carry.tryHold(
      CarriedItem(id: product.id, label: product.marathiName, quantity: 1),
    );
    if (!held) {
      shelfPickups -= 1;
      slot.productId = product.id;
      slot.quantity = 1;
      final count = shelf.slots.where((entry) => !entry.isEmpty).length;
      shelf.stock = ProductStock(productId: product.id, quantity: count);
      return false;
    }
    final hands = basket;
    if (hands != null && hands.carried && hands.stow(product.id)) {
      carry.release();
    }
    _reachPending = true;
    return true;
  }

  /// Moves one basket product into the hands. False when the hands are full
  /// or that spot is empty. The item can then be placed back on a shelf.
  bool drawFromBasket(int index) {
    final hands = basket;
    if (hands == null || carry.isHolding) {
      return false;
    }
    final id = hands.takeAt(index);
    if (id == null) {
      return false;
    }
    final product = catalog.lookup(id);
    if (product == null ||
        !carry.tryHold(
          CarriedItem(id: product.id, label: product.marathiName, quantity: 1),
        )) {
      hands.stow(id);
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
