import 'dart:math';

import 'package:flutter/material.dart';

import '../data/catalog/product_catalog.dart';
import '../game/carry/carry_controller.dart';
import '../game/carry/product_carry.dart';
import '../game/carry/shopping_basket.dart';
import '../game/checkout/checkout_session.dart';
import '../game/customers/customer_manager.dart';
import '../game/find/letter_round.dart';
import '../game/find/shelf_hint.dart';
import '../game/input/look_controller.dart';
import '../game/input/virtual_joystick.dart';
import '../game/interaction/interaction_system.dart';
import '../game/player/player_controller.dart';
import '../game/scene/prototype_scene_view.dart';
import '../game/world/collision_box.dart';
import '../game/world/supermarket/supermarket_layout.dart';
import 'basket_hud.dart';
import 'center_reticle.dart';
import 'checkout_panel.dart';
import 'customer_debug_hud.dart';
import 'interaction_prompt.dart';
import 'letter_round_hud.dart';

/// Third-person store: the room, the shopper, touch controls, and the HUD.
class PrototypeScreen extends StatefulWidget {
  const PrototypeScreen({super.key});

  @override
  State<PrototypeScreen> createState() => _PrototypeScreenState();
}

class _PrototypeScreenState extends State<PrototypeScreen> {
  final CollisionWorld _world = SupermarketLayout.createWorld();
  late final PlayerController _player = PlayerController(
    start: SupermarketLayout.playerStart,
    world: _world,
  );
  final InteractionSystem _interactions = InteractionSystem(maxDistance: 7);
  final CarryController _carry = CarryController();
  final ShoppingBasket _basket = ShoppingBasket();
  late final ProductCarry _productCarry = ProductCarry(
    carry: _carry,
    catalog: ProductCatalog.starter,
    basket: _basket,
  );
  late final CheckoutSession _checkout = CheckoutSession(
    catalog: ProductCatalog.starter,
    carry: _carry,
  );
  final CustomerManager _customers = CustomerManager(
    catalog: ProductCatalog.starter,
  );
  late final LetterRound _round = LetterRound(catalog: ProductCatalog.starter);
  bool _wasHolding = false;
  int _scoredPickups = 0;

  @override
  void initState() {
    super.initState();
    _carry.addListener(_judgePickup);
  }

  void _judgePickup() {
    final holding = _carry.isHolding;
    if (holding &&
        !_wasHolding &&
        _productCarry.shelfPickups != _scoredPickups) {
      _scoredPickups = _productCarry.shelfPickups;
      final product = _productCarry.heldDefinition;
      if (product != null) {
        _round.checkPickup(product);
      }
    }
    _wasHolding = holding;
  }

  /// Sets the basket on the floor just ahead of her. A blocked spot uses her feet.
  void _putBasketDown() {
    final yaw = _player.yaw;
    final forwardX = -sin(yaw);
    final forwardZ = -cos(yaw);
    var x = _player.position.x + forwardX * 0.72;
    var z = _player.position.z + forwardZ * 0.72;
    if (SupermarketLayout.occupied(x, z)) {
      x = _player.position.x;
      z = _player.position.z;
    }
    _basket.putDown(x: x, z: z, yaw: yaw);
  }

  @override
  void dispose() {
    _carry.removeListener(_judgePickup);
    _round.dispose();
    _player.dispose();
    _interactions.dispose();
    _basket.dispose();
    _carry.dispose();
    _checkout.dispose();
    _customers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PrototypeSceneView(
            player: _player,
            interactions: _interactions,
            world: _world,
            productCarry: _productCarry,
            checkout: _checkout,
            customers: _customers,
            basket: _basket,
            onAskCashier: () {
              _round.rememberHint(
                whereIsLetter(_productCarry.catalog, _round.letter),
              );
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.62,
              heightFactor: 1,
              child: LookController(
                onLook: _player.addLook,
                onLookEnd: _player.endLook,
              ),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 24,
            child: SafeArea(child: VirtualJoystick(onChanged: _player.setMove)),
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x00000000), Color(0x66000000)],
                  stops: [0.62, 1],
                ),
              ),
              child: SizedBox.expand(),
            ),
          ),
          const CenterReticle(),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 168),
                child: InteractionPrompt(
                  system: _interactions,
                  refresh: Listenable.merge([_carry, _checkout, _basket]),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: LetterRoundHud(round: _round),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomerDebugHud(customers: _customers),
                    const SizedBox(height: 8),
                    BasketHud(
                      basket: _basket,
                      catalog: ProductCatalog.starter,
                      carry: _carry,
                      onTakeOut: _productCarry.drawFromBasket,
                      onPutDown: _putBasketDown,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CheckoutPanel(session: _checkout),
            ),
          ),
        ],
      ),
    );
  }
}
