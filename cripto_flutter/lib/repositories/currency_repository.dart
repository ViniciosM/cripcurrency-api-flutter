import 'dart:async';
import 'dart:convert';

import 'package:cripto_flutter/database/db.dart';
import 'package:cripto_flutter/models/currency_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqlite_api.dart';

class CurrencyRepository extends ChangeNotifier {
  List<CurrencyModel> _table = [];
  late Timer interval;

  List<CurrencyModel> get table => _table;

  CurrencyRepository() {
    _setupCurrencyTable();
    _setupDataCurrencyTable();
    _readCurrencyTable();
  }

  getCurrencyHistory(CurrencyModel currency) async {
    final responde = await http.get(Uri.parse(
        'https://api.coinbase.com/v2/assets/prices/${currency.baseId}?base=BRL'));

    List<Map<String, dynamic>> prices = [];

    if (responde.statusCode == 200) {
      final json = jsonDecode(responde.body);
      final Map<String, dynamic> currency = json['data']['prices'];

      prices.add(currency['hour']);
      prices.add(currency['day']);
      prices.add(currency['week']);
      prices.add(currency['month']);
      prices.add(currency['year']);
      prices.add(currency['all']);
    }

    return prices;
  }

  checkPrices() async {
    String uri = 'https://api.coinbase.com/v2/assets/prices?base=BR';

    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> currencies = json['data'];

      Database db = await DB.instance.database;

      Batch batch = db.batch();

      _table.forEach((current) {
        currencies.forEach((fresh) {
          if (current.baseId == fresh['base_id']) {
            final currency = fresh['prices'];
            final price = currency['latest_price'];
            final timestamp = DateTime.parse(price['timestamp']);

            batch.update(
              'currencies',
              {
                'price': currency['latest'],
                'timestamp': timestamp.microsecondsSinceEpoch,
                'varHour': price['percent_change']['hour'].toString(),
                'varDay': price['percent_change']['day'].toString(),
                'varWeek': price['percent_change']['week'].toString(),
                'varMonth': price['percent_change']['month'].toString(),
                'varYear': price['percent_change']['year'].toString(),
                'varTotalPeriod': price['percent_change']['all'].toString(),
              },
              where: 'baseId = ?',
              whereArgs: [current.baseId],
            );
          }
        });
      });
      await batch.commit(noResult: true);
      await _readCurrencyTable();
    }
  }

  _readCurrencyTable() async {
    Database db = await DB.instance.database;

    List results = await db.query('currencies');

    _table = results.map((row) {
      return CurrencyModel(
        baseId: row['baseId'],
        icon: row['icon'],
        acronym: row['acronym'],
        name: row['name'],
        price: double.parse(row['price']),
        timeStamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp']),
        varHour: double.parse(row['varHour']),
        varDay: double.parse(row['varDay']),
        varWeek: double.parse(row['varWeek']),
        varMonth: double.parse(row['varMonth']),
        varYear: double.parse(row['varYear']),
        varTotalPeriod: double.parse(row['varTotalPeriod']),
      );
    }).toList();
    notifyListeners();
  }

  _currencyTableIsEmpty() async {
    Database db = await DB.instance.database;
    List results = await db.query('currencies');
    return results.isEmpty;
  }

  _setupDataCurrencyTable() async {
    if (await _currencyTableIsEmpty()) {
      String uri = 'https://api.coinbase.com/v2/assets/search?base=BRL';

      final response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> currencies = json['data'];
        Database db = await DB.instance.database;
        Batch batch = db.batch();

        for (var currency in currencies) {
          final price = currency['latest_price'];
          final timestamp = DateTime.parse(price['timestamp']);

          batch.insert('currency', {
            'baseId': currency['id'],
            'acronym': currency['symbol'],
            'name': currency['name'],
            'icon': currency['image_url'],
            'price': currency['latest'],
            'timestamp': timestamp.millisecondsSinceEpoch,
            'varHour': currency['percent_change']['hour'].toString(),
            'varDay': currency['percent_change']['day'].toString(),
            'varWeek': currency['percent_change']['week'].toString(),
            'varMonth': currency['percent_change']['month'].toString(),
            'varYear': currency['percent_change']['year'].toString(),
            'varTotalPeriod': currency['percent_change']['all'].toString()
          });
        }
        await batch.commit(noResult: true);
      }
    }
  }

  _setupCurrencyTable() async {
    final String table = '''
      CREATE TABLE IF NOT EXISTS currencies (
        baseId TEXT PRIMARY KEY,
        acronym TEXT,
        name TEXT,
        icon TEXT,
        price TEXT,
        timestamp INTEGER,
        varHour TEXT,
        varDay TEXT,
        varWeek TEXT,
        varMonth TEXT,
        varYear TEXT,
        varTotalPeriod TEXT
      );
    ''';
    Database db = await DB.instance.database;
    await db.execute(table);
  }
}
