import 'package:flutter/widgets.dart';

import '../render_objects/chat_bubble_ro.dart';

class ChatBubbleWidget extends LeafRenderObjectWidget {
  final String? text;
  final bool sender;

  const ChatBubbleWidget({super.key, this.text, required this.sender});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderChatBubble(
      text: text,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderChatBubble renderObject) {
    renderObject
      ..text = text
      ..markNeedsLayout();
  }
}
