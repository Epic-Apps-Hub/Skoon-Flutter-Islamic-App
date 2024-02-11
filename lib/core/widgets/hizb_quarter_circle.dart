import 'dart:math';

import 'package:flutter/material.dart';


class QuarterCircle extends StatelessWidget {
  final Color color; // Color of the quarter circle
  final double size; // Size of the quarter circle

  const QuarterCircle({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: QuarterCirclePainter(color),
    );
  }
}

class HalfCircle extends StatelessWidget {
  final Color color; // Color of the half circle
  final double size; // Size of the half circle

  const HalfCircle({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: HalfCirclePainter(color),
    );
  }
}

class ThreeQuartersCircle extends StatelessWidget {
  final Color color; // Color of the three-quarters circle
  final double size; // Size of the three-quarters circle

  const ThreeQuartersCircle({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: ThreeQuartersCirclePainter(color),
    );
  }
}

class QuarterCirclePainter extends CustomPainter {
  final Color color;

  QuarterCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Rect rect = Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height));
    const double startAngle = -pi / 2; // Start at the top
    const double sweepAngle = pi / 2; // 90 degrees (a quarter circle)

    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class HalfCirclePainter extends CustomPainter {
  final Color color;

  HalfCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Rect rect = Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height));
    const double startAngle = -pi / 2; // Start at the top
    const double sweepAngle = pi; // 180 degrees (half circle)

    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class ThreeQuartersCirclePainter extends CustomPainter {
  final Color color;

  ThreeQuartersCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Rect rect = Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height));
    const double startAngle = -pi / 2; // Start at the top
    const double sweepAngle = 3 * pi / 2; // 270 degrees (three-quarters circle)

    canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
