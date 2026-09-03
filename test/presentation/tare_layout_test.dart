// Dart imports:
import 'dart:io';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_config/app_config_cubit.dart';
import 'package:rice_tracker/app/bloc/app_data/app_data_cubit.dart';
import 'package:rice_tracker/app/di/injector.dart';
import 'package:rice_tracker/app/l10n/generated/app_localizations.dart';
import 'package:rice_tracker/app/theme/app_color.dart';
import 'package:rice_tracker/app/theme/app_theme.dart';
import 'package:rice_tracker/domain/models/tare_rate.dart';
import 'package:rice_tracker/presentation/purchaser_details/purchaser_details_screen.dart';
import 'package:rice_tracker/presentation/settings/features/delete_all_purchaser.dart';
import 'package:rice_tracker/presentation/settings/features/tare_deduction.dart';
import 'package:rice_tracker/presentation/settings/settings_screen.dart';

/// A phone, not the 800x600 the test surface defaults to.
///
/// The rate bar and the settings row both put two text boxes on one line
/// beside a label, so a wide surface is exactly where an overflow would hide —
/// and the Vietnamese labels are the longer ones.
const phone = Size(393, 850);

/// The boundary the last pumped screen was wrapped in, so a test can write the
/// tree out again after interacting with it.
GlobalKey? _lastBoundary;

/// The current screen as raw pixels, one per logical pixel.
///
/// Both the rasterising and the byte read happen inside [WidgetTester.runAsync]
/// — they are real engine calls, and awaiting either one on the fake clock
/// simply hangs the test.
typedef Pixels = ({ByteData data, int width, int height});

Future<Pixels> renderLast(WidgetTester tester) async {
  late Pixels pixels;

  await tester.runAsync(() async {
    final boundary =
        _lastBoundary!.currentContext!.findRenderObject()
            as RenderRepaintBoundary;

    final image = await boundary.toImage();

    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      pixels = (data: data!, width: image.width, height: image.height);
    } finally {
      image.dispose();
    }
  });

  return pixels;
}

/// Whether [colour] appears within a few pixels of ([x], [y]).
///
/// A small window rather than one exact pixel: a 2px border under antialiasing
/// lands where it lands, and the test is about which card the border belongs
/// to, not about hitting one coordinate.
bool hasNear(Pixels image, double x, double y, Color colour) {
  final data = image.data;

  const window = 6;

  for (var dy = -window; dy <= window; dy++) {
    for (var dx = -window; dx <= window; dx++) {
      final px = (x + dx).round();
      final py = (y + dy).round();

      if (px < 0 || py < 0 || px >= image.width || py >= image.height) continue;

      final offset = (py * image.width + px) * 4;

      final matches =
          (data.getUint8(offset) - (colour.r * 255)).abs() < 24 &&
          (data.getUint8(offset + 1) - (colour.g * 255)).abs() < 24 &&
          (data.getUint8(offset + 2) - (colour.b * 255)).abs() < 24;

      if (matches) return true;
    }
  }

  return false;
}

/// Writes the current screen out, when RICE_REPORT_OUT is set.
Future<void> captureLast(WidgetTester tester, String fileName) async {
  final outDir = Platform.environment['RICE_REPORT_OUT'];
  if (outDir == null || _lastBoundary == null) return;

  await tester.runAsync(() async {
    final boundary =
        _lastBoundary!.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    await File('$outDir/$fileName').writeAsBytes(data!.buffer.asUint8List());
  });
}

