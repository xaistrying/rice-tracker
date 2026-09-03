// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../app/enum/filter_period.dart';
import '../../app/extension/string_extension.dart';
import 'purchaser_model.dart';

/// [PurchaserModel.dateAdded] is written as 'dd/MM/yyyy HH:mm'.
final _dayFormat = DateFormat('dd/MM/yyyy');
final _timestampFormat = DateFormat('dd/MM/yyyy HH:mm');

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

/// Which half of a [PurchaserFilter] left nothing to show.
///
/// The two call for different advice: a query that matches nobody is fixed by
/// editing the query, not by widening the period.
enum FilterEmptyCause { query, period }

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
    // Both sides are folded, so 'tran' matches 'Trần'. Names are stored with
    // their marks but typing them costs the user several extra keystrokes per
    // letter, and most will type the bare form.
    final foldedQuery = query.trim().foldedForSearch;
    final range = rangeOn(now ?? DateTime.now());

    if (foldedQuery.isEmpty && range == null) return purchasers;

    return purchasers.where((purchaser) {
      if (foldedQuery.isNotEmpty &&
          !(purchaser.name ?? '').foldedForSearch.contains(foldedQuery)) {
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

  /// Why [apply] found nothing in [purchasers], or null when it found someone.
  ///
  /// The query is blamed only when it matches nobody at all: if it does match
  /// someone who simply falls outside the period, widening the period is what
  /// brings them back, so the period is the cause.
  ///
  /// Callers are expected to have already handled an empty [purchasers], which
  /// is not a filtering problem at all; it is reported as [FilterEmptyCause
  /// .period] here for want of anything better to say.
  FilterEmptyCause? emptyCause(
    List<PurchaserModel> purchasers, {
    DateTime? now,
  }) {
    final resolvedNow = now ?? DateTime.now();

    if (apply(purchasers, now: resolvedNow).isNotEmpty) return null;

    final queryOnly = withPeriod(FilterPeriod.all);

    if (query.trim().foldedForSearch.isNotEmpty &&
        queryOnly.apply(purchasers, now: resolvedNow).isEmpty) {
      return FilterEmptyCause.query;
    }

    return FilterEmptyCause.period;
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

/// The day a purchaser was added, to the minute, or null if it is missing or
/// malformed.
DateTime? purchaserAddedAt(PurchaserModel purchaser) {
  try {
    return _timestampFormat.parseStrict(purchaser.dateAdded ?? '');
  } catch (_) {
    return null;
  }
}

/// Newest first, with a time that cannot be read sinking to the bottom.
int _byNewestFirst(PurchaserModel a, PurchaserModel b) {
  final timeA = purchaserAddedAt(a);
  final timeB = purchaserAddedAt(b);

  if (timeA == null || timeB == null) {
    if (timeA == null && timeB == null) return 0;
    return timeA == null ? 1 : -1;
  }

  return timeB.compareTo(timeA);
}

/// Purchasers grouped by the day they were added, newest first within each day.
///
/// Grouping and ordering live here rather than in the list widget for the same
/// reason applying the filter does: the stats above the list are built from the
/// same data, and a second copy of this logic is how the two come to disagree.
///
/// [purchasers] arrives in the order records were created, and that position is
/// kept as the tiebreaker. [PurchaserModel.dateAdded] is only written to the
/// minute, so several purchasers entered inside one minute compare equal on
/// time — and [List.sort] is not stable, so without the tiebreaker their order
/// could differ from one rebuild to the next, shuffling under the reader.
Map<String, List<PurchaserModel>> groupPurchasersByDay(
  List<PurchaserModel> purchasers,
) {
  final byDay = <String, List<int>>{};

  for (var i = 0; i < purchasers.length; i++) {
    byDay.putIfAbsent(purchaserDayKey(purchasers[i]), () => []).add(i);
  }

  return {
    for (final entry in byDay.entries)
      entry.key:
          (entry.value..sort((a, b) {
                final byTime = _byNewestFirst(purchasers[a], purchasers[b]);
                // Later in the stored list means created later.
                return byTime != 0 ? byTime : b.compareTo(a);
              }))
              .map((i) => purchasers[i])
              .toList(),
  };
}
