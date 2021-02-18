import 'Storage.dart';

enum City {
  Semey,
  Taldykorgan
}

class Network {
  static Network shared = new Network();

  City city;

  String host_taldyk = 'http://64.227.116.41';//'https://zelodostavka.me';
  String host_semey = 'http://46.101.121.193';
  String host_dev = 'http://64.227.116.41';
  String host_taraz = 'http://167.71.53.8';

  String api = "";

  void setCity(City city) {
    this.city = city;

    switch (city) {
      case City.Semey:
        this.api = host_semey + "/api";
        break;
      case City.Taldykorgan:
        this.api = host_taldyk + "/api";
        break;
    }
  }

  String host() {
    switch (city) {
      case City.Semey:
        return host_semey;
      case City.Taldykorgan:
        return host_taldyk;
    }
  }

  Map<String, String> headers() {
    String token = Storage.shared.getItem("token");
    if (token == null) {
      return {
        'Content-Type': 'application/json; charset=UTF-8'
      };
    } else {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      };
    }
  }
}