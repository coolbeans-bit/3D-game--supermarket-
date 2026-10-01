import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../../data/models/product_definition.dart';
import '../../carry/carry_controller.dart';
import '../../carry/held_item_anchor.dart';
import '../../carry/product_carry.dart';
import '../../interaction/interactable.dart';
import '../../interaction/interaction_system.dart';
import '../../player/player_camera.dart';
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
  PlayerViewpoint? _view;
  double _yaw = 0;

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

  void follow(PlayerViewpoint view, double yaw) {
    _view = view;
    _yaw = yaw;
    final node = heldNode;
    if (node == null) {
      return;
    }
    node.position = anchor.worldPosition(eye: view.eye, target: view.target);
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
    final view = _view;
    if (view != null) {
      follow(view, _yaw);
    }
  }

  /// Drops the carried mesh after a checkout scan.
  void releaseHeldVisual() => _hideHeld();

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
      id: 'product-${product.id}',
      displayNameOf: () => product.name,
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
          return 'Place ${product.name}';
        }
        return product?.name ?? 'Shelf';
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
