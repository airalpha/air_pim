import 'dart:io';
import 'package:air_pmi/contacts/contacts_db_worker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'contacts_model.dart' show Contact, ContactsModel, contactsModel;
import '../utils.dart' as utils;
import "package:path/path.dart";


class ContactsEntry extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContactsEntry() {
    _nameController.addListener(() {
      contactsModel.entityBeingEdited.name = _nameController.text;
    });
    _emailController.addListener(() {
      contactsModel.entityBeingEdited.email = _emailController.text;
    });
    _phoneController.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneController.text;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if(contactsModel.entityBeingEdited != null) {
      _nameController.text = contactsModel.entityBeingEdited.name;
      _phoneController.text = contactsModel.entityBeingEdited.phone;
      _emailController.text = contactsModel.entityBeingEdited.email;
    }
    return ScopedModel(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget inChild, ContactsModel inModel) {
          File avatarFile = File(join(utils.docsDir.path, "avatar"));
          if(!avatarFile.existsSync()) {
            if(inModel.entityBeingEdited != null && inModel.entityBeingEdited?.id != null) {
              avatarFile = File(join(utils.docsDir.path, inModel.entityBeingEdited?.id.toString()));
            }
          }
          return Scaffold(
            body: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.image),
                    title: avatarFile.existsSync() 
                        ? Image.file(avatarFile)
                        : Text("Pas de photo"),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () => _selectAvatar(inContext),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person_outline),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Nom"),
                      controller: _nameController,
                      validator: (String value) {
                        if(value.length == 0) {
                          return "Entrer le nom";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(hintText: "Telephone"),
                      controller: _phoneController,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: "Email"),
                      controller: _emailController,
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
                    child: Text("Anuler"),
                    onPressed: () {
                      File avatarFile = File(join(utils.docsDir.path, "avatar"));
                      if(avatarFile.existsSync())
                        avatarFile.deleteSync();
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  FlatButton(
                    color: Colors.green,
                    textColor: Colors.white,
                    child: (inModel.entityBeingEdited?.id == null) ? Text("Ajouter") : Text("Modifier"),
                    onPressed: () {
                      _save(inContext, contactsModel);
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

  void _save(BuildContext inContext, ContactsModel contactsModel) async {
    if (!_formKey.currentState.validate()) { return; }
    if (contactsModel.entityBeingEdited?.id == null) {
      var id = await ContactsDBWorker.db.create(
          contactsModel.entityBeingEdited
      );
      File avatarFile = File(join(utils.docsDir.path, "avatar"));
      if(avatarFile.existsSync())
        avatarFile.renameSync(join(utils.docsDir.path, id.toString()));
    } else {
      await ContactsDBWorker.db.update(
          contactsModel.entityBeingEdited
      );
    }
    contactsModel.loadData("notes", ContactsDBWorker.db);
    contactsModel.setStackIndex(0);
    Scaffold.of(inContext).showSnackBar(
        SnackBar(
            backgroundColor : Colors.green,
            duration : Duration(seconds : 2),
            content : (contactsModel.entityBeingEdited?.id == null) ? Text("Contact ajouté !") : Text("Contact Modifié !")
        )
    );
  }

  Future _selectAvatar(BuildContext inContext) {
    return showDialog(
      context: inContext,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.image, color: Colors.blue,),
                    Text("Avatar"),
                  ],
                ),
                Divider(),
                GestureDetector(
                  child: ListTile(
                    leading: Icon(Icons.camera_enhance),
                    title: Text("Prendre une photo"),
                  ),
                  onTap: () async {
                    var cameraImage = await ImagePicker.pickImage(
                      source: ImageSource.camera
                    );
                    if(cameraImage != null) {
                      cameraImage.copySync(join(utils.docsDir.path, "avatar"));
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(context).pop();
                  },
                ),
                GestureDetector(
                  child: ListTile(
                    leading: Icon(Icons.image),
                    title: Text("Galerie"),
                  ),
                  onTap: () async {
                    var galleryImage = await ImagePicker.pickImage(
                      source: ImageSource.gallery
                    );
                    if(galleryImage != null) {
                      galleryImage.copySync(join(utils.docsDir.path, "avatar"));
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        );
      }
    );
  }
}
