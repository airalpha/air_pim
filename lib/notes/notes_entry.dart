import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "notes_db_worker.dart";
import "notes_model.dart" show NotesModel, notesModel;

class NotesEntry extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NotesEntry() {
    _titleController.addListener(() {
      notesModel.entityBeingEdited.title = _titleController.text;
    });

    _contentController.addListener((){
      notesModel.entityBeingEdited.content = _contentController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(notesModel.entityBeingEdited != null) {
      _titleController.text = notesModel.entityBeingEdited.title;
      _contentController.text = notesModel.entityBeingEdited.content;
    }

    return ScopedModel(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (BuildContext inContext, Widget inChild, NotesModel inModel){
          return Scaffold(
            body: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.title),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Titre"),
                      controller: _titleController,
                      validator: (String value) {
                        if(value.length == 0) {
                          return "Entrer le titre";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.content_paste),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      decoration: InputDecoration(hintText: "Content"),
                      controller: _contentController,
                      validator: (String value) {
                        if(value.length == 0) {
                          return "Entrer le contenu";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.color_lens),
                    title: Container(
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            child: Container(
                              decoration: ShapeDecoration(
                                shape: Border.all(width: 18, color: Colors.red) +
                                  Border.all(
                                    width: 6,
                                    color: notesModel.color == "red" ? Colors.red : Theme.of(inContext).canvasColor
                                  )
                              ),
                            ),
                            onTap: () {
                              notesModel.entityBeingEdited.color = "red";
                              notesModel.setColor("red");
                            },
                          ),
                          Spacer(),
                          GestureDetector(
                            child: Container(
                              decoration: ShapeDecoration(
                                  shape: Border.all(width: 18, color: Colors.green) +
                                      Border.all(
                                          width: 6,
                                          color: notesModel.color == "green" ? Colors.green : Theme.of(inContext).canvasColor
                                      )
                              ),
                            ),
                            onTap: () {
                              notesModel.entityBeingEdited.color = "green";
                              notesModel.setColor("green");
                            },
                          ),
                          Spacer(),
                          GestureDetector(
                            child: Container(
                              decoration: ShapeDecoration(
                                  shape: Border.all(width: 18, color: Colors.blue) +
                                      Border.all(
                                          width: 6,
                                          color: notesModel.color == "blue" ? Colors.blue : Theme.of(inContext).canvasColor
                                      )
                              ),
                            ),
                            onTap: () {
                              notesModel.entityBeingEdited.color = "blue";
                              notesModel.setColor("blue");
                            },
                          ),
                          Spacer(),
                          GestureDetector(
                            child: Container(
                              decoration: ShapeDecoration(
                                  shape: Border.all(width: 18, color: Colors.yellow) +
                                      Border.all(
                                          width: 6,
                                          color: notesModel.color == "yellow" ? Colors.yellow : Theme.of(inContext).canvasColor
                                      )
                              ),
                            ),
                            onTap: () {
                              notesModel.entityBeingEdited.color = "yellow";
                              notesModel.setColor("yellow");
                            },
                          ),
                          Spacer(),
                          GestureDetector(
                            child: Container(
                              decoration: ShapeDecoration(
                                  shape: Border.all(width: 18, color: Colors.grey) +
                                      Border.all(
                                          width: 6,
                                          color: notesModel.color == "grey" ? Colors.grey : Theme.of(inContext).canvasColor
                                      )
                              ),
                            ),
                            onTap: () {
                              notesModel.entityBeingEdited.color = "grey";
                              notesModel.setColor("grey");
                            },
                          ),
                          Spacer(),
                          GestureDetector(
                            child: Container(
                              decoration: ShapeDecoration(
                                  shape: Border.all(width: 18, color: Colors.purple) +
                                      Border.all(
                                          width: 6,
                                          color: notesModel.color == "purple" ? Colors.purple : Theme.of(inContext).canvasColor
                                      )
                              ),
                            ),
                            onTap: () {
                              notesModel.entityBeingEdited.color = "purple";
                              notesModel.setColor("purple");
                            },
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: <Widget>[
                  FlatButton(
                    color: Colors.red,
                    textColor: Colors.white,
                    child: Text("Anuler"),
                    onPressed: () {
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  FlatButton(
                    color: Colors.green,
                    textColor: Colors.white,
                    child: (inModel.entityBeingEdited.id == null) ? Text("Ajouter") : Text("Modifier"),
                    onPressed: () {
                      _save(inContext, notesModel);
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _save(BuildContext inContext, NotesModel inModel) async {
    if (!_formKey.currentState.validate()) { return; }
    if (inModel.entityBeingEdited.id == null) {
      await NotesDBWorker.db.create(
          notesModel.entityBeingEdited
      );
    } else {
      await NotesDBWorker.db.update(
          notesModel.entityBeingEdited
      );
    }
    notesModel.loadData("notes", NotesDBWorker.db);
    inModel.setStackIndex(0);
    Scaffold.of(inContext).showSnackBar(
        SnackBar(
            backgroundColor : Colors.green,
            duration : Duration(seconds : 2),
            content : (inModel.entityBeingEdited.id == null) ? Text("Note ajoutée !") : Text("Note Modifiée !")
        )
    );
  }
}
