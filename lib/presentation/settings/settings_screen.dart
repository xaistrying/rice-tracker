// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_config/app_config_cubit.dart';
import 'package:rice_tracker/app/l10n/generated/app_localizations.dart';
import 'package:rice_tracker/app/widgets/card_widget.dart';
import 'package:rice_tracker/presentation/settings/features/delete_all_purchaser.dart';
import 'package:rice_tracker/presentation/settings/features/tare_deduction.dart';
import '../../app/extension/context_extension.dart';
import '../../app/theme/app_color.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/widgets/segmented_button_widget.dart';

class _VersionLine extends StatelessWidget {
  const _VersionLine();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppConfigCubit, AppConfigState>(
      builder: (context, state) {
        final version = state.data.version;

        if (version == null || version.isEmpty) return const SizedBox.shrink();

        return Center(
          child: Text(
            'Version $version',
            style: const TextStyle(
              fontSize: AppDimens.fontSizeSmall,
              color: AppColor.grey,
            ),
          ),
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppDimens.padding16,
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding16,
        ),
        scrolledUnderElevation: 0.0,

        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark, // Android
          statusBarBrightness: Brightness.light, // iOS
          statusBarColor: Colors.transparent,
        ),

        leading: Padding(
          padding: const EdgeInsets.only(
            left: AppDimens.padding16,
            top: AppDimens.padding8,
            bottom: AppDimens.padding8,
            right: 0.0,
          ),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
            highlightColor: AppColor.primary,
            hoverColor: AppColor.selectionColor,
            child: Container(
              padding: const EdgeInsets.all(AppDimens.padding8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
              ),
              child: Icon(Icons.arrow_back_rounded, color: AppColor.black),
            ),
          ),
        ),

        title: Text(
          context.loc.settings,
          style: TextStyle(
            fontSize: AppDimens.fontSize20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding16),
          children: [
            CardWidget(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  context.loc.languages,
                  style: TextStyle(
                    fontSize: AppDimens.fontSizeDefault,
                    color: AppColor.black,
                  ),
                ),
                trailing: BlocBuilder<AppConfigCubit, AppConfigState>(
                  builder: (context, state) {
                    return SegmentedButtonWidget(
                      values: AppLocalizations.supportedLocales
                          .map((e) => e.languageCode)
                          .toList(),
                      selected: {state.data.locale.toString()},
                      onSelectionChanged: (newSelection) => context
                          .read<AppConfigCubit>()
                          .updateLocale(Locale(newSelection.first)),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: AppDimens.padding16),

            TareDeduction(),
            SizedBox(height: AppDimens.padding16),

            DeleteAllPurchaser(),
            SizedBox(height: AppDimens.padding24),

            const _VersionLine(),
            SizedBox(height: AppDimens.padding16),
          ],
        ),
      ),
    );
  }
}
