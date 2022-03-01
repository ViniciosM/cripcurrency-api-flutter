import 'dart:convert';

import 'package:cripto_flutter/models/currency_model.dart';

class HistoricModel {
  DateTime? operationDate;
  String? operationType;
  CurrencyModel? currency;
  double? value;
  double? quantity;

  HistoricModel({
    this.operationDate,
    this.operationType,
    this.currency,
    this.value,
    this.quantity,
  });

  HistoricModel copyWith({
    DateTime? operationDate,
    String? operationType,
    CurrencyModel? currency,
    double? value,
    double? quantity,
  }) {
    return HistoricModel(
      operationDate: operationDate ?? this.operationDate,
      operationType: operationType ?? this.operationType,
      currency: currency ?? this.currency,
      value: value ?? this.value,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'operationDate': operationDate?.millisecondsSinceEpoch,
      'operationType': operationType,
      'currency': currency?.toMap(),
      'value': value,
      'quantity': quantity,
    };
  }

  factory HistoricModel.fromMap(Map<String, dynamic> map) {
    return HistoricModel(
      operationDate: map['operationDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['operationDate'])
          : null,
      operationType: map['operationType'],
      currency: map['currency'] != null
          ? CurrencyModel.fromMap(map['currency'])
          : null,
      value: map['value']?.toDouble(),
      quantity: map['quantity']?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory HistoricModel.fromJson(String source) =>
      HistoricModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'HistoricModel(operationDate: $operationDate, operationType: $operationType, currency: $currency, value: $value, quantity: $quantity)';
  }
}
