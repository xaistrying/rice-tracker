// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import '../../../app/bloc/app_config/app_config_cubit.dart';
import '../../../app/extension/context_extension.dart';
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/widgets/card_widget.dart';
import '../../../app/widgets/tare_rate_fields.dart';

/// The switch for the sack deduction, and the rate a purchaser starts at.
///
/// Only the switch shows while it is off: the default rate has no meaning
/// until something is being deducted, and a stray edit to it then would be
/// invisible until the switch went on.
class TareDeduction extends StatelessWidget {
  const TareDeduction({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppConfigCubit, AppConfigState>(
      builder: (context, state) {
        final policy = state.data.tarePolicy;

        return CardWidget(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.loc.tareTitle,
                          style: const TextStyle(
                            fontSize: AppDimens.fontSizeDefault,
                            color: AppColor.black,
                          ),
                        ),
                        const SizedBox(height: AppDimens.padding4),
                        Text(
                          context.loc.tareDescription,
                          style: const TextStyle(
                            fontSize: AppDimens.fontSizeSmall,
                            color: AppColor.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.padding12),
                  // Every colour is named, the off state included. Material's
                  // defaults for the off state come from the seed scheme, not
                  // from AppColor, so leaving them alone put a grey-lilac
                  // switch on a page that has no other colour like it.
                  Switch(
                    value: policy.enabled,
                    thumbColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? AppColor.white
                          : AppColor.grey,
                    ),
                    trackColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? AppColor.primary
                          : AppColor.secondary,
                    ),
                    trackOutlineColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? AppColor.primary
                          : AppColor.border,
                    ),
                    trackOutlineWidth: const WidgetStatePropertyAll(
                      AppDimens.borderWidth2,
                    ),
                    onChanged: (value) =>
                        context.read<AppConfigCubit>().setTareEnabled(value),
                  ),
                ],
              ),

              // Greyed out while the switch is off rather than taken away.
              // Removing it changed the height of this card, which shuffled
              // everything below it every time the switch was touched.
              const SizedBox(height: AppDimens.padding12),
              Row(
                children: [
                  Text(
                    '${context.loc.tareDefaultLabel}:',
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeDefault,
                      color: policy.enabled ? AppColor.black : AppColor.grey,
                    ),
                  ),
                  const Spacer(),
                  TareRateFields(
                    rate: policy.defaultRate,
                    enabled: policy.enabled,
                    onChanged: (rate) =>
                        context.read<AppConfigCubit>().setTareDefaultRate(rate),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
