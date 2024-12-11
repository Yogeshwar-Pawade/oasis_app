import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 2, // Incremented version
      onCreate: (db, version) async {
        // Create the tasks table
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user TEXT,
            title TEXT,
            dueDate TEXT,
            status TEXT
          )
        ''');
        // Create the chat_messages table
        await db.execute('''
          CREATE TABLE chat_messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user TEXT,
            sender TEXT,
            message TEXT,
            timestamp TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS chat_messages (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user TEXT,
              sender TEXT,
              message TEXT,
              timestamp TEXT
            )
          ''');
        }
      },
    );
  }

  // Add task
  Future<bool> addTask(Map<String, dynamic> taskData , user) async {
    try {
      final db = await DBHelper().database;
      print("Inserting task data:");
      taskData["user"] = user;
      print(taskData);

      final id = await db.insert('tasks', taskData);
      if (id > 0) {
        // Insertion successful
        print("Task inserted with id: $id");
        return true;
      } else {
        // Insertion failed (unlikely with SQLite, but good to check)
        print("Insertion failed. ID is $id.");
        return false;
      }
    } catch (e) {
      // Handle errors gracefully
      print("Error during insertion: $e");
      return false;
    }
  }

  // Add a chat message
  Future<int> addChatMessage(Map<String, dynamic> messageData , user) async {
    final db = await DBHelper().database;
    messageData["user"] = user;
    return await db.insert('chat_messages', messageData);
  }

  // Retrieve chat messages
Future<List<Map<String, dynamic>>> getChatMessages(String user) async {
  final db = await DBHelper().database;
  return await db.query(
    'chat_messages',
    where: 'user = ?', // Add a WHERE clause to filter by user
    whereArgs: [user], // Provide the user value to replace the ? placeholder
    orderBy: 'timestamp ASC', // Keep ordering by timestamp
  );
}

  // Update a task
  Future<int> updateTask(Map<String, dynamic> taskData) async {
    final db = await DBHelper().database;
    return await db.update(
      'tasks',
      taskData,
      where: 'id = ?',
      whereArgs: [taskData['id']],
    );
  }

  Future<bool> updateTaskByTitle(Map<String, dynamic> taskData) async {
    try {
      final db = await DBHelper().database;

      final rowsAffected = await db.update(
        'tasks',
        taskData,
        where: 'title = ?',
        whereArgs: [taskData['title']],
      );

      if (rowsAffected > 0) {
        // Update was successful
        print("Task updated successfully. Rows affected: $rowsAffected");
        return true;
      } else {
        // No rows were updated (e.g., invalid title)
        print("No rows were updated. Title might not exist.");
        return false;
      }
    } catch (e) {
      // Handle errors gracefully
      print("Error during update: $e");
      return false;
    }
  }

  // Delete a task
  Future<int> deleteTask(int taskId) async {
    final db = await DBHelper().database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  Future<bool> deleteTaskByTitle(String title) async {
    try {
      final db = await DBHelper().database;

      final rowsDeleted = await db.delete(
        'tasks',
        where: 'title = ?',
        whereArgs: [title],
      );

      if (rowsDeleted > 0) {
        // Deletion successful
        print("Task deleted successfully. Rows deleted: $rowsDeleted");
        return true;
      } else {
        // No rows deleted (e.g., title not found)
        print("No rows deleted. Title might not exist.");
        return false;
      }
    } catch (e) {
      // Handle errors gracefully
      print("Error during deletion: $e");
      return false;
    }
  }

  // Retrieve tasks by status
Future<List<Map<String, dynamic>>> getTasksByStatus(String status, String username) async {
  final db = await DBHelper().database;
  return await db.query(
    'tasks', 
    where: 'status = ? AND user = ?', // Add username to the WHERE clause
    whereArgs: [status, username], // Pass both status and username
  );
}
  // Clear all tasks
  Future<void> clearAllTasks() async {
    final db = await DBHelper().database;
    await db.delete('tasks');
  }

  // Clear all chat messages
  Future<void> clearAllChatMessages() async {
    final db = await DBHelper().database;
    await db.delete('chat_messages');
  }

  // Clear tasks by status
  Future<void> clearTasksByStatus(String status) async {
    final db = await DBHelper().database;
    await db.delete(
      'tasks',
      where: 'status = ?',
      whereArgs: [status],
    );
  }
}
