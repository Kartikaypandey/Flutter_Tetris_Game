import 'package:flutter/material.dart';

class Pixel extends StatelessWidget {
  final Color color;
  final int number;
  const Pixel({super.key, required this.color, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      margin: const EdgeInsets.all(1),
    );
  }
}
