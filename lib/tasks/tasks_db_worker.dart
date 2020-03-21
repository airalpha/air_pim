import 'package:air_pmi/tasks/tasks_model.dart';
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../utils.dart" as utils;


class TasksDBWorker {
  TasksDBWorker._();

  static final TasksDBWorker db = TasksDBWorker._();

  Database _db;

  Future<Database> init() async {
    String path = join(utils.docsDir.path, "tasks.db");
    Database db = await openDatabase(
        path,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
          await inDB.execute(
              "CREATE TABLE IF NOT EXISTS tasks ("
                  "id INTEGER PRIMARY KEY,"
                  "description TEXT,"
                  "dueDate TEXT,"
                  "completed TEXT"
                  ")"
          );
        }
    );
    return db;
  }

  Future get database async {
    if(_db == null) {
      _db = await init();
    }
    return _db;
  }

  Task taskFromMap(Map map) {
    Task task = Task();
    task.id = map['id'];
    task.description = map['description'];
    task.dueDate = map['dueDate'];
    task.completed = map['completed'];

    return task;
  }

  Map<String, dynamic> taskToMap(Task task) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = task.id;
    map['description'] = task.description;
    map['dueDate'] = task.dueDate;
    map['completed'] = task.completed;

    return map;
  }

  Future create(Task task) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM tasks");
    int id = val.first['id'];
    if(id == null)
      id = 1;
    return await db.rawInsert(
        "INSERT INTO Tasks (id, description, dueDate, completed)"
            "VALUES (?,?,?,?)",
        [id, task.description, task.dueDate, task.completed]
    );
  }

  Future<Task> get(int id) async {
    Database db = await database;
    var req = await db.query(
        "Tasks",
        where: "id = ?",
        whereArgs: [id]
    );

    return taskFromMap(req.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var reqs = await db.query("Tasks");
    var list = reqs.isNotEmpty ? reqs.map((m) => taskFromMap(m)).toList() : [ ];

    return list;
  }

  Future update(Task task) async {
    Database db = await database;

    return await db.update(
        "Tasks", taskToMap(task), where: "id = ?", whereArgs: [task.id]
    );
  }

  Future delete(int id) async {
    Database db = await database;
    return await db.delete(
        "Tasks", where : "id = ?", whereArgs : [ id ]
    );
  }

}
