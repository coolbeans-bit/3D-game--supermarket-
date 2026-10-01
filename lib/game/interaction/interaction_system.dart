import 'package:flutter/foundation.dart';

import 'interactable.dart';
import 'interaction_result.dart';

/// Tracks which bound object the player is allowed to use.
///
/// [hitKey] is whatever the scene raycast uses to identify a mesh, usually the
/// scene node. This class does not cast rays.
class InteractionSystem extends ChangeNotifier {
  InteractionSystem({this.maxDistance = 2.5});

  /// Meters. Hits farther than this are ignored.
  final double maxDistance;

  final Map<Object, Interactable> _bindings = {};
  InteractionResult? _aim;

  InteractionResult? get aim => _aim;

  void bind(Object hitKey, Interactable interactable) {
    _bindings[hitKey] = interactable;
  }

  /// [hitKey] is the nearest surface the ray touched. Null means the ray
  /// missed or the caller rejected the hit.
  void setAim({required Object? hitKey, required double? distance}) {
    final next = _resolve(hitKey, distance);
    if (next?.target.id == _aim?.target.id) {
      return;
    }
    _aim = next;
    notifyListeners();
  }

  void interact() {
    final current = _aim?.target;
    if (current == null || !current.isInteractable) {
      return;
    }
    current.interact();
  }

  InteractionResult? _resolve(Object? hitKey, double? distance) {
    if (hitKey == null || distance == null || distance > maxDistance) {
      return null;
    }
    final interactable = _bindings[hitKey];
    if (interactable == null || !interactable.isInteractable) {
      return null;
    }
    return InteractionResult(target: interactable, distance: distance);
  }
}
