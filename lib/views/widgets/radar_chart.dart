import 'dart:math';
import 'package:flutter/material.dart';

class RadarChart extends StatelessWidget {
  final int clarity;
  final int pace;
  final int accuracy;

  const RadarChart({
    super.key,
    required this.clarity,
    required this.pace,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: CustomPaint(
        painter: RadarChartPainter(
          clarity: clarity.toDouble(),
          pace: pace.toDouble(),
          accuracy: accuracy.toDouble(),
        ),
      ),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final double clarity;
  final double pace;
  final double accuracy;

  RadarChartPainter({
    required this.clarity,
    required this.pace,
    required this.accuracy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = const Color(0xFF2E2C45).withAlpha((0.5 * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 24;
    final steps = 4;
    for (var i = 1; i <= steps; i++) {
      final r = radius * (i / steps);
      canvas.drawCircle(center, r, paintGrid);
    }

    final labels = ['Clarity', 'Pace', 'Accuracy'];
    final angles = [ -90.0, 30.0, 150.0 ];
    for (var index = 0; index < angles.length; index++) {
      final angle = angles[index] * (3.1415926535 / 180);
      final target = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, target, paintGrid);
      final labelOffset = Offset(
        center.dx + (radius + 20) * cos(angle),
        center.dy + (radius + 20) * sin(angle),
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[index],
          style: const TextStyle(color: Color(0xFF9896B0), fontSize: 12, fontWeight: FontWeight.w500),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        labelOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    final points = [clarity, pace, accuracy].asMap().entries.map((entry) {
      final angle = angles[entry.key] * (3.1415926535 / 180);
      final valueRadius = radius * (entry.value / 10.0);
      return Offset(
        center.dx + valueRadius * cos(angle),
        center.dy + valueRadius * sin(angle),
      );
    }).toList();

    final chartPaint = Paint()
      ..color = const Color(0xFF6C63FF).withAlpha((0.35 * 255).round())
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, chartPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) {
    return oldDelegate.clarity != clarity ||
        oldDelegate.pace != pace ||
        oldDelegate.accuracy != accuracy;
  }
}
