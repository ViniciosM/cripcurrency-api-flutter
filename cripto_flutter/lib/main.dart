import 'package:cripto_flutter/my_app.dart';
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
        ChangeNotifierProvider(create: (context) => CoinRepository()),
        ChangeNotifierProvider(create: (context) => AccountRepository()),
        ChangeNotifierProvider(create: (context) => AppSettings()),
      ],
      child: const MyApp(),
    )
  );
}
