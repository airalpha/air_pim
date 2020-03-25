import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../utils.dart" as utils;
import "appointments_model.dart";

class AppointMentsDBWorker {
  AppointMentsDBWorker._();

  static final AppointMentsDBWorker db = AppointMentsDBWorker._();

  Database _db;

  Future<Database> init() async {
    String path = join(utils.docsDir.path, "appointments.db");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
      await inDB.execute("CREATE TABLE IF NOT EXISTS appointments ("
          "id INTEGER PRIMARY KEY, title TEXT,"
          "description TEXT, apptDate TEXT, apptTime TEXT"
          ")");
    });
    return db;
  }

  Future get database async {
    if (_db == null) _db = await init();

    return _db;
  }

  Appointment appointmentFromMap(Map map) {
    Appointment appointMent = Appointment();
    appointMent.id = map['id'];
    appointMent.title = map['title'];
    appointMent.description = map['description'];
    appointMent.apptTime = map['apptTime'];
    appointMent.apptDate = map['apptDate'];

    return appointMent;
  }

  Map<String, dynamic> appointmentToMap(Appointment appointment) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = appointment.id;
    map['title'] = appointment.title;
    map['description'] = appointment.description;
    map['apptDate'] = appointment.apptDate;
    map['apptTime'] = appointment.apptTime;

    return map;
  }

  Future create(Appointment appointment) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM appointments");
    int id = val.first['id'];
    if (id == null) id = 1;
    return await db.rawInsert(
        "INSERT INTO appointments (id, title, description, apptTime, apptDate)"
        "VALUES (?, ?, ?, ?, ?)",
        [
          id,
          appointment.title,
          appointment.description,
          appointment.apptTime,
          appointment.apptDate
        ]);
  }

  Future<Appointment> get(int id) async {
    Database db = await database;
    var req = await db.query("appointments", where: "id = ?", whereArgs: [id]);

    return appointmentFromMap(req.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var reqs = await db.query("appointments");
    var list =
        reqs.isNotEmpty ? reqs.map((m) => appointmentFromMap(m)).toList() : [];

    return list;
  }

  Future update(Appointment appointment) async {
    Database db = await database;

    return await db.update("notes", appointmentToMap(appointment),
        where: "id = ?", whereArgs: [appointment.id]);
  }

  Future delete(int id) async {
    Database db = await database;
    return await  db.delete(
      "appointments",
      where: "id = ?",
      whereArgs: [id]
    );
  }

}
