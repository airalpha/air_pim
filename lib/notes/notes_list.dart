import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "notes_db_worker.dart";
import "notes_model.dart" show Note, NotesModel, notesModel;

class NotesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (BuildContext inContext, Widget inChild, NotesModel inModel) {
          return inModel.isLoading ? inModel.buildLoading() : Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                notesModel.entityBeingEdited = Note();
                notesModel.setColor(null);
                notesModel.setStackIndex(1);
              },
            ),
            body: notesModel.entityList.isEmpty
                ? notesModel.buildNoContent(inContext, "Aucune note")
                : ListView.builder(
                    itemCount: notesModel.entityList.length,
                    itemBuilder: (BuildContext context, int index) {
                      Note note = notesModel.entityList[index];
                      String content;
                      try {
                        content = "${note.content.substring(0, 50)} ...";
                      } catch (e){
                        content = note.content;
                      }
                      Color color = Colors.white;
                      switch (note.color) {
                        case "red":
                          color = Colors.red;
                          break;
                        case "green":
                          color = Colors.green;
                          break;
                        case "blue":
                          color = Colors.blue;
                          break;
                        case "yellow":
                          color = Colors.yellow;
                          break;
                        case "grey":
                          color = Colors.grey;
                          break;
                        case "purple":
                          color = Colors.purple;
                          break;
                      }

                      return Container(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: .25,
                          secondaryActions: <Widget>[
                            Card(
                              color: Colors.red,
                              elevation: 8,
                              child: IconSlideAction(
                                closeOnTap: true,
                                caption: "Supprimer",
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () => _deleteNote(context, note),
                              ),
                            )
                          ],
                          child: Card(
                            elevation: 8,
                            shape: BeveledRectangleBorder(),
                            //color: color,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.event_note,
                                  color: color,
                                ),
                              ),
                              title: Text('${note.title}'),
                              subtitle: Text('$content'),
                              onTap: () async {
                                notesModel.entityBeingEdited =
                                    await NotesDBWorker.db.get(note.id);
                                notesModel.setColor(
                                    notesModel.entityBeingEdited.color);
                                notesModel.setStackIndex(1);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  Future _deleteNote(BuildContext inContext, Note note) {
    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Supprimer la note'),
            content: Text("Voulez vous supprimer cette note ?"),
            actions: <Widget>[
              FlatButton(
                child: Text('Annuler'),
                textColor: Colors.green,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Supprimer"),
                textColor: Colors.red,
                onPressed: () async {
                  await NotesDBWorker.db.delete(note.id);
                  Navigator.of(context).pop();
                  Scaffold.of(inContext).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Note supprimée !"),
                  ));
                  notesModel.loadData("notes", NotesDBWorker.db);
                },
              )
            ],
          );
        });
  }
}
