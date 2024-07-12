import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    _controller.text = "";
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
                    child: SizedBox(
                      width: 100,
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: CustomPaint(
                            painter: ChatBubblePainter(
                                color: Colors.blue,
                                alignment: Alignment.topRight,
                                tail: true,
                                radius: _controller.text == "" ? 12 : 15,
                                text: ""),
                            child: ListenableBuilder(
                                listenable: _controller,
                                builder: (BuildContext context,
                                        Widget? child) =>
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                .7,
                                      ),
                                      margin: const EdgeInsets.fromLTRB(
                                          17, 7, 40, 7),
                                      child: TimestampedChatMessage(
                                        text: _controller.text == ""
                                            ? "  "
                                            : _controller.text,
                                        sentAt: "",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    )),
                          )),
                    ),
                  );
                })),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
              child: Row(children: [
                const Icon(
                  CupertinoIcons.camera_fill,
                  size: 35,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    height: 35,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: SvgPicture.asset(
                      "assets/appstore.svg",
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoTextField(
                    controller: _controller,
                    placeholder: " iMessage",
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey.withOpacity(0.5), width: 2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(17))),
                  ),
                ),
              ])),
        ],
      ),
    );
  }
}
