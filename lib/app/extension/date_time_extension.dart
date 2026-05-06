// Package imports:
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get uniqueId => microsecondsSinceEpoch.toString();

  String toTimeString() {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }
}