void main() {
  late AppDataCubit data;
  late AppConfigCubit config;

  setUpAll(() async {
    // Otherwise every glyph is an Ahem box and the written-out image shows
    // nothing about whether the labels actually fit.
    final loader = FontLoader('OpenSans')
      ..addFont(
        File(
          'assets/fonts/OpenSans-VariableFont_wdth,wght.ttf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await loader.load();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    await initDependencies();
    data = AppDataCubit();
    config = AppConfigCubit();
    await config.setTareEnabled(true);
  });

  tearDown(() async {
    await data.close();
    await config.close();
  });

  /// Pumps [screen] at phone size and, when RICE_REPORT_OUT is set, writes it
  /// out so the result can be looked at rather than only asserted on.
  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    required String locale,
    String? fileName,
  }) async {
    await tester.binding.setSurfaceSize(phone);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.runAsync(() => AppLocalizations.delegate.load(Locale(locale)));

    final key = GlobalKey();
    _lastBoundary = key;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AppDataCubit>.value(value: data),
          BlocProvider<AppConfigCubit>.value(value: config),
        ],
        child: RepaintBoundary(
          key: key,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: screen,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    if (fileName != null) await captureLast(tester, fileName);
  }

  for (final locale in ['en', 'vi']) {
    testWidgets('the rate bar fits a phone in $locale', (tester) async {
      await data.addNewPurchaser(name: 'Trần Văn A');
      final pushed = data.state.data.purchaserList.single;
      for (var i = 0; i < 5; i++) {
        await data.addBagToPurchaser(id: pushed.id, weight: '45.5');
      }

      await pumpScreen(
        tester,
        PurchaserDetailsScreen(purchaser: pushed),
        locale: locale,
        fileName: 'screen_details_$locale.png',
      );

      // A RenderFlex overflow is thrown, not just painted yellow, so this is
      // what actually catches the label and the two boxes not fitting.
      expect(tester.takeException(), isNull);
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('the settings row fits a phone in $locale', (tester) async {
      await pumpScreen(
        tester,
        const SettingsScreen(),
        locale: locale,
        fileName: 'screen_settings_$locale.png',
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(Switch), findsOneWidget);
    });
  }

  testWidgets('the default boxes stay put, greyed, while the switch is off', (
    tester,
  ) async {
    await config.setTareEnabled(false);

    await pumpScreen(
      tester,
      const SettingsScreen(),
      locale: 'vi',
      fileName: 'screen_settings_off.png',
    );

    expect(find.byType(Switch), findsOneWidget);
    expect(
      find.byType(TextFormField),
      findsNWidgets(2),
      reason: 'removing them made the card shorter and shuffled the page',
    );

    for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.enabled, isFalse);
    }
  });

  testWidgets('a disabled box cannot be typed into', (tester) async {
    await config.setTareEnabled(false);
    await pumpScreen(tester, const SettingsScreen(), locale: 'en');

    await tester.tap(find.byType(TextFormField).first);
    await tester.pumpAndSettle();

    expect(
      tester.testTextInput.isVisible,
      isFalse,
      reason: 'a greyed field must not take focus or raise the keyboard',
    );
    expect(config.state.data.tarePolicy.defaultRate, TareRate.standard);
  });

  testWidgets('the card is the same height either way', (tester) async {
    // The whole point of greying rather than hiding.
    await config.setTareEnabled(false);
    await pumpScreen(tester, const SettingsScreen(), locale: 'vi');
    final off = tester.getSize(find.byType(TareDeduction));

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    final on = tester.getSize(find.byType(TareDeduction));

    expect(on, off);
  });

  testWidgets('the switch enables the rate boxes without a reopen', (
    tester,
  ) async {
    await config.setTareEnabled(false);
    await pumpScreen(
      tester,
      const SettingsScreen(),
      locale: 'en',
      fileName: 'screen_settings_before_toggle.png',
    );

    bool boxesUsable() => tester
        .widgetList<TextField>(find.byType(TextField))
        .every((f) => f.enabled ?? true);

    expect(boxesUsable(), isFalse);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Counting the boxes proves nothing now that they are always there; what
    // has to change is whether they can be used.
    expect(boxesUsable(), isTrue);
    expect(config.state.data.tarePolicy.enabled, isTrue);

    await captureLast(tester, 'screen_settings_after_toggle.png');
  });

  testWidgets('the delete border follows the card when it is moved', (
    tester,
  ) async {
    // Its border was once an Ink decoration, which paints onto the ancestor
    // Material rather than onto itself and does not follow a relayout: the
    // border stayed at the old offset, drawing a red box across whatever was
    // above while the label sat outside it.
    //
    // Layout alone cannot catch that — getRect reported the right place all
    // along — so this reads the pixels.
    //
    // The ListView matters and is not scenery: with the card in a plain
    // Column under a Scaffold the Material repaints whole and the stale
    // decoration never shows, so that arrangement passes with the bug present.
    // Settings itself no longer changes height, hence this stand-in for it.
    final gap = ValueNotifier<double>(0);
    addTearDown(gap.dispose);

    await pumpScreen(
      tester,
      Scaffold(
        body: ValueListenableBuilder<double>(
          valueListenable: gap,
          builder: (context, height, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(height: height),
              const DeleteAllPurchaser(),
            ],
          ),
        ),
      ),
      locale: 'en',
    );

    final before = tester.getRect(find.byType(DeleteAllPurchaser));

    gap.value = 200;
    await tester.pumpAndSettle();

    final after = tester.getRect(find.byType(DeleteAllPurchaser));
    expect(after.top, greaterThan(before.top), reason: 'it has to have moved');

    final image = await renderLast(tester);

    expect(
      hasNear(image, after.left, after.center.dy, AppColor.destructive),
      isTrue,
      reason: 'the border must be drawn around the card it belongs to',
    );
    expect(
      hasNear(image, before.left, before.center.dy, AppColor.destructive),
      isFalse,
      reason: 'no border may be left behind at the place it moved from',
    );
  });

  testWidgets('a rate set in settings reaches a new purchaser', (tester) async {
    await config.setTareDefaultRate(const TareRate(bags: 4, kgTenths: 5));
    await data.addNewPurchaser(name: 'Bình');

    expect(
      data.state.data.purchaserList.single.tareRate,
      const TareRate(bags: 4, kgTenths: 5),
    );
  });
}
