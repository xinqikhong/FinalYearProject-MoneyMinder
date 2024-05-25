/*import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mypfm/view/currency_provider.dart';

class CurrencyService {
  final String apiKey; // Replace with your Open Exchange Rates API key

  CurrencyService(this.apiKey);

  Future<List<Currency>> fetchAvailableCurrencies() async {
    final url = Uri.parse(
        'https://openexchangerates.org/api/latest.json?app_id=$apiKey&base=USD'); // Replace base currency if needed
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('line 17 - response.statusCode == 200');
      final data = json.decode(response.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>;
      return rates.entries
          .map((entry) => Currency(
              code: entry.key,
              symbol: entry.value,
              name: getCurrencyName(entry.key)))
          .toList();
    } else {
      print('line 21 - Failed to fetch currencies');
      throw Exception('Failed to fetch currencies');
    }
  }

  // Replace this with a function that retrieves the currency name based on the code (optional)
  String getCurrencyName(String code) {
    // Implement logic to retrieve currency name based on code (e.g., using a separate API or lookup table)
    return code; // Placeholder for now
  }
}*/
