// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app_color.dart';

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
  );

  static final _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'OpenSans',
  );

  static ThemeData get lightTheme => _lightTheme;
  static ThemeData get darkTheme => _darkTheme;
}
