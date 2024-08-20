import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:socket_client/models/chat_bubble.dart';

import '../custom_paints/chat_bubble_paint.dart';
import 'chat_message_widget.dart';

class AnimatedBubble extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final Offset middlePosition;
  final VoidCallback onComplete;
  final bool isServer;
  final ChatBubble bubble;

  const AnimatedBubble({
    Key? key,
    required this.startPosition,
    required this.endPosition,
    required this.middlePosition,
    required this.onComplete,
    required this.isServer,
    required this.bubble,
  }) : super(key: key);

  @override
  _AnimatedBubbleState createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<AnimatedBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Path _path;
  late PathMetric _pathMetric;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _path = Path()
      ..moveTo(widget.startPosition.dx,
          widget.startPosition.dy) // Start at (50, 100)
      ..quadraticBezierTo(widget.middlePosition.dx, widget.middlePosition.dy,
          widget.endPosition.dx, widget.endPosition.dy);

    // Extract the path metrics
    _pathMetric = _path.computeMetrics().first;

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Get the position on the path based on the animation value
        final PathMetric pathMetric = _pathMetric;
        final Offset position = pathMetric
            .getTangentForOffset(pathMetric.length * _animation.value)!
            .position;
        return Positioned(
          left: position.dx,
          top: position.dy,
          child: Material(
            type: MaterialType.transparency,
            child: CustomPaint(
              painter: ChatBubblePainter(
                color: widget.isServer ? Colors.grey : Colors.blue,
                alignment:
                    widget.isServer ? Alignment.topLeft : Alignment.topRight,
                tail: widget.bubble.tail,
                radius: widget.bubble.text == "" ? 12 : 15,
                text: "",
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .7,
                ),
                margin: widget.isServer
                    ? const EdgeInsets.fromLTRB(40, 7, 17, 7)
                    : const EdgeInsets.fromLTRB(17, 7, 40, 7),
                child: ChatMessage(
                  text:
                      (widget.bubble.text).isEmpty ? "  " : widget.bubble.text,
                  sentAt: "",
                  style: TextStyle(
                    color: widget.isServer ? Colors.black : Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
