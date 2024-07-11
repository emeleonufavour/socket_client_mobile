import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_client/ui/custom_paints/chat_bubble_paint.dart';

import '../../main.dart';
import '../widgets/chat_message_widget.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = "Hello World";
  }

  List<Widget> chats = [Container(), Container()];

  @override
  Widget build(BuildContext context) {
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
            child: ListView.builder(
                reverse: true,
                itemCount: chats.length,
                itemBuilder: ((context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 2.0, right: 1.0),
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: CustomPaint(
                          painter: ChatBubblePainter(
                              color: Colors.blue,
                              alignment: Alignment.topRight,
                              tail: true,
                              text: ""),
                          child: ListenableBuilder(
                              listenable: _controller,
                              builder: (BuildContext context, Widget? child) =>
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              .7,
                                    ),
                                    margin:
                                        const EdgeInsets.fromLTRB(17, 7, 20, 7),
                                    child: TimestampedChatMessage(
                                      text: _controller.text == ""
                                          ? "    "
                                          : _controller.text,
                                      sentAt: "",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )),
                        )),
                  );
                })),
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: TextField(
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }
}
