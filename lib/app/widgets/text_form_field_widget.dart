// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../theme/app_color.dart';
import '../theme/app_dimens.dart';

class TextFormFieldWidget extends StatelessWidget {
  const TextFormFieldWidget({
    super.key,
    required this.controller,
    this.onTapOutsideEnabled = true,
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.hintText,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final bool onTapOutsideEnabled;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? hintText;

  /// Takes focus, and so opens the keyboard, as soon as this is first built.
  ///
  /// Off by default: it is only right where typing is the reason the screen
  /// was opened.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,

      onTapOutside: onTapOutsideEnabled
          ? (_) => WidgetsBinding.instance.focusManager.primaryFocus?.unfocus()
          : null,

      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      textInputAction: textInputAction,

      style: TextStyle(
        fontSize: AppDimens.fontSizeDefault,
        color: AppColor.black,
      ),

      decoration: InputDecoration(
        hint: hintText == null
            ? null
            : Text(
                hintText ?? '',
                style: TextStyle(
                  fontSize: AppDimens.fontSizeDefault,
                  color: AppColor.grey,
                ),
              ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
          borderSide: BorderSide(color: AppColor.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
          borderSide: BorderSide(color: AppColor.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
          borderSide: BorderSide(color: AppColor.destructive, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
          borderSide: BorderSide(color: AppColor.destructive, width: 2),
        ),
      ),
    );
  }
}
