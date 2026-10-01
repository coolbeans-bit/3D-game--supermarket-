import 'package:asmitra_game/game/interaction/interactable.dart';
import 'package:asmitra_game/game/interaction/interaction_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a hit inside range selects the bound object', () {
    final system = InteractionSystem(maxDistance: 2.5);
    var used = 0;
    final box = BasicInteractable(
      id: 'test-box',
      displayName: 'Test Box',
      prompt: 'INTERACT',
      onInteract: () => used++,
    );
    final key = Object();
    system.bind(key, box);

    system.setAim(hitKey: key, distance: 1.2);

    expect(system.aim?.target.displayName, 'Test Box');
    system.interact();
    expect(used, 1);
  });

  test('a hit past the configured distance is ignored', () {
    final system = InteractionSystem(maxDistance: 2.5);
    final key = Object();
    system.bind(
      key,
      BasicInteractable(
        id: 'far',
        displayName: 'Far',
        prompt: 'INTERACT',
        onInteract: () {},
      ),
    );

    system.setAim(hitKey: key, distance: 2.5);
    expect(system.aim?.target.id, 'far');

    system.setAim(hitKey: key, distance: 2.51);
    expect(system.aim, isNull);
  });

  test('an unbound surface and a disabled object do not target', () {
    final system = InteractionSystem(maxDistance: 2.5);
    final disabled = BasicInteractable(
      id: 'off',
      displayName: 'Off',
      prompt: 'INTERACT',
      isInteractable: false,
      onInteract: () {},
    );
    final key = Object();
    system.bind(key, disabled);

    system.setAim(hitKey: key, distance: 1);
    expect(system.aim, isNull);

    system.setAim(hitKey: Object(), distance: 1);
    expect(system.aim, isNull);

    system.setAim(hitKey: null, distance: null);
    expect(system.aim, isNull);
  });
}
