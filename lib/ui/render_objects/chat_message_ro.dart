import 'dart:math';

import 'package:flutter/rendering.dart';

class ChatMessageRenderObject extends RenderBox {
  ChatMessageRenderObject({
    required String text,
    required TextStyle textStyle,
    required TextDirection textDirection,
  }) {
    _text = text;
    _textStyle = textStyle;
    _textDirection = textDirection;
    _textPainter = TextPainter(
      text: textTextSpan,
      textDirection: _textDirection,
    );
  }

  late TextDirection _textDirection;
  late String _text;
  late TextPainter _textPainter;
  late TextStyle _textStyle;
  late double _lineHeight;
  late double _lastMessageLineWidth;
  double _longestLineWidth = 0;
  late int _numMessageLines;

  String get text => _text;
  set text(String val) {
    if (val == _text) return;
    _text = val;
    _textPainter.text = textTextSpan;
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  TextStyle get textStyle => _textStyle;
  set textStyle(TextStyle val) {
    if (val == _textStyle) return;
    _textStyle = val;
    _textPainter.text = textTextSpan;
    markNeedsLayout();
  }

  set textDirection(TextDirection val) {
    if (_textDirection == val) {
      return;
    }
    _textDirection = val;
    _textPainter.textDirection = val;
    markNeedsSemanticsUpdate();
    markNeedsLayout();
  }

  TextSpan get textTextSpan => TextSpan(text: _text, style: _textStyle);

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isSemanticBoundary = true;
    config.label = _text;
    config.textDirection = _textDirection;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _layoutText(double.infinity);
    return _longestLineWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      computeMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) {
    final computedSize = _layoutText(width);
    return computedSize.height;
  }

  @override
  void performLayout() {
    final unconstrainedSize = _layoutText(constraints.maxWidth);
    size = constraints.constrain(
      Size(unconstrainedSize.width, unconstrainedSize.height),
    );
  }

  Size _layoutText(double maxWidth) {
    if (_textPainter.text?.toPlainText() == '') {
      return Size.zero;
    }
    assert(
      maxWidth > 0,
      'You must allocate SOME space to layout a ChatMessageRenderObject. Received a '
      '`maxWidth` value of $maxWidth.',
    );

    _textPainter.layout(maxWidth: maxWidth);
    final textLines = _textPainter.computeLineMetrics();

    _longestLineWidth = 0;
    for (final line in textLines) {
      _longestLineWidth = max(_longestLineWidth, line.width);
    }

    final sizeOfMessage = Size(_longestLineWidth, _textPainter.height);

    _lastMessageLineWidth = textLines.last.width;
    _lineHeight = textLines.last.height;
    _numMessageLines = textLines.length;

    return sizeOfMessage;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_textPainter.text?.toPlainText() == '') {
      return;
    }

    _textPainter.paint(context.canvas, offset);
  }
}
