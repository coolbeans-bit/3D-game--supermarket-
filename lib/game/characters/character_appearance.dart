/// Flat color used by placeholder figures. Rendering stays outside this type.
class RgbColor {
  const RgbColor(this.r, this.g, this.b);

  final double r;
  final double g;
  final double b;
}

/// How a placeholder marks a character without a finished model.
enum FigureAccent { cap, sash, ears }

/// Body, head, and one simple accent. Customers and Chiku can both use this.
class CharacterAppearance {
  const CharacterAppearance({
    required this.body,
    required this.head,
    required this.accent,
    required this.accentKind,
  });

  final RgbColor body;
  final RgbColor head;
  final RgbColor accent;
  final FigureAccent accentKind;
}
