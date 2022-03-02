import 'package:cripto_flutter/configs/app_settings.dart';
import 'package:cripto_flutter/models/currency_model.dart';
import 'package:cripto_flutter/repositories/currency_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

class GraphicHistoric extends StatefulWidget {
  CurrencyModel currency;

  GraphicHistoric({Key? key, required this.currency}) : super(key: key);

  @override
  State<GraphicHistoric> createState() => _GraphicHistoricState();
}

enum Period { hora, dia, semana, mes, ano, total }

class _GraphicHistoricState extends State<GraphicHistoric> {
  List<Color> colors = [
    const Color(0xFF3F51B5),
  ];
  Period period = Period.hora;
  List<Map<String, dynamic>> historic = [];
  List completeData = [];
  List<FlSpot> dataGraphic = [];
  double maxX = 0;
  double maxY = 0;
  double minY = 0;
  ValueNotifier<bool> loaded = ValueNotifier(false);
  late CurrencyRepository currencyRepository;
  late Map<String, String> loc;
  late NumberFormat real;

  setDados() async {
    loaded.value = false;
    dataGraphic = [];

    if (historic.isEmpty) {
      historic = await currencyRepository.getCurrencyHistory(widget.currency);
    }

    completeData = historic[period.index]['prices'];
    completeData = completeData.reversed.map((item) {
      double preco = double.parse(item[0]);
      int time = int.parse(item[1].toString() + '000');
      return [preco, DateTime.fromMillisecondsSinceEpoch(time)];
    }).toList();

    maxX = completeData.length.toDouble();
    maxY = 0;
    minY = double.infinity;

    for (var item in completeData) {
      maxY = item[0] > maxY ? item[0] : maxY;
      minY = item[0] < minY ? item[0] : minY;
    }

    for (int i = 0; i < completeData.length; i++) {
      dataGraphic.add(FlSpot(
        i.toDouble(),
        completeData[i][0],
      ));
    }
    loaded.value = true;
  }

  LineChartData getChartData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: dataGraphic,
          isCurved: true,
          colors: colors,
          barWidth: 2,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            colors: colors.map((color) => color.withOpacity(0.15)).toList(),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: const Color(0xFF343434),
          getTooltipItems: (data) {
            return data.map((item) {
              final date = getDate(item.spotIndex);
              return LineTooltipItem(
                real.format(item.y),
                const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: '\n $date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(.5),
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }

  getDate(int index) {
    DateTime date = completeData[index][1];
    if (period != Period.ano && period != Period.total) {
      return DateFormat('dd/MM - hh:mm').format(date);
    } else {
      return DateFormat('dd/MM/y').format(date);
    }
  }

  chartButton(Period p, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        onPressed: () => setState(() => period = p),
        child: Text(label),
        style: (period != p)
            ? ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.grey),
              )
            : ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.indigo[50]),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    currencyRepository = context.read<CurrencyRepository>();
    loc = context.read<AppSettings>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
    setDados();

    return Container(
      child: AspectRatio(
        aspectRatio: 2,
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  chartButton(Period.hora, '1H'),
                  chartButton(Period.dia, '24H'),
                  chartButton(Period.semana, '7D'),
                  chartButton(Period.mes, 'Mês'),
                  chartButton(Period.ano, 'Ano'),
                  chartButton(Period.total, 'Tudo'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: ValueListenableBuilder(
                valueListenable: loaded,
                builder: (context, bool isLoaded, _) {
                  return (isLoaded)
                      ? LineChart(
                          getChartData(),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
