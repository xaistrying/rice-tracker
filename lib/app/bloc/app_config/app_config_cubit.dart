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
  AppConfigCubit() : super(const _InitialState(AppConfigStateData())) {
    _init();
  }

  final _repo = getIt<ConfigRepository>();

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
    updateLocale(
      AppLocalizations.supportedLocales.firstWhere(
        (locale) => locale.languageCode == languageCode,
      ),
    );
  }

  void updateLocale(Locale? locale) {
    _repo.cacheLanguageCode(
      languageCode: locale?.languageCode ?? LanguageCode.en.name,
    );
    emit(UpdateLocaleState(state.data.copyWith(locale: locale)));
  }
}
