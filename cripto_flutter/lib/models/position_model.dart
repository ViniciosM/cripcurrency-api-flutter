import 'dart:convert';

import 'package:cripto_flutter/models/currency_model.dart';

class PositionModel {
  CurrencyModel? currency;
  double? quantity;
  PositionModel({
    this.currency,
    this.quantity,
  });

  PositionModel copyWith({
    CurrencyModel? currency,
    double? quantity,
  }) {
    return PositionModel(
      currency: currency ?? this.currency,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency?.toMap(),
      'quantity': quantity,
    };
  }

  factory PositionModel.fromMap(Map<String, dynamic> map) {
    return PositionModel(
      currency: map['currency'] != null ? CurrencyModel.fromMap(map['currency']) : null,
      quantity: map['quantity']?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory PositionModel.fromJson(String source) => PositionModel.fromMap(json.decode(source));

  @override
  String toString() => 'PositionModel(currency: $currency, quantity: $quantity)';
}
