class Task {
  final int id;
  final String title;
  final String status;
  final String? dueDate;

  Task({
    required this.id,
    required this.title,
    required this.status,
    this.dueDate,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      status: map['status'],
      dueDate: map['dueDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'dueDate': dueDate,
    };
  }
}