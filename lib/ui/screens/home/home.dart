import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:socket_client/models/chat_bubble.dart';
import 'package:socket_client/ui/widgets/animated_bubble.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../helper/double_linkedlist.dart';
import '../../../models/node.dart';
import '../../custom_paints/chat_bubble_paint.dart';
import '../../widgets/chat_message_widget.dart';
import '../../widgets/glass_app_bar.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  OverlayEntry? _overlayEntry;
  final GlobalKey bubbleKey = GlobalKey();
  final TextEditingController _chatTextController = TextEditingController();
  late IO.Socket socket;
  final StreamController<String> _chatStreamController =
      StreamController<String>();
  final ScrollController _scrollController = ScrollController();
  final _animationDuration = const Duration(milliseconds: 400);
  final Map<int, GlobalKey> _bubbleKeys = {};

  @override
  void initState() {
    super.initState();
    _configureSocket();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    socket.dispose();
    _chatStreamController.close();
    _scrollController.dispose();

    super.dispose();
  }

  void performBubbleAnimationFromTextField(
      BuildContext context, ChatBubble bubble, bool isServer) {
    final bubblePosition = Offset(MediaQuery.sizeOf(context).width / 3.5,
        MediaQuery.sizeOf(context).height / 1.12);
    final middlePosition = Offset(MediaQuery.sizeOf(context).width / 1.5,
        MediaQuery.sizeOf(context).height / 1.5);
    final position = Offset(MediaQuery.sizeOf(context).width / 1.2,
        MediaQuery.sizeOf(context).height / 4);

    _overlayEntry = OverlayEntry(
        builder: (context) => AnimatedBubble(
            startPosition: bubblePosition,
            middlePosition: middlePosition,
            endPosition: position,
            onComplete: () {
              _overlayEntry?.remove();
              _overlayEntry = null;
            },
            isServer: isServer,
            bubble: bubble));

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _onScroll() {
    if (_scrollController.position.atEdge) {
      bool isTop = _scrollController.position.pixels == 0;
      if (isTop) {
        log("Scrolled to the top");
      } else {
        log("Scrolled to the end");
        // Here you can trigger an action when the user reaches the end
      }
    }
  }

  void _configureSocket() {
    socket = IO.io(
        'http://localhost:8080',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());

    socket.connect();

    socket.on('connect', (_) {
      log('Successfully connected to server');
    });

    socket.on('server', (data) {
      _chatStreamController.sink.add(data);
    });

    socket.on('disconnect', (_) {
      log('Disconnected from server');
    });

    socket.on('error', (error) {
      log('Error: $error');
    });
  }

  void _sendMessage(BuildContext context, ChatBubble bubble, bool isServer) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_chatTextController.text.isNotEmpty && context.mounted) {
        _addMessage(false, _chatTextController.text, context);
        socket.emit('client', _chatTextController.text);
        _chatTextController.clear();
      }
    });

    performBubbleAnimationFromTextField(context, bubble, isServer);
  }

  void _addMessage(bool isServer, String text, BuildContext context) {
    final list =
        Provider.of<DoubleLinkedList<ChatBubble>>(context, listen: false);
    if (text.isNotEmpty) {
      int chatCount = _getChatCount(list);
      final previousNode = _getNodeAt(list, chatCount - 1);

      list.append(
          ChatBubble(isServer: isServer, text: text),
          previousNode?.value.isServer == isServer
              ? previousNode?.value.copyWith(tail: false)
              : null);
      _listKey.currentState
          ?.insertItem(chatCount, duration: _animationDuration);
    }
  }

  int _getChatCount(DoubleLinkedList<ChatBubble> list) {
    int count = 0;
    Node<ChatBubble>? current = list.head;
    while (current != null) {
      count++;
      current = current.next;
    }
    return count;
  }

  Node<ChatBubble>? _getNodeAt(DoubleLinkedList<ChatBubble> list, int index) {
    int count = 0;
    Node<ChatBubble>? current = list.head;
    while (current != null && count < index) {
      count++;
      current = current.next;
    }
    return current;
  }

  @override
  Widget build(BuildContext context) {
    final list = Provider.of<DoubleLinkedList<ChatBubble>>(context);
    return Scaffold(
      appBar: GlassAppBar(
        toolBarHeight: MediaQuery.sizeOf(context).height * 0.1,
        leading: const Icon(
          Icons.arrow_back_ios,
          color: Colors.blue,
        ),
        title: const Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/bitmoji.png"),
            ),
            Text(
              "Favour",
              style: TextStyle(color: Colors.black, fontSize: 15),
            )
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Icon(
              CupertinoIcons.video_camera,
              size: 40,
              color: Colors.blue,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<String>(
              stream: _chatStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _addMessage(true, snapshot.data!, context);
                }
                return AnimatedList(
                  key: _listKey,
                  reverse: false,
                  initialItemCount: _getChatCount(list),
                  itemBuilder: (context, index, animation) {
                    final currentNode = _getNodeAt(list, index);
                    if (currentNode != null) {
                      return _buildMessageBubble(
                          currentNode.value, animation, index);
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              },
            ),
          ),
          _buildTextField(
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      ChatBubble bubble, Animation<double> animation, int index) {
    bool isServer = bubble.isServer;
    _bubbleKeys[index] = _bubbleKeys[index] ?? GlobalKey();
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, right: 1.0, bottom: 3.0),
      child: Align(
        alignment: isServer ? Alignment.centerLeft : Alignment.centerRight,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: AnimatedContainer(
              duration: _animationDuration,
              child: CustomPaint(
                painter: ChatBubblePainter(
                  color: isServer ? Colors.grey : Colors.blue,
                  alignment: isServer ? Alignment.topLeft : Alignment.topRight,
                  tail: bubble.tail,
                  radius: bubble.text == "" ? 12 : 15,
                  text: "",
                ),
                child: Container(
                  key: _bubbleKeys[index],
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .7,
                  ),
                  margin: isServer
                      ? const EdgeInsets.fromLTRB(40, 7, 17, 7)
                      : const EdgeInsets.fromLTRB(17, 7, 40, 7),
                  child: ChatMessage(
                    text: (bubble.text).isEmpty ? "  " : bubble.text,
                    sentAt: "",
                    style: TextStyle(
                      color: isServer ? Colors.black : Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.camera_fill,
            size: 35,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              height: 35,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SvgPicture.asset(
                "assets/appstore.svg",
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: _chatTextController,
              placeholder: "iMessage",
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.grey.withOpacity(0.5), width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(17)),
              ),
              onSubmitted: (value) => _sendMessage(
                  context, ChatBubble(isServer: false, text: value), false),
            ),
          ),
        ],
      ),
    );
  }
}
