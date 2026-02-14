import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(0, size.height * 0.05666783);
    path_0.cubicTo(
      0,
      size.height * 0.03454881,
      size.width * 0.03590702,
      size.height * 0.01661777,
      size.width * 0.08020050,
      size.height * 0.01661777,
    );
    path_0.lineTo(size.width * 0.2500000, size.height * 0.01661777);
    path_0.lineTo(size.width * 0.3750000, size.height * 0.01661777);
    path_0.lineTo(size.width * 0.3986491, size.height * 0.01661777);
    path_0.cubicTo(
      size.width * 0.4231855,
      size.height * 0.01661777,
      size.width * 0.4457694,
      size.height * 0.01019831,
      size.width * 0.4673784,
      size.height * 0.004394618,
    );
    path_0.cubicTo(
      size.width * 0.4767068,
      size.height * 0.001889700,
      size.width * 0.4877895,
      0,
      size.width * 0.5000000,
      0,
    );
    path_0.cubicTo(
      size.width * 0.5122105,
      0,
      size.width * 0.5232932,
      size.height * 0.001889700,
      size.width * 0.5326216,
      size.height * 0.004394631,
    );
    path_0.cubicTo(
      size.width * 0.5542306,
      size.height * 0.01019831,
      size.width * 0.5768145,
      size.height * 0.01661777,
      size.width * 0.6013509,
      size.height * 0.01661777,
    );
    path_0.lineTo(size.width * 0.6250000, size.height * 0.01661777);
    path_0.lineTo(size.width * 0.7500000, size.height * 0.01661777);
    path_0.lineTo(size.width * 0.9197995, size.height * 0.01661777);
    path_0.cubicTo(
      size.width * 0.9640927,
      size.height * 0.01661777,
      size.width,
      size.height * 0.03454881,
      size.width,
      size.height * 0.05666783,
    );
    path_0.lineTo(size.width, size.height * 1.391740);
    path_0.lineTo(0, size.height * 1.391740);
    path_0.lineTo(0, size.height * 0.05666783);
    path_0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = const Color(0xff2F98D7).withOpacity(1.0);
    canvas.drawPath(path_0, paint0Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Changed to false for better performance
  }
}
