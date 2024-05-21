import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MyAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      // Add other properties as needed, such as actions, leading, etc.
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}