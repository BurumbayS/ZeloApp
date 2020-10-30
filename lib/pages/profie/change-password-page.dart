
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    print('checking');

    if (_oldPassTextFieldController.text != "" && _newPassTextFieldController.text != "" && _confirmedPassTextFieldController.text != "") {
      return true;
    }

    return false;
  }

  void _changePassword() {
    if (_newPassTextFieldController.text != _confirmedPassTextFieldController.text) {
      setState(() {
        _errorText = 'Пароли не совпадают';
      });
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
            setState(() {});
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