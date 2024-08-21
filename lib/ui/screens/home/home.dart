import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
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
  final player = AudioPlayer();
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
  final GlobalKey _appBarKey = GlobalKey();
  int _characterCount = 0;
  int maxTextForBubble = 27;

  @override
  void initState() {
    super.initState();
    _configureSocket();
    _chatTextController.addListener(() {
      setState(() {
        _characterCount = _chatTextController.text.length;
        log("character count => $_characterCount");
      });
    });
    // _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    socket.dispose();
    _chatStreamController.close();
    _scrollController.dispose();

    super.dispose();
  }

  double _getUnitTextWidth() {
    final TextPainter textPainter = TextPainter(
      text: const TextSpan(text: "o", style: TextStyle(fontSize: 16)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.size.width;
  }

  void performBubbleAnimationFromTextField(
      BuildContext context, ChatBubble bubble, bool isServer) {
    final size = MediaQuery.sizeOf(context);
    final chatCount =
        _getChatCount(context.read<DoubleLinkedList<ChatBubble>>());
    Offset initialbubblePosition = Offset(
        MediaQuery.sizeOf(context).width / 3.4,
        MediaQuery.sizeOf(context).height / 1.10);

    Offset? endPosition;
    if (chatCount == 0) {
      final RenderBox? appBarRenderBox =
          _appBarKey.currentContext?.findRenderObject() as RenderBox?;

      if (appBarRenderBox == null) {
        log("Couldn't find the  App bar render box");
        return;
      }

      endPosition = appBarRenderBox.localToGlobal(Offset.zero);
    } else {
      final previousChatBubbleKey = _bubbleKeys[chatCount - 1];
      final previousChatBubbleRenderBox =
          previousChatBubbleKey?.currentState?.context.findRenderObject()
              as RenderBox?;

      if (previousChatBubbleRenderBox == null) {
        log("Couldn't find the  chat bubble render box");
        return;
      }

      endPosition = previousChatBubbleRenderBox.localToGlobal(Offset.zero);
    }

    double? endBubbleXPosition;
    double unitTextWidth = _getUnitTextWidth();

    if (_characterCount < maxTextForBubble) {
      endBubbleXPosition = (size.width - ((unitTextWidth * _characterCount)));
    } else {
      endBubbleXPosition = (size.width - ((unitTextWidth * maxTextForBubble)));
    }

    Offset middlePosition = Offset(
        endBubbleXPosition,
        ((initialbubblePosition.dy - endPosition.dy) * 0.95) +
            (size.height - initialbubblePosition.dy));
    // log("Init position => $initialbubblePosition");
    // log("Middle position => $middlePosition");
    // log("End X position => $endBubbleXPosition || full width => ${size.width}");
    // log("End Y position => ${endPosition.dy + 100}|| full height => ${size.height}");

    _overlayEntry = OverlayEntry(builder: (context) {
      return AnimatedBubble(
          startPosition: initialbubblePosition,
          middlePosition: middlePosition,
          endPosition: Offset(endBubbleXPosition!, endPosition!.dy + 100),
          onComplete: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
          isServer: isServer,
          bubble: bubble);
    });

    Overlay.of(context).insert(_overlayEntry!);
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

  Future<void> _sendMessage(
      BuildContext context, ChatBubble bubble, bool isServer) async {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_chatTextController.text.isNotEmpty && context.mounted) {
        _addMessage(false, _chatTextController.text, context);

        socket.emit('client', _chatTextController.text);
        _chatTextController.clear();
      }
    });
    performBubbleAnimationFromTextField(context, bubble, isServer);
    await player.play(AssetSource("sound/send_chat.wav"));
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
      backgroundColor: Color(0xff121212),
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
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Icon(
              key: _appBarKey,
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
                  controller: _scrollController,
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
    final chatBubbleKey = _bubbleKeys[index] ??= GlobalKey();
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, right: 1.0, bottom: 3.0),
      child: Align(
        alignment: isServer ? Alignment.centerLeft : Alignment.centerRight,
        child: AnimatedContainer(
          key: chatBubbleKey,
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
              // maxLines: null,
              // minLines: 1,
              controller: _chatTextController,
              placeholder: "iMessage",
              placeholderStyle: TextStyle(fontSize: 16, color: Colors.white),
              style: const TextStyle(fontSize: 16, color: Colors.white),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.grey.withOpacity(0.5), width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(17)),
              ),
              onSubmitted: (value) async => await _sendMessage(
                  context, ChatBubble(isServer: false, text: value), false),
            ),
          ),
        ],
      ),
    );
  }
}
