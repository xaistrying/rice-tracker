// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:rice_tracker/app/l10n/generated/app_localizations.dart';
import 'package:rice_tracker/app/theme/app_color.dart';
import 'package:rice_tracker/app/widgets/dialog_widget.dart';

Future<void> pumpDialog(WidgetTester tester, DialogWidget dialog) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: dialog),
    ),
  );
  // l10n.yaml sets use-deferred-loading, so nothing below Localizations builds
  // on the first frame.
  await tester.pumpAndSettle();
}

/// The confirm button's fill, or null when it is not on screen.
Color? confirmFill(WidgetTester tester) {
  final buttons = tester.widgetList<TextButton>(find.byType(TextButton));
  if (buttons.length < 2) return null;
  return buttons.last.style?.backgroundColor?.resolve({});
}

void main() {
  testWidgets('a dialog with something to confirm shows both buttons', (
    tester,
  ) async {
    await pumpDialog(
      tester,
      DialogWidget(title: 'Delete this?', confirmButtonFunc: () {}),
    );

    expect(find.byType(TextButton), findsNWidgets(2));
    expect(find.text('Close'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });

  testWidgets('a dialog that only reports something shows no Confirm', (
    tester,
  ) async {
    await pumpDialog(
      tester,
      const DialogWidget(
        title: 'Warning',
        body: Text('Please enter an amount between 0 and 1000.'),
        showConfirmButton: false,
      ),
    );

    expect(
      find.text('Confirm'),
      findsNothing,
      reason: 'there is no action to agree to',
    );
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    expect(find.text('Please enter an amount between 0 and 1000.'), findsOne);
  });

  testWidgets('Close fills the width when it is the only button', (
    tester,
  ) async {
    await pumpDialog(
      tester,
      const DialogWidget(title: 'Warning', showConfirmButton: false),
    );
    final alone = tester.getSize(find.byType(TextButton)).width;

    await pumpDialog(
      tester,
      DialogWidget(title: 'Warning', confirmButtonFunc: () {}),
    );
    final shared = tester.getSize(find.byType(TextButton).first).width;

    expect(
      alone,
      greaterThan(shared),
      reason: 'a lone Close must not sit in half the dialog',
    );
  });

  testWidgets('a disabled Confirm is still shown', (tester) async {
    // Distinct from showConfirmButton: this is a choice that cannot be made
    // yet, and the button vanishing as the user typed would be worse.
    await pumpDialog(
      tester,
      const DialogWidget(title: 'Add new person', isConfirmButtonDisable: true),
    );

    expect(find.text('Confirm'), findsOneWidget);
    expect(find.byType(TextButton), findsNWidgets(2));
    expect(confirmFill(tester), AppColor.lightPrimary);
  });

  testWidgets('an enabled Confirm keeps the primary fill', (tester) async {
    await pumpDialog(
      tester,
      DialogWidget(title: 'Delete this?', confirmButtonFunc: () {}),
    );

    expect(confirmFill(tester), AppColor.primary);
  });

  testWidgets('a custom confirm label is used', (tester) async {
    await pumpDialog(
      tester,
      DialogWidget(
        title: 'Delete all',
        confirmButtonName: 'Delete',
        confirmButtonFunc: () {},
      ),
    );

    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Confirm'), findsNothing);
  });
}
