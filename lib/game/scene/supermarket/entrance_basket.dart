import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../carry/shopping_basket.dart';
import '../../interaction/interactable.dart';
import '../../interaction/interaction_system.dart';
import '../../world/collision_box.dart';
import '../../world/supermarket/supermarket_layout.dart';
import 'blockout_geometry.dart';

/// A stack of baskets just inside the door.
///
/// [model] is Kenney's Mini Market shopping basket (CC0). Without it, a
/// plain box is used so the stand still exists.
void addEntranceBasket(
  Scene scene,
  InteractionSystem interactions,
  CollisionWorld world,
  ShoppingBasket basket, {
  Node? model,
}) {
  const x = SupermarketLayout.basketX;
  const z = SupermarketLayout.basketZ;
  world.boxes.add(
    CollisionBox.padded(
      centerX: x,
      centerZ: z,
      sizeX: 0.55,
      sizeZ: 0.42,
      padding: SupermarketLayout.playerRadius,
    ),
  );
  final interactable = _BasketInteractable(basket);
  final template = model;
  if (template == null) {
    final body = _blockoutStack(scene, x, z);
    interactions.bind(body, interactable);
    return;
  }
  for (var i = 0; i < 3; i++) {
    final node = template.clone()
      ..position = Vector3(x, i * 0.25, z)
      ..rotation = Quaternion.axisAngle(Vector3(0, 1, 0), 0.5);
    scene.add(node);
    _bindTree(interactions, node, interactable);
  }
}

Node _blockoutStack(Scene scene, double x, double z) {
  final brown = BlockoutPalette.flat(0.45, 0.28, 0.14, 0.72);
  final handle = BlockoutPalette.flat(0.62, 0.5, 0.28, 0.6);
  final body = addBox(
    scene,
    name: 'entrance-basket',
    center: Vector3(x, 0.16, z),
    size: Vector3(0.46, 0.22, 0.32),
    material: brown,
    shadowStatic: false,
  );
  addBox(
    scene,
    name: 'entrance-basket-handle',
    center: Vector3(x, 0.34, z),
    size: Vector3(0.36, 0.06, 0.06),
    material: handle,
    shadowStatic: false,
    castsShadows: false,
  );
  return body;
}

void _bindTree(
  InteractionSystem interactions,
  Node node,
  Interactable interactable,
) {
  interactions.bind(node, interactable);
  for (final child in node.children) {
    _bindTree(interactions, child, interactable);
  }
}

class _BasketInteractable implements Interactable {
  _BasketInteractable(this.basket);

  final ShoppingBasket basket;

  @override
  String get id => 'entrance-basket';

  @override
  String get displayName => 'Baskets';

  @override
  String get prompt => 'Take basket';

  @override
  int? get priceAmount => null;

  @override
  bool get isInteractable => !basket.carried && !basket.isOnFloor;

  @override
  void interact() => basket.take();
}
