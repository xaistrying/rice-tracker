// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:rice_tracker/app/extension/context_extension.dart';
import '../../../app/bloc/app_data/app_data_cubit.dart';
import '../../../app/constants/image_constant.dart';
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/widgets/dialog_widget.dart';
import '../../../domain/models/purchaser_model.dart';

class AppBarCustom extends StatefulWidget implements PreferredSizeWidget {
  const AppBarCustom({super.key, required this.purchaser});

  final PurchaserModel purchaser;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppBarCustom> createState() => _AppBarCustomState();
}

class _AppBarCustomState extends State<AppBarCustom> {
  final newNameController = TextEditingController();

  @override
  void dispose() {
    newNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: AppDimens.padding16,
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding16,
      ),
      scrolledUnderElevation: 0.0,
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
      title: GestureDetector(
        onTap: () {
          newNameController.text = widget.purchaser.name ?? '';
          showDialog(
            context: context,
            builder: (context) => ValueListenableBuilder(
              valueListenable: newNameController,
              builder: (context, value, child) => DialogWidget(
                isConfirmButtonDisable: newNameController.text == '',
                title: 'Edit Name',
                body: Column(
                  children: [
                    Text(
                      'Enter a new name to replace the current one.',
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeDefault,
                        color: AppColor.foreground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppDimens.padding12),
                    Align(
                      alignment: AlignmentGeometry.centerLeft,
                      child: Text(
                        'Name',
                        style: TextStyle(
                          fontSize: AppDimens.fontSizeDefault,
                          fontWeight: FontWeight.bold,
                          color: AppColor.black,
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimens.padding4),
                    TextFormField(
                      controller: newNameController,
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeDefault,
                        color: AppColor.black,
                      ),
                      decoration: InputDecoration(
                        hint: Text(
                          'Enter name...',
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
                confirmButtonFunc: newNameController.text == ''
                    ? null
                    : () {
                        context.read<AppDataCubit>().updatePurchaserName(
                          id: widget.purchaser.id,
                          newName: newNameController.text,
                        );
                        context.pop();
                      },
              ),
            ),
          );
        },
        child: BlocBuilder<AppDataCubit, AppDataState>(
          builder: (context, state) {
            return SizedBox(
              width: double.maxFinite,
              child: Text(
                widget.purchaser.name ?? '',
                style: TextStyle(
                  fontSize: AppDimens.fontSize20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),

      actions: [
        IconButton(
          onPressed: () =>
              showDialog(
                context: context,
                builder: (context) => DialogWidget(
                  title: context.loc.deleteItemTitle,
                  body: Text(
                    context.loc.deleteItemDescription,
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeDefault,
                      color: AppColor.foreground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  confirmButtonFunc: () {
                    context.read<AppDataCubit>().removePurchaser(
                      id: widget.purchaser.id,
                    );
                    context.pop(true);
                  },
                ),
              ).then((value) {
                if (context.mounted && value == true) {
                  context.pop();
                }
              }),
          highlightColor: AppColor.primary,
          hoverColor: AppColor.selectionColor,
          icon: SvgPicture.asset(
            ImageConstant.delete,
            colorFilter: const ColorFilter.mode(
              AppColor.destructive,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}
