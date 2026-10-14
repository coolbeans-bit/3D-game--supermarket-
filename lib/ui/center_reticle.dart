import 'package:flutter/widgets.dart';

/// Soft aim mark so the view stays readable while you look around.
class CenterReticle extends StatelessWidget {
  const CenterReticle({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Center(
        child: CustomPaint(
          key: Key('center-reticle'),
          size: Size(28, 28),
          painter: _ReticlePainter(),
        ),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  const _ReticlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final shadow = Paint()
      ..color = const Color(0x66000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final ring = Paint()
      ..color = const Color(0xF2FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 8, shadow);
    canvas.drawCircle(center, 8, ring);
    canvas.drawCircle(center, 2.2, Paint()..color = const Color(0xF2FFFFFF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
