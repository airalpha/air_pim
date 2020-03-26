import 'dart:io';
import 'package:air_pmi/contacts/contacts_db_worker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
            body: ListView.builder(
              itemCount: contactsModel.entityList.length,
              itemBuilder:
              (BuildContext context, int inIndex) {
                Contact contact = contactsModel.entityList[inIndex];
                File avatarFile = File(join(utils.docsDir.path, contact.id.toString()));
                bool avatarFileExists = avatarFile.existsSync();

                return Column(
                  children: <Widget>[
                    Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: .25,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          backgroundImage: avatarFileExists
                              ? FileImage(avatarFile)
                              : null,
                          child: avatarFileExists
                              ? null
                              : Text(contact.name.substring(0, 1).toUpperCase()),
                        ),
                        title: Text("${contact.name}"),
                        subtitle: contact.phone == null
                            ? null
                            : Text("${contact.phone}"),
                        onTap: () async {
                          File avatarFile = File(join(utils.docsDir.path, "avatar"));
                          if(avatarFile.existsSync()) avatarFile.deleteSync();
                          contactsModel.entityBeingEdited = await ContactsDBWorker.db.get(contact.id);
                          contactsModel.setStackIndex(1);
                        },
                      ),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: "Supprimer",
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () => _deleteContact(inContext, contact),
                        )
                      ],
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  _deleteContact(BuildContext inContext, Contact contact) {
    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Supprimer un contact"),
            content: Text("Voulez vous supprimer ${contact.name} ?"),
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
                  File avatarFile = File(join(utils.docsDir.path, contact.id.toString()));
                  if(avatarFile.existsSync())
                    avatarFile.deleteSync();
                  await ContactsDBWorker.db.delete(contact.id);
                  Navigator.of(context).pop();
                  Scaffold.of(inContext).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Contact supprimer !"),
                  ));
                  contactsModel.loadData("contacts", ContactsDBWorker.db);
                },
              )
            ],
          );
        });
  }
}
