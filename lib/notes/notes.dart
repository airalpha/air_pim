import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "notes_db_worker.dart";
import "notes_list.dart";
import "notes_entry.dart";
import "notes_model.dart" show NotesModel, notesModel;

class Notes extends StatelessWidget {
  Notes() {
    notesModel.loadData("notes", NotesDBWorker.db);
  }

  Widget build(BuildContext inContext) {
    return ScopedModel<NotesModel> (
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (BuildContext inContext, Widget inChild, NotesModel inModel) {
          return IndexedStack(
            index: inModel.stackIndex,
            children: <Widget>[
              NotesList(),
              NotesEntry()
            ],
          );
        },
      ),
    );
  }
}
