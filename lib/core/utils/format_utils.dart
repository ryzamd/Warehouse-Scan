import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormatUtils {
  static String formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMd(locale).format(date);
  }
  
  static String formatDateTime(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMd(locale).add_Hms().format(dateTime);
  }
  
  static String formatNumber(BuildContext context, num number) {
    final locale = Localizations.localeOf(context).toString();
    return NumberFormat.decimalPattern(locale).format(number);
  }
  
  static String formatCurrency(BuildContext context, num amount) {
    final locale = Localizations.localeOf(context).toString();
    return NumberFormat.currency(locale: locale, symbol: '¥').format(amount);
  }
}