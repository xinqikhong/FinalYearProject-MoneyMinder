import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  double _baseRate = 1.0;

  Currency? get selectedCurrency => _selectedCurrency;
  double get baseRate => _baseRate;

  CurrencyProvider() {
    _loadSelectedCurrency();
  }

  void setBaseRate(double rate) {
    _baseRate = rate;
    notifyListeners();
  }

  Future<void> setSelectedCurrency(String code, double rate) async {
    _selectedCurrency = Currency(code: code, rate: rate);
    notifyListeners();
    await _saveSelectedCurrency();
  }

  double convertAmount(double amount) {
    if (_selectedCurrency == null) {
      return amount;
    }

    // Use MYR rate as the base rate for conversion
    double amountInBaseCurrency = amount / _baseRate;
    print('amount:  $amount, _baseRate: $_baseRate');
    print(_selectedCurrency!.rate);
    return amountInBaseCurrency * _selectedCurrency!.rate;
  }

  Future<void> _saveSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedCurrency != null) {
      await prefs.setString('selectedCurrency', _selectedCurrency!.code);
      await prefs.setDouble('selectedCurrencyRate', _selectedCurrency!.rate);
    }
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
}
