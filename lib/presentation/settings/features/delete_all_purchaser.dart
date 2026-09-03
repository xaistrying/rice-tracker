// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../app/bloc/app_data/app_data_cubit.dart';
import '../../../app/extension/context_extension.dart';
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/widgets/dialog_widget.dart';
import '../../../app/widgets/text_form_field_widget.dart';

class DeleteAllPurchaser extends StatefulWidget {
  const DeleteAllPurchaser({super.key});

  @override
  State<DeleteAllPurchaser> createState() => _DeleteAllPurchaserState();
}

class _DeleteAllPurchaserState extends State<DeleteAllPurchaser> {
  final confirmController = TextEditingController();

  @override
  void dispose() {
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The border is on a Container rather than on an Ink, which is what it
    // used to be. An Ink paints its decoration onto the nearest Material
    // rather than onto itself, and inside a scrolling list that painting does
    // not follow a relayout: when the card above this one changed height, the
    // border stayed at the old offset, drawing a red box across that card
    // while this label sat outside it.
    return Container(
      decoration: BoxDecoration(
        color: AppColor.card,
        border: BoxBorder.all(color: AppColor.destructive),
        borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
      ),
      // Keeps the ripple inside the rounded corners.
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ValueListenableBuilder(
                valueListenable: confirmController,
                builder: (context, value, child) {
                  return DialogWidget(
                    title: context.loc.warning,
                    body: Column(
                      children: [
                        Text(
                          context.loc.deleteAllPurchaserDialogDescription,
                          style: TextStyle(
                            fontSize: AppDimens.fontSizeDefault,
                            color: AppColor.foreground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppDimens.padding12),

                        TextFormFieldWidget(
                          controller: confirmController,
                          hintText:
                              context.loc.deleteAllPurchaserConfirmHinText,
                        ),
                      ],
                    ),
                    isConfirmButtonDisable: confirmController.text != 'DELETE',
                    confirmButtonFunc: () {
                      context.read<AppDataCubit>().deleteAllPurchaser();
                      context.pop();
                    },
                  );
                },
              ),
            ).then((_) {
              WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
              confirmController.clear();
            });
          },
          highlightColor: AppColor.destructiveSelectionColor,
          overlayColor: WidgetStatePropertyAll(
            AppColor.destructiveSelectionColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.padding16,
              vertical: AppDimens.padding12,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                context.loc.deleteAllPurchaser,
                style: TextStyle(
                  fontSize: AppDimens.fontSizeDefault,
                  color: AppColor.destructive,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
