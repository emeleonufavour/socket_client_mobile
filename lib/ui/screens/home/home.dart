import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:socket_client/models/chat_bubble.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../helper/double_linkedlist.dart';
import '../../../models/node.dart';
import '../../custom_paints/chat_bubble_paint.dart';
import '../../widgets/chat_message_widget.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _chatTextController = TextEditingController();
  late IO.Socket socket;
  final StreamController<String> _chatStreamController =
      StreamController<String>();

  @override
  void initState() {
    super.initState();
    _configureSocket();
  }

  @override
  void dispose() {
    socket.dispose();
    _chatStreamController.close();
    super.dispose();
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

  void _sendMessage(BuildContext context) {
    if (_chatTextController.text.isNotEmpty) {
      _addMessage(false, _chatTextController.text, context);
      socket.emit('client', _chatTextController.text);
      _chatTextController.clear();
    }
  }

  void _addMessage(bool isServer, String text, BuildContext context) {
    final list =
        Provider.of<DoubleLinkedList<ChatBubble>>(context, listen: false);
    if (text.isNotEmpty) {
      final previousNode = _getNodeAt(list, _getChatCount(list) - 1);

      list.append(
          ChatBubble(isServer: isServer, text: text),
          previousNode?.value.copyWith(
              tail: previousNode.value.isServer == isServer ? false : true));
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
      appBar: AppBar(
        backgroundColor: Colors.red,
        toolbarHeight: MediaQuery.sizeOf(context).height * 0.1,
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
                return ListView.builder(
                  reverse: false,
                  itemCount: _getChatCount(list),
                  itemBuilder: (context, index) {
                    final currentNode = _getNodeAt(list, index);
                    return _buildMessageBubble(currentNode!.value);
                  },
                );
              },
            ),
          ),
          _buildTextField(context),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatBubble bubble) {
    bool isServer = bubble.isServer;
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, right: 1.0),
      child: Align(
        alignment: isServer ? Alignment.centerLeft : Alignment.centerRight,
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
            child: TimestampedChatMessage(
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
    );
  }

  Widget _buildTextField(BuildContext context) {
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
              onSubmitted: (value) => _sendMessage(context),
            ),
          ),
        ],
      ),
    );
  }
}
