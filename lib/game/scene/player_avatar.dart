import 'dart:math';

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// The shopper you follow.
///
/// Model: Quaternius Animated Woman, public domain (CC0).
/// https://poly.pizza/m/nIItLV9nxS
class PlayerAvatar {
  PlayerAvatar(this.scene);

  static const assetPath = 'assets/characters/player.glb';
  static const idleName = 'CharacterArmature|Idle';
  static const walkName = 'CharacterArmature|Walk';
  static const reachName = 'CharacterArmature|Interact';

  /// Shrinks the authored figure a little so she fits the aisles.
  static const bodyScale = 0.86;

  /// Ground speed, in meters per second, that matches one walk cycle at
  /// normal playback.
  static const walkReferenceSpeed = 1.25;

  final Scene scene;
  Node? _root;
  Node? _hand;
  AnimationClip? _idle;
  AnimationClip? _walk;
  AnimationClip? _reach;
  double _walkWeight = 0;
  final Vector3 _position = Vector3.zero();
  final Quaternion _rotation = Quaternion.identity();
  final Vector3 _up = Vector3(0, 1, 0);
  final Vector3 _scale = Vector3.all(bodyScale);

  Future<void> load() async {
    final model = await Node.fromGlbAsset(assetPath);
    _silence(model);
    _hand = model.getChildByName('Wrist.R');
    _root = Node(name: 'player')
      ..scale = _scale
      ..add(model);
    scene.add(_root!);

    final idle = model.findAnimationByName(idleName);
    final walk = model.findAnimationByName(walkName);
    final reach = model.findAnimationByName(reachName);
    if (idle != null) {
      _idle = model.createAnimationClip(idle)
        ..loop = true
        ..weight = 1
        ..play();
    }
    if (walk != null) {
      _walk = model.createAnimationClip(walk)
        ..loop = true
        ..weight = 0
        ..play();
    }
    if (reach != null) {
      _reach = model.createAnimationClip(reach)
        ..loop = false
        ..weight = 0;
    }
  }

  /// Plays the reach once, so a pickup reads as her hand taking the item.
  void playReach() {
    final reach = _reach;
    if (reach == null) {
      return;
    }
    reach.weight = 1;
    reach.replay();
  }

  /// World position of her right hand, or null before the model has loaded.
  Vector3? carryPoint() {
    final hand = _hand;
    if (hand == null) {
      return null;
    }
    final matrix = hand.globalTransform;
    final point = matrix.getTranslation();
    final along = Vector3(
      matrix.entry(0, 0),
      matrix.entry(1, 0),
      matrix.entry(2, 0),
    );
    final length = along.length;
    if (length > 1e-6) {
      point.addScaled(along, 0.05 / length);
    }
    point.y -= 0.03;
    return point;
  }

  /// Places the character on [feet] and blends idle into a paced walk.
  void sync({
    required Vector3 feet,
    required double yaw,
    required double moveAmount,
    required double speed,
    required double deltaSeconds,
  }) {
    final root = _root;
    if (root == null) {
      return;
    }
    _position.setValues(feet.x, feet.y, feet.z);
    root.position = _position;
    _rotation.setAxisAngle(_up, yaw);
    root.rotation = _rotation;

    final reaching = _reach != null && _reach!.playing;
    if (reaching) {
      _reach!.weight = 1;
      _idle?.weight = 0;
      _walk?.weight = 0;
      return;
    }
    _reach?.weight = 0;

    final moving = moveAmount > 0.05;
    final target = moving ? 1.0 : 0.0;
    final step = min(1.0, deltaSeconds * 5);
    _walkWeight += (target - _walkWeight) * step;
    _walk?.weight = _walkWeight;
    _walk?.playbackTimeScale = moving ? speed / walkReferenceSpeed : 1;
    _idle?.weight = 1 - _walkWeight;
  }
}

void _silence(Node node) {
  node.raycastable = false;
  for (final child in node.children) {
    _silence(child);
  }
}
