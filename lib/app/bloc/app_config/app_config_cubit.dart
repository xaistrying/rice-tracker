// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import '../../../domain/repositories/config_repository.dart';
import '../../di/injector.dart';
import '../../enum/language_code.dart';

part 'app_config_state.dart';
part 'app_config_cubit.freezed.dart';

class AppConfigCubit extends Cubit<AppConfigState> {
  AppConfigCubit() : super(const _InitialState(AppConfigStateData())) {
    _init();
  }

  final _repo = getIt<ConfigRepository>();

  Future<void> _init() async {
  }

  void updateLocale(Locale? locale) {
    _repo.cacheLanguageCode(
      languageCode: locale?.languageCode ?? LanguageCode.en.name,
    );
    emit(UpdateLocaleState(state.data.copyWith(locale: locale)));
  }
}
