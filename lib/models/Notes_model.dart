class NotesModel {
  final String title;
  final String body;
  final int id;
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
