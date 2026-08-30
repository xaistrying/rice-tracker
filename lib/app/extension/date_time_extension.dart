// Package imports:
import 'package:intl/intl.dart';

/// Disambiguates ids generated within the same clock tick.
int _idSequence = 0;

extension DateTimeExtension on DateTime {
  /// An id that is unique even for calls made in quick succession.
  ///
  /// [DateTime.now] is much coarser than its microsecond unit on some
  /// platforms — 100 consecutive calls can all report the same value — so the
  /// timestamp alone collides. Colliding ids are dangerous here because
  /// records are looked up by id: two bags sharing one would both be removed
  /// by a single delete.
  String get uniqueId => '$microsecondsSinceEpoch-${_idSequence++}';

  String toTimeString() {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }
}
