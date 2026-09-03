// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_config/app_config_cubit.dart';
import 'package:rice_tracker/app/bloc/app_data/app_data_cubit.dart';
import 'package:rice_tracker/app/di/injector.dart';
import 'package:rice_tracker/app/l10n/generated/app_localizations.dart';
import 'package:rice_tracker/presentation/settings/settings_screen.dart';

/// Stands in for what the platform reports about the installed package.
void mockPackage({String version = '2.0.0', String buildNumber = '2002'}) {
  PackageInfo.setMockInitialValues(
    appName: 'Rice Tracker',
    packageName: 'com.xaistrying.ricetracker',
    version: version,
    buildNumber: buildNumber,
    buildSignature: '',
  );
}

void main() {
  late AppConfigCubit config;
  late AppDataCubit data;

  Future<void> boot() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    await initDependencies();
    config = AppConfigCubit();
    data = AppDataCubit();
    addTearDown(config.close);
    addTearDown(data.close);
  }

  Future<void> pumpSettings(WidgetTester tester, {String locale = 'en'}) async {
    await tester.runAsync(() => AppLocalizations.delegate.load(Locale(locale)));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AppConfigCubit>.value(value: config),
          BlocProvider<AppDataCubit>.value(value: data),
        ],
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the version the package reports', (tester) async {
    mockPackage();
    await boot();
    await pumpSettings(tester);

    expect(find.text('2.0.0+2'), findsOneWidget);
  });

  testWidgets('strips the architecture out of a split build number', (
    tester,
  ) async {
    // --split-per-abi stores abi * 1000 + build, so the arm64 APK carries 2002
    // where pubspec says 2. Printing that raw reads as a year and does not
    // match anything written down.
    mockPackage(buildNumber: '2002');
    await boot();
    await pumpSettings(tester);

    expect(find.text('2.0.0+2'), findsOneWidget);
    expect(find.textContaining('2002'), findsNothing);
  });

  testWidgets('leaves a plain build number alone', (tester) async {
    // A single fat APK is not multiplied, so there is nothing to strip.
    mockPackage(buildNumber: '2');
    await boot();
    await pumpSettings(tester);

    expect(find.text('2.0.0+2'), findsOneWidget);
  });

  testWidgets('follows the package rather than a constant', (tester) async {
    // The point of reading it at runtime: change what is installed and the
    // screen changes with it, with nothing in the source to remember to edit.
    mockPackage(version: '3.1.4', buildNumber: '3004');
    await boot();
    await pumpSettings(tester);

    expect(find.text('3.1.4+4'), findsOneWidget);
    expect(find.textContaining('2.0.0'), findsNothing);
  });

  testWidgets('reads the same whatever the language', (tester) async {
    // There is no word in it any more, so nothing here should translate — this
    // guards against a label creeping back in on one side only.
    mockPackage();
    await boot();
    await pumpSettings(tester, locale: 'vi');

    expect(find.text('2.0.0+2'), findsOneWidget);
  });

  testWidgets('drops the build number when there is none', (tester) async {
    mockPackage(buildNumber: '');
    await boot();
    await pumpSettings(tester);

    expect(find.text('2.0.0'), findsOneWidget);
  });
}
