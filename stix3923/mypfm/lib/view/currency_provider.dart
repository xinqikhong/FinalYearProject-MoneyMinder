import 'package:flutter/material.dart';

class Currency {
  final String code;
  final double rate;

  Currency({required this.code, required this.rate});
}

class CurrencyProvider with ChangeNotifier {
  Currency? _selectedCurrency;

  Currency? get selectedCurrency => _selectedCurrency;

  void setSelectedCurrency(String code, double rate) {
    _selectedCurrency = Currency(code: code, rate: rate);
    notifyListeners();
  }

  double convertAmount(double amount, double baseRate) {
    if (_selectedCurrency == null) {
      return amount;
    }

    return amount * (_selectedCurrency!.rate / baseRate);
  }
}
