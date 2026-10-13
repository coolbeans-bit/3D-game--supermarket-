import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../characters/character_appearance.dart';
import '../carry/product_carry.dart';
import '../checkpoints/std1_run.dart';
import '../checkout/checkout_session.dart';
import '../customers/customer_manager.dart';
import '../interaction/interaction_system.dart';
import '../player/player_camera.dart';
import '../player/player_controller.dart';
import '../literacy/literacy_session.dart';
import '../world/collision_box.dart';
import 'aim_raycast.dart';
import 'characters/placeholder_figure.dart';
import 'products/held_product_presenter.dart';
import 'supermarket/blockout_geometry.dart';
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
    required this.learning,
    this.checkpoint,
  });

  final PlayerController player;
  final InteractionSystem interactions;
  final CollisionWorld world;
  final ProductCarry productCarry;
  final CheckoutSession checkout;
  final CustomerManager customers;
  final LiteracySession learning;
  final Std1Run? checkpoint;

  @override
  State<PrototypeSceneView> createState() => _PrototypeSceneViewState();
}

class _PrototypeSceneViewState extends State<PrototypeSceneView> {
  Scene? _scene;
  HeldProductPresenter? _presenter;
  CustomerPresenter? _customers;
  Node? _student;
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
          widget.learning,
          checkpoint: widget.checkpoint,
        );
        _student = _addStudent(scene);
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

  void _syncStudent() {
    final body = _student;
    if (body == null) {
      return;
    }
    final feet = widget.player.position;
    body.position = Vector3(feet.x, feet.y, feet.z);
    body.rotation = Quaternion.axisAngle(Vector3(0, 1, 0), widget.player.yaw);
  }

  void _updateAim(Scene scene) {
    final view = widget.player.viewpoint();
    final direction = view.target - view.eye;
    if (direction.length2 > 1e-8) {
      direction.normalize();
    }
    final hit = castAimRay(
      scene: scene,
      origin: view.eye + direction * 0.55,
      direction: direction,
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
    final view = thirdPersonViewpoint(
      feet: widget.player.position,
      yaw: widget.player.yaw,
      pitch: widget.player.pitch,
    );
    return PerspectiveCamera(
      position: view.eye,
      target: view.target,
      fovRadiansY: 60 * pi / 180,
    );
  }

  Node _addStudent(Scene scene) {
    final root = Node(name: 'student');
    addPlaceholderFigure(
      root,
      name: 'student',
      accentKind: FigureAccent.cap,
      body: BlockoutPalette.flat(0.25, 0.45, 0.75, 0.5),
      head: BlockoutPalette.flat(0.93, 0.76, 0.62, 0.45),
      accent: BlockoutPalette.flat(0.9, 0.3, 0.22, 0.5),
    );
    root.add(
      Node(
        name: 'student-nose',
        mesh: Mesh(
          SphereGeometry(radius: 0.035, segments: 8, rings: 6),
          BlockoutPalette.flat(0.9, 0.62, 0.5, 0.45),
        ),
      )..position = Vector3(0, 1.22, -0.11),
    );
    scene.add(root);
    return root;
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
          _syncStudent();
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
