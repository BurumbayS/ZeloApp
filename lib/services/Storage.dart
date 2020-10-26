import 'package:localstorage/localstorage.dart';

class Storage {
  static LocalStorage shared = new LocalStorage('data');

  static Future<String> itemBy(String key) async {
    await shared.ready;
    return shared.getItem(key);
  }
}