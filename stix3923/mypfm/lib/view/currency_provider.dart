import 'package:flutter/material.dart';

class Currency with ChangeNotifier {
  Currency({required this.code, required this.symbol, required this.name});

  String code;
  String symbol;
  String name;

  void setCurrency(Currency newCurrency) {
    code = newCurrency.code;
    symbol = newCurrency.symbol;
    name = newCurrency.name;
    notifyListeners(); // Notify listeners about the change
  }
}

class CurrencyProvider extends ChangeNotifier {
  Currency? _selectedCurrency;

  Currency? get selectedCurrency => _selectedCurrency;

  set selectedCurrency(Currency? newCurrency) {
    _selectedCurrency = newCurrency;
    notifyListeners();
  }
}
