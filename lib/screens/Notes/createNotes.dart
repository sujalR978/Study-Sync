import 'package:flutter/material.dart';

class Createnotes extends StatefulWidget {
  const Createnotes({super.key});

  @override
  State<Createnotes> createState() => _CreatenotesState();
}

class _CreatenotesState extends State<Createnotes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back_ios)),

        title: Center(
          child: Text('Notes', style: TextStyle(fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
