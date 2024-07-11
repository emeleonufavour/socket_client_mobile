import 'package:flutter/material.dart';

import '../render_objects/chat_message_ro.dart';

class TimestampedChatMessage extends LeafRenderObjectWidget {
  const TimestampedChatMessage({
    super.key,
    required this.text,
    required this.sentAt,
    this.style,
  });

  final String text;
  final String sentAt;
  final TextStyle? style;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = style;
    if (style == null || style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    }
    return ChatMessageRenderObject(
      text: text,
      textDirection: Directionality.of(context),
      textStyle: effectiveTextStyle!,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    ChatMessageRenderObject renderObject,
  ) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = style;
    if (style == null || style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    }
    renderObject.text = text;
    renderObject.textStyle = effectiveTextStyle!;

    renderObject.textDirection = Directionality.of(context);
  }
}
