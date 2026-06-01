import 'package:flutter/material.dart';

class category_card extends StatefulWidget {
  const category_card({super.key});

  @override
  State<category_card> createState() => _category_cardState();
}

class _category_cardState extends State<category_card> {
  @override
  Widget build(BuildContext context) {
    return Container(height: 30, width: 60, color: Colors.amber);
  }
}
