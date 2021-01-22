import 'package:localstorage/localstorage.dart';

class Storage {
  static LocalStorage shared = new LocalStorage('data');

  static setItem(String key, String value) async {
    await shared.ready;
    shared.setItem(key, value);
  }

  static Future<String> itemBy(String key) async {
    await shared.ready;
    return shared.getItem(key);
  }
}