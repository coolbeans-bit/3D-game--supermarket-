import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../../carry/product_carry.dart';
import '../../carry/shopping_basket.dart';
import '../../checkout/checkout_session.dart';
import '../../interaction/interaction_system.dart';
import '../../world/collision_box.dart';
import '../products/held_product_presenter.dart';
import 'blockout_geometry.dart';
import 'carried_basket.dart';
import 'supermarket_checkout.dart';
import 'entrance_basket.dart';
import 'supermarket_entrance.dart';
import 'supermarket_room.dart';
import 'supermarket_shelf.dart';
import 'produce_mart.dart';
import 'supermarket_storage.dart';

/// The shelf presenter plus the basket the player carries after taking one.
class BuiltStore {
  BuiltStore(this.products, this.playerBasket);

  final HeldProductPresenter products;
  final PlayerBasket? playerBasket;
}

/// Assembles the supermarket blockout. [world] already holds static obstacles.
/// Entrance and storage add the door boxes they move.
BuiltStore buildSupermarketScene(
  Scene scene,
  InteractionSystem interactions,
  CollisionWorld world,
  ProductCarry productCarry,
  CheckoutSession checkout, {
  ShoppingBasket? basket,
  Node? basketModel,
  void Function()? onAskCashier,
}) {
  final palette = BlockoutPalette();
  addSupermarketRoom(scene, palette);
  addSupermarketEntrance(scene, interactions, world, palette);
  if (basket != null) {
    addEntranceBasket(
      scene,
      interactions,
      world,
      basket,
      model: basketModel,
    );
  }
  final presenter = addSupermarketShelves(
    scene,
    interactions,
    palette,
    productCarry,
  );
  addSupermarketCheckout(
    scene,
    interactions,
    palette,
    checkout,
    basket: basket,
    onAskCashier: onAskCashier,
  );
  addSupermarketStorage(scene, interactions, world, palette);
  addProduceMart(scene, world);

  scene.directionalLight = DirectionalLight(
    direction: Vector3(-0.35, -1, -0.25),
    color: Vector3(1, 0.97, 0.9),
    intensity: 3.2,
    castsShadow: true,
  );
  final model = basketModel;
  final hands = basket;
  PlayerBasket? playerBasket;
  if (model != null && hands != null) {
    playerBasket = PlayerBasket(
      basket: hands,
      interactions: interactions,
      carried: CarriedBasket(
        scene: scene,
        factory: presenter.factory,
        catalog: productCarry.catalog,
        template: model,
        label: 'player',
      ),
    );
  }
  return BuiltStore(presenter, playerBasket);
}
