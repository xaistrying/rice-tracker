import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  });

  final TextEditingController controller;
  final bool onTapOutsideEnabled;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,

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
                  color: AppColor.foreground,
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
