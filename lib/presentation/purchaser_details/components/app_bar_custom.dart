// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:rice_tracker/app/extension/context_extension.dart';
import '../../../app/bloc/app_data/app_data_cubit.dart';
import '../../../app/constants/image_constant.dart';
import '../../../app/error/failure.dart';
import '../../../app/service/report_share_service.dart';
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/widgets/dialog_widget.dart';
import '../../../app/widgets/text_form_field_widget.dart';
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

  bool _sharing = false;

  @override
  void dispose() {
    newNameController.dispose();
    super.dispose();
  }

  /// Renders the report and hands it to the system share sheet.
  ///
  /// Awaited rather than left to run on its own so a failure surfaces as a
  /// logged error instead of an unhandled one, and so the button can be put
  /// back afterwards.
  Future<void> _share(BuildContext context) async {
    setState(() => _sharing = true);

    try {
      await ReportShareService.sharePurchaserReport(context, widget.purchaser);
    } catch (e, s) {
      reportFailure('sharePurchaserReport', e, s);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
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

      title: GestureDetector(
        onTap: () {
          newNameController.text = widget.purchaser.name ?? '';

          showDialog(
            context: context,
            builder: (context) => ValueListenableBuilder(
              valueListenable: newNameController,
              builder: (context, value, child) => DialogWidget(
                isConfirmButtonDisable: newNameController.text == '',
                title: context.loc.editName,
                body: Column(
                  children: [
                    SizedBox(height: AppDimens.padding12),
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
                    TextFormFieldWidget(
                      controller: newNameController,
                      hintText: context.loc.enterName,
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
          // Null while a share is in flight, which disables the button. Two
          // taps in one frame both run before anything rebuilds, so without
          // this a fast double tap renders and shares the report twice.
          onPressed: _sharing ? null : () => _share(context),
          highlightColor: AppColor.primary,
          hoverColor: AppColor.selectionColor,
          icon: SvgPicture.asset(
            ImageConstant.share,
            colorFilter: ColorFilter.mode(
              _sharing ? AppColor.grey : AppColor.black,
              BlendMode.srcIn,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
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
            });
          },
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
