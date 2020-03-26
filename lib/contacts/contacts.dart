import 'contacts_entry.dart';
import 'contacts_model.dart' show contactsModel, ContactsModel;
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'contacts_list.dart';

class Contacts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget inChild, ContactsModel inModel) {
          return IndexedStack(
            index: inModel.stackIndex,
            children: <Widget>[
              ContactsList(),
              ContactsEntry(),
            ],
          );
        },
      ),
    );
  }
}
