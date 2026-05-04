// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:rice_tracker/app/extension/context_extension.dart';
import '../theme/app_color.dart';
import '../theme/app_dimens.dart';

class DialogWidget extends StatelessWidget {
  const DialogWidget({
    super.key,
    required this.title,
    this.body,
    this.confirmButtonFunc,
    this.confirmButtonName,
    this.isConfirmButtonDisable = false,
  });

  final String title;
  final Widget? body;
  final Function()? confirmButtonFunc;
  final String? confirmButtonName;
  final bool isConfirmButtonDisable;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.padding24),
        constraints: const BoxConstraints(maxWidth: 400.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Text(
              title,
              style: TextStyle(
                fontSize: AppDimens.fontSize18,
                fontWeight: FontWeight.bold,
                // color: AppColor.getWhiteBlack(context),
              ),
              textAlign: TextAlign.center,
            ),
            // Body
            body ?? const SizedBox.shrink(),

            // Actions
            const SizedBox(height: AppDimens.padding20),
            Row(
              spacing: AppDimens.padding12,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context.pop(false),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.padding16,
                        vertical: AppDimens.padding16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimens.borderRadius8,
                        ),
                      ),
                      side: BorderSide(
                        width: AppDimens.borderWidth1,
                        color: AppColor.border,
                      ),
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: Colors.transparent,
                    ),
                    child: Text(
                      context.loc.close,
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeDefault,
                        fontWeight: FontWeight.bold,
                        color: AppColor.foreground,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: isConfirmButtonDisable
                        ? null
                        : () {
                            if (confirmButtonFunc != null) {
                              confirmButtonFunc?.call();
                            }
                          },
                    style: TextButton.styleFrom(
                      backgroundColor: isConfirmButtonDisable
                          ? AppColor.lightPrimary
                          : AppColor.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.padding16,
                        vertical: AppDimens.padding16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimens.borderRadius4,
                        ),
                      ),
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: Colors.transparent,
                    ),
                    child: Text(
                      confirmButtonName ?? context.loc.confirm,
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeDefault,
                        fontWeight: FontWeight.bold,
                        color: isConfirmButtonDisable
                            ? AppColor.grey
                            : AppColor.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
