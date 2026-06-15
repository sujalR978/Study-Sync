import 'package:flutter/material.dart';
import 'package:study_sync/screens/Notes/Notes.dart';

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
        leading: IconButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => Notes()));
          },
          icon: Icon(Icons.arrow_back_ios),
        ),

        title: Padding(
          padding: const EdgeInsets.only(left: 110),
          child: Text(
            'Add Notes',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
