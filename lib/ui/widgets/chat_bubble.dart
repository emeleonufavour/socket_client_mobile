import 'package:flutter/widgets.dart';

import '../render_objects/chat_bubble_ro.dart';

class ChatBubbleWidget extends LeafRenderObjectWidget {
  final String? text;
  final String sentAt;
  final bool sender;
  final bool tail;
  final TextStyle textStyle;
  const ChatBubbleWidget(
      {super.key,
      this.text,
      required this.sentAt,
      required this.sender,
      required this.textStyle,
      required this.tail});

  @override
  RenderChatBubble createRenderObject(BuildContext context) {
    return RenderChatBubble(
        text: text,
        sender: sender,
        tail: tail,
        sentAt: sentAt,
        textStyle: textStyle);
  }

  @override
  void updateRenderObject(BuildContext context, RenderChatBubble renderObject) {
    renderObject
      ..text = text
      ..sender = sender
      ..sentAt = sentAt
      ..tail = tail
      ..textStyle = textStyle
      ..markNeedsLayout()
      ..markNeedsPaint();
  }
}
