
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cripto_flutter/database/db_firestore.dart';
import 'package:cripto_flutter/models/currency_model.dart';
import 'package:cripto_flutter/repositories/currency_repository.dart';
import 'package:cripto_flutter/services/auth_service.dart';
import 'package:flutter/cupertino.dart';

class FavoritesRepository extends ChangeNotifier{

  List<CurrencyModel> _list = [];
  late FirebaseFirestore db;
  late AuthService auth;
  CurrencyRepository currencies;

  FavoritesRepository({required this.auth, required this.currencies}) {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
    await _readFavorites();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  _readFavorites() async {
    if (auth.user != null && _list.isEmpty) {
      try {
        final snapshot = await db
            .collection('users/${auth.user!.uid}/favorites')
            .get();

        snapshot.docs.forEach((doc) {
          CurrencyModel currency = currencies.table
              .firstWhere((currency) => currency.acronym == doc.get('acronym'));
          _list.add(currency);

          notifyListeners();
        });
      } catch (e) {
        print('No one user id');
      }
    }
  }

  UnmodifiableListView<CurrencyModel> get list => UnmodifiableListView(_list);

  saveAll(List<CurrencyModel> currencies) {
    currencies.forEach((currency) async {
      if (!_list.any((current) => current.acronym == currency.acronym)) {
        _list.add(currency);
        await db
            .collection('users/${auth.user!.uid}/favorites')
            .doc(currency.acronym)
            .set({
          'currency': currency.name,
          'acronym': currency.acronym,
          'price': currency.price,
        });
      }
    });
    notifyListeners();
  }

  remove(CurrencyModel currency) async {
    await db
        .collection('user/${auth.user!.uid}/favorites')
        .doc(currency.acronym)
        .delete();
    _list.remove(currency);
    notifyListeners();
  }

}