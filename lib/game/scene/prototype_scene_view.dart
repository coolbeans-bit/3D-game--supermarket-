import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_scene/scene.dart';

import '../carry/product_carry.dart';
import '../checkout/checkout_session.dart';
import '../customers/customer_manager.dart';
import '../interaction/interaction_system.dart';
import '../player/player_controller.dart';
import '../world/collision_box.dart';
import 'aim_raycast.dart';
import 'products/held_product_presenter.dart';
import 'supermarket/customer_presenter.dart';
import 'supermarket/supermarket_scene.dart';

/// Renders the supermarket blockout and advances the player each frame.
class PrototypeSceneView extends StatefulWidget {
  const PrototypeSceneView({
    super.key,
    required this.player,
    required this.interactions,
    required this.world,
    required this.productCarry,
    required this.checkout,
    required this.customers,
  });

  final PlayerController player;
  final InteractionSystem interactions;
  final CollisionWorld world;
  final ProductCarry productCarry;
  final CheckoutSession checkout;
  final CustomerManager customers;

  @override
  State<PrototypeSceneView> createState() => _PrototypeSceneViewState();
}

class _PrototypeSceneViewState extends State<PrototypeSceneView> {
  Scene? _scene;
  HeldProductPresenter? _presenter;
  CustomerPresenter? _customers;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    try {
      _scene = Scene();
    } catch (error) {
      _error = error.toString();
      return;
    }

    Scene.initializeStaticResources().then((_) {
      if (!mounted) {
        return;
      }
      final scene = _scene;
      if (scene == null || !Scene.isReadyToRender) {
        setState(() {
          _error = 'Flutter Scene did not finish starting.';
        });
        return;
      }
      try {
        _presenter = buildSupermarketScene(
          scene,
          widget.interactions,
          widget.world,
          widget.productCarry,
          widget.checkout,
        );
        widget.checkout.onHandsCleared = () {
          _presenter?.releaseHeldVisual();
        };
        _customers = CustomerPresenter(scene);
        setState(() => _ready = true);
      } catch (error) {
        setState(() => _error = error.toString());
      }
    });
  }

  void _updateAim(Scene scene) {
    final view = widget.player.viewpoint();
    final hit = castAimRay(
      scene: scene,
      origin: view.eye,
      direction: view.target - view.eye,
      maxDistance: widget.interactions.maxDistance,
    );
    final presenter = _presenter;
    final key = presenter == null
        ? hit?.node
        : presenter.aimKeyFor(
            hit: hit?.node,
            eye: view.eye,
            point: hit?.worldPoint,
            holding: widget.productCarry.carry.isHolding,
          );
    widget.interactions.setAim(hitKey: key, distance: hit?.distance);
  }

  PerspectiveCamera _camera(Duration _) {
    final view = widget.player.viewpoint();
    return PerspectiveCamera(
      position: view.eye,
      target: view.target,
      fovRadiansY: 60 * pi / 180,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scene;
    if (_ready && scene != null) {
      return SceneView(
        scene,
        cameraBuilder: _camera,
        onTick: (_, deltaSeconds) {
          widget.customers.tick(
            deltaSeconds,
            widget.world,
            avoid: widget.player.position,
          );
          widget.player.tick(deltaSeconds);
          _customers?.sync(widget.customers.active);
          _presenter?.follow(widget.player.viewpoint(), widget.player.yaw);
          _updateAim(scene);
        },
      );
    }
    final error = _error;
    if (error == null) {
      return const SizedBox.expand();
    }
    return ColoredBox(
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFFFB4A8), fontSize: 14),
          ),
        ),
      ),
    );
  }
}
