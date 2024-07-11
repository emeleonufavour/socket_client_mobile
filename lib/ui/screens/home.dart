import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socket_client/ui/widgets/chat_bubble.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});
  final TextEditingController _controller = TextEditingController();

  List<Widget> chats = [
    // const Align(
    //     alignment: Alignment.centerRight,
    //     child: ChatBubbleWidget(
    //       text: "Hello",
    //       sender: true,
    //       tail: true,
    //     )),
    // Align(
    //   alignment: Alignment.centerRight,
    //   child: Container(
    //     color: Colors.red,
    //     child: Padding(
    //         padding: EdgeInsets.all(10),
    //         child: ChatBubbleWidget(
    //           text: "Hola",
    //           sender: true,
    //           tail: true,
    //         )),
    //   ),
    // ),
  ];
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
                  return Align(
                      alignment: Alignment.centerRight,
                      child: ListenableBuilder(
                        listenable: _controller,
                        builder: (BuildContext context, Widget? child) =>
                            ChatBubbleWidget(
                          text: _controller.text,
                          sentAt: "2:45 PM",
                          sender: true,
                          tail: false,
                        ),
                      ));
                })),
          ),
        ],
      ),
    );
  }
}
