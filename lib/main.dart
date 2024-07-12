import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'ui/screens/home.dart';
import 'ui/widgets/chat_message_widget.dart';

void main() {
  runApp(const MyApp());
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
