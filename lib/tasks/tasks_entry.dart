import 'package:air_pmi/tasks/tasks_db_worker.dart';
import 'package:air_pmi/tasks/tasks_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import "../utils.dart" as utils;

class TasksEntry extends StatelessWidget {
  final TextEditingController _descriptionController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry() {
    _descriptionController.addListener(() {
      tasksModel.entityBeingEdited.description = _descriptionController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(tasksModel.entityBeingEdited != null)
      _descriptionController.text = tasksModel.entityBeingEdited.description;

    return ScopedModel<TasksModel>(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext inContext, Widget inChild, TasksModel inModel) {
          return Scaffold(
            body: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.assignment),
                    title: TextFormField(
                      controller: _descriptionController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      decoration: InputDecoration(hintText: "Description"),
                      validator: (String value) {
                        if(value.length == 0){
                          return "Entrer une description";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text("Date de fin"),
                    subtitle: Text(
                      tasksModel.chosenDate == null ? "" : tasksModel.chosenDate
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String chosenDate = await utils.selectDate(
                          inContext, tasksModel, tasksModel.entityBeingEdited.dueDate);
                        if(chosenDate != null) {
                          tasksModel.entityBeingEdited.dueDate = chosenDate;
                        }
                      },
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
                      _save(inContext, tasksModel);
                    },
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _save(BuildContext inContext, TasksModel inModel) async {
    if (!_formKey.currentState.validate()) { return; }
    if (inModel.entityBeingEdited.id == null) {
      await TasksDBWorker.db.create(
          tasksModel.entityBeingEdited
      );
    } else {
      await TasksDBWorker.db.update(
          tasksModel.entityBeingEdited
      );
    }
    tasksModel.loadData("tasks", TasksDBWorker.db);
    inModel.setStackIndex(0);
    Scaffold.of(inContext).showSnackBar(
        SnackBar(
            backgroundColor : Colors.green,
            duration : Duration(seconds : 2),
            content : (inModel.entityBeingEdited.id == null) ? Text("Tache ajoutée !") : Text("Tache Modifiée !")
        )
    );
  }
}
