import '../characters/character_appearance.dart';
import 'customer_type.dart';

/// Placeholder looks for the three shopper types. Colors are original.
const customerAppearances = <String, CharacterAppearance>{
  'regular': CharacterAppearance(
    body: RgbColor(0.72, 0.38, 0.24),
    head: RgbColor(0.93, 0.78, 0.64),
    accent: RgbColor(0.95, 0.72, 0.28),
    accentKind: FigureAccent.cap,
  ),
  'quick-shopper': CharacterAppearance(
    body: RgbColor(0.16, 0.55, 0.62),
    head: RgbColor(0.93, 0.78, 0.64),
    accent: RgbColor(0.95, 0.45, 0.28),
    accentKind: FigureAccent.sash,
  ),
  'slow-shopper': CharacterAppearance(
    body: RgbColor(0.48, 0.36, 0.62),
    head: RgbColor(0.93, 0.78, 0.64),
    accent: RgbColor(0.55, 0.72, 0.42),
    accentKind: FigureAccent.cap,
  ),
};

CharacterAppearance appearanceFor(CustomerType type) {
  return customerAppearances[type.id] ?? customerAppearances['regular']!;
}
