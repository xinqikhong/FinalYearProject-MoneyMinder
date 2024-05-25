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
  final ScrollController _scrollController = ScrollController();
  bool _showTopButton = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _countryNames = _fetchCountryNames();
    _currencyRates = _fetchCurrencyRates(widget.apiKey);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _isDisposed = true;
    super.dispose();
  }

  void _scrollListener() {
    if (!_isDisposed) {
      setState(() {
        _showTopButton = _scrollController.offset > 100.0;
      });
    }
  }

  Future<Map<String, String>> _fetchCountryNames() async {
    final url = Uri.parse(
        'https://openexchangerates.org/api/currencies.json?show_alternative=1');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data.cast<String, String>();
      } else {
        throw Exception(
            'Failed to fetch country names (Status code: ${response.statusCode})');
      }
    } catch (error) {
      throw Exception('Error fetching country names: $error');
    }
  }

  Future<Map<String, double>> _fetchCurrencyRates(String apiKey) async {
    final url = Uri.parse(
        'https://openexchangerates.org/api/latest.json?app_id=$apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;
        return rates.map((key, value) => MapEntry(key, value.toDouble()));
      } else {
        throw Exception(
            'Failed to fetch currency rates (Status code: ${response.statusCode})');
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
          title: const Text('Currency Setting',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              )),
          centerTitle: true,
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
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
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
                          .where((entry) =>
                              entry.key
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ||
                              entry.value
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()))
                          .toList();

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredCurrencies.length,
                        itemBuilder: (context, index) {
                          final entry = filteredCurrencies[index];
                          final currencyCode = entry.key;
                          final countryName = entry.value;
                          final rate = currencyRates[currencyCode] ?? 1.0;

                          return ListTile(
                            title: Text('$currencyCode - $countryName'),
                            trailing: currencyProvider.selectedCurrency?.code ==
                                    currencyCode
                                ? Icon(Icons.check, color: Colors.green)
                                : null,
                            onTap: () {
                              currencyProvider.setSelectedCurrency(
                                  currencyCode, rate);
                              Navigator.pop(
                                  context, currencyProvider.selectedCurrency);
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
        floatingActionButton: _showTopButton
            ? FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(30), // Adjust the value as needed
                ),
                onPressed: () {
                  _scrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                },
                child: const Icon(Icons.arrow_upward),
              )
            : null);
  }
}
