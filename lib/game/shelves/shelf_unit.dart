import '../../data/models/product_definition.dart';
import '../../data/models/product_stock.dart';
import 'shelf_slot.dart';

/// Logical shelf: levels of slots that can hold one catalog product.
///
/// The shelf stores a product id and a count. It does not copy prices.
class ShelfUnit {
  ShelfUnit._(this.id, this.slots, this.shelfType);

  final String id;
  final List<ShelfSlot> slots;

  /// Which products this face can hold. Comes from product data, not a list.
  final ShelfType shelfType;

  ProductStock? stock;

  int get capacity => slots.length;

  int get quantity => stock?.quantity ?? 0;

  /// Occupied slots. The scene draws one visual for each.
  int get visualCount => slots.where((slot) => !slot.isEmpty).length;

  /// Top level is filled first so eye-height stock is visible.
  factory ShelfUnit.empty({
    required String id,
    required int slotsPerLevel,
    int levelCount = 3,
    ShelfType shelfType = ShelfType.dry,
  }) {
    if (slotsPerLevel <= 0 || levelCount <= 0) {
      throw ArgumentError('a shelf needs at least one slot');
    }
    final slots = <ShelfSlot>[];
    for (var level = levelCount - 1; level >= 0; level--) {
      for (var index = 0; index < slotsPerLevel; index++) {
        slots.add(ShelfSlot(level: level, index: index));
      }
    }
    return ShelfUnit._(id, slots, shelfType);
  }

  /// Same shelf type, and either empty or already holding this product.
  bool canPlace(ProductDefinition product) {
    if (product.shelfType != shelfType) {
      return false;
    }
    final current = stock?.productId;
    if (current != null && current != product.id) {
      return false;
    }
    final cap = capacity < product.maxShelfQuantity
        ? capacity
        : product.maxShelfQuantity;
    if (quantity >= cap) {
      return false;
    }
    return slots.any((slot) => slot.isEmpty);
  }

  /// Clears one occupied slot. Returns false when that slot cannot give an item.
  bool takeFromSlot(ShelfSlot slot) {
    if (!slots.contains(slot) || slot.isEmpty) {
      return false;
    }
    final id = slot.productId;
    if (id == null || stock == null || stock!.productId != id) {
      return false;
    }
    slot.clear();
    final remaining = slots.where((entry) => !entry.isEmpty).length;
    stock = remaining == 0
        ? null
        : ProductStock(productId: id, quantity: remaining);
    return true;
  }

  /// Fills the first empty slot, top level first. Null when the shelf refuses.
  ShelfSlot? placeOne(ProductDefinition product) {
    if (!canPlace(product)) {
      return null;
    }
    for (final slot in slots) {
      if (!slot.isEmpty) {
        continue;
      }
      slot.productId = product.id;
      slot.quantity = 1;
      final next = slots.where((entry) => !entry.isEmpty).length;
      stock = ProductStock(productId: product.id, quantity: next);
      return slot;
    }
    return null;
  }

  void stockProduct(ProductDefinition product, int quantity) {
    if (quantity < 0) {
      throw ArgumentError('shelf quantity cannot be negative');
    }
    final cap = capacity < product.maxShelfQuantity
        ? capacity
        : product.maxShelfQuantity;
    if (quantity > cap) {
      throw ArgumentError('quantity $quantity exceeds shelf capacity $cap');
    }
    stock = quantity == 0
        ? null
        : ProductStock(productId: product.id, quantity: quantity);
    var remaining = quantity;
    for (final slot in slots) {
      if (remaining > 0) {
        slot.productId = product.id;
        slot.quantity = 1;
        remaining--;
      } else {
        slot.clear();
      }
    }
  }

  void removeStock(ProductDefinition product, int amount) {
    if (amount < 0) {
      throw ArgumentError('cannot remove a negative amount');
    }
    if (stock != null && stock!.productId != product.id) {
      throw ArgumentError('shelf holds ${stock!.productId}');
    }
    stockProduct(product, quantity - amount);
  }
}
