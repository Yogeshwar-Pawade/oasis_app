import 'db_helper.dart';

Map<String, dynamic> parseToTaskJson(Map<String, dynamic> params) {
  return {
    "title": params["task_name"],
    "dueDate": params["task_duedate"] ?? "",
    "status": "pending" // Default status for new tasks
  };
}

void handleTaskOperation(Map<String, dynamic> input, user) {
  // Extract operation type and task object
  String? operationType = input['operation_type'];
  if (operationType == null) {
    print('Operation type is required.');
    return;
  }
  Map<String, dynamic> taskObject = parseToTaskJson(input['task_object']);
  final DBHelper _dbHelper = DBHelper();

  // Call appropriate function based on operation type
  switch (operationType) {
    case 'create':
      _dbHelper.addTask(taskObject, user);
      print("Task added: ${taskObject['title']}");
      break;
    case 'update':
      taskObject['status'] = 'completed';
      _dbHelper.updateTaskByTitle(taskObject);
      print("Task updated: ${taskObject['title']}");
      break;
    case 'delete':
      _dbHelper.deleteTaskByTitle(taskObject['title']);
      print("Deleting task with id: ${taskObject['title']}");
      // _dbHelper(taskObject);
      break;
    default:
      print('Invalid operation type: $operationType');
  }
}
