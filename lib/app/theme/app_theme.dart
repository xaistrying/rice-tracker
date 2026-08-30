// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app_color.dart';
import 'app_dimens.dart';

class AppTheme {
  AppTheme._();

  static final _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'OpenSans',
    scaffoldBackgroundColor: AppColor.background,
    appBarTheme: AppBarTheme(backgroundColor: Colors.transparent),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionColor: AppColor.selectionColor,
      selectionHandleColor: AppColor.primary,
    ),
    iconButtonTheme: IconButtonThemeData(style: ButtonStyle()),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,

    // No colorScheme is set, so built-in Material surfaces would otherwise
    // fall back to the default Material 3 purple. The app's own widgets all
    // paint with AppColor, so the date picker is the first place that shows.
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColor.card,
      rangePickerBackgroundColor: AppColor.background,
      rangePickerHeaderBackgroundColor: AppColor.background,
      rangePickerHeaderForegroundColor: AppColor.foreground,
      headerBackgroundColor: AppColor.background,
      headerForegroundColor: AppColor.foreground,
      rangeSelectionBackgroundColor: AppColor.lightPrimary,
      dayForegroundColor: const WidgetStatePropertyAll(AppColor.foreground),
      dayBackgroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? AppColor.primary : null,
      ),
      dayOverlayColor: const WidgetStatePropertyAll(AppColor.selectionColor),
      todayForegroundColor: const WidgetStatePropertyAll(AppColor.foreground),
      todayBackgroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? AppColor.primary : null,
      ),
      todayBorder: const BorderSide(
        color: AppColor.primary,
        width: AppDimens.borderWidth2,
      ),
      rangeSelectionOverlayColor: const WidgetStatePropertyAll(
        AppColor.selectionColor,
      ),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: AppColor.foreground,
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: AppColor.foreground,
      ),
    ),
  );

  static final _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'OpenSans',
  );

  static ThemeData get lightTheme => _lightTheme;
  static ThemeData get darkTheme => _darkTheme;
}
