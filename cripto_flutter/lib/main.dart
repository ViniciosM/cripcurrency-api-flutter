import 'package:cripto_flutter/configs/app_settings.dart';
import 'package:cripto_flutter/configs/hive_config.dart';
import 'package:cripto_flutter/my_app.dart';
import 'package:cripto_flutter/repositories/account_repository.dart';
import 'package:cripto_flutter/repositories/currency_repository.dart';
import 'package:cripto_flutter/repositories/favorites_repository.dart';
import 'package:cripto_flutter/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();
  //await Firebase.initializeApp();
  runApp(
    MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthService()),
      ChangeNotifierProvider(create: (context) => CurrencyRepository()),
      ChangeNotifierProvider(
          create: (context) => AccountRepository(
              currencies: context.read<CurrencyRepository>())),
      ChangeNotifierProvider(
          create: (context) => FavoritesRepository(
              currencies: context.read<CurrencyRepository>(),
              auth: context.read<AuthService>())),
      ChangeNotifierProvider(create: (context) => AppSettings()),
    ],
    child: const MyApp(),
  ));
}
