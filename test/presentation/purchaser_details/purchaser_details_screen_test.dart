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
import 'package:rice_tracker/app/l10n/generated/app_localizations.dart';
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import 'package:rice_tracker/domain/models/tare_rate.dart';
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
  late AppConfigCubit configCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    await initDependencies();
    cubit = AppDataCubit();
    configCubit = AppConfigCubit();
  });

  tearDown(() async {
    await cubit.close();
    await configCubit.close();
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
      MultiBlocProvider(
        providers: [
          BlocProvider<AppDataCubit>.value(value: cubit),
          BlocProvider<AppConfigCubit>.value(value: configCubit),
        ],
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

  testWidgets('the weight field has focus as soon as the screen opens', (
    tester,
  ) async {
    await pumpDetailsFor(tester, name: 'Frank');

    final field = tester.widget<EditableText>(find.byType(EditableText));

    expect(
      field.focusNode.hasFocus,
      isTrue,
      reason: 'weighing bags is why the screen was opened, so no extra tap',
    );
    // Focus alone is not enough; this is what actually raises the keyboard.
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('typing goes straight into the field, with no tap first', (
    tester,
  ) async {
    final pushed = await pumpDetailsFor(tester, name: 'Grace');

    await tester.enterText(find.byType(EditableText), '12.5');
    await tester.pump();

    expect(find.text('12.5'), findsOneWidget);
    expect(
      cubit.state.data.purchaserList.single.id,
      pushed.id,
      reason: 'typing must not have committed anything on its own',
    );
    expect(cubit.state.data.purchaserList.single.quantity, 0);
  });

  group('the sack deduction', () {
    testWidgets('is nowhere to be seen while the switch is off', (
      tester,
    ) async {
      final pushed = await pumpDetailsFor(tester, name: 'Hana');
      await cubit.addBagToPurchaser(id: pushed.id, weight: '10');
      await tester.pump();

      expect(find.text('Bag tare:'), findsNothing);
      expect(
        visibleText(tester),
        contains('10.0'),
        reason: 'the total is what was weighed until the switch is on',
      );
      expect(
        find.byType(EditableText),
        findsOneWidget,
        reason: 'only the weight field; the rate boxes must not be built',
      );
    });

    testWidgets('shows the net, with the arithmetic under it', (tester) async {
      await configCubit.setTareEnabled(true);

      final pushed = await pumpDetailsFor(tester, name: 'Ivy');
      for (var i = 0; i < 4; i++) {
        await cubit.addBagToPurchaser(id: pushed.id, weight: '10');
      }
      await tester.pump();

      final shown = visibleText(tester);

      // Four bags at three to the kilo: 40.0 weighed, 1.4 of sack, 38.6 owed.
      expect(shown, contains('38.6'));
      expect(
        shown,
        contains('40.0 − 1.4'),
        reason: 'a total that does not add up to the bags above reads as a bug',
      );
      expect(find.text('Bag tare:'), findsOneWidget);
    });

    testWidgets('deducts nothing, and explains nothing, with no bags', (
      tester,
    ) async {
      await configCubit.setTareEnabled(true);
      await pumpDetailsFor(tester, name: 'Jo');

      expect(
        visibleText(tester),
        isNot(contains('−')),
        reason: 'there is no arithmetic to show when nothing was deducted',
      );
    });

    testWidgets('a rate typed here is kept on that purchaser', (tester) async {
      await configCubit.setTareEnabled(true);

      final pushed = await pumpDetailsFor(tester, name: 'Kim');
      for (var i = 0; i < 4; i++) {
        await cubit.addBagToPurchaser(id: pushed.id, weight: '10');
      }
      await tester.pump();

      // The bags box of the rate bar, which sits above the weight field.
      await tester.enterText(find.byType(TextFormField).first, '2');
      await tester.pumpAndSettle();

      expect(
        cubit.state.data.purchaserList.single.tareRate,
        const TareRate(bags: 2, kgTenths: 10),
      );
      expect(
        visibleText(tester),
        contains('38.0'),
        reason: 'two to the kilo takes 2.0 off the 40.0 weighed',
      );
    });

    testWidgets('a new purchaser starts at the default rate', (tester) async {
      // Stamped at creation rather than left to follow, so that changing the
      // default later does not restate a load already weighed and settled.
      await configCubit.setTareEnabled(true);
      await configCubit.setTareDefaultRate(
        const TareRate(bags: 4, kgTenths: 10),
      );

      await pumpDetailsFor(tester, name: 'Lan');

      expect(
        cubit.state.data.purchaserList.single.tareRate,
        const TareRate(bags: 4, kgTenths: 10),
      );
    });
  });
}
