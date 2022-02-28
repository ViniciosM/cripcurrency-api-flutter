
import 'dart:convert';
import 'package:cripto_flutter/models/coin_model.dart';

class HistoricModel {
  DateTime? operationDate;
  String? operationType;
  CoinModel? coin;
  double? value;
  double? quantity;

  HistoricModel({
    this.operationDate,
    this.operationType,
    this.coin,
    this.value,
    this.quantity,
  });

  HistoricModel copyWith({
    DateTime? operationDate,
    String? operationType,
    CoinModel? coin,
    double? value,
    double? quantity,
  }) {
    return HistoricModel(
      operationDate: operationDate ?? this.operationDate,
      operationType: operationType ?? this.operationType,
      coin: coin ?? this.coin,
      value: value ?? this.value,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'operationDate': operationDate?.millisecondsSinceEpoch,
      'operationType': operationType,
      'coin': coin?.toMap(),
      'value': value,
      'quantity': quantity,
    };
  }

  factory HistoricModel.fromMap(Map<String, dynamic> map) {
    return HistoricModel(
      operationDate: map['operationDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['operationDate']) : null,
      operationType: map['operationType'],
      coin: map['coin'] != null ? CoinModel.fromMap(map['coin']) : null,
      value: map['value']?.toDouble(),
      quantity: map['quantity']?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory HistoricModel.fromJson(String source) => HistoricModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'HistoricModel(operationDate: $operationDate, operationType: $operationType, coin: $coin, value: $value, quantity: $quantity)';
  }

}
