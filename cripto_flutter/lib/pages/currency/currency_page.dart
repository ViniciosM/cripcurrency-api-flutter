import 'package:cripto_flutter/configs/app_settings.dart';
import 'package:cripto_flutter/models/currency_model.dart';
import 'package:cripto_flutter/pages/currency_details/currency_details_page.dart';
import 'package:cripto_flutter/repositories/currency_repository.dart';
import 'package:cripto_flutter/repositories/favorites_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({Key? key}) : super(key: key);

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  late List<CurrencyModel> table;
  late NumberFormat real;
  late Map<String, String> loc;
  List<CurrencyModel> selected = [];
  late FavoritesRepository favoritesRep;
  late CurrencyRepository currenciesRep;

  readNumberFormat() {
    loc = context.watch<AppSettings>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
  }

  changeLanguageButton() {
    final locale = loc['locale'] == 'pt_BR' ? 'en_US' : 'pt_BR';
    final name = loc['locale'] == 'pt_BR' ? '\$' : 'R\$';

    return PopupMenuButton(
      icon: const Icon(Icons.language),
      itemBuilder: (context) => [
        PopupMenuItem(
            child: ListTile(
          leading: const Icon(Icons.swap_vert),
          title: Text('Usar $locale'),
          onTap: () {
            context.read<AppSettings>().setLocale(locale, name);
            Navigator.pop(context);
          },
        )),
      ],
    );
  }

  appBarDinamica() {
    if (selected.isEmpty) {
      return AppBar(
        title: const Text('Cripto Moedas'),
        actions: [
          changeLanguageButton(),
        ],
      );
    } else {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            clearSelected();
          },
        ),
        title: Text('${selected.length} selecionadas'),
        backgroundColor: Colors.blueGrey[50],
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        textTheme: const TextTheme(
          headline6: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  showDetails(CurrencyModel currency) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CurrencyDetailsPage(currency: currency,),
      ),
    );
  }

  clearSelected() {
    setState(() {
      selected = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // favoritas = Provider.of<FavoritasRepository>(context);
    favoritesRep = context.watch<FavoritesRepository>();
    currenciesRep = context.watch<CurrencyRepository>();
    table = currenciesRep.table;
    readNumberFormat();

    return Scaffold(
      appBar: appBarDinamica(),
      body: RefreshIndicator(
        onRefresh: () => currenciesRep.checkPrices(),
        child: ListView.separated(
          itemBuilder: (BuildContext context, int ic) {
            return ListTile(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              leading: (selected.contains(table[ic]))
                  ? const CircleAvatar(
                      child: Icon(Icons.check),
                    )
                  : SizedBox(
                      child: Image.network(table[ic].icon!),
                      width: 40,
                    ),
              title: Row(
                children: [
                  Text(
                    table[ic].name!,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (favoritesRep.list
                      .any((fav) => fav.acronym == table[ic].acronym))
                    const Icon(Icons.circle, color: Colors.amber, size: 8),
                ],
              ),
              trailing: Text(
                real.format(table[ic].price),
                style: const TextStyle(fontSize: 15),
              ),
              selected: selected.contains(table[ic]),
              selectedTileColor: Colors.indigo[50],
              onLongPress: () {
                setState(() {
                  (selected.contains(table[ic]))
                      ? selected.remove(table[ic])
                      : selected.add(table[ic]);
                });
              },
              onTap: () => showDetails(table[ic]),
            );
          },
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, ___) => const Divider(),
          itemCount: table.length,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selected.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                favoritesRep.saveAll(selected);
                clearSelected();
              },
              icon: const Icon(Icons.star),
              label: const Text(
                'FAVORITAR',
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
