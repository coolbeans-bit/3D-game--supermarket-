import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../../data/models/product_definition.dart';
import '../../carry/carry_controller.dart';
import '../../carry/held_item_anchor.dart';
import '../../carry/product_carry.dart';
import '../../checkout/sale_return.dart';
import '../../interaction/interactable.dart';
import '../../interaction/interaction_system.dart';
import '../../shelves/shelf_slot.dart';
import '../../shelves/store_shelf_plan.dart';
import '../../world/supermarket/supermarket_layout.dart';
import 'product_visual_factory.dart';

/// Shelf stock, the carried mesh, and the aim prompts for pickup and place.
class HeldProductPresenter {
  HeldProductPresenter({
    required this.scene,
    required this.interactions,
    required this.productCarry,
    required this.factory,
    this.anchor = const HeldItemAnchor(),
  });

  final Scene scene;
  final InteractionSystem interactions;
  final ProductCarry productCarry;
  final ProductVisualFactory factory;
  final HeldItemAnchor anchor;

  final List<_ShelfFace> _faces = [];
  final Map<Node, _ShelfFace> _productFace = {};
  final Map<Node, String> _frameGondola = {};
  final Map<ShelfSlot, Node> _slotNodes = {};

  Node? heldNode;
  Vector3? _feet;
  double _yaw = 0;
  Vector3? _grabFrom;
  double _grabElapsed = 1;

  static const double _grabSeconds = 0.5;

  CarryController get carry => productCarry.carry;

  void registerFrame(String gondolaName, List<Node> parts) {
    for (final part in parts) {
      _frameGondola[part] = gondolaName;
    }
  }

  void addFace(StockedShelf stocked) {
    final face = _ShelfFace(stocked);
    _faces.add(face);
    interactions.bind(face.aimKey, _shelfInteractable(face));
    for (final slot in stocked.unit.slots) {
      if (slot.isEmpty) {
        continue;
      }
      _spawnSlot(face, slot);
    }
  }

  /// Hit key for [InteractionSystem]. Products stay pickups until the hands
  /// are full; then a product or the shelf frame targets that shelf face.
  Object? aimKeyFor({
    required Object? hit,
    required Vector3 eye,
    required Vector3? point,
    required bool holding,
  }) {
    if (hit is! Node) {
      return hit;
    }
    final productFace = _productFace[hit];
    if (productFace != null) {
      return holding ? productFace.aimKey : hit;
    }
    final gondolaName = _frameGondola[hit];
    if (gondolaName != null && point != null) {
      return _nearestFace(gondolaName, point, eye)?.aimKey ?? hit;
    }
    return hit;
  }

  void follow(
    Vector3 feet,
    double yaw, {
    Vector3? hand,
    double deltaSeconds = 0,
  }) {
    _feet = feet;
    _yaw = yaw;
    final node = heldNode;
    if (node == null) {
      return;
    }
    final target = hand ?? anchor.worldPosition(feet: feet, yaw: yaw);
    final from = _grabFrom;
    var position = target;
    if (from != null && _grabElapsed < _grabSeconds) {
      _grabElapsed += deltaSeconds;
      final t = (_grabElapsed / _grabSeconds).clamp(0.0, 1.0);
      final eased = t * t * (3 - 2 * t);
      position = from + (target - from) * eased;
    }
    node.position = position;
    node.rotation = Quaternion.axisAngle(Vector3(0, 1, 0), yaw);
  }

  void _spawnSlot(_ShelfFace face, ShelfSlot slot) {
    final productId = slot.productId;
    if (productId == null) {
      return;
    }
    final product = productCarry.catalog.require(productId);
    final node = factory.place(
      scene,
      product: product,
      position: shelfSlotPosition(
        plan: face.stocked.plan,
        slot: slot,
        itemHeight: productHeight(product.shape),
      ),
      name: '${face.stocked.plan.id}-${slot.level}-${slot.index}',
    );
    _productFace[node] = face;
    _slotNodes[slot] = node;
    interactions.bind(node, _productInteractable(face, slot, product));
  }

  void _pickup(_ShelfFace face, ShelfSlot slot) {
    if (!productCarry.pickup(face.stocked.unit, slot)) {
      return;
    }
    final node = _slotNodes.remove(slot);
    if (node != null) {
      _grabFrom = node.position.clone();
      _grabElapsed = 0;
      _productFace.remove(node);
      scene.remove(node);
    }
    _showHeld();
    interactions.setAim(hitKey: null, distance: null);
  }

  void _place(_ShelfFace face) {
    final slot = productCarry.place(face.stocked.unit);
    if (slot == null) {
      return;
    }
    _hideHeld();
    _spawnSlot(face, slot);
  }

