// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_data/app_data_cubit.dart';
import 'package:rice_tracker/app/di/injector.dart';
import 'package:rice_tracker/app/l10n/generated/app_localizations.dart';
import 'package:rice_tracker/data/datasources/purchaser_data_source.dart';
import 'package:rice_tracker/presentation/home/components/store_read_issue_banner.dart';

String record(String id, String name, {String? rawId}) =>
    '{"id":${rawId ?? '"$id"'},"name":"$name",'
    '"listOfRiceBagWeights":[{"id":"b$id","weight":50.0}],'
    '"dateAdded":"29/08/2026 09:00"}';

final healthy = '[${record('1', 'Alice')},${record('2', 'Bob')}]';

/// Bob's id written as a number, which PurchaserModel cannot parse.
final oneBadRecord =
    '[${record('1', 'Alice')},${record('2', 'Bob', rawId: '2')}]';

const unreadable = '{not json';

Future<AppDataCubit> bootWith(String? stored) async {
  SharedPreferences.setMockInitialValues(
    stored == null ? {} : {PurchaserDataSourceImpl.purchaserListKey: stored},
  );
  await getIt.reset();
  await initDependencies();
  return AppDataCubit();
}

Future<void> pumpBanner(WidgetTester tester, AppDataCubit cubit) async {
  await tester.pumpWidget(
    BlocProvider<AppDataCubit>.value(
      value: cubit,
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: StoreReadIssueBanner()),
      ),
    ),
  );
  // l10n.yaml sets use-deferred-loading, so nothing below Localizations builds
  // on the first frame.
  await tester.pumpAndSettle();
}

/// Every string on screen, including RichText spans find.text cannot see.
String visibleText(WidgetTester tester) {
  final buffer = StringBuffer();

  for (final widget in tester.allWidgets) {
    if (widget is Text && widget.data != null) {
      buffer.writeln(widget.data);
    } else if (widget is RichText) {
      buffer.writeln(widget.text.toPlainText());
    }
  }

  return buffer.toString();
}

void main() {
  testWidgets('a healthy store shows nothing at all', (tester) async {
    final cubit = await bootWith(healthy);
    addTearDown(cubit.close);

    await pumpBanner(tester, cubit);

    expect(cubit.state.data.purchaserList, hasLength(2));
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    expect(visibleText(tester).trim(), isEmpty);
  });

  testWidgets('an empty store shows nothing at all', (tester) async {
    final cubit = await bootWith(null);
    addTearDown(cubit.close);

    await pumpBanner(tester, cubit);

    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
  });

  testWidgets('an unreadable store says so rather than looking empty', (
    tester,
  ) async {
    final cubit = await bootWith(unreadable);
    addTearDown(cubit.close);

    await pumpBanner(tester, cubit);

    // The list is empty here, which is exactly what a fresh install shows.
    // Without this the user's only reading is that the app lost everything.
    expect(cubit.state.data.purchaserList, isEmpty);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

    final shown = visibleText(tester);
    expect(shown, contains('could not be opened'));
    expect(
      shown,
      contains('not been deleted'),
      reason: 'the user must be told not to start re-entering everything',
    );
  });

  testWidgets('a partial read reports how many records are missing', (
    tester,
  ) async {
    final cubit = await bootWith(oneBadRecord);
    addTearDown(cubit.close);

    await pumpBanner(tester, cubit);

    // This is the quiet one: the list looks entirely normal.
    expect(cubit.state.data.purchaserList.map((e) => e.name), ['Alice']);
    expect(cubit.state.data.unreadableRecords, 1);

    final shown = visibleText(tester);
    expect(shown, contains('1 record could not be read'));
    expect(
      shown,
      contains('totals here are lower'),
      reason: 'the short grand total is the part with no other signal',
    );
  });

  testWidgets('it can be dismissed', (tester) async {
    final cubit = await bootWith(unreadable);
    addTearDown(cubit.close);

    await pumpBanner(tester, cubit);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
  });

  testWidgets('the issue clears once the store reads cleanly again', (
    tester,
  ) async {
    final cubit = await bootWith(unreadable);
    addTearDown(cubit.close);

    await pumpBanner(tester, cubit);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

    // Writing replaces the unreadable value, so the next read succeeds.
    await cubit.addNewPurchaser(name: 'Dave');
    cubit.updatePurchaserList();
    await tester.pumpAndSettle();

    expect(cubit.state.data.readIssue, isNull);
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
  });
}
