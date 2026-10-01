import 'package:flutter/foundation.dart';

/// Whether the player's hands are free.
enum CarryState { empty, holding }

/// The one thing currently carried. Later items (a box, a basket, a tool)
/// use the same id and quantity. Product details stay in the catalog.
class CarriedItem {
  const CarriedItem({required this.id, required this.label, this.quantity = 1});

  final String id;
  final String label;
  final int quantity;
}

/// Hands: empty, or holding exactly one item.
class CarryController extends ChangeNotifier {
  CarryState _state = CarryState.empty;
  CarriedItem? _held;

  CarryState get state => _state;

  CarriedItem? get held => _held;

  bool get isHolding => _state == CarryState.holding;

  /// False when the hands are already full, or the item is not a real unit.
  bool tryHold(CarriedItem item) {
    if (_state == CarryState.holding || item.quantity < 1 || item.id.isEmpty) {
      return false;
    }
    _held = item;
    _state = CarryState.holding;
    notifyListeners();
    return true;
  }

  /// Clears the hands. Null when nothing was held.
  CarriedItem? release() {
    if (_state != CarryState.holding) {
      return null;
    }
    final item = _held;
    _held = null;
    _state = CarryState.empty;
    notifyListeners();
    return item;
  }
}
