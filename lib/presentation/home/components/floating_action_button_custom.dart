// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_data/app_data_cubit.dart';
import 'package:rice_tracker/app/extension/context_extension.dart';
import '../../../app/constants/image_constant.dart';
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/widgets/dialog_widget.dart';

class FloatingActionButtonCustom extends StatelessWidget {
  const FloatingActionButtonCustom({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) => ValueListenableBuilder(
            valueListenable: controller,
            builder: (BuildContext context, value, Widget? child) =>
                DialogWidget(
                  isConfirmButtonDisable: controller.text == '',
                  title: context.loc.enterNameDialogTitle,
                  body: Column(
                    children: [
                      // Description
                      Text(
                        context.loc.enterNameDialogDescription,
                        style: TextStyle(
                          fontSize: AppDimens.fontSizeDefault,
                          color: AppColor.foreground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppDimens.padding12),

                      // Name Input
                      Align(
                        alignment: AlignmentGeometry.centerLeft,
                        child: Text(
                          context.loc.name,
                          style: TextStyle(
                            fontSize: AppDimens.fontSizeDefault,
                            fontWeight: FontWeight.bold,
                            color: AppColor.black,
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimens.padding4),

                      TextFormField(
                        controller: controller,
                        style: TextStyle(
                          fontSize: AppDimens.fontSizeDefault,
                          color: AppColor.black,
                        ),
                        decoration: InputDecoration(
                          hint: Text(
                            context.loc.enterName,
                            style: TextStyle(
                              fontSize: AppDimens.fontSizeDefault,
                              color: AppColor.foreground,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.borderRadius8,
                            ),
                            borderSide: BorderSide(color: AppColor.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.borderRadius8,
                            ),
                            borderSide: BorderSide(
                              color: AppColor.primary,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.borderRadius8,
                            ),
                            borderSide: BorderSide(
                              color: AppColor.destructive,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.borderRadius8,
                            ),
                            borderSide: BorderSide(
                              color: AppColor.destructive,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  confirmButtonName: context.loc.add,
                  confirmButtonFunc: controller.text == ''
                      ? null
                      : () {
                          context.read<AppDataCubit>().addNewPurchaser(
                            name: controller.text,
                          );
                          context.pop(true);
                        },
                ),
          ),
        ).then((value) => controller.clear()),
        backgroundColor: AppColor.primary,
        shape: CircleBorder(),
        elevation: 1,
        highlightElevation: 0,
        hoverElevation: 0,
        disabledElevation: 1,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: SvgPicture.asset(
          ImageConstant.add,
          colorFilter: const ColorFilter.mode(
            AppColor.foreground,
            BlendMode.srcIn,
          ),
          height: AppDimens.iconSize20,
        ),
      ),
    );
  }
}
