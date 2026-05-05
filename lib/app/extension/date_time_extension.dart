// Package imports:
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get uniqueId => microsecondsSinceEpoch.toString();

  String toTimeString() {
    return DateFormat('yyyy/MM/dd HH:mm').format(this);
  }
}
