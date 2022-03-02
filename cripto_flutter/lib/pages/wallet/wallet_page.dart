import 'dart:ui';

import 'package:cripto_flutter/configs/app_settings.dart';
import 'package:cripto_flutter/models/position_model.dart';
import 'package:cripto_flutter/repositories/account_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int index = 0;
  double totalWallet = 0;
  double balance = 0;
  late NumberFormat real;
  late AccountRepository account;

  String graphicLabel = '';
  double graphicValue = 0;
  List<PositionModel> wallet = [];

  @override
  Widget build(BuildContext context) {
    account = context.watch<AccountRepository>();
    final loc = context.read<AppSettings>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
    balance = account.balance;

    setTotalWallet();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 48, bottom: 8),
              child: Text('Valor da Carteira', style: TextStyle(fontSize: 18)),
            ),
            Text(
              real.format(totalWallet),
              style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.5),
            ),
          ],
        ),
      ),
    );
  }

  setTotalWallet() {
    final walletList = account.wallet;

    setState(() {
      totalWallet = account.balance;
      for (var position in walletList) {
        totalWallet += position.currency!.price! * position.quantity!;
      }
    });
  }

  setGraphicData(int index) {
    if (index < 0) return;

    if (index == wallet.length) {
      graphicLabel = 'Saldo';
      graphicValue = account.balance;
    } else {
      graphicLabel = wallet[index].currency!.name!;
      graphicValue = wallet[index].currency!.price! * wallet[index].quantity!;
    }
  }

  loadWallet() {
    setGraphicData(index);
    wallet = account.wallet;
    final sizeList = wallet.length + 1;

    return List.generate(sizeList, (i) {
      final isTouched = i == index;
      final isBalance = i == sizeList - 1;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      final color = isTouched ? Colors.tealAccent : Colors.tealAccent[400];

      double percentage = 0;
      if (!isBalance) {
        percentage =
            wallet[i].currency!.price! * wallet[i].quantity! / totalWallet;
      } else {
        percentage = (account.balance > 0) ? account.balance / totalWallet : 0;
      }
      percentage *= 100;

      return PieChartSectionData(
        color: color,
        value: percentage,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      );
    });
  }

  loadGraphic() {
    return (account.balance <= 0)
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: PieChart(PieChartData(
                    sectionsSpace: 5,
                    centerSpaceRadius: 120,
                    sections: loadWallet(),
                    pieTouchData: PieTouchData(
                      touchCallback: (touch) => setState(() {
                        index = touch.touchedSection!.touchedSectionIndex;
                        setGraphicData(index);
                      }),
                    ))),
              ),
              Column(
                children: [
                  Text(
                    graphicLabel,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    real.format(graphicValue),
                    style: const TextStyle(
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  Widget loadHistoric() {
    final historic = account.historic;
    final date = DateFormat('dd/MM/yyyy - hh:mm');
    List<Widget> widgets = [];

    for (var operation in historic) {
      widgets.add(ListTile(
        title: Text(operation.currency!.name!),
        subtitle: Text(date.format(operation.operationDate!)),
        trailing: Text(
            real.format((operation.currency!.price! * operation.quantity!))),
      ));
      widgets.add(const Divider());
    }
    return Column(
      children: widgets,
    );
  }
}
