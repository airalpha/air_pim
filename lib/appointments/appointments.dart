import 'package:air_pmi/appointments/appointments_db_worker.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'appointments_model.dart' show AppointmentsModel, appointmentsModel;
import 'appointments_entry.dart';
import 'appointments_list.dart';

class Appointments extends StatelessWidget {
  Appointments() {
    appointmentsModel.loadData("appointments", AppointMentsDBWorker.db);
  }

  @override
  Widget build(BuildContext inContext) {
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget inChild, AppointmentsModel inModel){
          return IndexedStack(
            index: inModel.stackIndex,
            children: <Widget>[
              AppointmentsList(),
              AppointmentsEntry()
            ],
          );
        },
      ),
    );
  }
}
