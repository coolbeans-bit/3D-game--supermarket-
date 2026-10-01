/// Something the player can use while looking at it.
///
/// Future store pieces (a shelf, product, checkout, delivery, or door) implement
/// this. The raycast system does not know those types.
abstract interface class Interactable {
  String get id;

  String get displayName;

  /// Short label for the interaction control, such as "INTERACT".
  String get prompt;

  /// Whole currency units to show beside the name, or null.
  int? get priceAmount;

  bool get isInteractable;

  void interact();
}

/// Generic interactable whose action is supplied by the caller.
class BasicInteractable implements Interactable {
  BasicInteractable({
    required this.id,
    required this.displayName,
    required this.prompt,
    required this.onInteract,
    this.isInteractable = true,
    this.priceAmount,
  });

  @override
  final String id;

  @override
  final String displayName;

  @override
  final String prompt;

  @override
  bool isInteractable;

  @override
  final int? priceAmount;

  final void Function() onInteract;

  @override
  void interact() => onInteract();
}
