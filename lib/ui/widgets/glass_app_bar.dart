import 'dart:ui';
import 'package:flutter/material.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final double? toolBarHeight;

  final List<Widget> actions;
  final Widget? leading;

  GlassAppBar(
      {super.key,
      required this.title,
      this.toolBarHeight,
      this.leading,
      this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: key,
      child: Container(
        decoration: BoxDecoration(
          color:
              Color(0xff121212).withOpacity(0.3), // semi-transparent background
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AppBar(
            backgroundColor:
                Colors.transparent, // set background to transparent
            elevation: 0.0,
            toolbarHeight: toolBarHeight,
            leading: leading,
            title: title,
            actions: actions,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 30);
}
