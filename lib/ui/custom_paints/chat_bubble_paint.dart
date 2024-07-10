import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ChatBubblePainter extends CustomPainter {
  final Color color;
  final Alignment alignment;
  final bool tail;
  final String text;

  ChatBubblePainter({
    required this.color,
    required this.alignment,
    required this.tail,
    required this.text,
  });

  final double _radius = 10.0;
  final double _padding = 15.0;

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    Paint paint = Paint()
      // ..color = color;
      ..shader = ui.Gradient.linear(
        Offset(w / 2, 0),
        Offset(w / 2, h),
        [Colors.lightBlue, Colors.blue],
      );

    Path path = Path();

    if (alignment == Alignment.topRight) {
      if (tail) {
        path.moveTo(_radius * 2, 0);
        path.quadraticBezierTo(0, 0, 0, _radius * 1.5);
        path.lineTo(0, h - _radius * 1.5);
        path.quadraticBezierTo(0, h, _radius * 2, h);
        path.lineTo(w - _radius * 3, h);
        path.quadraticBezierTo(
            w - _radius * 1.5, h, w - _radius * 1.5, h - _radius * 0.6);
        path.quadraticBezierTo(w - _radius * 1, h, w, h);
        path.quadraticBezierTo(
            w - _radius * 0.8, h, w - _radius, h - _radius * 1.5);
        path.lineTo(w - _radius, _radius * 1.5);
        path.quadraticBezierTo(w - _radius, 0, w - _radius * 3, 0);
      } else {
        path.moveTo(_radius * 2, 0);
        path.quadraticBezierTo(0, 0, 0, _radius * 1.5);
        path.lineTo(0, h - _radius * 1.5);
        path.quadraticBezierTo(0, h, _radius * 2, h);
        path.lineTo(w - _radius * 3, h);
        path.quadraticBezierTo(w - _radius, h, w - _radius, h - _radius * 1.5);
        path.lineTo(w - _radius, _radius * 1.5);
        path.quadraticBezierTo(w - _radius, 0, w - _radius * 3, 0);
      }
    } else {
      if (tail) {
        path.moveTo(_radius * 3, 0);
        path.quadraticBezierTo(_radius, 0, _radius, _radius * 1.5);
        path.lineTo(_radius, h - _radius * 1.5);
        path.quadraticBezierTo(_radius * .8, h, 0, h);
        path.quadraticBezierTo(
            _radius * 1, h, _radius * 1.5, h - _radius * 0.6);
        path.quadraticBezierTo(_radius * 1.5, h, _radius * 3, h);
        path.lineTo(w - _radius * 2, h);
        path.quadraticBezierTo(w, h, w, h - _radius * 1.5);
        path.lineTo(w, _radius * 1.5);
        path.quadraticBezierTo(w, 0, w - _radius * 2, 0);
      } else {
        path.moveTo(_radius * 3, 0);
        path.quadraticBezierTo(_radius, 0, _radius, _radius * 1.5);
        path.lineTo(_radius, h - _radius * 1.5);
        path.quadraticBezierTo(_radius, h, _radius * 3, h);
        path.lineTo(w - _radius * 2, h);
        path.quadraticBezierTo(w, h, w, h - _radius * 1.5);
        path.lineTo(w, _radius * 1.5);
        path.quadraticBezierTo(w, 0, w - _radius * 2, 0);
      }
    }

    path.close();
    canvas.clipPath(path);
    canvas.drawPath(path, paint);

    // Paint text
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 16.0),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    textPainter.layout(maxWidth: size.width - 2 * _padding);
    textPainter.paint(
        canvas,
        Offset(
          alignment == Alignment.topRight
              ? _padding
              : size.width - textPainter.width - _padding,
          h / 2 - textPainter.height / 2,
        ));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
