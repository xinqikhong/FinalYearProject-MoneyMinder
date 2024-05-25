import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'currency_provider.dart';

class CurrencySettingScreen extends StatefulWidget {
  final String apiKey = '4b46bd46ff33430fb739ce4e243dea69';

  const CurrencySettingScreen({Key? key}) : super(key: key);
  
  @override
  _CurrencySettingScreenState createState() => _CurrencySettingScreenState();
}

class _CurrencySettingScreenState extends State<CurrencySettingScreen> {
  late Future<Map<String, String>> _countryNames;
  late Future<Map<String, double>> _currencyRates;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _countryNames = _fetchCountryNames();
    _currencyRates = _fetchCurrencyRates(widget.apiKey);
  }

  Future<Map<String, String>> _fetchCountryNames() async {
    final url = Uri.parse('https://openexchangerates.org/api/currencies.json?show_alternative=1');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data.cast<String, String>();
      } else {
        throw Exception('Failed to fetch country names (Status code: ${response.statusCode})');
      }
    } catch (error) {
      throw Exception('Error fetching country names: $error');
    }
  }

  Future<Map<String, double>> _fetchCurrencyRates(String apiKey) async {
    final url = Uri.parse('https://openexchangerates.org/api/latest.json?app_id=$apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;
        return rates.map((key, value) => MapEntry(key, value.toDouble()));
      } else {
        throw Exception('Failed to fetch currency rates (Status code: ${response.statusCode})');
      }
    } catch (error) {
      throw Exception('Error fetching currency rates: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Setting'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _countryNames,
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

          final countryNames = snapshot.data!;

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: FutureBuilder<Map<String, double>>(
                  future: _currencyRates,
                  builder: (context, rateSnapshot) {
                    if (rateSnapshot.hasError) {
                      return Center(
                        child: Text('Error fetching currency rates'),
                      );
                    }

                    if (!rateSnapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final currencyRates = rateSnapshot.data!;
                    final filteredCurrencies = countryNames.entries
                        .where((entry) => entry.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                          entry.value.toLowerCase().contains(_searchQuery.toLowerCase()))
                        .toList();

                    return ListView.builder(
                      itemCount: filteredCurrencies.length,
                      itemBuilder: (context, index) {
                        final entry = filteredCurrencies[index];
                        final currencyCode = entry.key;
                        final countryName = entry.value;
                        final rate = currencyRates[currencyCode] ?? 1.0;

                        return ListTile(
                          title: Text('$currencyCode - $countryName'),
                          trailing: currencyProvider.selectedCurrency?.code == currencyCode
                              ? Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            currencyProvider.setSelectedCurrency(currencyCode, rate);
                            Navigator.pop(context, currencyProvider.selectedCurrency);
                            //Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
