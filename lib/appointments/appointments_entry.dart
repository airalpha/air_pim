import 'dart:math';

import 'package:air_pmi/appointments/appointments_db_worker.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'appointments_model.dart' show AppointmentsModel, appointmentsModel;
import '../utils.dart' as utils;

class AppointmentsEntry extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntry() {
    _titleController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleController.text;
    });

    _descriptionController.addListener(() {
      appointmentsModel.entityBeingEdited.description = _descriptionController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget inChild, AppointmentsModel inModel) {
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
                        if(value.length == 0)
                          return "Entrer le titre";
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      decoration: InputDecoration(hintText: "Description"),
                      controller: _descriptionController,
                      validator: (String value) {
                        if(value.length == 0)
                          return "Entrer la description";
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text("Date"),
                    subtitle: Text(
                      appointmentsModel.chosenDate == null ? "" : appointmentsModel.chosenDate
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String choosenDate = await utils.selectDate(inContext, appointmentsModel, appointmentsModel.entityBeingEdited.apptDate);
                        if(choosenDate != null)
                          appointmentsModel.entityBeingEdited.apptDate = choosenDate;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.alarm),
                    title: Text("Heure"),
                    subtitle: Text(
                        appointmentsModel.apptTime == null ? "" : appointmentsModel.apptTime
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () => _seletTime(inContext),
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
                    child: Text("Annuler"),
                    onPressed: () {
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  FlatButton(
                    color: Colors.green,
                    textColor: Colors.white,
                    child: (appointmentsModel.entityBeingEdited.id == null) ? Text("Ajouter") : Text("Modifier"),
                    onPressed: () {
                      _save(inContext, appointmentsModel);
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

  _seletTime(BuildContext inContext) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if(appointmentsModel.entityBeingEdited.apptTime != null) {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
      initialTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1])
      );
    }

    TimeOfDay picked = await showTimePicker(context: inContext, initialTime: initialTime);

    if(picked != null) {
      appointmentsModel.entityBeingEdited.apptTime = "${picked.hour},${picked.minute}";
      appointmentsModel.setApptTime(picked.format(inContext));
    }
  }

  void _save(BuildContext inContext, AppointmentsModel appointmentsModel) async {
    if(!_formKey.currentState.validate())
      return;
    if(appointmentsModel.entityBeingEdited.id == null) {
      await AppointMentsDBWorker.db.create(
        appointmentsModel.entityBeingEdited
      );
    } else {
      await AppointMentsDBWorker.db.update(
        appointmentsModel.entityBeingEdited
      );
    }
    appointmentsModel.loadData("appointments", AppointMentsDBWorker.db);
    appointmentsModel.setStackIndex(0);
    Scaffold.of(inContext).showSnackBar(
        SnackBar(
            backgroundColor : Colors.green,
            duration : Duration(seconds : 2),
            content : (appointmentsModel.entityBeingEdited.id == null) ? Text("Rendez-vous ajouté !") : Text("Rendez-vous Modifié !")
        )
    );
  }
}
