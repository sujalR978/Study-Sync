class NotesModel {
  final String title;
  final String body;
  final String id;
  final int order;

  NotesModel({
    required this.title,
    required this.body,
    required this.id,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {'title': title, 'body': body, 'id': id, 'order': order};
  }
}

class EditNotesModel {
  final String body;
  final String title;

  EditNotesModel({required this.title, required this.body});s

  Map<String, dynamic> toMap() {
    return {'title': title, 'body': body};
  }
}
