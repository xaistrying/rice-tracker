// Flutter imports:
import 'package:flutter/material.dart';

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import '../../../domain/models/tare_policy.dart';
import '../../../domain/models/tare_rate.dart';
import '../../../domain/repositories/config_repository.dart';
import '../../di/injector.dart';
import '../../error/failure.dart';
import '../../enum/language_code.dart';
import '../../l10n/generated/app_localizations.dart';

part 'app_config_state.dart';
part 'app_config_cubit.freezed.dart';

class AppConfigCubit extends Cubit<AppConfigState> {
  /// [repo] defaults to the container so that a BlocProvider does not have to
  /// resolve it, while a test can still pass a fake.
  AppConfigCubit({ConfigRepository? repo})
    : _repo = repo ?? getIt<ConfigRepository>(),
      super(const _InitialState(AppConfigStateData())) {
    _init();
  }

  final ConfigRepository _repo;

  /// Reads the version out of the installed package.
  ///
  /// Deliberately not a constant in the source: a hardcoded string is one more
  /// thing to remember on every release, and the first time it is forgotten the
  /// app confidently reports the wrong version to whoever is trying to help.
  /// This comes from the same pubspec value that Gradle stamps into the APK, so
  /// it cannot disagree with what was installed.
  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();

      if (isClosed) return;

      emit(
        UpdateVersion(
          state.data.copyWith(
            version: info.version,
            buildNumber: info.buildNumber,
          ),
        ),
      );
    } catch (e, s) {
      // A platform channel, so it can fail — most plainly on a build where the
      // plugin was added but the app was only hot reloaded. Leaving version
      // null hides the line rather than taking the screen down with it.
      reportFailure('loadAppVersion', e, s);
    }
  }

  Future<void> _init() async {
    // Read before the locale, so the one rebuild that follows already has the
    // right totals rather than showing gross weights and correcting itself.
    emit(
      UpdateTarePolicy(
        state.data.copyWith(
          tarePolicy: _repo.getTarePolicy().getOrElse((_) => TarePolicy.off),
        ),
      ),
    );

    final languageCode = _repo.getLanguageCode().getOrElse((_) {
      // Get Device Language Code
      final Locale deviceLocale =
          WidgetsBinding.instance.platformDispatcher.locale;
      String languageCode = deviceLocale.languageCode;

      if (!LanguageCode.values.any((value) => value.name == languageCode)) {
        languageCode = LanguageCode.en.name;
      }

      return languageCode;
    });
    unawaited(_loadVersion());

    await updateLocale(
      AppLocalizations.supportedLocales.firstWhere(
        (locale) => locale.languageCode == languageCode,
        // The stored code is only as current as the release that wrote it.
        // Without this, dropping a supported locale would throw from the
        // constructor for anyone still holding that code — a crash on every
        // launch, with no way out but clearing app data.
        orElse: () => Locale(LanguageCode.en.name),
      ),
    );
  }

  /// Applies [locale] and records it.
  ///
  /// The state is emitted first so the UI switches immediately; awaiting the
  /// write only decides when a failure is logged, not what the user sees.
  Future<void> updateLocale(Locale? locale) async {
    emit(UpdateLocaleState(state.data.copyWith(locale: locale)));

    await _repo.cacheLanguageCode(
      languageCode: locale?.languageCode ?? LanguageCode.en.name,
    );
  }

  /// Turns the sack deduction on or off.
  ///
  /// The per-purchaser rates are left where they are. Someone who was set to
  /// four bags to the kilo is still set to it when this is switched back on,
  /// so a stray tap costs a tap and not the setup.
  Future<void> setTareEnabled(bool enabled) =>
      _updateTarePolicy(state.data.tarePolicy.copyWith(enabled: enabled));

  /// Sets the rate a purchaser starts at when none was chosen for them.
  ///
  /// Ignores an unusable rate rather than storing it: [rate] comes from two
  /// text boxes, and the bags half is a divisor.
  Future<void> setTareDefaultRate(TareRate rate) async {
    if (!rate.isValid) return;

    await _updateTarePolicy(state.data.tarePolicy.copyWith(defaultRate: rate));
  }

  /// Emitted before the write, for the same reason [updateLocale] is: the
  /// switch has to move under the finger, and awaiting the store only decides
  /// when a failure is logged.
  Future<void> _updateTarePolicy(TarePolicy policy) async {
    emit(UpdateTarePolicy(state.data.copyWith(tarePolicy: policy)));

    await _repo.cacheTarePolicy(policy);
  }
}
