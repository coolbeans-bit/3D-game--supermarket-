import 'package:flutter/widgets.dart';

/// Right-side drag surface. [dx] and [dy] are pixel deltas, y positive down.
class LookController extends StatelessWidget {
  const LookController({super.key, required this.onLook});

  final void Function(double dx, double dy) onLook;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerMove: (event) => onLook(event.delta.dx, event.delta.dy),
      child: const SizedBox.expand(),
    );
  }
}
