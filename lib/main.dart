import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_client/models/chat_bubble.dart';
import 'helper/double_linkedlist.dart';
import 'ui/screens/home/home.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => DoubleLinkedList<ChatBubble>(),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff147efb)),
        primaryColor: const Color(0xff147efb),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}
