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
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import 'package:rice_tracker/presentation/purchaser_details/purchaser_details_screen.dart';

/// Every string the screen is currently showing.
///
/// The stats are built from [RichText] spans rather than plain [Text], so
/// find.text cannot see them on its own.
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
  late AppDataCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    await initDependencies();
    cubit = AppDataCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  /// Pushes the screen the way the router does: with the purchaser as it is
  /// at that moment. That instance goes stale on the next edit, which is the
  /// whole point of these tests.
  Future<PurchaserModel> pumpDetailsFor(
    WidgetTester tester, {
    required String name,
  }) async {
    await cubit.addNewPurchaser(name: name);
    final pushed = cubit.state.data.purchaserList.single;

    await tester.pumpWidget(
      BlocProvider<AppDataCubit>.value(
        value: cubit,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PurchaserDetailsScreen(purchaser: pushed),
        ),
      ),
    );
    // l10n.yaml sets use-deferred-loading, so AppLocalizations resolves
    // asynchronously; nothing below Localizations builds on the first frame.
    await tester.pumpAndSettle();

    return pushed;
  }

  testWidgets(
    'a bag added while the screen is open appears without reopening',
    (tester) async {
      final pushed = await pumpDetailsFor(tester, name: 'Alice');

      expect(visibleText(tester), contains('0 bags'));

      await cubit.addBagToPurchaser(id: pushed.id, weight: '10');
      await tester.pump();

      final shown = visibleText(tester);
      expect(
        shown,
        contains('1 bags'),
        reason: 'the count must update in place',
      );
      expect(
        shown,
        contains('10.0'),
        reason: 'the new bag and total must show',
      );

      // The instance the screen was pushed with is deliberately left behind by
      // the edit; the screen has to be reading the cubit instead.
      expect(
        pushed.listOfRiceBagWeights ?? const [],
        isEmpty,
        reason: 'the pushed model is stale, so the UI cannot be reading it',
      );
    },
  );

  testWidgets('the total accumulates across several bags', (tester) async {
    final pushed = await pumpDetailsFor(tester, name: 'Bob');

    await cubit.addBagToPurchaser(id: pushed.id, weight: '10.5');
    await cubit.addBagToPurchaser(id: pushed.id, weight: '4.5');
    await tester.pump();

    final shown = visibleText(tester);
    expect(shown, contains('2 bags'));
    expect(shown, contains('15.0'));
  });

  testWidgets('removing a bag updates the count and total in place', (
    tester,
  ) async {
    final pushed = await pumpDetailsFor(tester, name: 'Carol');

    await cubit.addBagToPurchaser(id: pushed.id, weight: '10');
    await cubit.addBagToPurchaser(id: pushed.id, weight: '5');
    await tester.pump();

    final bagId =
        cubit.state.data.purchaserList.single.listOfRiceBagWeights!.first.id;
    await cubit.removeBagFromPurchaser(purchaserId: pushed.id, bagId: bagId);
    await tester.pump();

    final shown = visibleText(tester);
    expect(shown, contains('1 bags'));
    expect(shown, contains('5.0'));
  });

  testWidgets('a rename updates the title in place', (tester) async {
    final pushed = await pumpDetailsFor(tester, name: 'Dave');

    expect(find.text('Dave'), findsOneWidget);

    await cubit.updatePurchaserName(id: pushed.id, newName: 'Dave Renamed');
    await tester.pump();

    expect(find.text('Dave Renamed'), findsOneWidget);
    expect(find.text('Dave'), findsNothing);
  });

  testWidgets('deleting the purchaser does not throw before the screen pops', (
    tester,
  ) async {
    final pushed = await pumpDetailsFor(tester, name: 'Erin');

    await cubit.removePurchaser(id: pushed.id);
    await tester.pump();

    // Falls back to the pushed instance rather than blowing up on a missing id.
    expect(tester.takeException(), isNull);
    expect(find.text('Erin'), findsOneWidget);
  });
}
