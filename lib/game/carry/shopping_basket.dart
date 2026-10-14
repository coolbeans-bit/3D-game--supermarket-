import 'package:flutter/foundation.dart';

/// The basket taken from the stand by the entrance.
///
/// One product still fits in the hands. With the basket, further products
/// are put away so the hands are free for the next shelf.
class ShoppingBasket extends ChangeNotifier {
  static const int capacity = 6;

  bool carried = false;

  /// Floor position after it is put down. Null while it is carried or still on the stand.
  double? dropX;
  double? dropZ;
  double dropYaw = 0;

  final List<String> _ids = [];

  int get count => _ids.length;

  bool get hasRoom => _ids.length < capacity;

  /// True when this basket is sitting on the floor where it was put down.
  bool get isOnFloor => !carried && dropX != null && dropZ != null;

  List<String> get productIds => List.unmodifiable(_ids);

  void take() {
    if (carried) {
      return;
    }
    carried = true;
    dropX = null;
    dropZ = null;
    notifyListeners();
  }

  /// False when the basket was not taken or it is already full.
  bool stow(String productId) {
    if (!carried || productId.isEmpty || !hasRoom) {
      return false;
    }
    _ids.add(productId);
    notifyListeners();
    return true;
  }

  /// The next product to scan, or null when the basket is empty.
  String? takeNext() => takeAt(0);

  /// Removes the product at [index]. Null when that spot is empty.
  String? takeAt(int index) {
    if (index < 0 || index >= _ids.length) {
      return null;
    }
    final id = _ids.removeAt(index);
    notifyListeners();
    return id;
  }

  /// Leaves the basket at [x], [z], facing [yaw]. Items stay inside it.
  void putDown({required double x, required double z, required double yaw}) {
    if (!carried) {
      return;
    }
    carried = false;
    dropX = x;
    dropZ = z;
    dropYaw = yaw;
    notifyListeners();
  }
}
