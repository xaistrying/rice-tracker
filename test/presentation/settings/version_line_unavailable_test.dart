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
import 'package:rice_tracker/presentation/settings/settings_screen.dart';

/// Deliberately its own file, with no call to PackageInfo.setMockInitialValues.
///
/// That call writes a static that survives for the rest of the file, so this
/// case cannot be checked alongside the ones that mock it — the mock from an
/// earlier test would still be in place and the channel would never be reached.
void main() {
  testWidgets('no version line, and no crash, when it cannot be read', (
    tester,
  ) async {
    // What a hot reload after adding the plugin looks like: no platform
    // channel to answer. An absent line beats a wrong version number for
    // someone trying to report a problem.
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    await initDependencies();

    final config = AppConfigCubit();
    final data = AppDataCubit();
    addTearDown(config.close);
    addTearDown(data.close);

    await tester.runAsync(() => AppLocalizations.delegate.load(Locale('en')));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AppConfigCubit>.value(value: config),
          BlocProvider<AppDataCubit>.value(value: data),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('2.0.0'), findsNothing);
    expect(config.state.data.version, isNull);
  });
}
