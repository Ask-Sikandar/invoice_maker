import 'package:flutter/material.dart';

class HomePageIconButtons extends StatefulWidget {
  const HomePageIconButtons({super.key, required this.onPressed, required this.icon, required this.label });
  final void Function()? onPressed;
  final Icon icon;
  final String label;

  @override
  State<HomePageIconButtons> createState() => _HomePageIconButtonsState();
}

class _HomePageIconButtonsState extends State<HomePageIconButtons> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(onPressed: widget.onPressed, icon: widget.icon, iconSize: 70,),
        Text(widget.label)
      ],
    );
  }
}