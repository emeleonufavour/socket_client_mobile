import 'package:flutter/material.dart';

extension StateHelpers<T extends StatefulWidget> on State<T> {
  void setStateSafely(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }
}
