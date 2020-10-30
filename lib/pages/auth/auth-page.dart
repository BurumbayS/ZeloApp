import 'dart:convert';

import 'package:ZeloApp/services/Network.dart';
import 'package:ZeloApp/services/Storage.dart';
import 'package:ZeloApp/utils/alertDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class AuthPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new AuthPageState();
  }

}

class AuthPageState extends State<AuthPage> {

  final _nameTextFieldController = TextEditingController();
  final _mailTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();

  bool _hasAccount = false;

  bool _fieldsFilledCorrectly() {

    if (!_hasAccount && _nameTextFieldController.text != "" && _mailTextFieldController.text != "" && _passwordTextFieldController.text != "") {
      return true;
    }

    if (_hasAccount && _mailTextFieldController.text != "" && _passwordTextFieldController.text != "") {
      return true;
    }

    return false;
  }

  void login() async {
    var response = await http.post(
      Network.api + "/login/",
      headers: Network.shared.headers(),
      body: jsonEncode(<String, String>{
        'email': _mailTextFieldController.text,
        'password': _passwordTextFieldController.text
      }),
    );

    var responseJson = json.decode(response.body);

    if (responseJson['code'] == 0) {
      Storage.shared.setItem("token", responseJson['token'].toString());
      Storage.shared.setItem("user_data", json.encode(responseJson['user']));
      Navigator.pop(context);
    } else {
      showDialog(context: context, builder: (_) =>
          CustomAlertDialog.shared.dialog("Ошибка!",
              responseJson['error'].toString(),
              true,
              context, () {

              }));
    }
  }

