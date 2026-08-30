// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import '../../../domain/repositories/config_repository.dart';
import '../../di/injector.dart';
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

  Future<void> _init() async {
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
}
