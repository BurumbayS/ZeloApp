
import 'dart:convert';

import 'package:ZeloApp/services/Network.dart';
import 'package:ZeloApp/utils/alertDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

enum ChangePasswordSection {
  OLD_PASSWORD,
  NEW_PASSWORD,
  CONFIRM_PASSWORD
}

class ChangePasswordPageState extends State<ChangePasswordPage> {

  var sections = [ChangePasswordSection.OLD_PASSWORD, ChangePasswordSection.NEW_PASSWORD, ChangePasswordSection.CONFIRM_PASSWORD];

  final _oldPassTextFieldController = TextEditingController();
  final _newPassTextFieldController = TextEditingController();
  final _confirmedPassTextFieldController = TextEditingController();

  var _errorText = '';

  String _sectionPlaceholder(section) {
    switch (section) {
      case ChangePasswordSection.OLD_PASSWORD:
        return 'Старый пароль';
      case ChangePasswordSection.NEW_PASSWORD:
        return 'Новый пароль';
      case ChangePasswordSection.CONFIRM_PASSWORD:
        return 'Подтвердить пароль';
    }
  }

  TextEditingController _sectionController(section) {
    switch (section) {
      case ChangePasswordSection.OLD_PASSWORD:
        return  _oldPassTextFieldController;
      case ChangePasswordSection.NEW_PASSWORD:
        return _newPassTextFieldController;
      case ChangePasswordSection.CONFIRM_PASSWORD:
        return _confirmedPassTextFieldController;
    }
  }

  bool _fieldsFilledCorrectly() {
    if (_oldPassTextFieldController.text != "" && _newPassTextFieldController.text != "" && _confirmedPassTextFieldController.text != "") {
      return true;
    }

    return false;
  }

  void _changePassword() async {
    if (_newPassTextFieldController.text != _confirmedPassTextFieldController.text) {
      setState(() {
        _errorText = 'Пароли не совпадают';
      });
    }

    var _dataToUpdate = {
      "old_password": _oldPassTextFieldController.text,
      "new_password": _newPassTextFieldController.text
    };

    http.Response response = await http.put(
        Network.api + "/reset_password/",
        headers: Network.shared.headers(),
        body: jsonEncode(_dataToUpdate)
    );

    var json = jsonDecode(response.body);

    if (json['code'] == 1) {
      setState(() {
        _errorText = json['error'];
      });
    } else {
      showDialog(context: context, builder: (_) => CustomAlertDialog.shared.dialog("Поздравляем!\n", "Ваш пароль успешно изменен", true, context, () {
        Navigator.pop(context);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text ('Сменить пароль'),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 10, top: 15),
              child: GestureDetector(
                onTap: () {
                  _changePassword();
                },
                child: Text (
                  'Готово',
                  style: GoogleFonts.openSans(
                      color: (_fieldsFilledCorrectly()) ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                  ),
                ),
              )
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: sections.length + 1,
          padding: const EdgeInsets.all(20.0),
          itemBuilder: (context, i) {
            if (i == sections.length) {
              return _errorLabel();
            }

            return _textFieldForm(sections[i]);
          }
      ),
    );
  }

  Widget _textFieldForm(section) {
    return Column(
      children: <Widget>[
        TextFormField(
          onChanged: (text) {
            setState(() {
              _errorText = "";
            });
          },
          controller: _sectionController(section),
          obscureText: true,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: _sectionPlaceholder(section),
              hintStyle: GoogleFonts.openSans(
                  color: Colors.grey[500]
              )
          ),
          style: GoogleFonts.openSans(
              fontSize: 18
          ),
        ),

        Divider(
          color: Colors.grey,
        )
      ],
    );
  }

  Widget _errorLabel() {
    return Padding (
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Text(
        _errorText,
        textAlign: TextAlign.center,
        style: GoogleFonts.openSans(
          color: Colors.red,
          fontSize: 18
        ),
      ),
    );
  }

}

class ChangePasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ChangePasswordPageState();
  }
}