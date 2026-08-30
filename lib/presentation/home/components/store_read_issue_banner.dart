// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_data/app_data_cubit.dart';
import '../../../app/extension/context_extension.dart';
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';

/// Says so when the stored records could not all be read.
///
/// Without it the two failure modes are both invisible. An unreadable store
/// shows the same empty list a fresh install shows, so the only reasonable
/// reading is that the app lost everything — and the user starts typing months
/// of purchases back in while the originals sit safely in the backup key. A
/// partial read is quieter still: the list looks entirely normal with a record
/// missing and the totals short.
class StoreReadIssueBanner extends StatefulWidget {
  const StoreReadIssueBanner({super.key});

  @override
  State<StoreReadIssueBanner> createState() => _StoreReadIssueBannerState();
}

class _StoreReadIssueBannerState extends State<StoreReadIssueBanner> {
  /// Dismissal is deliberately not persisted: if the store still cannot be
  /// read on the next launch, that is worth saying again.
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppDataCubit, AppDataState>(
      builder: (context, state) {
        final issue = state.data.readIssue;

        if (issue == null || _dismissed) return const SizedBox.shrink();

        final String title;
        final String description;

        switch (issue) {
          case StoreReadIssue.unreadable:
            title = context.loc.storeUnreadableTitle;
            description = context.loc.storeUnreadableDescription;
          case StoreReadIssue.partial:
            title = context.loc.storePartialTitle(state.data.unreadableRecords);
            description = context.loc.storePartialDescription;
        }

        return Container(
          width: double.maxFinite,
          margin: const EdgeInsets.fromLTRB(
            AppDimens.padding16,
            AppDimens.padding12,
            AppDimens.padding16,
            0,
          ),
          padding: const EdgeInsets.all(AppDimens.padding12),
          decoration: BoxDecoration(
            color: AppColor.lightWarning,
            border: Border.all(color: AppColor.warning),
            borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppDimens.padding8,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColor.warning,
                size: AppDimens.iconSize20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppDimens.padding4,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppDimens.fontSizeDefault,
                        color: AppColor.warning,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: AppDimens.fontSizeSmall,
                        color: AppColor.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _dismissed = true),
                behavior: HitTestBehavior.opaque,
                child: Tooltip(
                  message: context.loc.dismiss,
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColor.warning,
                    size: AppDimens.iconSize20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
