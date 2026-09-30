import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final DateFormat _date = DateFormat('dd MMM yyyy, hh:mm a');

  static String formatPrice(double price) => _currency.format(price);

  static String formatDate(DateTime date) => _date.format(date);
}