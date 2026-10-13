import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../carry/product_carry.dart';
import '../../checkout/checkout_session.dart';
import '../../interaction/interaction_system.dart';
import '../../checkpoints/std1_run.dart';
import '../../literacy/literacy_session.dart';
import '../../world/collision_box.dart';
import '../products/held_product_presenter.dart';
import 'blockout_geometry.dart';
import 'supermarket_checkout.dart';
import 'market_fruits.dart';
import 'supermarket_dressing.dart';
import 'supermarket_entrance.dart';
import 'supermarket_room.dart';
import 'supermarket_shelf.dart';
import 'supermarket_storage.dart';

/// Assembles the supermarket blockout. [world] already holds static obstacles.
/// Entrance and storage add the door boxes they move.
HeldProductPresenter buildSupermarketScene(
  Scene scene,
  InteractionSystem interactions,
  CollisionWorld world,
  ProductCarry productCarry,
  CheckoutSession checkout,
  LiteracySession learning, {
  Std1Run? checkpoint,
}) {
  final palette = BlockoutPalette();
  addSupermarketRoom(scene, palette);
  addSupermarketEntrance(scene, interactions, world, palette);
  final presenter = addSupermarketShelves(
    scene,
    interactions,
    palette,
    productCarry,
  );
  addSupermarketCheckout(scene, interactions, palette, checkout);
  addSupermarketStorage(scene, interactions, world, palette);
  addSupermarketDressing(scene, world, palette);
  addMarketFruits(scene, interactions, learning, checkpoint: checkpoint);

  scene.directionalLight = DirectionalLight(
    direction: Vector3(-0.35, -1, -0.25),
    color: Vector3(1, 0.95, 0.84),
    intensity: 3.5,
    castsShadow: true,
  );
  return presenter;
}
