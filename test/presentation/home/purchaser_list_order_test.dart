// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_config/app_config_cubit.dart';
import 'package:rice_tracker/app/bloc/app_data/app_data_cubit.dart';
import 'package:rice_tracker/app/di/injector.dart';
import 'package:rice_tracker/app/extension/date_time_extension.dart';
import 'package:rice_tracker/app/l10n/generated/app_localizations.dart';
import 'package:rice_tracker/data/datasources/purchaser_data_source.dart';
import 'package:rice_tracker/domain/models/purchaser_filter.dart';
import 'package:rice_tracker/presentation/home/components/purchaser_list.dart';

String record(String name, String at) =>
    '{"id":"$name","name":"$name",'
    '"listOfRiceBagWeights":[{"id":"b$name","weight":50.0}],'
    '"dateAdded":"$at"}';

void main() {
  late AppDataCubit data;
  late AppConfigCubit config;

  /// Boots with the store already holding [entries], in the order they were
  /// created — which is the order the app writes them in.
  Future<void> bootWith(List<(String, String)> entries) async {
    final json = '[${entries.map((e) => record(e.$1, e.$2)).join(',')}]';

    SharedPreferences.setMockInitialValues({
      PurchaserDataSourceImpl.purchaserListKey: json,
    });
    await getIt.reset();
    await initDependencies();

    data = AppDataCubit();
    config = AppConfigCubit();
    addTearDown(data.close);
    addTearDown(config.close);
  }

  Future<void> pumpList(WidgetTester tester) async {
    final filter = ValueNotifier(const PurchaserFilter());
    addTearDown(filter.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AppDataCubit>.value(value: data),
          BlocProvider<AppConfigCubit>.value(value: config),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: PurchaserList(filter: filter)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The names as they are actually stacked down the screen, rather than as
  /// the widget tree happens to hold them.
  List<String> namesDownTheScreen(
    WidgetTester tester,
    List<String> candidates,
  ) {
    final placed = [
      for (final name in candidates)
        if (tester.any(find.text(name)))
          (name, tester.getTopLeft(find.text(name)).dy),
    ]..sort((a, b) => a.$2.compareTo(b.$2));

    return placed.map((e) => e.$1).toList();
  }

  testWidgets('the newest of a day is at the top of that day', (tester) async {
    await bootWith([
      ('Early', '02/09/2026 08:15'),
      ('Midday', '02/09/2026 12:40'),
      ('Late', '02/09/2026 17:05'),
    ]);
    await pumpList(tester);

    expect(namesDownTheScreen(tester, ['Early', 'Midday', 'Late']), [
      'Late',
      'Midday',
      'Early',
    ]);
  });

  testWidgets('the day headers still run newest day first', (tester) async {
    await bootWith([
      ('Older', '01/09/2026 09:00'),
      ('Newer', '02/09/2026 09:00'),
    ]);
    await pumpList(tester);

    expect(namesDownTheScreen(tester, ['Older', 'Newer']), ['Newer', 'Older']);
  });

  testWidgets('a purchaser added now goes to the top', (tester) async {
    // What the change is actually for: the person just weighed is the one
    // being looked at, and they used to land at the bottom.
    // Derived from the clock, not hardcoded: a fixed stamp is only 'earlier'
    // for part of the day, and the run that proved it was 04:18 in the
    // morning with the seed set to 08:15.
    final earlier = DateTime.now()
        .subtract(const Duration(minutes: 2))
        .toTimeString();

    await bootWith([('Earlier', earlier)]);
    await pumpList(tester);

    await data.addNewPurchaser(name: 'Just now');
    await tester.pumpAndSettle();

    final shown = namesDownTheScreen(tester, ['Earlier', 'Just now']);

    expect(shown.first, 'Just now');
  });
}
