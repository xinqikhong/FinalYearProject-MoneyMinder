import 'package:flutter/material.dart';
import 'package:mypfm/view/currency_provider.dart';
import 'package:mypfm/view/currency_service.dart';
import 'package:provider/provider.dart';

class CurrencySettingScreen extends StatefulWidget {
  @override
  _CurrencySettingScreenState createState() => _CurrencySettingScreenState();
}

class _CurrencySettingScreenState extends State<CurrencySettingScreen> {
  late Future<List<Currency>> _availableCurrencies;

  @override
  void initState() {
    super.initState();
    _availableCurrencies = _fetchAvailableCurrencies();
  }

  Future<List<Currency>> _fetchAvailableCurrencies() async {
    final currencyService = CurrencyService('4b46bd46ff33430fb739ce4e243dea69'); // Replace with your API key
    return await currencyService.fetchAvailableCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Setting'),
      ),
      body: FutureBuilder<List<Currency>>(
        future: _availableCurrencies,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching currencies'),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final availableCurrencies = snapshot.data!;

          return ListView.builder(
            itemCount: availableCurrencies.length,
            itemBuilder: (context, index) {
              final currency = availableCurrencies[index];
              return ListTile(
                title: Text('${currency.code} - ${currency.name}'),
                trailing: currencyProvider.selectedCurrency?.code == currency.code
                    ? Icon(Icons.check)
                    : null,
                onTap: () {
                  // Update selected currency in the provider
                  currencyProvider.selectedCurrency = currency;

                  // Close the Currency Setting Screen and navigate back
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}
