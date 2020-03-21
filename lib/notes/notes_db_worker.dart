import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../utils.dart" as utils;
import "notes_model.dart";

class NotesDBWorker {
  NotesDBWorker._();

  static final NotesDBWorker db = NotesDBWorker._();

  Database _db;

  Future<Database> init() async {
    String path = join(utils.docsDir.path, "notes.db");
    Database db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database inDB, int inVersion) async {
        await inDB.execute(
            "CREATE TABLE IF NOT EXISTS notes ("
                "id INTEGER PRIMARY KEY,"
                "title TEXT,"
                "content TEXT,"
                "color TEXT"
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

  Note noteFromMap(Map map) {
    Note note = Note();
    note.id = map['id'];
    note.title = map['title'];
    note.content = map['content'];
    note.color = map['color'];

    return note;
  }

  Map<String, dynamic> noteToMap(Note note) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = note.id;
    map['title'] = note.title;
    map['content'] = note.content;
    map['color'] = note.color;

    return map;
  }

  Future create(Note note) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM notes");
    int id = val.first['id'];
    if(id == null)
      id = 1;
    return await db.rawInsert(
      "INSERT INTO notes (id, title, content, color)"
          "VALUES (?,?,?,?)",
      [id, note.title, note.content, note.color]
    );
  }

  Future<Note> get(int id) async {
    Database db = await database;
    var req = await db.query(
      "notes",
      where: "id = ?",
      whereArgs: [id]
    );

    return noteFromMap(req.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var reqs = await db.query("notes");
    var list = reqs.isNotEmpty ? reqs.map((m) => noteFromMap(m)).toList() : [ ];

    return list;
  }

  Future update(Note note) async {
    Database db = await database;

    return await db.update(
        "notes", noteToMap(note), where: "id = ?", whereArgs: [note.id]
    );
  }

  Future delete(int id) async {
    Database db = await database;
    return await db.delete(
        "notes", where : "id = ?", whereArgs : [ id ]
    );
  }

}
