import 'package:flutter/material.dart';

import '../data/catalog/product_catalog.dart';
import '../game/carry/carry_controller.dart';
import '../game/carry/product_carry.dart';
import '../game/checkout/checkout_session.dart';
import '../game/customers/customer_manager.dart';
import '../game/find/letter_round.dart';
import '../game/input/look_controller.dart';
import '../game/input/virtual_joystick.dart';
import '../game/interaction/interaction_system.dart';
import '../game/player/player_controller.dart';
import '../game/scene/prototype_scene_view.dart';
import '../game/world/collision_box.dart';
import '../game/world/supermarket/supermarket_layout.dart';
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
  late final ProductCarry _productCarry = ProductCarry(
    carry: _carry,
    catalog: ProductCatalog.starter,
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

  @override
  void initState() {
    super.initState();
    _carry.addListener(_judgePickup);
  }

  void _judgePickup() {
    final holding = _carry.isHolding;
    if (holding && !_wasHolding) {
      final product = _productCarry.heldDefinition;
      if (product != null) {
        _round.checkPickup(product);
      }
    }
    _wasHolding = holding;
  }

  @override
  void dispose() {
    _carry.removeListener(_judgePickup);
    _round.dispose();
    _player.dispose();
    _interactions.dispose();
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
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.62,
              heightFactor: 1,
              child: LookController(onLook: _player.addLook),
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
                  refresh: Listenable.merge([_carry, _checkout]),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LetterRoundHud(round: _round),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: CustomerDebugHud(customers: _customers),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 280, left: 16, right: 16),
              child: CheckoutPanel(session: _checkout),
            ),
          ),
        ],
      ),
    );
  }
}

