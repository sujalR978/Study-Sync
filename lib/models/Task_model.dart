class TaskModel {
  String id;
  String title;
  String description;
  String category;
  String priority;
  DateTime dueDate;
  String dueTime;

  bool isCompleted;
  int order;

  DateTime createdAt;
  DateTime updatedAt;
  TaskModel({ 
    required this.id,

    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    required this.dueTime,
    required this.isCompleted,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> TaskMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'isCompleted': isCompleted,
      'order': order,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class updateTaskModel {
  String title;
  String description;
  String category;
  String priority;
  DateTime dueDate;
  String dueTime;

  DateTime updatedAt;

  updateTaskModel({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    required this.dueTime,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'updatedAt': updatedAt,
    };
  }
}
