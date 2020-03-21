import 'package:air_pmi/BaseModel.dart';

class Task {
  int id;
  String description;
  String dueDate;
  String completed = "false";
}

class TasksModel extends BaseModel {

}

TasksModel tasksModel = TasksModel();
