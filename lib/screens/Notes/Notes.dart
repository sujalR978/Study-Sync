import 'package:flutter/material.dart';
import 'package:study_sync/screens/BottomNavigation.dart';
import 'package:study_sync/screens/Notes/createNotes.dart';
import 'package:study_sync/services/Notes_service.dart';


class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => Bottomnavigation()));
          },
          icon: Icon(Icons.arrow_back_ios),
        ),

        title: Padding(
          padding: const EdgeInsets.only(left: 110),
          child: Text('Notes', style: TextStyle(fontWeight: FontWeight.w500)),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => Createnotes()));
        },
        child: Icon(Icons.add),
      ),

      body: SafeArea(child: Column(
        children: [
          StreamBuilder(stream: NotesService().getNotes(), builder: (context,index){
            
          })
        ],
      )),
    );
  }
}
