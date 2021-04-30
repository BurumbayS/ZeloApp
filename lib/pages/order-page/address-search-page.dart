
import 'dart:convert';

import 'package:ZeloApp/models/Address.dart';
import 'package:ZeloApp/services/Network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:http/http.dart' as http;

import 'map-page.dart';

class BBox {
  Point leftBottom;
  Point rightTop;

  BBox(Point leftBottom, Point rightTop) {
    this.leftBottom = leftBottom;
    this.rightTop = rightTop;
  }
}

class AddressSearchPage extends StatefulWidget {

  Address address;
  Coordinates placeCoordinates;

  AddressSearchPage({Key key, this.address, this.placeCoordinates}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new AddressSearchPageState();
  }
}

class AddressSearchPageState extends State<AddressSearchPage> {

  final TaldykkBox = BBox(Point(latitude: 44.975728, longitude: 78.300946), Point(latitude: 45.060002, longitude: 78.448917));
  final TarazBox = BBox(Point(latitude: 42.837710, longitude: 71.242950), Point(latitude: 43.042798, longitude: 71.563141));
  final SemeyBox = BBox(Point(latitude: 50.333628, longitude: 80.097300), Point(latitude: 50.489405, longitude: 80.356962));

  var searchText = "";
  List<Address> searchResults = [];

  var _addressTextController = new TextEditingController();

  void _searchAddress(String address) async {
    searchText = address;

    await Future.delayed(Duration(milliseconds: 500));

    if (searchText != address) { return; }

    var baseURL = "https://search-maps.yandex.ru/v1/?type=geo&lang=ru_RU&apikey=b5e16ac6-6e22-4a90-8940-25d258b393e6";

    var bbox = "${TaldykkBox.leftBottom.longitude},${TaldykkBox.leftBottom.latitude}~${TaldykkBox.rightTop.longitude},${TaldykkBox.rightTop.latitude}";
    var requestURL = "$baseURL&text=$address&bbox=$bbox";

    var response = await http.get(requestURL);
    var responseJson = jsonDecode(response.body);

    searchResults = [];

    for (Map<String, dynamic> item in responseJson["features"]) {
      var place = Address();
      place.firstAddress = item["properties"]["name"];
      place.description = item["properties"]["description"];
      place.latitude = item["geometry"]["coordinates"][1];
      place.longitude = item["geometry"]["coordinates"][0];

      setState(() {
        searchResults.add(place);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Адрес",
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0, top: 18),
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapSearchPage(widget.address, widget.placeCoordinates)
                      )
                  );

                  if (result != null) {
                    setState(() {
                      widget.address = result;
                      _addressTextController.text = widget.address.firstAddress;
                    });
                  }
                },
                child: Text (
                  "Карта",
                  style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 18
                  ),
                ),
              )
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
              child: Text(
                "Укажите свой адрес или найдите на карте",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                    fontSize: 14,
                    color: Colors.blue
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: TextFormField(
            controller: _addressTextController,
//          focusNode: _focusOnPhone,
              keyboardType: TextInputType.text,
              onChanged: (address) {
                setState(() {
                  _searchAddress(address);
                });
              },
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey[300],
                    ),
                  ),
                  hintText: 'Укажите свой адрес',
                  hintStyle: GoogleFonts.openSans(
                      color: Colors.grey[500]
                  )
              ),
              style: GoogleFonts.openSans(
                  fontSize: 18
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: TextFormField(
//          controller: _phoneTextController,
//          focusNode: _focusOnPhone,
              keyboardType: TextInputType.text,
              onChanged: (number) {
                setState(() {
//              _order.contactPhone = number;
//                  _phoneTextFieldController.text = formattedNumber(number);
                });
              },
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey[300],
                    ),
                  ),
                  hintText: 'Подъезд, квартира и т.д',
                  hintStyle: GoogleFonts.openSans(
                      color: Colors.grey[500]
                  )
              ),
              style: GoogleFonts.openSans(
                  fontSize: 18
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return _suggestedAddress(searchResults[index]);
                },
              ),
            )
          )
        ],
      )
    );
  }

  Widget _suggestedAddress(Address address) {
    return InkWell(
      onTap: () {
        widget.address = address;
        _addressTextController.text = address.firstAddress;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, top: 10 ,right: 20),
            child: Text(
              address.firstAddress,
              style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 16
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 20, top: 5, right: 20),
            child: Text(
              address.description,
              style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.grey
              ),
            ),
          ),

          Divider()
        ],
      ),
    );
  }
}