import "dart:io";
import 'package:air_pmi/Home.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:path_provider/path_provider.dart";
import "appointments/appointments.dart";
import "contacts/contacts.dart";
import "notes/notes.dart";
import "tasks/tasks.dart";
import "utils.dart" as utils;

void main() {
  startMeUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;

    runApp(FlutterBook());
  }

  WidgetsFlutterBinding.ensureInitialized();
  startMeUp();
}

class FlutterBook extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData(
        brightness: Brightness.dark
      ),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountEmail: Text('allphaair@gmail.com'),
                  accountName: Text('AIR ALPHA'),
                  currentAccountPicture: Container(
                    child: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                ListTile(
                  title: Text("About"),
                  leading: Icon(Icons.account_balance),
                )
              ],
            ),
          ),
          appBar: AppBar(
            title: Text('AIR PMI'),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.date_range),
                  text: "Rendez-vous",
                ),
                Tab(
                  icon: Icon(Icons.contacts),
                  text: "Contacs",
                ),
                Tab(
                  icon: Icon(Icons.note),
                  text: "Notes",
                ),
                Tab(
                  icon: Icon(Icons.assignment_turned_in),
                  text: "Taches",
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              //Appointments(),
              Appointments(),
              MyHomePage(),
              //Contacts(),
              Notes(),
              Tasks(),
            ],
          ),
        ),
      ),
    );
  }
}

