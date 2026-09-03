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
    this.focusNode,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.contentPadding,
    this.isDense = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool onTapOutsideEnabled;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? hintText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;

  /// Overrides the roomy default, for a field that has to sit inline in a row
  /// of text rather than own a line of its own.
  final EdgeInsetsGeometry? contentPadding;
  final bool isDense;

  /// When false the field is greyed and cannot be focused or typed into.
  ///
  /// For a setting that is switched off rather than gone: the control stays
  /// where it was so the page around it does not jump.
  final bool enabled;

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
      enabled: enabled,
      focusNode: focusNode,
      onChanged: onChanged,
      textAlign: textAlign,

      onTapOutside: onTapOutsideEnabled
          ? (_) => WidgetsBinding.instance.focusManager.primaryFocus?.unfocus()
          : null,

      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      textInputAction: textInputAction,

      style: TextStyle(
        fontSize: AppDimens.fontSizeDefault,
        color: enabled ? AppColor.black : AppColor.grey,
      ),

      decoration: InputDecoration(
        isDense: isDense,
        contentPadding: contentPadding,
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
        // Named rather than left to Material, which greys it from the seed
        // colour scheme and not from AppColor.
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
          borderSide: BorderSide(color: AppColor.border),
        ),
        filled: !enabled,
        fillColor: AppColor.secondary,
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