  void register() async {
    var response = await http.post(
      Network.api + "/register/",
      headers: Network.shared.headers(),
      body: jsonEncode(<String, String>{
        'email': _mailTextFieldController.text,
        'name': _nameTextFieldController.text,
        'password': _passwordTextFieldController.text
      }),
    );

    var responseJson = json.decode(response.body);
    if (responseJson["code"] == 0) {
      showDialog(context: context, builder: (_) =>
          CustomAlertDialog.shared.dialog("Успешно!",
              "Ваш аккаунт успешно создан!\nВойдите, используя ваши данные",
              true,
              context, () {
                _passwordTextFieldController.text = "";
                _mailTextFieldController.text = "";
                setState(() {
                  _hasAccount = true;
                });
              }));
    } else {
      showDialog(context: context, builder: (_) =>
          CustomAlertDialog.shared.dialog("Ошибка!",
              "Ошибки создания аккаунта!",
              true,
              context, () {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text('Регистрация'),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0, top: 18),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _hasAccount = !_hasAccount;
                  });
                },
                child: Text (
                  (!_hasAccount) ? 'Войти' : 'Регистрация',
                  style: GoogleFonts.openSans(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
              )
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return (_hasAccount) ? _loginForm() : _registrationForm();
        },
      )
    );
  }

  Widget _registrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding (
          padding: EdgeInsets.only(top: 50, bottom: 20),
          child: Text(
            'Регистрация',
            style: GoogleFonts.capriola(
                fontSize: 26
            ),
          ),
        ),

        //name field
        Container(
            height: 70,
            margin: EdgeInsets.only(left: 30, right: 30, top: 20),
            decoration: BoxDecoration (
              border: Border(bottom: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.grey[300])),
            ),

            child: Row (
              children: <Widget>[
                Container (
                  width: 60,
                  height: 70,
                  padding: EdgeInsets.only(left: 10, right: 20),
                  child: Image(
                      image: AssetImage('assets/images/user.png')
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: TextFormField(
                      controller: _nameTextFieldController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Имя',
                          hintStyle: GoogleFonts.openSans(
                              color: Colors.grey[500]
                          )
                      ),
                      style: GoogleFonts.openSans(
                          fontSize: 18
                      ),
                    ),
                  ),
                )

              ],
            )
        ),

        //mail field
        Container(
            height: 70,
            margin: EdgeInsets.only(left: 30, right: 30, top: 10),
            decoration: BoxDecoration (
              border: Border(bottom: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.grey[300])),
            ),

            child: Row (
              children: <Widget>[
                Container (
                  width: 60,
                  height: 70,
                  padding: EdgeInsets.only(right: 20, left: 10),
                  child: Image(
                      image: AssetImage('assets/images/mail.png')
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: TextFormField(
                      controller: _mailTextFieldController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Электронная почта',
                          hintStyle: GoogleFonts.openSans(
                              color: Colors.grey[500]
                          )
                      ),
                      style: GoogleFonts.openSans(
                          fontSize: 18
                      ),
                    ),
                  ),
                )

              ],
            )
        ),

        //password field
        Container(
            height: 70,
            margin: EdgeInsets.only(left: 30, right: 30, top: 10),
            decoration: BoxDecoration (
              border: Border(bottom: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.grey[300])),
            ),

            child: Row (
              children: <Widget>[
                Container (
                  width: 60,
                  height: 70,
                  padding: EdgeInsets.only(left: 10, right: 20),
                  child: Image(
                      image: AssetImage('assets/images/password.png')
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: TextFormField(
                      controller: _passwordTextFieldController,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Пароль',
                          hintStyle: GoogleFonts.openSans(
                              color: Colors.grey[500]
                          )
                      ),
                      style: GoogleFonts.openSans(
                          fontSize: 18
                      ),
                    ),
                  ),
                )

              ],
            )
        ),

        //button field
        Container(
          height: 50,
          margin: EdgeInsets.only(top: 50),
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              boxShadow: [BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),]
          ),

          child: FlatButton(
            color: (_fieldsFilledCorrectly()) ? Colors.blue[400] : Colors.grey,
            textColor: Colors.white,
            splashColor: (_fieldsFilledCorrectly()) ? Colors.blue[700] : Colors.grey[0],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)
            ),

            child: Text(
                'Регистрация',
                style: GoogleFonts.openSans(
                    fontSize: 22,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.bold
                )
            ),
            onPressed: () {
              if ( (_fieldsFilledCorrectly())) { register(); }
            },
          ),
        ),
      ],
    );
  }

  Widget _loginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding (
          padding: EdgeInsets.only(top: 50, bottom: 20),
          child: Text(
            'Вход',
            style: GoogleFonts.capriola(
                fontSize: 26
            ),
          ),
        ),

        //email field
        Container(
            height: 70,
            margin: EdgeInsets.only(left: 30, right: 30, top: 10),
            decoration: BoxDecoration (
              border: Border(bottom: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.grey[300])),
            ),

            child: Row (
              children: <Widget>[
                Container (
                  width: 60,
                  height: 70,
                  padding: EdgeInsets.only(right: 20, left: 10),
                  child: Image(
                      image: AssetImage('assets/images/mail.png')
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: TextFormField(
                      controller: _mailTextFieldController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Электронная почта',
                          hintStyle: GoogleFonts.openSans(
                              color: Colors.grey[500]
                          )
                      ),
                      style: GoogleFonts.openSans(
                          fontSize: 18
                      ),
                    ),
                  ),
                )

              ],
            )
        ),

        //password field
        Container(
            height: 70,
            margin: EdgeInsets.only(left: 30, right: 30, top: 10),
            decoration: BoxDecoration (
              border: Border(bottom: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.grey[300])),
            ),

            child: Row (
              children: <Widget>[
                Container (
                  width: 60,
                  height: 70,
                  padding: EdgeInsets.only(left: 10, right: 20),
                  child: Image(
                      image: AssetImage('assets/images/password.png')
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: TextFormField(
                      controller: _passwordTextFieldController,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Пароль',
                          hintStyle: GoogleFonts.openSans(
                              color: Colors.grey[500]
                          )
                      ),
                      style: GoogleFonts.openSans(
                          fontSize: 18
                      ),
                    ),
                  ),
                )

              ],
            )
        ),

        //login button
        Container(
          height: 50,
          margin: EdgeInsets.only(top: 50),
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              boxShadow: [BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),]
          ),

          child: FlatButton(
            color: (_fieldsFilledCorrectly()) ? Colors.blue[400] : Colors.grey,
            textColor: Colors.white,
            splashColor: (_fieldsFilledCorrectly()) ? Colors.blue[700] : Colors.grey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)
            ),

            child: Text(
                'Вход',
                style: GoogleFonts.openSans(
                    fontSize: 22,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.bold
                )
            ),
            onPressed: () {
              login();
            },
          ),
        ),
      ],
    );
  }
}