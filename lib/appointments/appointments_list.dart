import 'package:air_pmi/appointments/appointments_model.dart';
import 'package:flutter/material.dart';
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
                decoration: BoxDecoration(color: Colors.blue),
              )));
    }
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget inChild,
            AppointmentsModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                appointmentsModel.entityBeingEdited = Appointment();
                DateTime now = DateTime.now();
                appointmentsModel.entityBeingEdited.apptDate = "${now.year},${now.month},${now.day}";
                appointmentsModel.setChosenDate(DateFormat.yMMMMd("en_US").format(now.toLocal()));
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
                      onDayPressed:
                          (DateTime inDate, List<Event> inEvents) {
                        _showAppointments(inDate, inContext);
                      })
                  )
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAppointments(DateTime inDate, BuildContext inContext) async {
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
                              Text(DateFormat.yMMMMd("en_US").format(inDate.toLocal()),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(inContext).accentColor,
                                  fontSize: 24
                                ),
                              ),
                              Divider(),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: appointmentsModel.entityList.length,
                                  itemBuilder: (BuildContext inContext, int inIndex) {
                                    Appointment appointment = appointmentsModel.entityList[inIndex];
                                    if (appointment.apptDate != "${inDate.year},${inDate.month},${inDate.day}")
                                      return Container(child: Text("${inDate.toString()}"),);

                                    String apptTime = "";
                                    if (appointment.apptTime != null) {
                                      List timeParts = appointment.apptTime.split(",");
                                      TimeOfDay at = TimeOfDay(
                                        hour: int.parse(timeParts[0]),
                                        minute: int.parse(timeParts[1])
                                      );
                                      apptTime = " (${at.format(inContext)})";
                                    }

                                    return Slidable(
                                      actionPane: SlidableDrawerActionPane(),
                                      actionExtentRatio: .25,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        color: Colors.grey.shade300,
                                        child: ListTile(
                                          title: Text("${appointment.title} $apptTime"),
                                          subtitle: appointment.description ==
                                              null
                                              ? null
                                              : Text("${appointment.description}"),
                                          onTap: () async {
                                            //_editAppointment(inContext, appointment);
                                          },
                                        ),
                                      ),
                                      secondaryActions: <Widget>[
                                        IconSlideAction(
                                          caption: "Delete",
                                          color: Colors.red,
                                          icon: Icons.delete,
                                          onTap: (){

                                          }
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
        }
    );
  }
}