  void _showHeld() {
    final product = productCarry.heldDefinition;
    if (product == null) {
      return;
    }
    _hideHeld();
    final node = factory.place(
      scene,
      product: product,
      position: Vector3.zero(),
      name: 'held-${product.id}',
    );
    final scale = anchor.visualScale;
    node
      ..scale = Vector3(scale, scale, scale)
      ..raycastable = false
      ..castsShadows = false
      ..shadowStatic = false
      ..frustumCulled = false;
    heldNode = node;
    final feet = _feet;
    if (feet != null) {
      follow(feet, _yaw);
    }
  }

  /// Shows the held mesh when an item has moved from the basket into the hands.
  void ensureHeld() {
    if (heldNode != null || !carry.isHolding) {
      return;
    }
    _showHeld();
  }

  /// Drops the carried mesh after a checkout scan.
  void releaseHeldVisual() => _hideHeld();

  /// Puts cancelled scans back on the shelf that stocks that product.
  ///
  /// A product whose shelf is full goes back into empty hands instead.
  void restock(List<String> productIds) {
    final result = returnScannedProducts(
      productIds: productIds,
      catalog: productCarry.catalog,
      shelves: [for (final face in _faces) face.stocked],
    );
    for (final returned in result.placed) {
      final face = _faceFor(returned.shelfId);
      if (face != null) {
        _spawnSlot(face, returned.slot);
      }
    }
    if (result.unplacedIds.isEmpty || carry.isHolding) {
      return;
    }
    final product = productCarry.catalog.lookup(result.unplacedIds.first);
    if (product == null) {
      return;
    }
    if (carry.tryHold(CarriedItem(id: product.id, label: product.marathiName))) {
      _showHeld();
    }
  }

  _ShelfFace? _faceFor(String shelfId) {
    for (final face in _faces) {
      if (face.stocked.plan.id == shelfId) {
        return face;
      }
    }
    return null;
  }

  void _hideHeld() {
    final node = heldNode;
    if (node == null) {
      return;
    }
    scene.remove(node);
    heldNode = null;
  }

  Interactable _productInteractable(
    _ShelfFace face,
    ShelfSlot slot,
    ProductDefinition product,
  ) {
    return _LiveInteractable(
      id: 'product-${face.stocked.plan.id}-${slot.level}-${slot.index}',
      displayNameOf: () => product.marathiName,
      promptOf: () => 'Pick Up',
      priceOf: () => product.sellingPrice,
      onInteract: () => _pickup(face, slot),
    );
  }

  Interactable _shelfInteractable(_ShelfFace face) {
    final shelf = face.stocked.unit;
    return _LiveInteractable(
      id: 'shelf-${face.stocked.plan.id}',
      displayNameOf: () {
        if (!carry.isHolding) {
          return 'Shelf';
        }
        final product = productCarry.heldDefinition;
        if (product != null && shelf.canPlace(product)) {
          return 'Place ${product.marathiName}';
        }
        return product?.marathiName ?? 'Shelf';
      },
      promptOf: () {
        if (!carry.isHolding) {
          return 'Inspect';
        }
        return productCarry.canPlaceOn(shelf) ? 'Place' : 'Cannot Place';
      },
      onInteract: () {
        if (carry.isHolding) {
          _place(face);
        }
      },
    );
  }

  _ShelfFace? _nearestFace(String gondolaName, Vector3 point, Vector3 eye) {
    final gondola = SupermarketLayout.shelves.firstWhere(
      (shelf) => shelf.name == gondolaName,
    );
    final side = eye.x >= gondola.centerX ? 1 : -1;
    _ShelfFace? best;
    var bestDistance = double.infinity;
    for (final face in _faces) {
      final plan = face.stocked.plan;
      if (plan.gondolaName != gondolaName || plan.side != side) {
        continue;
      }
      final distance = (point.z - plan.centerZ).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = face;
      }
    }
    return best;
  }
}

class _ShelfFace {
  _ShelfFace(this.stocked);

  final StockedShelf stocked;
  final Object aimKey = Object();
}

class _LiveInteractable implements Interactable {
  _LiveInteractable({
    required this.id,
    required this.displayNameOf,
    required this.promptOf,
    required this.onInteract,
    this.priceOf,
  });

  @override
  final String id;

  final String Function() displayNameOf;
  final String Function() promptOf;
  final int? Function()? priceOf;
  final void Function() onInteract;

  @override
  String get displayName => displayNameOf();

  @override
  String get prompt => promptOf();

  @override
  int? get priceAmount => priceOf?.call();

  @override
  bool get isInteractable => true;

  @override
  void interact() => onInteract();
}
