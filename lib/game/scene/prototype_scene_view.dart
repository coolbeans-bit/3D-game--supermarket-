import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_scene/scene.dart';

import '../carry/product_carry.dart';
import '../carry/shopping_basket.dart';
import '../checkout/checkout_session.dart';
import '../customers/customer_manager.dart';
import '../interaction/interaction_system.dart';
import '../player/player_controller.dart';
import '../world/collision_box.dart';
import 'aim_raycast.dart';
import 'humans/human_figure.dart';
import 'player_avatar.dart';
import 'products/held_product_presenter.dart';
import 'supermarket/carried_basket.dart';
import 'supermarket/cashier_presenter.dart';
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
    this.basket,
    this.onAskCashier,
  });

  final PlayerController player;
  final InteractionSystem interactions;
  final CollisionWorld world;
  final ProductCarry productCarry;
  final CheckoutSession checkout;
  final CustomerManager customers;
  final ShoppingBasket? basket;

  /// Aim the gold bell in front of the cashier, then press this.
  final void Function()? onAskCashier;

  @override
  State<PrototypeSceneView> createState() => _PrototypeSceneViewState();
}

class _PrototypeSceneViewState extends State<PrototypeSceneView> {
  Scene? _scene;
  HeldProductPresenter? _presenter;
  PlayerBasket? _playerBasket;
  CustomerPresenter? _customers;
  CashierPresenter? _cashier;
  PlayerAvatar? _avatar;
  bool _wasHolding = false;
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

    Scene.initializeStaticResources().then((_) async {
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
        final basketModel = widget.basket == null
            ? null
            : await Node.fromGlbAsset('assets/props/shopping_basket.glb');
        final store = buildSupermarketScene(
          scene,
          widget.interactions,
          widget.world,
          widget.productCarry,
          widget.checkout,
          basket: widget.basket,
          basketModel: basketModel,
          onAskCashier: widget.onAskCashier,
        );
        _presenter = store.products;
        _playerBasket = store.playerBasket;
        widget.checkout.onHandsCleared = () {
          _presenter?.releaseHeldVisual();
        };
        widget.checkout.onSaleCancelled = (productIds) {
          _presenter?.restock(productIds);
        };
        final people = await HumanLibrary.load();
        if (!mounted) {
          return;
        }
        _customers = CustomerPresenter(
          scene,
          people,
          basketTemplate: basketModel,
          products: store.products.factory,
          catalog: widget.productCarry.catalog,
        );
        _cashier = CashierPresenter(scene, people)..place();
        final avatar = PlayerAvatar(scene)
          ..attach(people.spawn(HumanLibrary.woman).node);
        if (!mounted) {
          return;
        }
        _avatar = avatar;
        setState(() => _ready = true);
      } catch (error) {
        if (!mounted) {
          return;
        }
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
            eye: widget.player.position,
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
      fovRadiansY: 50 * pi / 180,
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
          final before = widget.player.position.clone();
          widget.player.tick(deltaSeconds);
          final step = deltaSeconds.clamp(0.0, 0.05);
          final groundSpeed = step == 0
              ? 0.0
              : widget.player.position.distanceTo(before) / step;
          _customers?.sync(widget.customers.active, deltaSeconds);
          _playerBasket?.follow(widget.player.position, widget.player.yaw);
          _cashier?.sync(deltaSeconds);
          final avatar = _avatar;
          avatar?.sync(
            feet: widget.player.position,
            yaw: widget.player.yaw,
            moveAmount: groundSpeed > 0.12 ? 1 : 0,
            speed: groundSpeed,
            deltaSeconds: deltaSeconds,
          );
          if (widget.productCarry.carry.isHolding) {
            _presenter?.ensureHeld();
          }
          if (widget.productCarry.consumeReach() ||
              (widget.productCarry.carry.isHolding && !_wasHolding)) {
            avatar?.playReach();
          }
          _wasHolding = widget.productCarry.carry.isHolding;
          _presenter?.follow(
            widget.player.position,
            widget.player.yaw,
            hand: avatar?.carryPoint(),
            deltaSeconds: deltaSeconds,
          );
          _updateAim(scene);
          _playerBasket?.offerIfClose(
            widget.player.position,
            widget.interactions,
          );
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
