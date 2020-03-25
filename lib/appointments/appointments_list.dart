import 'package:air_pmi/appointments/appointments_db_worker.dart';
import 'package:air_pmi/appointments/appointments_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

class AppointmentsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    EventList<Event> _markedDateMap = EventList();
    for (int i = 0; i < appointmentsModel.entityList.length; i++) {
      Appointment appointment = appointmentsModel.entityList[i];
      List dateParts = appointment.apptDate.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]),
          int.parse(dateParts[1]), int.parse(dateParts[2]));

      _markedDateMap.add(
          apptDate,
          Event(
              date: apptDate,
              icon: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(1000)),
                    border: Border.all(color: Colors.blue, width: 2.0)),
                child: Icon(
                  Icons.event_available,
                  color: Colors.amber,
                ),
              )
          )
      );
    }
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget inChild,
            AppointmentsModel inModel) {
          return inModel.isLoading ? inModel.buildLoading() : Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                appointmentsModel.entityBeingEdited = Appointment();
                DateTime now = DateTime.now();
                appointmentsModel.entityBeingEdited.apptDate =
                    "${now.year},${now.month},${now.day}";
                appointmentsModel.setChosenDate(
                    DateFormat.yMMMMd("en_US").format(now.toLocal()));
                appointmentsModel.setApptTime(null);
                appointmentsModel.setStackIndex(1);
              },
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: CalendarCarousel<Event>(
                            thisMonthDayBorderColor: Colors.blueGrey,
                            daysHaveCircularBorder: true,
                            markedDatesMap: _markedDateMap,
                            markedDateCustomShapeBorder: CircleBorder(
                                side: BorderSide(color: Colors.blue, width: 1.5)
                            ),
                            onDayPressed:
                                (DateTime inDate, List<Event> inEvents) {
                              _showAppointments(inDate, inContext);
                            })))
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAppointments(DateTime inDate, BuildContext inContext) async {
    debugPrint(_empty(inDate).toString());
    showModalBottomSheet(
        context: inContext,
        builder: (BuildContext inContext) {
          return ScopedModel<AppointmentsModel>(
            model: appointmentsModel,
            child: ScopedModelDescendant<AppointmentsModel>(
              builder: (BuildContext inContext, Widget inChild,
                  AppointmentsModel inModel) {
                return Scaffold(
                  body: Container(
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: GestureDetector(
                          child: Column(
                            children: <Widget>[
                              Text(
                                DateFormat.yMMMMd("en_US")
                                    .format(inDate.toLocal()),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Theme.of(inContext).accentColor,
                                    fontSize: 24),
                              ),
                              Divider(),
                              Expanded(
                                child: _empty(inDate) ? inModel.buildNoContent(inContext, "Pas de rendez-vous", height: 200.0, font_size: 30.0) : ListView.builder(
                                  itemCount: appointmentsModel.entityList.length,
                                  itemBuilder: (BuildContext inContext, int inIndex) {
                                    Appointment appointment =
                                        appointmentsModel.entityList[inIndex];
                                    if (appointment.apptDate !=
                                        "${inDate.year},${inDate.month},${inDate.day}")
                                      return Container(height: 0,);

                                    String apptTime = "";
                                    if (appointment.apptTime != null) {
                                      List timeParts =
                                          appointment.apptTime.split(",");
                                      TimeOfDay at = TimeOfDay(
                                          hour: int.parse(timeParts[0]),
                                          minute: int.parse(timeParts[1]));
                                      apptTime = " (${at.format(inContext)})";
                                    }

                                    return Slidable(
                                      actionPane: SlidableDrawerActionPane(),
                                      actionExtentRatio: .25,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        color: Colors.blue.shade500,
                                        child: ListTile(
                                          title: Text(
                                              "${appointment.title} $apptTime",
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: appointment.description ==
                                                  null
                                              ? null
                                              : Text(
                                                  "${appointment.description}",
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
                                          ),
                                          onTap: () async {
                                            _editAppointment(inContext, appointment);
                                          },
                                        ),
                                      ),
                                      secondaryActions: <Widget>[
                                        Container(
                                          child: IconSlideAction(
                                              caption: "Supprimer",
                                              color: Colors.red,
                                              icon: Icons.delete,
                                              onTap: () {
                                                _deleteAppointment(inContext, appointment);
                                              }),
                                          margin: EdgeInsets.only(bottom: 8),
                                        )
                                      ],
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  void _editAppointment(BuildContext inContext, Appointment appointment) async {
    appointmentsModel.entityBeingEdited = await AppointMentsDBWorker.db.get(appointment.id);
    if (appointmentsModel.entityBeingEdited.apptDate == null) {
      appointmentsModel.setChosenDate(null);
    } else {
      List dateParts =
      appointmentsModel.entityBeingEdited.apptDate.split(",");
      DateTime apptDate = DateTime(
          int.parse(dateParts[0]), int.parse(dateParts[1]),
          int.parse(dateParts[2]));

      appointmentsModel.setChosenDate(
          DateFormat.yMMMMd("en_US").format(apptDate.toLocal()));
    }
    if (appointmentsModel.entityBeingEdited.apptTime == null) {
      appointmentsModel.setApptTime(null);
    } else {
      List timeParts =
      appointmentsModel.entityBeingEdited.apptTime.split(",");
      TimeOfDay apptTime = TimeOfDay(
          hour : int.parse(timeParts[0]),
          minute : int.parse(timeParts[1]));
      appointmentsModel.setApptTime(apptTime.format(inContext));
    }
    appointmentsModel.setStackIndex(1);
    Navigator.pop(inContext);
  }

  _deleteAppointment(BuildContext inContext, Appointment appointment) {
    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Supprimer le rendez-vous"),
            content: Text("Voulez vous supprimer ce rendez-vous ?"),
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
                  await AppointMentsDBWorker.db.delete(appointment.id);
                  Navigator.of(context).pop();
                  Scaffold.of(inContext).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Rendez-vous supprimer !"),
                  ));
                  appointmentsModel.loadData("appointments", AppointMentsDBWorker.db);
                },
              )
            ],
          );
        });
  }

  _empty(DateTime inDate) {
    int count = 0;
    for (int i = 0; i < appointmentsModel.entityList.length; i++) {
      Appointment appointment = appointmentsModel.entityList[i];
      if (appointment.apptDate == "${inDate.year},${inDate.month},${inDate.day}") {
        count++;
      }
    }

    return count==0;
  }
}
