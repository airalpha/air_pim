import 'package:air_pmi/BaseModel.dart';

class Appointment {
  int id;
  String title;
  String description;
  String apptTime;
  String apptDate;
}

class AppointmentsModel extends BaseModel {
  String apptTime;

  void setApptTime(String inApptTime) {
    apptTime = inApptTime;
    notifyListeners();
  }
}

AppointmentsModel appointmentsModel = AppointmentsModel();