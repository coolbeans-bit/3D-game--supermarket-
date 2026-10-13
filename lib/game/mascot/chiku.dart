import '../characters/character_appearance.dart';

/// Moments Chiku may speak. The opening visit uses the welcome line.
enum ChikuMoment {
  welcome,
  tutorial,
  lowStock,
  customerArrival,
  successfulSale,
  progression,
}

/// As Mitra's rabbit mascot. Identity and lines only; no scene node.
class Chiku {
  const Chiku._();

  static const String name = 'Chiku';

  static const CharacterAppearance appearance = CharacterAppearance(
    body: RgbColor(0.95, 0.86, 0.72),
    head: RgbColor(0.98, 0.9, 0.8),
    accent: RgbColor(0.93, 0.55, 0.62),
    accentKind: FigureAccent.ears,
  );

  static const Map<ChikuMoment, String> lines = {
    ChikuMoment.welcome: 'Welcome to As Mitra Market!',
    ChikuMoment.tutorial: "Let's get the shelves ready!",
    ChikuMoment.lowStock: "We're running low on bread!",
    ChikuMoment.customerArrival: 'Looks like our first customer!',
    ChikuMoment.successfulSale: 'Great sale!',
    ChikuMoment.progression: 'Your store is growing!',
  };

  static String line(ChikuMoment moment) => lines[moment]!;
}
