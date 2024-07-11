import 'dart:math';

import 'package:flutter/material.dart';
import '../custom_paints/chat_bubble_paint.dart';

class RenderChatBubble extends RenderBox {
  String? _text;
  String _sentAt;
  bool _sender;
  bool _tail;
  TextStyle _textStyle;
  TextPainter _textPainter;
  TextPainter _sentAtTextPainter;

  RenderChatBubble(
      {String? text,
      required String sentAt,
      required bool sender,
      required TextStyle textStyle,
      required bool tail})
      : _text = text,
        _sentAt = sentAt,
        _sender = sender,
        _tail = tail,
        _textStyle = textStyle,
        _textPainter = TextPainter(
            text: TextSpan(text: text, style: textStyle),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left),
        _sentAtTextPainter = TextPainter(
            text: TextSpan(text: sentAt, style: textStyle),
            textDirection: TextDirection.ltr);

  TextSpan get textTextSpan => TextSpan(text: _text, style: _textStyle);
  TextSpan get sentTextSpan =>
      TextSpan(text: _sentAt, style: _textStyle.copyWith(color: Colors.grey));

  // Saved values from 'performLayout' used in 'paint'
  late bool _sentAtFitsOnLastLine;
  late double _lineHeight;
  late double _lastMessageLineWidth;
  late double _longestLineWidth;
  late double _sentAtLineWidth;
  late int _numMessageLines;

  set sentAt(String value) {
    if (_sentAt != value) {
      _sentAt = value;
      _sentAtTextPainter.text = sentTextSpan;
      markNeedsLayout();
      markNeedsSemanticsUpdate();
    }
  }

  String get sentAt => _sentAt;

  set text(String? value) {
    if (_text != value) {
      _text = value;
      _textPainter.text = textTextSpan;
      markNeedsLayout();
      markNeedsSemanticsUpdate();
    }
  }

  String? get text => _text;

  set sender(bool value) {
    if (_sender != value) {
      _sender = value;
      markNeedsLayout();
      markNeedsSemanticsUpdate();
    }
  }

  bool get sender => _sender;

  set tail(bool value) {
    if (_tail != value) {
      _tail = value;
      markNeedsLayout();
      markNeedsSemanticsUpdate();
    }
  }

  bool get tail => _tail;

  set textStyle(TextStyle value) {
    if (_textStyle != value) {
      _textStyle = value;
      _textPainter.text = textTextSpan;
      _sentAtTextPainter.text = sentTextSpan;
      markNeedsLayout();
      markNeedsSemanticsUpdate();
    }
  }

  TextStyle get textStyle => _textStyle;

  set textPainter(TextPainter value) {
    if (_textPainter != value) {
      _textPainter = value;
      markNeedsLayout();
      markNeedsSemanticsUpdate();
    }
  }

  set sentAtTextPainter(TextPainter value) {
    if (_sentAtTextPainter != value) {
      _sentAtTextPainter = value;
      markNeedsLayout();
      markNeedsSemanticsUpdate();
    }
  }

  @override
  void performLayout() {
    // _textPainter.text = TextSpan(
    //   text: text,
    //   style: const TextStyle(color: Colors.white, fontSize: 16.0),
    // );
    // _textPainter.layout(maxWidth: constraints.maxWidth - 50.0);

    // size = Size(
    //   _textPainter.width + 35.0,
    //   _textPainter.height + 18.0,
    // );
    _textPainter.layout(maxWidth: constraints.maxWidth);
    final textLines = _textPainter.computeLineMetrics();

    _longestLineWidth = 0;
    for (final line in textLines) {
      _longestLineWidth = max(_longestLineWidth, line.width);
    }

    _lastMessageLineWidth = textLines.last.width;
    _lineHeight = textLines.last.height;
    _numMessageLines = textLines.length;

    final sizeOfMessage = Size(_longestLineWidth, _textPainter.height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final painter = ChatBubblePainter(
      text: text ?? "",
      color: Colors.blue,
      alignment: sender ? Alignment.topRight : Alignment.topLeft,
      tail: tail,
    );

    painter.paint(context.canvas, size);
  }

  // @override
  // void describeSemanticsConfiguration(SemanticsConfiguration config) {
  //   super.describeSemanticsConfiguration(config);
  //   config
  //     ..isSemanticBoundary = true
  //     ..label = 'Chat Bubble with text: ${text ?? ""}';
  // }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _textPainter.layout();
    return _textPainter.maxIntrinsicWidth + 30;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _textPainter.layout();
    return _textPainter.height + 20;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _textPainter.layout();
    return _textPainter.height + 20;
  }
}
