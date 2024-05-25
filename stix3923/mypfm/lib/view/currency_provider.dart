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
  String? _userId;

  Currency? get selectedCurrency => _selectedCurrency;
  double get baseRate => _baseRate;

  CurrencyProvider() {
    _loadBaseRate();
    _fetchCurrencyRates();
    //_loadSelectedCurrency();
  }

  void setUserId(String? userId) {
    _userId = userId;
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
    await _saveSelectedCurrency();
    notifyListeners();
  }

  double convertAmountDisplay(double amount) {
    if (_selectedCurrency == null) {
      return amount;
    }

    // Use MYR rate as the base rate for conversion
    double amountInBaseCurrency = amount / _baseRate;
    print('amount:  $amount, _baseRate: $_baseRate');
    print(_selectedCurrency!.code);
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
    print(_selectedCurrency!.code);
    print(_selectedCurrency!.rate);
    return amountInSelectedCurrency * _baseRate;
  }

  Future<void> _saveSelectedCurrency() async {
    if (_userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (_selectedCurrency != null) {
      await prefs.setString(
          'selectedCurrency_${_userId!}', _selectedCurrency!.code);
      await prefs.setDouble(
          'selectedCurrencyRate_${_userId!}', _selectedCurrency!.rate);
    }
  }

  Future<void> _saveBaseRate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('baseRate', _baseRate);
  }

  Future<void> _loadSelectedCurrency() async {
    if (_userId == null) {
      // User ID is null, initialize with MYR
      _selectedCurrency = Currency(code: 'MYR', rate: _baseRate);
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('selectedCurrency_${_userId!}');
    final rate = prefs.getDouble('selectedCurrencyRate_${_userId!}');
    if (code != null && rate != null) {
      _selectedCurrency = Currency(code: code, rate: rate);
    } else {
      // No currency saved for the user, initialize with MYR
      _selectedCurrency = Currency(code: 'MYR', rate: _baseRate);
    }
    notifyListeners();
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
