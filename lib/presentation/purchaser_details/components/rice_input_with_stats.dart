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
              Row(
                spacing: AppDimens.padding8,
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
                                text: '${widget.purchaser.quantity ?? 0}',
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
                      child: Center(
                        child: RichText(
                          maxLines: 1,
                          text: TextSpan(
                            text: (widget.purchaser.totalWeight ?? 0.0)
                                .toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: AppDimens.fontSize16,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primary,
                            ),
                            children: [
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
                      ),
                    ),
                  ),
                ],
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
