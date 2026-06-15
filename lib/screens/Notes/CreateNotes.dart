import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_sync/screens/Notes/Notes.dart';
import 'package:study_sync/widgets/custom_textfield.dart';

class Createnotes extends StatefulWidget {
  const Createnotes({super.key});

  @override
  State<Createnotes> createState() => _CreatenotesState();
}

class _CreatenotesState extends State<Createnotes> {
  final TextEditingController notesName = TextEditingController();

  final TextEditingController notesBody = TextEditingController();
  final GlobalKey<FormState> KeyForm = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    notesBody.dispose();
    notesName.dispose();
    super.dispose();
  }

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
          padding: const EdgeInsets.only(left: 90),
          child: Text(
            'Add Notes',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: KeyForm,
              child: Column(
                children: [
                  CustomTextfield.customTextField(
                    hintText: 'Add Note Title...',
                    icon: Icons.note,
                    controller: notesName,
                    context: context,
                    valideter: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Add Notes title';
                      }
                      return null;
                    },
                    regex: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9a-zA-Z]')),
                    ],
                  ),
                  CustomTextfield.customTextField(
                    hintText: 'Add Note Body...',
                    icon: Icons.note,
                    controller: notesBody,
                    context: context,
                    valideter: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Add Notes title';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
