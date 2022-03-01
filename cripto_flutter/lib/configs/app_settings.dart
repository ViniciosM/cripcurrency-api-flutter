


import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class AppSettings extends ChangeNotifier {

  late Box box;

  Map<String, String> locale = {
    'locale': 'pt_BR',
    'name': 'R\$',
  }

  AppSettings(){
    _startSettings();
  }

  _startSettings() async {
    await _startPreferences();
    await _readLocale();
  }

  Future<void> _startPreferences() async {
    box = await Hive.openBox('preferences');
  }

  _readLocale(){
    final local = box.get('local') ?? 'pt_BR';
    final name = box.get('name') ?? 'R\$';

    locale = {
      'locale': local,
      'name': name,
    };

    notifyListeners();
  }

   setLocale(String local, String name) async {
    await box.put('local', local);
    await box.put('name', name);
    await _readLocale();
  }

}