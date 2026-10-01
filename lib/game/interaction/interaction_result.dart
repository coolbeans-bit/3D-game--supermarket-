import 'interactable.dart';

/// A successful aim at an [Interactable] within range.
class InteractionResult {
  const InteractionResult({required this.target, required this.distance});

  final Interactable target;

  /// Meters from the camera to the hit.
  final double distance;
}
