

import 'dart:convert';

import 'package:ZeloApp/models/User.dart';
import 'package:ZeloApp/pages/profie/change-password-page.dart';
import 'package:ZeloApp/services/Storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

enum ProfileSections {
  HEADER,
  CHANGE_PASS,
  MY_ORDERS,
  PRIVACY_POLICY,
  LOGOUT
}

class ProfilePageState extends State<ProfilePage> {

  var sections = [ProfileSections.HEADER, ProfileSections.CHANGE_PASS, ProfileSections.PRIVACY_POLICY, ProfileSections.LOGOUT];
  User user;

  @override
  void initState() {
    super.initState();

    _getUserData();
  }

  void _getUserData() async {
    var userData = await Storage.itemBy('user_data');
    var userJson = json.decode(userData);

    setState(() {
      user = User.fromJson(userJson);
    });
  }

  String _getSectionStringValue(ProfileSections section) {
    switch (section) {
      case ProfileSections.CHANGE_PASS:
        return 'Сменить пароль';
      case ProfileSections.MY_ORDERS:
        return 'Мои заказы';
      case ProfileSections.PRIVACY_POLICY:
        return 'Политика конфиденциальности';
      case ProfileSections.LOGOUT:
        return 'Выйти';
    }
  }

  void _actionItemPressed(ProfileSections section) {
    switch (section) {
      case ProfileSections.CHANGE_PASS:
        _changePassword();
        break;
      case ProfileSections.PRIVACY_POLICY:
        _openPrivacyPolicy();
        break;
      case ProfileSections.LOGOUT:
        _logout();
    }
  }

  void _openPrivacyPolicy() async{
    const url = 'https://zelodostavka.me/api/privacy_policy/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _changePassword() {
    Navigator.push(context,CupertinoPageRoute(builder: (context) => ChangePasswordPage()));
  }

  void _logout() {
    User.logout();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text('Профиль'),
      ),
      body: ListView.builder(
          itemCount: sections.length,
          padding: const EdgeInsets.all(10.0),
          itemBuilder: (context, i) {
            if (i == 0) { return _header(); }
            
            return _actionItem(sections[i]);
          }
      ),
    );
  }

  Widget _header() {
    return Padding (
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      child:  Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text (
            (user != null) ? user.name : '',
            style: GoogleFonts.openSans(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.w600
            ),
          ),

          Padding (
            padding: EdgeInsets.only(bottom: 50),
            child: Text (
              (user != null) ? user.email : '',
              style: GoogleFonts.openSans(
                color: Colors.grey,
                fontSize: 20,
//                fontWeight: FontWeight.w600
              ),
            ),
          ),

          Divider (
            color: Colors.grey,
          )
        ],
      ),
    );
  }

  Widget _actionItem(ProfileSections section) {
    return InkWell (
      onTap: () {
        _actionItemPressed(section);
      },
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding (
            padding: EdgeInsets.all(10),
            child: Text(
              _getSectionStringValue(section),
              style: GoogleFonts.openSans(
                  fontSize: 22,
//          fontWeight: FontWeight.w600,
                  color: (section == ProfileSections.LOGOUT) ? Colors.red : Colors.blue
              ),
            ),
          ),

          Divider (
            color: Colors.grey,
          )
        ],
      )
    );
  }

}

class ProfilePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new ProfilePageState();
  }
}