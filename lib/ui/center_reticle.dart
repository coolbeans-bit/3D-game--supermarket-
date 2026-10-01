import 'package:flutter/widgets.dart';

/// Fixed center marker for later raycast aiming.
class CenterReticle extends StatelessWidget {
  const CenterReticle({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Center(
        child: CustomPaint(
          key: Key('center-reticle'),
          size: Size(18, 18),
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
    final paint = Paint()
      ..color = const Color(0xF2FFFFFF)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final center = size.center(Offset.zero);
    canvas.drawLine(
      Offset(center.dx - 7, center.dy),
      Offset(center.dx + 7, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 7),
      Offset(center.dx, center.dy + 7),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
