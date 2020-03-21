import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "tasks_db_worker.dart";
import "tasks_list.dart";
import "tasks_entry.dart";
import "tasks_model.dart" show TasksModel, tasksModel;

class Tasks extends StatelessWidget {
  Tasks() {
    tasksModel.loadData("tasks", TasksDBWorker.db);
  }

  Widget build(BuildContext inContext) {
    return ScopedModel<TasksModel> (
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext inContext, Widget inChild, TasksModel inModel) {
          return IndexedStack(
            index: inModel.stackIndex,
            children: <Widget>[
              TasksList(),
              TasksEntry()
            ],
          );
        },
      ),
    );
  }
}
