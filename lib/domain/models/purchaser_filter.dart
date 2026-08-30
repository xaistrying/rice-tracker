// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../app/enum/filter_period.dart';
import 'purchaser_model.dart';

/// [PurchaserModel.dateAdded] is written as 'dd/MM/yyyy HH:mm'.
final _dayFormat = DateFormat('dd/MM/yyyy');

/// Parses a 'dd/MM/yyyy' day, or null if it is malformed.
///
/// Uses [DateFormat.parseStrict] so a malformed value is rejected rather than
/// silently coerced into some other date.
DateTime? parseDayKey(String key) {
  try {
    return _dayFormat.parseStrict(key);
  } catch (_) {
    return null;
  }
}

/// The 'dd/MM/yyyy' part of [PurchaserModel.dateAdded].
String purchaserDayKey(PurchaserModel purchaser) =>
    (purchaser.dateAdded ?? '').split(' ').first;

/// The day a purchaser was added, or null if it is missing or malformed.
DateTime? purchaserDay(PurchaserModel purchaser) =>
    parseDayKey(purchaserDayKey(purchaser));

/// The name query and time period the home list is narrowed by.
///
/// Applying it lives here rather than in the widgets so the list and the
/// stats above it cannot disagree about what is being shown.
@immutable
class PurchaserFilter {
  const PurchaserFilter({
    this.query = '',
    this.period = FilterPeriod.all,
    this.customRange,
  });

  final String query;
  final FilterPeriod period;

  /// Only meaningful when [period] is [FilterPeriod.custom].
  final DateTimeRange? customRange;

  bool get isFiltering => query.trim().isNotEmpty || period != FilterPeriod.all;

  /// The same filter narrowed by a different [query].
  PurchaserFilter withQuery(String query) =>
      PurchaserFilter(query: query, period: period, customRange: customRange);

  /// The same filter switched to [period].
  ///
  /// Any custom range is dropped unless it is still the period in use, so
  /// leaving the custom period and coming back to it starts fresh rather than
  /// silently reusing the range picked last time.
  PurchaserFilter withPeriod(FilterPeriod period) => PurchaserFilter(
    query: query,
    period: period,
    customRange: period == FilterPeriod.custom ? customRange : null,
  );

  /// The same filter switched to [range] as its custom period.
  PurchaserFilter withCustomRange(DateTimeRange range) => PurchaserFilter(
    query: query,
    period: FilterPeriod.custom,
    customRange: range,
  );

  /// The inclusive span of days [period] covers, or null when it covers all.
  ///
  /// Days are built with the [DateTime] constructor rather than by adding a
  /// [Duration], so a day is always a calendar day even across a daylight
  /// saving change.
  DateTimeRange? rangeOn(DateTime now) {
    switch (period) {
      case FilterPeriod.all:
        return null;
      case FilterPeriod.today:
        final today = DateTime(now.year, now.month, now.day);
        return DateTimeRange(start: today, end: today);
      case FilterPeriod.thisWeek:
        // Weeks run Monday (weekday 1) to Sunday.
        final monday = DateTime(
          now.year,
          now.month,
          now.day - (now.weekday - 1),
        );
        return DateTimeRange(
          start: monday,
          end: DateTime(monday.year, monday.month, monday.day + 6),
        );
      case FilterPeriod.thisMonth:
        // Day 0 of the next month is the last day of this one.
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case FilterPeriod.custom:
        return customRange;
    }
  }

  /// [purchasers] narrowed to those matching both the query and the period.
  List<PurchaserModel> apply(List<PurchaserModel> purchasers, {DateTime? now}) {
    final trimmedQuery = query.trim().toLowerCase();
    final range = rangeOn(now ?? DateTime.now());

    if (trimmedQuery.isEmpty && range == null) return purchasers;

    return purchasers.where((purchaser) {
      if (trimmedQuery.isNotEmpty &&
          !(purchaser.name ?? '').toLowerCase().contains(trimmedQuery)) {
        return false;
      }

      if (range == null) return true;

      final day = purchaserDay(purchaser);

      // An undated record cannot be placed in a period, so it is only shown
      // when no period is selected.
      if (day == null) return false;

      return !day.isBefore(range.start) && !day.isAfter(range.end);
    }).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaserFilter &&
          other.query == query &&
          other.period == period &&
          other.customRange == customRange;

  @override
  int get hashCode => Object.hash(query, period, customRange);
}
