import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/db_helper.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String username;

  const TaskDetailsScreen({Key? key, required this.username}) : super(key: key);

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Task> _pendingTasks = [];
  List<Task> _completedTasks = [];
  bool _showCompletedTasks = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() async {
    List<Map<String, dynamic>> pendingTasksData =
        await _dbHelper.getTasksByStatus('pending', widget.username);
    List<Map<String, dynamic>> completedTasksData =
        await _dbHelper.getTasksByStatus('completed', widget.username);

    setState(() {
      _pendingTasks =
          pendingTasksData.map((data) => Task.fromMap(data)).toList();
      _completedTasks =
          completedTasksData.map((data) => Task.fromMap(data)).toList();
    });
  }

  void _updateTaskStatus(int id, String newStatus) async {
    await _dbHelper.updateTask({'id': id, 'status': newStatus});
    _fetchTasks();
  }

  void _deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    _fetchTasks();
  }

  void _clearCompletedTasks() async {
    await _dbHelper.clearTasksByStatus('completed');
    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'OASIS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showCompletedTasks = !_showCompletedTasks;
                });
              },
              child: Text(
                'Show Completed',
                style: TextStyle(
                  color: _showCompletedTasks ? Colors.blue : Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.black,
        child: _buildTaskList(),
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView(
      padding: EdgeInsets.all(12.0),
      children: [
        if (_pendingTasks.isNotEmpty)
          Text(
            'Reminders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ..._buildTaskSection(_pendingTasks, 'completed'),
        if (_showCompletedTasks && _completedTasks.isNotEmpty) ...[
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_completedTasks.length} Completed',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              GestureDetector(
                onTap: _clearCompletedTasks,
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          ..._buildTaskSection(_completedTasks, 'pending'),
        ],
      ],
    );
  }

  List<Widget> _buildTaskSection(List<Task> tasks, String newStatus) {
    const mediumGreyColor = Color(0xFF1C1C1E);

    return tasks.map((task) {
      return Dismissible(
        key: Key(task.id.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          _deleteTask(task.id);
        },
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),
        child: Column(
          children: [
            ListTile(
              tileColor: mediumGreyColor,
              leading: Radio<String>(
                value: newStatus,
                groupValue: task.status,
                onChanged: (value) {
                  if (value != null) _updateTaskStatus(task.id, value);
                },
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (task.status == newStatus) {
                      return Colors.orange;
                    }
                    return Colors.white;
                  },
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  if (task.dueDate != null && task.dueDate!.isNotEmpty)
                    Text(
                      task.dueDate!,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            Divider(
              color: mediumGreyColor,
              height: 1,
              thickness: 1,
              indent: 72,
            ),
          ],
        ),
      );
    }).toList();
  }
}