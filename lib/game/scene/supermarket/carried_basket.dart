import 'dart:math';

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../../data/catalog/product_catalog.dart';
import '../../carry/shopping_basket.dart';
import '../../interaction/interactable.dart';
import '../../interaction/interaction_system.dart';
import '../products/product_visual_factory.dart';

/// Local spots inside the basket, in meters. X is to the holder's right,
/// Z is forward, Y is up from the basket's base.
final List<Vector3> _itemSlots = [
  Vector3(-0.07, 0.1, -0.04),
  Vector3(0.07, 0.1, -0.04),
  Vector3(-0.07, 0.1, 0.06),
  Vector3(0.07, 0.1, 0.06),
  Vector3(0, 0.18, 0),
  Vector3(0.04, 0.24, 0.02),
];

/// One basket mesh plus the product meshes sitting in it.
class CarriedBasket {
  CarriedBasket({
    required this.scene,
    required this.factory,
    required this.catalog,
    required Node template,
    required this.label,
    this.scale = 1.15,
  }) {
    node = template.clone()
      ..scale = Vector3.all(scale)
      ..position = Vector3(0, -8, 0);
    _silence(node);
    scene.add(node);
  }

  final Scene scene;
  final ProductVisualFactory factory;
  final ProductCatalog catalog;
  final String label;
  final double scale;
  late final Node node;
  final List<Node> _items = [];
  List<String> _ids = const [];

  /// Puts the basket in front of [feet] and fills it with [productIds].
  ///
  /// [onFloor] sits the base on the ground at [feet] instead of at the waist.
  void place(
    Vector3 feet,
    double yaw,
    List<String> productIds, {
    bool onFloor = false,
  }) {
    final origin = onFloor ? Vector3(feet.x, 0, feet.z) : holdPoint(feet, yaw);
    node
      ..position = origin
      ..rotation = Quaternion.axisAngle(Vector3(0, 1, 0), yaw)
      ..scale = Vector3.all(scale);
    _ensureItems(productIds);
    final forwardX = -sin(yaw);
    final forwardZ = -cos(yaw);
    final rightX = -cos(yaw);
    final rightZ = sin(yaw);
    for (var i = 0; i < _items.length; i++) {
      final slot = _itemSlots[i];
      _items[i].position = Vector3(
        origin.x + rightX * slot.x + forwardX * slot.z,
        origin.y + slot.y,
        origin.z + rightZ * slot.x + forwardZ * slot.z,
      );
      _items[i].rotation = Quaternion.axisAngle(Vector3(0, 1, 0), yaw);
    }
  }

  void hide() {
    node.position = Vector3(0, -8, 0);
    for (final item in _items) {
      item.position = Vector3(0, -8, 0);
    }
    setRaycastable(false);
  }

  /// The carried basket stays silent so the aim ray can reach the shelves.
  void setRaycastable(bool enabled) {
    _setRaycast(node, enabled);
    for (final item in _items) {
      item.raycastable = enabled;
    }
  }

  void bindAim(InteractionSystem interactions, Interactable target) {
    _bindAim(interactions, node, target);
    for (final item in _items) {
      interactions.bind(item, target);
    }
  }

  void remove() {
    scene.remove(node);
    for (final item in _items) {
      scene.remove(item);
    }
    _items.clear();
  }

  void _ensureItems(List<String> productIds) {
    if (_matches(productIds)) {
      return;
    }
    for (final item in _items) {
      scene.remove(item);
    }
    _items.clear();
    _ids = List<String>.of(productIds);
    final count = min(_ids.length, _itemSlots.length);
    for (var i = 0; i < count; i++) {
      final product = catalog.lookup(_ids[i]);
      if (product == null) {
        continue;
      }
      final item = factory.place(
        scene,
        product: product,
        position: Vector3.zero(),
        name: 'carried-$label-$i-${product.id}',
      );
      item
        ..scale = Vector3.all(0.5)
        ..raycastable = false
        ..castsShadows = false
        ..shadowStatic = false
        ..frustumCulled = false;
      _items.add(item);
    }
  }

  bool _matches(List<String> productIds) {
    if (productIds.length != _ids.length) {
      return false;
    }
    for (var i = 0; i < productIds.length; i++) {
      if (productIds[i] != _ids[i]) {
        return false;
      }
    }
    return true;
  }
}

/// The player's basket. Hidden until they take one from the stand.
class PlayerBasket {
  PlayerBasket({
    required this.basket,
    required CarriedBasket carried,
    required InteractionSystem interactions,
  }) : _carried = carried,
       _interactions = interactions,
       _pickup = _DroppedBasket(basket) {
    _near = Object();
    interactions.bind(_near, _pickup);
  }

  final ShoppingBasket basket;
  final CarriedBasket _carried;
  final InteractionSystem _interactions;
  final _DroppedBasket _pickup;
  late final Object _near;

  /// How close she must stand before a basket on the floor can be picked up
  /// without the aim ray landing on the short mesh.
  static const double pickupReach = 1.2;

  void follow(Vector3 feet, double yaw) {
    if (basket.carried) {
      _carried.setRaycastable(false);
      _carried.place(feet, yaw, basket.productIds);
      return;
    }
    final x = basket.dropX;
    final z = basket.dropZ;
    if (x != null && z != null) {
      _carried.place(
        Vector3(x, 0, z),
        basket.dropYaw,
        basket.productIds,
        onFloor: true,
      );
      _carried.setRaycastable(true);
      _carried.bindAim(_interactions, _pickup);
      return;
    }
    _carried.hide();
  }

  /// Offers pickup when she is beside the basket and nothing else is aimed.
  void offerIfClose(Vector3 feet, InteractionSystem interactions) {
    if (!basket.isOnFloor || interactions.aim != null) {
      return;
    }
    final x = basket.dropX;
    final z = basket.dropZ;
    if (x == null || z == null) {
      return;
    }
    final dx = feet.x - x;
    final dz = feet.z - z;
    final distance = sqrt(dx * dx + dz * dz);
    if (distance > pickupReach) {
      return;
    }
    interactions.setAim(hitKey: _near, distance: distance);
  }
}

/// In front of the body, about waist height. The model's base is its origin.
Vector3 holdPoint(Vector3 feet, double yaw) {
  final forwardX = -sin(yaw);
  final forwardZ = -cos(yaw);
  return Vector3(
    feet.x + forwardX * 0.46,
    feet.y + 0.48,
    feet.z + forwardZ * 0.46,
  );
}

void _silence(Node node) {
  node.raycastable = false;
  for (final child in node.children) {
    _silence(child);
  }
}

void _setRaycast(Node node, bool enabled) {
  node.raycastable = enabled;
  for (final child in node.children) {
    _setRaycast(child, enabled);
  }
}

void _bindAim(InteractionSystem interactions, Node node, Interactable target) {
  interactions.bind(node, target);
  for (final child in node.children) {
    _bindAim(interactions, child, target);
  }
}

class _DroppedBasket implements Interactable {
  _DroppedBasket(this.basket);

  final ShoppingBasket basket;

  @override
  String get id => 'dropped-basket';

  @override
  String get displayName => 'Basket';

  @override
  String get prompt => 'Pick up';

  @override
  int? get priceAmount => null;

  @override
  bool get isInteractable => basket.isOnFloor;

  @override
  void interact() => basket.take();
}
