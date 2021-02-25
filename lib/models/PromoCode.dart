import 'package:enum_to_string/enum_to_string.dart';

enum PromoCodeType {
  FREEDELIVERY,
  BONUS,
  SALE
}

class PromoCode {
  String code;
  PromoCodeType type;
  int bonus;
  int sale;

  PromoCode(json){
    this.code = json['code'];

    this.type = EnumToString.fromString(PromoCodeType.values, json['type']['type']);

    switch (this.type) {
      case PromoCodeType.BONUS:
        this.bonus = json['bonus'];
        break;
      case PromoCodeType.SALE:
        this.sale = json['sale'];
        break;
      default:
        break;
    }
  }
}