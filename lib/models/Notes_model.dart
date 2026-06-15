class NotesModel {
  final String title;
  final String body;

  NotesModel({required this.title, required this.body});

  Map<String, String> toMap() {
    return {'title': title, 'body': body};
  }
}
