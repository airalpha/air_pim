import 'package:air_pmi/tasks/tasks_db_worker.dart';
import 'package:air_pmi/tasks/tasks_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'tasks_model.dart' show tasksModel, TasksModel, Task;

class TasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<TasksModel>(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
          builder:
              (BuildContext inContext, Widget inChild, TasksModel inModel) {
            return inModel.isLoading ? inModel.buildLoading() : Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  tasksModel.entityBeingEdited = Task();
                  tasksModel.setStackIndex(1);
                },
              ),
              body: tasksModel.entityList.isEmpty
                  ? inModel.buildNoContent(inContext, "Aucune tache")
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      itemCount: tasksModel.entityList.length,
                      itemBuilder: (BuildContext context, int index) {
                        Task task = tasksModel.entityList[index];
                        String sDueDate;
                        String description;
                        try {
                          description = "${task.description.substring(0, 25)} ...";
                        } catch (e){
                          description = task.description;
                        }
                        if (task.dueDate != null) {
                          List dateParts = task.dueDate.split(",");
                          DateTime dueDate = DateTime(int.parse(dateParts[0]),
                              int.parse(dateParts[1]), int.parse(dateParts[2]));
                          sDueDate = DateFormat.yMMMMd("en_US")
                              .format(dueDate.toLocal());
                        }
                        return Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: .25,
                          child: ListTile(
                            leading: Checkbox(
                              value: task.completed == "true" ? true : false,
                              onChanged: (value) async {
                                task.completed = value.toString();
                                await TasksDBWorker.db.update(task);
                                tasksModel.loadData("tasks", TasksDBWorker.db);
                              },
                            ),
                            title: Text(
                              "${description}",
                              style: task.completed == 'true'
                                  ? TextStyle(
                                      color: Theme.of(inContext).disabledColor,
                                      decoration: TextDecoration.lineThrough)
                                  : TextStyle(
                                      color: Theme.of(inContext)
                                          .textTheme
                                          .title
                                          .color),
                            ),
                            onTap: () async {
                              if (task.completed == "true") {
                                return;
                              }
                              tasksModel.entityBeingEdited =
                                  await TasksDBWorker.db.get(task.id);
                              if (tasksModel.entityBeingEdited.dueDate ==
                                  null) {
                                tasksModel.setChosenDate(null);
                              } else {
                                tasksModel.setChosenDate(sDueDate);
                              }
                              tasksModel.setStackIndex(1);
                            },
                          ),
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              icon: Icons.delete,
                              caption: "Supprimer",
                              color: Colors.red,
                              onTap: () => _deleteTask(inContext, task),
                            )
                          ],
                        );
                      },
                    ),
            );
          },
        ));
  }

  _deleteTask(BuildContext inContext, Task task) {
    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Supprimer la tache"),
            content: Text("Voulez vous supprimer cette tache ?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Annuler"),
                textColor: Colors.green,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Supprimer"),
                textColor: Colors.red,
                onPressed: () async {
                  await TasksDBWorker.db.delete(task.id);
                  Navigator.of(context).pop();
                  Scaffold.of(inContext).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Tache supprimer !"),
                  ));
                  tasksModel.loadData("tasks", TasksDBWorker.db);
                },
              )
            ],
          );
        });
  }
}
