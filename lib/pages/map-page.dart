import 'dart:async';
import 'dart:io';

import 'package:ZeloApp/models/Address.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:flutter/cupertino.dart';
import 'delivery-address-details.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as geolocator;

// ignore: must_be_immutable
class MapSearchPage extends StatefulWidget{

  Address address;
  Address newAddress;

  MapSearchPage(Address address) {
    this.address = address;
  }

  @override
  State<StatefulWidget> createState() {
    return new MapSearchPageState(this.address);
  }
}

class MapSearchPageState extends State<MapSearchPage>  {

  static const PLACE_API_KEY = "AIzaSyC4ATGNItCqpljzi47MRKMFGRT-ZNZvtJg";
  PermissionStatus _permissionStatus = PermissionStatus.unknown;

//  String searchText = "";
//  String response = '';
  bool _loading = false;

  int _requestCount = 0;
  Address address = new Address();

  YandexMapController controller;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final List<PermissionGroup> permissions = <PermissionGroup>[PermissionGroup.location];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
    await PermissionHandler().requestPermissions(permissions);
    setState(() {
      _permissionStatus = permissionRequestResult[PermissionGroup.location];
    });
  }

  MapSearchPageState(Address address) {
    this.address = address;
  }

  Future<void> cameraPositionChanged(dynamic arguments) async {
    _requestCount++;
    int currentRequestCount = _requestCount;

    await Future.delayed(Duration(milliseconds: 100));

    if (_requestCount == currentRequestCount) {
      setState(() {
        _loading = true;
      });

      double lat = arguments['latitude'];
      double long = arguments['longitude'];

      address.latitude = lat;
      address.longitude = long;

      String baseURL = "https://geocode-maps.yandex.ru/1.x/";
      String request = '$baseURL?format=json&apikey=583d6b1f-a874-49de-8897-38a706b71f96&geocode=$long,$lat';
      Response response = await Dio().get(request);

      Response distanceResponse = await Dio().get("https://maps.googleapis.com/maps/api/distancematrix/json?language=ru_RU&units=metric&origins=45.01271475297843,78.4021995759503&destinations=$lat,$long&key=AIzaSyDxgI8Z7Tw33nw46fsN98hEEwTdqgZoCBY");

      setState(() {
        String addressString = response.data['response']['GeoObjectCollection']['featureMember'][0]['GeoObject']['name'];
        address.firstAddress = addressString;
      });

      int distanceInMeters = distanceResponse.data['rows'][0]['elements'][0]['distance']['value'];
      address.distance = distanceInMeters;

      setState(() {
        _loading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        appBar: AppBar(
          title: Text(
            'Адрес доставки',
            style: GoogleFonts.openSans(

            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack (
                children: <Widget>[
                  YandexMap(
                    onMapCreated: (YandexMapController yandexMapController) async {
                      controller = yandexMapController;

                      double zoom = (address.firstAddress == '') ? 13 : 18;
                      await controller.move(
                          point: Point(latitude: address.latitude, longitude: address.longitude),
                          zoom: zoom,
                          animation: const MapAnimation(smooth: true, duration: 0.5)
                      );

                      final Point currentTarget = await controller.enableCameraTracking(
                          Placemark(
                            point: const Point(latitude: 0, longitude: 0),
                            iconName: 'assets/images/pin.png',
                            opacity: 0.8,
                          ),
                          cameraPositionChanged
                      );
                    },
                  ),

                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: Container(
                      height: 40,
                      width: 40,
                      padding: EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),]
                      ),
                      child: FlatButton (
                        padding: EdgeInsets.all(0),
                        child: Image.asset('assets/images/cursor.png'),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)
                        ),

                        onPressed: () async {
                          if (_permissionStatus == PermissionStatus.granted) {
                            geolocator.LocationData location = await geolocator.Location().getLocation();
                            await controller.move(
                                point: Point(latitude: location.latitude, longitude: location.longitude),
                                zoom: 18,
                                animation: const MapAnimation(smooth: true, duration: 0.5)
                            );
                          } else {
                            _requestPermission();
                          }
                        }
                      ),
                    ),
                  )
                ],
              )
            ),

            Container(
              padding: (Platform.isIOS) ? EdgeInsets.only(top: 10, bottom: 50) : EdgeInsets.only(top: 10, bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(3, 0),
                  ),]
              ),

              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 20, right: 10),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: 30,
                          width: 30,
                          margin: EdgeInsets.only(left: 16, right: 10),
                          child: Image.asset('assets/images/pin.png'),
                        ),
                        Expanded (
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Text(
                              address.firstAddress,
                              maxLines: 10,
                              style: TextStyle(
                                  fontSize: 18
                              ),
                            ),
                          ),
                        ),

                        Container(
                          height: 20,
                          width: 20,
                          margin: EdgeInsets.only(right: 10),
                          child: Center (
                            child: SpinKitRing(
                                color: (_loading) ? Colors.grey[300] : Colors.white
                            ),
                          )
                        )

                      ],
                    ),
                  ),

                  InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeliveryAddressDetails(address.secondAddress),
                          )
                      );
                      setState(() {
                        address.secondAddress = result;
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: 20,
                          width: 20,
                          margin: EdgeInsets.only(left: 21, right: 15),
                          child: Image.asset('assets/images/home.png'),
                        ),
                        Container(
                          child: Text(
                            (address.secondAddress == '') ? 'Подъезд, квартира и т.д' : address.secondAddress,
                            style: TextStyle(
                                fontSize: 18,
                                color: (address.secondAddress == '') ? Colors.grey[500] : Colors.black
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width - 32,
                    margin: EdgeInsets.only(left: 16, right: 16, top: 30),
                    child: FlatButton(
                      color: Colors.blue[400],
                      textColor: Colors.white,
                      splashColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0)
                      ),

                      child: Text(
                          'Подтвердить адрес',
                          style: GoogleFonts.openSans(
                              fontSize: 20,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.bold
                          )
                      ),
                      onPressed: () async {
                          Navigator.pop(context, this.address);
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        )
    );
  }

}
