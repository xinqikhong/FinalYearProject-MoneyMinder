import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Currency {
  final String code;
  final double rate;

  Currency({required this.code, required this.rate});

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'rate': rate,
    };
  }

  static Currency fromMap(Map<String, dynamic> map) {
    return Currency(
      code: map['code'],
      rate: map['rate'],
    );
  }
}

class CurrencyProvider with ChangeNotifier {
  Currency? _selectedCurrency;
  late double _baseRate;

  Currency? get selectedCurrency => _selectedCurrency;
  double get baseRate => _baseRate;

  CurrencyProvider() {
    _loadBaseRate();
    _fetchCurrencyRates();
    _loadSelectedCurrency();
  }

  Future<void> _fetchCurrencyRates() async {
    final apiKey =
        '4b46bd46ff33430fb739ce4e243dea69'; // Replace with your actual API key
    final url = Uri.parse(
        'https://openexchangerates.org/api/latest.json?app_id=$apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;
        final myrRate = rates['MYR'] ?? 1.0;
        _baseRate = myrRate;
        await _saveBaseRate();
        notifyListeners(); // Notify listeners about the change
      } else {
        // Handle error fetching rates
        print(
            'Error fetching currency rates (Status code: ${response.statusCode})');
      }
    } catch (error) {
      // Handle errors
      print('Error fetching currency rates: $error');
    }
  }

  /*void setBaseRate(double rate) {
    _baseRate = rate;
    notifyListeners();
  }*/

  Future<void> setSelectedCurrency(String code, double rate) async {
    _selectedCurrency = Currency(code: code, rate: rate);
    notifyListeners();
    await _saveSelectedCurrency();
  }

  double convertAmountDisplay(double amount) {
    if (_selectedCurrency == null) {
      return amount;
    }

    // Use MYR rate as the base rate for conversion
    double amountInBaseCurrency = amount / _baseRate;
    print('amount:  $amount, _baseRate: $_baseRate');
    print(_selectedCurrency!.rate);
    return amountInBaseCurrency * _selectedCurrency!.rate;
  }

  double convertAmountSend(double amount) {
    if (_selectedCurrency == null) {
      return amount;
    }

    // Use MYR rate as the base rate for conversion
    double amountInSelectedCurrency = amount / _selectedCurrency!.rate;
    print('amount:  $amount, _baseRate: $_baseRate');
    print(_selectedCurrency!.rate);
    return amountInSelectedCurrency * _baseRate;
  }

  Future<void> _saveSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedCurrency != null) {
      await prefs.setString('selectedCurrency', _selectedCurrency!.code);
      await prefs.setDouble('selectedCurrencyRate', _selectedCurrency!.rate);
    }
  }

  Future<void> _saveBaseRate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('baseRate', _baseRate);
  }

  Future<void> _loadSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('selectedCurrency');
    final rate = prefs.getDouble('selectedCurrencyRate');
    if (code != null && rate != null) {
      _selectedCurrency = Currency(code: code, rate: rate);
      notifyListeners();
    }
  }

  Future<void> _loadBaseRate() async {
    final prefs = await SharedPreferences.getInstance();
    final baseRate = prefs.getDouble('baseRate');
    if (baseRate != null) {
      _baseRate = baseRate;
      notifyListeners();
    }
  }
}
