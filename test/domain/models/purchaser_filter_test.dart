// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:rice_tracker/app/enum/filter_period.dart';
import 'package:rice_tracker/domain/models/purchaser_filter.dart';
import 'package:rice_tracker/domain/models/purchaser_model.dart';

PurchaserModel person(String name, String? dateAdded) =>
    PurchaserModel(id: name, name: name, dateAdded: dateAdded);

void main() {
  // A Wednesday, so the Monday and Sunday of its week are both mid-month.
  final now = DateTime(2026, 8, 26, 14, 30);

  group('period ranges', () {
    DateTimeRange? rangeFor(FilterPeriod period) =>
        PurchaserFilter(period: period).rangeOn(now);

    test('all covers everything', () {
      expect(rangeFor(FilterPeriod.all), isNull);
    });

    test('today is a single day', () {
      final range = rangeFor(FilterPeriod.today)!;
      expect(range.start, DateTime(2026, 8, 26));
      expect(range.end, DateTime(2026, 8, 26));
    });

    test('this week runs Monday to Sunday', () {
      final range = rangeFor(FilterPeriod.thisWeek)!;
      expect(range.start, DateTime(2026, 8, 24), reason: 'Monday');
      expect(range.end, DateTime(2026, 8, 30), reason: 'Sunday');
    });

    test('a week is correct when it spans a month boundary', () {
      // Wednesday 2 September 2026; that week starts on 31 August.
      final range = PurchaserFilter(
        period: FilterPeriod.thisWeek,
      ).rangeOn(DateTime(2026, 9, 2))!;

      expect(range.start, DateTime(2026, 8, 31));
      expect(range.end, DateTime(2026, 9, 6));
    });

    test('a week is correct when it spans a year boundary', () {
      // Friday 1 January 2027; that week starts on 28 December 2026.
      final range = PurchaserFilter(
        period: FilterPeriod.thisWeek,
      ).rangeOn(DateTime(2027, 1, 1))!;

      expect(range.start, DateTime(2026, 12, 28));
      expect(range.end, DateTime(2027, 1, 3));
    });

    test('a Monday belongs to its own week, not the previous one', () {
      final range = PurchaserFilter(
        period: FilterPeriod.thisWeek,
      ).rangeOn(DateTime(2026, 8, 24))!;

      expect(range.start, DateTime(2026, 8, 24));
    });

    test('a Sunday belongs to the week that began six days earlier', () {
      final range = PurchaserFilter(
        period: FilterPeriod.thisWeek,
      ).rangeOn(DateTime(2026, 8, 30))!;

      expect(range.start, DateTime(2026, 8, 24));
      expect(range.end, DateTime(2026, 8, 30));
    });

    test('this month ends on the real last day', () {
      final range = rangeFor(FilterPeriod.thisMonth)!;
      expect(range.start, DateTime(2026, 8, 1));
      expect(range.end, DateTime(2026, 8, 31));
    });

    test('a 30-day month ends on the 30th', () {
      final range = PurchaserFilter(
        period: FilterPeriod.thisMonth,
      ).rangeOn(DateTime(2026, 9, 15))!;

      expect(range.end, DateTime(2026, 9, 30));
    });

    test('February in a leap year ends on the 29th', () {
      final range = PurchaserFilter(
        period: FilterPeriod.thisMonth,
      ).rangeOn(DateTime(2028, 2, 10))!;

      expect(range.end, DateTime(2028, 2, 29));
    });

    test('December does not roll into the wrong year', () {
      final range = PurchaserFilter(
        period: FilterPeriod.thisMonth,
      ).rangeOn(DateTime(2026, 12, 10))!;

      expect(range.start, DateTime(2026, 12, 1));
      expect(range.end, DateTime(2026, 12, 31));
    });
  });

  group('apply', () {
    final people = [
      person('today', '26/08/2026 09:00'),
      person('monday', '24/08/2026 09:00'),
      person('lastWeek', '19/08/2026 09:00'),
      person('lastMonth', '15/07/2026 09:00'),
      person('undated', null),
      person('malformed', 'not-a-date'),
    ];

    List<String> namesFor(PurchaserFilter filter) =>
        filter.apply(people, now: now).map((e) => e.name!).toList();

    test('all returns every record, undated ones included', () {
      expect(namesFor(const PurchaserFilter()), [
        'today',
        'monday',
        'lastWeek',
        'lastMonth',
        'undated',
        'malformed',
      ]);
    });

    test('today matches only that day', () {
      expect(namesFor(const PurchaserFilter(period: FilterPeriod.today)), [
        'today',
      ]);
    });

    test('this week includes its first day', () {
      expect(namesFor(const PurchaserFilter(period: FilterPeriod.thisWeek)), [
        'today',
        'monday',
      ]);
    });

    test('this month spans the whole month', () {
      expect(namesFor(const PurchaserFilter(period: FilterPeriod.thisMonth)), [
        'today',
        'monday',
        'lastWeek',
      ]);
    });

    test('a period excludes undated and malformed records', () {
      final filtered = namesFor(
        const PurchaserFilter(period: FilterPeriod.thisMonth),
      );

      expect(filtered, isNot(contains('undated')));
      expect(filtered, isNot(contains('malformed')));
    });

    test('a custom range is inclusive at both ends', () {
      final filter = PurchaserFilter(
        period: FilterPeriod.custom,
        customRange: DateTimeRange(
          start: DateTime(2026, 8, 19),
          end: DateTime(2026, 8, 24),
        ),
      );

      expect(namesFor(filter), ['monday', 'lastWeek']);
    });

    test('a single-day custom range matches that day', () {
      final filter = PurchaserFilter(
        period: FilterPeriod.custom,
        customRange: DateTimeRange(
          start: DateTime(2026, 8, 24),
          end: DateTime(2026, 8, 24),
        ),
      );

      expect(namesFor(filter), ['monday']);
    });

    test('a custom period with no range set filters nothing out', () {
      expect(
        namesFor(const PurchaserFilter(period: FilterPeriod.custom)),
        hasLength(people.length),
      );
    });

    test('the query matches on any part of the name, ignoring case', () {
      final matches = const PurchaserFilter(
        query: 'MOND',
      ).apply(people, now: now);

      expect(matches.map((e) => e.name), ['monday']);
    });

    test('a whitespace-only query is not treated as a filter', () {
      expect(namesFor(const PurchaserFilter(query: '   ')), hasLength(6));
    });

    test('query and period both apply', () {
      final filter = const PurchaserFilter(
        query: 'a',
        period: FilterPeriod.thisMonth,
      );

      // 'today' and 'monday' contain an 'a'; 'lastWeek' does too, but only
      // those within the month survive both conditions.
      expect(namesFor(filter), ['today', 'monday', 'lastWeek']);
    });

    test('the source list is never mutated', () {
      const PurchaserFilter(period: FilterPeriod.today).apply(people, now: now);
      expect(people, hasLength(6));
    });
  });

  group('switching period', () {
    final customFilter = PurchaserFilter(
      query: 'bob',
      period: FilterPeriod.custom,
      customRange: DateTimeRange(
        start: DateTime(2026, 8, 3),
        end: DateTime(2026, 8, 12),
      ),
    );

    test('leaving custom drops the range so returning to it starts fresh', () {
      final switched = customFilter.withPeriod(FilterPeriod.today);

      expect(switched.period, FilterPeriod.today);
      expect(
        switched.customRange,
        isNull,
        reason: 'a stale range would relabel the chip and prefill the picker',
      );
    });

    test('every non-custom period drops the range', () {
      for (final period in FilterPeriod.values.where(
        (p) => p != FilterPeriod.custom,
      )) {
        expect(
          customFilter.withPeriod(period).customRange,
          isNull,
          reason: 'range survived a switch to $period',
        );
      }
    });

    test('staying on custom keeps the range', () {
      expect(
        customFilter.withPeriod(FilterPeriod.custom).customRange,
        customFilter.customRange,
      );
    });

    test('switching period keeps the search query', () {
      expect(customFilter.withPeriod(FilterPeriod.all).query, 'bob');
    });

    test('withCustomRange sets both the period and the range', () {
      final range = DateTimeRange(
        start: DateTime(2026, 7, 1),
        end: DateTime(2026, 7, 5),
      );
      final switched = const PurchaserFilter(
        period: FilterPeriod.today,
      ).withCustomRange(range);

      expect(switched.period, FilterPeriod.custom);
      expect(switched.customRange, range);
    });

    test('withQuery leaves the period and range untouched', () {
      final requeried = customFilter.withQuery('alice');

      expect(requeried.query, 'alice');
      expect(requeried.period, FilterPeriod.custom);
      expect(requeried.customRange, customFilter.customRange);
    });

    test('a cleared range makes the filter match everything again', () {
      final cleared = customFilter.withPeriod(FilterPeriod.all).withQuery('');

      expect(cleared.isFiltering, isFalse);
    });
  });

  group('isFiltering', () {
    test('is false by default', () {
      expect(const PurchaserFilter().isFiltering, isFalse);
    });

    test('is false for a whitespace-only query', () {
      expect(const PurchaserFilter(query: '  ').isFiltering, isFalse);
    });

    test('is true once a period is chosen', () {
      expect(
        const PurchaserFilter(period: FilterPeriod.today).isFiltering,
        isTrue,
      );
    });
  });
}
