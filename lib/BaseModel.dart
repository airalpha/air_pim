import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "package:scoped_model/scoped_model.dart";

class BaseModel extends Model {
  bool isLoading = false;
  int stackIndex = 0;
  List entityList = [];
  var entityBeingEdited;
  String chosenDate;

  void setChosenDate(String inDate) {
    chosenDate = inDate;
    notifyListeners();
  }

  void loadData(String inEntityType, dynamic inDatabase) async {
    isLoading = true;
    notifyListeners();
    entityList = await inDatabase.getAll();
    isLoading = false;
    notifyListeners();
  }

  void setStackIndex(int inStackIndex) {
    stackIndex = inStackIndex;
    notifyListeners();
  }

  Container buildNoContent(BuildContext inContext, String message) {
    final Orientation orientation = MediaQuery
        .of(inContext)
        .orientation;
    return Container(
      child: Center(
        child: ListView(
          padding: EdgeInsets.only(top: 50.0),
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/no_data.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 50.0,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
