// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:rice_tracker/app/enum/filter_period.dart';
import 'package:rice_tracker/app/extension/context_extension.dart';
import 'package:rice_tracker/app/theme/app_color.dart';
import 'package:rice_tracker/app/theme/app_dimens.dart';
import 'package:rice_tracker/domain/models/purchaser_filter.dart';

class PeriodFilterChips extends StatefulWidget {
  const PeriodFilterChips({super.key, required this.filter});

  final ValueNotifier<PurchaserFilter> filter;

  @override
  State<PeriodFilterChips> createState() => _PeriodFilterChipsState();
}

class _PeriodFilterChipsState extends State<PeriodFilterChips> {
  final _scrollController = ScrollController();

  static final _chipDateFormat = DateFormat('dd/MM');

  ValueNotifier<PurchaserFilter> get filter => widget.filter;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Brings the custom chip fully into view.
  ///
  /// It is the last chip and grows wider once a range is picked, so choosing
  /// one would otherwise leave the new label clipped at the edge.
  void _revealCustomChip() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _labelFor(BuildContext context, FilterPeriod period) {
    switch (period) {
      case FilterPeriod.all:
        return context.loc.allTime;
      case FilterPeriod.today:
        return context.loc.today;
      case FilterPeriod.thisWeek:
        return context.loc.thisWeek;
      case FilterPeriod.thisMonth:
        return context.loc.thisMonth;
      case FilterPeriod.custom:
        final range = filter.value.customRange;
        if (range == null) return context.loc.customRange;
        return '${_chipDateFormat.format(range.start)} - '
            '${_chipDateFormat.format(range.end)}';
    }
  }

  Future<void> _select(BuildContext context, FilterPeriod period) async {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();

    if (period != FilterPeriod.custom) {
      filter.value = filter.value.withPeriod(period);
      return;
    }

    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      // Records cannot be dated in the future.
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: filter.value.customRange,
      helpText: context.loc.selectDateRange,
      // Calendar only: the default also offers a typed-entry mode behind a
      // pencil toggle, which is a second way to do the same thing.
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      // The range picker paints today from colorScheme.primary directly and
      // overwrites the colour of DatePickerThemeData.todayBorder with it, so
      // no amount of datePickerTheme reaches it. Override the scheme for this
      // subtree only, rather than app-wide where it would restyle every
      // built-in Material widget at once.
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColor.primary,
              onPrimary: AppColor.black,
            ),
          ),
          child: child!,
        );
      },
    );

    // Leaving the picker without choosing must not change the current filter.
    if (picked == null) return;

    filter.value = filter.value.withCustomRange(picked);

    _revealCustomChip();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: filter,
      builder: (context, _) {
        final selected = filter.value.period;

        return SizedBox(
          height: 36,
          // The stretch at the ends is the overscroll indicator, not the
          // physics: Android already scrolls with ClampingScrollPhysics, which
          // reports the excess as an OverscrollNotification, and that is what
          // the indicator animates on. It can only be turned off here.
          //
          // ListView does not forward scrollBehavior the way CustomScrollView
          // does, so this wraps rather than passing an argument.
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(overscroll: false),
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: FilterPeriod.values.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppDimens.padding8),
              itemBuilder: (context, index) {
                final period = FilterPeriod.values[index];
                final isSelected = period == selected;

                return ChoiceChip(
                  label: Text(_labelFor(context, period)),
                  selected: isSelected,
                  onSelected: (_) => _select(context, period),
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                  labelStyle: TextStyle(
                    fontSize: AppDimens.fontSizeDefault,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: AppColor.foreground,
                  ),
                  backgroundColor: AppColor.card,
                  selectedColor: AppColor.lightPrimary,
                  side: BorderSide(
                    width: AppDimens.borderWidth1,
                    color: isSelected ? AppColor.primary : AppColor.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimens.borderRadius8,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
