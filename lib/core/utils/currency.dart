import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppCurrency {
  usd('\$', 'USD', 'US Dollar'),
  ngn('\u20A6', 'NGN', 'Nigerian Naira');

  const AppCurrency(this.symbol, this.code, this.label);
  final String symbol;
  final String code;
  final String label;
}

/// Persists the user's currency choice to SharedPreferences.
final currencyProvider =
    NotifierProvider<CurrencyNotifier, AppCurrency>(CurrencyNotifier.new);

class CurrencyNotifier extends Notifier<AppCurrency> {
  static const _key = 'preferred_currency';

  @override
  AppCurrency build() {
    _load();
    return AppCurrency.usd;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code == AppCurrency.ngn.code) {
      state = AppCurrency.ngn;
    }
  }

  Future<void> setCurrency(AppCurrency c) async {
    state = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, c.code);
  }
}

/// Format a number as currency with thousand separators.
String formatAmount(double? amount, AppCurrency currency) {
  if (amount == null) return '${currency.symbol}-';
  final whole = amount.round();
  final formatted = _addThousandSeparators(whole);
  return '${currency.symbol}$formatted';
}

String _addThousandSeparators(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return n < 0 ? '-${buf.toString()}' : buf.toString();
}
