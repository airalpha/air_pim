import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../utils.dart" as utils;
import "contacts_model.dart";

class ContactsDBWorker {
  ContactsDBWorker._();

  static final ContactsDBWorker db = ContactsDBWorker._();

  Database _db;

  Future<Database> init() async {
    String path = join(utils.docsDir.path, "contacts.db");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
          await inDB.execute("CREATE TABLE IF NOT EXISTS contacts ("
              "id INTEGER PRIMARY KEY, name TEXT,"
              "email TEXT, phone TEXT"
              ")");
        });
    return db;
  }

  Future get database async {
    if (_db == null) _db = await init();

    return _db;
  }

  Contact contactFromMap(Map map) {
    Contact contact = Contact();
    contact.id = map['id'];
    contact.name = map['name'];
    contact.phone = map['phone'];
    contact.email = map['email'];

    return contact;
  }

  Map<String, dynamic> contactToMap(Contact contact) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = contact.id;
    map['name'] = contact.name;
    map['phone'] = contact.phone;
    map['email'] = contact.email;

    return map;
  }

  Future create(Contact contact) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM contacts");
    int id = val.first['id'];
    if (id == null) id = 1;
    return await db.rawInsert(
        "INSERT INTO contacts (id, name, phone, email)"
            "VALUES (?, ?, ?, ?)",
        [
          id,
          contact.name,
          contact.phone,
          contact.email
        ]);
  }

  Future<Contact> get(int id) async {
    Database db = await database;
    var req = await db.query("contacts", where: "id = ?", whereArgs: [id]);

    return contactFromMap(req.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var reqs = await db.query("contacts");
    var list =
    reqs.isNotEmpty ? reqs.map((m) => contactFromMap(m)).toList() : [];

    return list;
  }

  Future update(Contact contact) async {
    Database db = await database;

    return await db.update("contacts", contactToMap(contact),
        where: "id = ?", whereArgs: [contact.id]);
  }

  Future delete(int id) async {
    Database db = await database;
    return await  db.delete(
        "contacts",
        where: "id = ?",
        whereArgs: [id]
    );
  }

}
