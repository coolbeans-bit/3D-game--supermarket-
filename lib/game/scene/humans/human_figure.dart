import 'dart:math';

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../player_avatar.dart';
import 'human_outfit.dart';

/// One loaded body and the clip names that body actually contains.
class SpawnedHuman {
  SpawnedHuman({
    required this.node,
    required this.idle,
    required this.walk,
    this.reach,
  });

  final Node node;
  final String idle;
  final String walk;
  final String? reach;
}

/// Loads each person once so copies can walk on their own.
///
/// Product meshes stay in the product presenters. This file only places people.
class HumanLibrary {
  HumanLibrary._(this._templates);

  static const woman = 'woman';
  static const man = 'man';
  static const sleeves = 'sleeves';
  static const casual = 'casual';
  static const cashier = 'cashier';

  static const _manIdle = 'HumanArmature|Man_Idle';
  static const _manWalk = 'HumanArmature|Man_Walk';

  static const _specs = <String, (String, String, String, String)>{
    woman: (
      PlayerAvatar.assetPath,
      PlayerAvatar.idleName,
      PlayerAvatar.walkName,
      PlayerAvatar.reachName,
    ),
    man: ('assets/characters/man.glb', _manIdle, _manWalk, ''),
    sleeves: ('assets/characters/man_sleeves.glb', _manIdle, _manWalk, ''),
    casual: ('assets/characters/man_casual.glb', _manIdle, _manWalk, ''),
    cashier: ('assets/characters/cashier.glb', _manIdle, _manWalk, ''),
  };

  static const customerBodies = <String>[woman, man, sleeves, casual];

  final Map<String, Node> _templates;

  static Future<HumanLibrary> load() async {
    final templates = <String, Node>{};
    for (final entry in _specs.entries) {
      templates[entry.key] = await Node.fromGlbAsset(entry.value.$1);
    }
    return HumanLibrary._(templates);
  }

  /// A fresh copy. Skins are rebound, so each person animates on their own.
  SpawnedHuman spawn(String id) {
    final spec = _specs[id];
    final template = _templates[id];
    if (spec == null || template == null) {
      throw ArgumentError('unknown person $id');
    }
    final reach = spec.$4.isEmpty ? null : spec.$4;
    return SpawnedHuman(
      node: template.clone(),
      idle: spec.$2,
      walk: spec.$3,
      reach: reach,
    );
  }

  /// Shoppers rotate through the woman and the three men.
  static String bodyFor(String id) {
    final digits = RegExp(r'(\d+)$').firstMatch(id);
    if (digits != null) {
      final index = int.parse(digits.group(1)!);
      return customerBodies[index % customerBodies.length];
    }
    var hash = 0;
    for (final unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return customerBodies[hash % customerBodies.length];
  }
}

/// One posed person. Idle while standing, walk while [sync] reports speed.
class HumanFigure {
  HumanFigure({
    required this.scene,
    required Node model,
    required String name,
    required String idleName,
    required String walkName,
    String? reachName,
    this.scale = PlayerAvatar.bodyScale,
    HumanOutfit? outfit,
  }) {
    if (outfit != null) {
      applyOutfit(model, outfit);
    }
    _silence(model);
    _root = Node(name: name)
      ..scale = Vector3.all(scale)
      ..add(model);
    scene.add(_root);

    final idle = model.findAnimationByName(idleName);
    final walk = model.findAnimationByName(walkName);
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
    if (reachName != null) {
      final reach = model.findAnimationByName(reachName);
      if (reach != null) {
        _reach = model.createAnimationClip(reach)
          ..loop = false
          ..weight = 0;
      }
    }
  }

  /// Plays the reach once. Models without that clip keep standing.
  void playReach() {
    final reach = _reach;
    if (reach == null) {
      return;
    }
    reach.weight = 1;
    reach.replay();
  }

  final Scene scene;
  final double scale;
  late final Node _root;
  AnimationClip? _idle;
  AnimationClip? _walk;
  AnimationClip? _reach;
  double _walkWeight = 0;
  final Vector3 _position = Vector3.zero();
  final Quaternion _rotation = Quaternion.identity();
  final Vector3 _up = Vector3(0, 1, 0);

  void sync({
    required Vector3 feet,
    required double yaw,
    required double speed,
    required double deltaSeconds,
  }) {
    _position.setValues(feet.x, feet.y, feet.z);
    _root.position = _position;
    _rotation.setAxisAngle(_up, yaw);
    _root.rotation = _rotation;

    final reaching = _reach != null && _reach!.playing;
    if (reaching) {
      _reach!.weight = 1;
      _idle?.weight = 0;
      _walk?.weight = 0;
      return;
    }
    _reach?.weight = 0;

    final moving = speed > 0.12;
    final target = moving ? 1.0 : 0.0;
    final step = min(1.0, deltaSeconds * 5);
    _walkWeight += (target - _walkWeight) * step;
    _walk?.weight = _walkWeight;
    // The clip is authored for a full-size stride. Shorter people take
    // slightly quicker steps, and the rate stays in a human range so a
    // slower shopper does not move in slow motion.
    final stride = (PlayerAvatar.bodyScale / scale).clamp(0.85, 1.2);
    final pace = speed / PlayerAvatar.walkReferenceSpeed * stride;
    _walk?.playbackTimeScale = moving ? pace.clamp(0.85, 1.25) : 1;
    _idle?.weight = 1 - _walkWeight;
  }

  void remove() {
    scene.remove(_root);
  }
}

void _silence(Node node) {
  node.raycastable = false;
  for (final child in node.children) {
    _silence(child);
  }
}
