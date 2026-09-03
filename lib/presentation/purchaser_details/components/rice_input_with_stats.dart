// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_data/app_data_cubit.dart';
import 'package:rice_tracker/app/extension/context_extension.dart';
import 'package:rice_tracker/app/widgets/dialog_widget.dart';
import '../../../app/bloc/app_config/app_config_cubit.dart';
import '../../../app/constants/image_constant.dart';
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/widgets/text_form_field_widget.dart';
import '../../../domain/models/purchaser_model.dart';

class RiceInputWithStats extends StatefulWidget {
  const RiceInputWithStats({super.key, required this.purchaser});

  final PurchaserModel purchaser;

  @override
  State<RiceInputWithStats> createState() => _RiceInputWithStatsState();
}

class _RiceInputWithStatsState extends State<RiceInputWithStats> {
  final riceAmountController = TextEditingController();

  @override
  void dispose() {
    riceAmountController.dispose();
    super.dispose();
  }

  /// The weight this purchaser is settled on, with the arithmetic under it.
  ///
  /// The big number is the one that gets paid on, so it is the net. Without
  /// the line below it the total would simply not add up to the bags on the
  /// screen above, which reads as a bug rather than as a deduction.
  Widget _weight(BuildContext context) {
    final policy = context.watch<AppConfigCubit>().state.data.tarePolicy;

    final gross = widget.purchaser.totalWeight;
    final deduction = policy.deductionFor(widget.purchaser);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          maxLines: 1,
          TextSpan(
            text: policy.netWeightOf(widget.purchaser).toStringAsFixed(1),
            style: const TextStyle(
              fontSize: AppDimens.fontSize16,
              fontWeight: FontWeight.bold,
              color: AppColor.primary,
            ),
            children: const [
              TextSpan(
                text: ' kg',
                style: TextStyle(
                  fontSize: AppDimens.fontSizeDefault,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
        ),

        // Nothing to explain when nothing was taken off — an empty purchaser
        // deducts zero even with the switch on.
        if (deduction > 0)
          Text(
            '${gross.toStringAsFixed(1)} − ${deduction.toStringAsFixed(1)}',
            maxLines: 1,
            style: const TextStyle(
              fontSize: AppDimens.fontSizeSmall,
              color: AppColor.grey,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.card,
        border: Border(top: BorderSide(width: 1, color: AppColor.border)),
      ),
      // Scaffold only insets its body for the system navigation bar when it
      // has a bottomNavigationBar or persistentFooterButtons, and this screen
      // has neither, so the input would sit underneath it. The card keeps
      // painting behind the bar; only the content is lifted clear of it.
      //
      // MediaQuery.padding.bottom is already zero while the keyboard is up,
      // so this adds nothing on top of the resize Scaffold has done.
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding16),
          child: Column(
            spacing: AppDimens.padding16,
            children: [
              // Stats
              //
              // Wrapped so the two boxes stay the same height: the weight one
              // grows a second line whenever the sacks are being deducted.
              IntrinsicHeight(
                child: Row(
                  spacing: AppDimens.padding8,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Number of Bags
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.padding16,
                          vertical: AppDimens.padding12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.border,
                          border: Border.all(color: AppColor.grey, width: 2),
                          borderRadius: BorderRadius.circular(
                            AppDimens.borderRadius8,
                          ),
                        ),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${widget.purchaser.quantity}',
                                  style: TextStyle(
                                    fontSize: AppDimens.fontSize16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.foreground,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${context.loc.bags}',
                                  style: TextStyle(
                                    fontSize: AppDimens.fontSizeDefault,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Total Weight
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.padding16,
                          vertical: AppDimens.padding12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.lightPrimary,
                          border: Border.all(color: AppColor.primary, width: 2),
                          borderRadius: BorderRadius.circular(
                            AppDimens.borderRadius8,
                          ),
                        ),
                        child: Center(child: _weight(context)),
                      ),
                    ),
                  ],
                ),
              ),

              // Rice Amount Input
              IntrinsicHeight(
                child: Row(
                  spacing: AppDimens.padding8,

                  children: [
                    Expanded(
                      child: TextFormFieldWidget(
                        controller: riceAmountController,
                        onTapOutsideEnabled: false,

                        // Weighing bags is the whole reason this screen is
                        // opened, so the keyboard is up and ready to type.
                        autofocus: true,

                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
                          SinglePeriodEnforcer(),
                        ],
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,

                        hintText: context.loc.enterAnAmount,
                      ),
                    ),

                    // Action Button
                    SizedBox(
                      width: 60,
                      child: ValueListenableBuilder(
                        valueListenable: riceAmountController,
                        builder: (context, value, child) => IconButton(
                          onPressed: () {
                            if (double.tryParse(value.text) != null) {
                              final number = double.parse(value.text);

                              if (number < 0 || number >= 1000) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return DialogWidget(
                                      title: context.loc.warning,
                                      body: Text(
                                        context
                                            .loc
                                            .warningRiceAmountDescription,
                                      ),
                                      // Nothing to confirm: this only reports
                                      // that the amount was out of range.
                                      showConfirmButton: false,
                                    );
                                  },
                                );
                              } else {
                                context.read<AppDataCubit>().addBagToPurchaser(
                                  id: widget.purchaser.id,
                                  weight: value.text,
                                );
                              }
                            }
                            riceAmountController.clear();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: riceAmountController.text == ''
                                ? AppColor.lightPrimary
                                : AppColor.primary,
                            disabledBackgroundColor: AppColor.lightPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimens.borderRadius8,
                              ),
                            ),
                            padding: const EdgeInsets.all(AppDimens.padding16),
                            splashFactory: NoSplash.splashFactory,
                            overlayColor: Colors.transparent,
                          ),
                          icon: SvgPicture.asset(
                            ImageConstant.add,
                            colorFilter: ColorFilter.mode(
                              riceAmountController.text == ''
                                  ? AppColor.grey
                                  : AppColor.foreground,
                              BlendMode.srcIn,
                            ),
                            height: AppDimens.iconSize20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SinglePeriodEnforcer extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    // Allow only one period
    if ('.'.allMatches(newText).length <= 1) {
      return newValue;
    }
    return oldValue;
  }
}
