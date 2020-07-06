import "dart:io";
import 'package:air_pmi/pages/help.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import "package:path_provider/path_provider.dart";
import 'package:url_launcher/url_launcher.dart';
import "appointments/appointments.dart";
import "contacts/contacts.dart";
import "notes/notes.dart";
import "tasks/tasks.dart";
import "utils.dart" as utils;

const String testDevice = '';

void main() {
  startMeUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(Pmi());
  }

  WidgetsFlutterBinding.ensureInitialized();
  startMeUp();
}

class Pmi extends StatefulWidget{
  @override
  _PmiState createState() => _PmiState();
}

class _PmiState extends State<Pmi> with SingleTickerProviderStateMixin{

  GlobalKey<NavigatorState> _nav = GlobalKey();
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _nav,
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          drawer: Container(
            width: 275.0,
            child: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage("assets/images/icon.png")
                      ),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          bottom: 12.0,
                          left: 16.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "AIR PIM",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0, color: Colors.blue),
                              ),
                              Text(
                                  "Personal Information Management"
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text("Rendez-vous"),
                    leading: Icon(Icons.date_range, color: Colors.blue.shade900,),
                    onTap: () {
                      _nav.currentState.pop();
                      _tabController.index = 0;
                    }
                  ),
                  ListTile(
                    title: Text("Contacts"),
                    leading: Icon(Icons.contacts, color: Colors.blue.shade900,),
                    onTap: (){
                      _nav.currentState.pop();
                      _tabController.index = 1;
                    },
                  ),
                  ListTile(
                    title: Text("Notes"),
                    leading: Icon(Icons.note, color: Colors.blue.shade900,),
                    onTap: () {
                      _nav.currentState.pop();
                      _tabController.index = 2;
                    },
                  ),
                  ListTile(
                    title: Text("Taches"),
                    leading: Icon(Icons.assignment_turned_in, color: Colors.blue.shade900,),
                    onTap: () {
                      _nav.currentState.pop();
                      _tabController.index = 3;
                    },
                  ),
                  SizedBox(height: 10.0,),
                  Divider(),
                  ListTile(
                    title: Text("Aide"),
                    leading: Icon(Icons.live_help, color: Colors.green,),
                    onTap: () => _nav.currentState.push(MaterialPageRoute(builder: (context) => Help())),
                  ),
                  ListTile(
                    title: Text("Fermer"),
                    leading: Icon(Icons.backspace, color: Colors.red,),
                    onTap: () => _nav.currentState.pop(),
                  ),
                  ListTile(
                    title: Text("Contact"),
                    leading: Icon(Icons.contact_phone, color: Colors.yellowAccent,),
                    onTap: _launchURL,
                  ),
                  ListTile(
                    title: Text('1.0'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            title: Text('AIR PIM'),
            bottom: TabBar(
              controller: _tabController,
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
            controller: _tabController,
            children: <Widget>[
              Appointments(),
              Contacts(),
              Notes(),
              Tasks(),
            ],
          ),
        ),
      ),
    );
  }

  void goTo(int index) {
    
  }

  _launchURL() async {
    const url = 'https://airalpha.yo.fr/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}



