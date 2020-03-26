import 'package:air_pmi/BaseModel.dart';

class Contact {
  int id;
  String name;
  String phone;
  String email;
}

class ContactsModel extends BaseModel {
  void triggerRebuild() {
    notifyListeners();
  }
}

ContactsModel contactsModel = ContactsModel();