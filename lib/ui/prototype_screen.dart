import 'package:flutter/material.dart';

import '../data/catalog/product_catalog.dart';
import '../game/carry/carry_controller.dart';
import '../game/carry/product_carry.dart';
import '../game/checkout/checkout_session.dart';
import '../game/customers/customer_manager.dart';
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

/// First-person test screen: the room, touch controls, and a small HUD.
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
  final InteractionSystem _interactions = InteractionSystem(maxDistance: 4.5);
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

  @override
  void dispose() {
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
          _PrototypeHud(player: _player, carry: _carry),
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
              padding: const EdgeInsets.only(top: 148, left: 16, right: 16),
              child: CheckoutPanel(session: _checkout),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrototypeHud extends StatelessWidget {
  const _PrototypeHud({required this.player, required this.carry});

  final PlayerController player;
  final CarryController carry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Material(
            color: const Color(0xCC111111),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'As Mitra Game',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Supermarket blockout',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  ListenableBuilder(
                    listenable: Listenable.merge([player, carry]),
                    builder: (context, _) {
                      final position = player.position;
                      String axis(String name, double value) =>
                          '$name ${value.toStringAsFixed(2)}';
                      final holding = carry.held;
                      final carried = holding == null
                          ? ''
                          : '\nHolding ${holding.label}';
                      return Text(
                        '${axis('Player X', position.x)}\n'
                        '${axis('Player Y', position.y)}\n'
                        '${axis('Player Z', position.z)}'
                        '$carried',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
