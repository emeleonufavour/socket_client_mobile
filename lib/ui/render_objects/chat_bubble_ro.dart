import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../custom_paints/chat_bubble_paint.dart';

class RenderChatBubble extends RenderBox {
  String? text;
  final TextPainter _textPainter;

  RenderChatBubble({this.text})
      : _textPainter = TextPainter(
            textDirection: TextDirection.ltr, textAlign: TextAlign.left);

  @override
  void performLayout() {
    _textPainter.text = TextSpan(
      text: text,
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
    );
    _textPainter.layout(maxWidth: constraints.maxWidth - 50.0);

    size = Size(
      _textPainter.width + 40.0,
      _textPainter.height + 20.0,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final painter = ChatBubblePainter(
      text: text ?? "",
      color: Colors.blue,
      alignment: Alignment.topRight,
      tail: true,
    );

    painter.paint(context.canvas, size);
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isSemanticBoundary = true
      ..label = 'Chat Bubble with text: ${text ?? ""}';
  }
}
