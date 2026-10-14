import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../carry/product_carry.dart';
import '../../checkout/checkout_session.dart';
import '../../interaction/interaction_system.dart';
import '../../world/collision_box.dart';
import '../products/held_product_presenter.dart';
import 'blockout_geometry.dart';
import 'supermarket_checkout.dart';
import 'supermarket_entrance.dart';
import 'supermarket_room.dart';
import 'supermarket_shelf.dart';
import 'produce_mart.dart';
import 'supermarket_storage.dart';

/// Assembles the supermarket blockout. [world] already holds static obstacles.
/// Entrance and storage add the door boxes they move.
HeldProductPresenter buildSupermarketScene(
  Scene scene,
  InteractionSystem interactions,
  CollisionWorld world,
  ProductCarry productCarry,
  CheckoutSession checkout,
) {
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
  addProduceMart(scene, world);

  scene.directionalLight = DirectionalLight(
    direction: Vector3(-0.35, -1, -0.25),
    color: Vector3(1, 0.97, 0.9),
    intensity: 3.2,
    castsShadow: true,
  );
  return presenter;
}
