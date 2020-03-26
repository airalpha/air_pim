import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'contacts_model.dart' show Contact, ContactsModel, contactsModel;
import '../utils.dart' as utils;
import "package:path/path.dart";

class ContactsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget inChild, ContactsModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                File avatarFile = File(join(utils.docsDir.path, "avatar"));
                if(avatarFile.existsSync())
                  avatarFile.deleteSync();

                contactsModel.entityBeingEdited = Contact();
                contactsModel.setStackIndex(1);
              },
            ),
            body: Container(),
          );
        },
      ),
    );
  }
}
