import 'package:cripto_flutter/database/db.dart';
import 'package:cripto_flutter/models/currency_model.dart';
import 'package:cripto_flutter/models/historic_model.dart';
import 'package:cripto_flutter/models/position_model.dart';
import 'package:cripto_flutter/repositories/currency_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqlite_api.dart';

class AccountRepository extends ChangeNotifier {
  late Database db;
  List<PositionModel> _wallet = [];
  List<HistoricModel> _historic = [];
  double _balance = 0;
  CurrencyRepository currencies;

  get balance => _balance;
  List<PositionModel> get wallet => _wallet;
  List<HistoricModel> get historic => _historic;

  AccountRepository({required this.currencies}) {
    _initRepository();
  }

  _initRepository() async {
    await _getBalance();
    await _getWallet();
    await _getHistoric();
  }

  _getBalance() async {
    db = await DB.instance.database;
    List account = await db.query('account', limit: 1);
    _balance = account.first['balance'];
    notifyListeners();
  }

  setBalance(double value) async {
    db = await DB.instance.database;
    db.update('account', {
      'balance': value,
    });
    _balance = value;
    notifyListeners();
  }

  buy(CurrencyModel currency, double value) async {
    db = await DB.instance.database;

    await db.transaction((txn) async {
      final currencyPosition = await txn
          .query('wallet', where: 'acronym = ?', whereArgs: [currency.acronym]);
      if (currencyPosition.isEmpty) {
        await txn.insert('wallet', {
          'acronym': currency.acronym,
          'currency': currency.name,
          'quantity': (value / currency.price!).toString()
        });
      } else {
        final current =
            double.parse(currencyPosition.first['quantity'].toString());
        await txn.update(
          'wallet',
          {'quantity': (current + (value / currency.price!)).toString()},
          where: 'acronym = ?',
          whereArgs: [currency.acronym],
        );
      }
      await txn.insert('historic', {
        'acronym': currency.acronym,
        'currency': currency.name,
        'quantity': (value / currency.price!).toString(),
        'value': value,
        'operationType': 'buy',
        'operationDate': DateTime.now().microsecondsSinceEpoch
      });
      await _initRepository();
      notifyListeners();
    });
  }

  _getWallet() async {
    _wallet = [];
    List positions = await db.query('wallet');

    positions.forEach((position) {
      CurrencyModel currency = currencies.table.firstWhere(
        (c) => c.acronym == position['acronym'],
      );
      _wallet.add(PositionModel(
        currency: currency,
        quantity: double.parse(position['quantity']),
      ));
    });
    notifyListeners();
  }

  _getHistoric() async {
    _historic = [];
    List operations = await db.query('historic');

    operations.forEach((operation) {
      CurrencyModel currency =
          currencies.table.firstWhere((c) => c.acronym == operation['acronym']);
      _historic.add(HistoricModel(
        operationDate:
            DateTime.fromMicrosecondsSinceEpoch(operation['operationDate']),
        operationType: operation['operationType'],
        currency: currency,
        value: operation['value'],
        quantity: double.parse(operation['quantity']),
      ));
    });
    notifyListeners();
  }
}
