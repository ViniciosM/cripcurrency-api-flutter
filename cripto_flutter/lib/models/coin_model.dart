import 'dart:convert';



class CoinModel {

  String? baseId;
  String? icon;
  String? name;
  String? acronym;
  double? price;
  DateTime? timeStamp;
  double? varHour;
  double? varDay;
  double? varWeek;
  double? varMonth;
  double? varYear;
  double? varTotalPeriod;

  CoinModel({
    this.baseId,
    this.icon,
    this.name,
    this.acronym,
    this.price,
    this.timeStamp,
    this.varHour,
    this.varDay,
    this.varWeek,
    this.varMonth,
    this.varYear,
    this.varTotalPeriod,
  });


  CoinModel copyWith({
    String? baseId,
    String? icon,
    String? name,
    String? acronym,
    double? price,
    DateTime? timeStamp,
    double? varHour,
    double? varDay,
    double? varWeek,
    double? varMonth,
    double? varYear,
    double? varTotalPeriod,
  }) {
    return CoinModel(
      baseId: baseId ?? this.baseId,
      icon: icon ?? this.icon,
      name: name ?? this.name,
      acronym: acronym ?? this.acronym,
      price: price ?? this.price,
      timeStamp: timeStamp ?? this.timeStamp,
      varHour: varHour ?? this.varHour,
      varDay: varDay ?? this.varDay,
      varWeek: varWeek ?? this.varWeek,
      varMonth: varMonth ?? this.varMonth,
      varYear: varYear ?? this.varYear,
      varTotalPeriod: varTotalPeriod ?? this.varTotalPeriod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'baseId': baseId,
      'icon': icon,
      'name': name,
      'acronym': acronym,
      'price': price,
      'timeStamp': timeStamp?.millisecondsSinceEpoch,
      'varHour': varHour,
      'varDay': varDay,
      'varWeek': varWeek,
      'varMonth': varMonth,
      'varYear': varYear,
      'varTotalPeriod': varTotalPeriod,
    };
  }

  factory CoinModel.fromMap(Map<String, dynamic> map) {
    return CoinModel(
      baseId: map['baseId'],
      icon: map['icon'],
      name: map['name'],
      acronym: map['acronym'],
      price: map['price']?.toDouble(),
      timeStamp: map['timeStamp'] != null ? DateTime.fromMillisecondsSinceEpoch(map['timeStamp']) : null,
      varHour: map['varHour']?.toDouble(),
      varDay: map['varDay']?.toDouble(),
      varWeek: map['varWeek']?.toDouble(),
      varMonth: map['varMonth']?.toDouble(),
      varYear: map['varYear']?.toDouble(),
      varTotalPeriod: map['varTotalPeriod']?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CoinModel.fromJson(String source) => CoinModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CoinModel(baseId: $baseId, icon: $icon, name: $name, acronym: $acronym, price: $price, timeStamp: $timeStamp, varHour: $varHour, varDay: $varDay, varWeek: $varWeek, varMonth: $varMonth, varYear: $varYear, varTotalPeriod: $varTotalPeriod)';
  }


}
