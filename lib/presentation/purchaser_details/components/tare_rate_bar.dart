// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../app/bloc/app_config/app_config_cubit.dart';
import '../../../app/bloc/app_data/app_data_cubit.dart';
import '../../../app/extension/context_extension.dart';
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/widgets/tare_rate_fields.dart';
import '../../../domain/models/purchaser_model.dart';

/// This purchaser's sack rate, sitting above their bags.
///
/// Here rather than beside the weight input because it is a fact about the
/// person, not about the bag being weighed: it is set once when they arrive
/// and then left alone, while the input below is used on every bag.
///
/// Kept to a single line on purpose. The bag list underneath is what takes the
/// remaining height, so a second line here costs a row of bags — most of all
/// with the keyboard up, which is exactly when the list is being used.
class TareRateBar extends StatelessWidget {
  const TareRateBar({super.key, required this.purchaser});

  final PurchaserModel purchaser;

  @override
  Widget build(BuildContext context) {
    final policy = context.watch<AppConfigCubit>().state.data.tarePolicy;

    return Container(
      // The Column above spaces its children but not its top edge, so the bar
      // would otherwise sit flush against the app bar.
      margin: const EdgeInsets.fromLTRB(
        AppDimens.padding16,
        AppDimens.padding8,
        AppDimens.padding16,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding12,
        vertical: AppDimens.padding8,
      ),
      decoration: BoxDecoration(
        color: AppColor.card,
        border: Border.all(color: AppColor.border),
        borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
      ),
      child: Row(
        children: [
          Text(
            '${context.loc.tareTitle}:',
            style: const TextStyle(
              fontSize: AppDimens.fontSizeDefault,
              fontWeight: FontWeight.bold,
              color: AppColor.black,
            ),
          ),
          const Spacer(),
          TareRateFields(
            rate: policy.rateFor(purchaser),
            // The effect is deliberately not shown here: the stats box at the
            // bottom of this same screen already reads '554.2 - 4.0', and
            // printing the deduction twice on one screen invites the reader to
            // hunt for a difference between them.
            onChanged: (rate) => context
                .read<AppDataCubit>()
                .updatePurchaserTareRate(id: purchaser.id, rate: rate),
          ),
        ],
      ),
    );
  }
}
