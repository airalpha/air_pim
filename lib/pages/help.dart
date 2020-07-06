import 'package:air_pmi/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help"),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 10.0),
        children: <Widget>[
          Card(
            child: Column(
              children: <Widget>[
                Image.asset("assets/images/add.png"),
                Padding(padding: EdgeInsets.all(10.0), child: Text("Appuyer sur ce boutton pour ajouter"))
              ],
            ),
          ),
          SizedBox(
            height: 50.0,
          ),
          Card(
            child: Column(
              children: <Widget>[
                Image.asset("assets/images/slide.png"),
                Padding(padding: EdgeInsets.all(10.0), child: Text("Glisser l'élément vers la gauche pour supprimer"))
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: RaisedButton(
              child: Text("Retour"),
              color: Colors.lightBlue,
              textColor: Colors.white,
              onPressed:() => Navigator.of(context).push(MaterialPageRoute(builder: (context) => Pmi())),
            ),
          )
        ],
      ),
    );
  }
}
