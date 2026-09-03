// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_config/app_config_cubit.dart';
import 'package:rice_tracker/app/bloc/app_data/app_data_cubit.dart';
import 'package:rice_tracker/app/extension/context_extension.dart';
import 'package:rice_tracker/app/theme/app_dimens.dart';
import 'package:rice_tracker/app/widgets/card_widget.dart';
import 'package:rice_tracker/app/widgets/no_something_yet_tile.dart';
import 'package:rice_tracker/domain/models/purchaser_filter.dart';
import '../../../app/constants/image_constant.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_color.dart';

class PurchaserList extends StatelessWidget {
  const PurchaserList({super.key, required this.filter});

  final ValueNotifier<PurchaserFilter> filter;

  @override
  Widget build(BuildContext context) {
    // No buildWhen: the stats above this list are built from the same state
    // without one, and narrowing only this side is how the two come to
    // disagree about what is on screen.
    // Every card's figure is net, worked out by the same policy the grand
    // total above and the shared report use.
    final tarePolicy = context.watch<AppConfigCubit>().state.data.tarePolicy;

    return BlocBuilder<AppDataCubit, AppDataState>(
      builder: (context, state) {
        if (state.data.purchaserList.isEmpty) {
          return NoSomethingYetTile(
            title: context.loc.noPeopleTitle,
            description: context.loc.noPeopleDescription,
          );
        }
        return ValueListenableBuilder(
          valueListenable: filter,
          builder: (context, activeFilter, child) {
            final purchaserList = activeFilter.apply(state.data.purchaserList);

            if (purchaserList.isEmpty) {
              // Telling someone to widen a date range they never touched is
              // no help when it is the typed name that matched nobody.
              final cause = activeFilter.emptyCause(state.data.purchaserList);
              final blamesQuery = cause == FilterEmptyCause.query;

              return NoSomethingYetTile(
                title: blamesQuery
                    ? context.loc.noSearchResultTitle
                    : context.loc.noPurchaserInPeriodTitle,
                description: blamesQuery
                    ? context.loc.noSearchResultDescription
                    : context.loc.noPurchaserInPeriodDescription,
              );
            }

            // Grouped by day, and newest first inside each day.
            final groups = groupPurchasersByDay(purchaserList);

            // Sort chronologically (newest first). Comparing the raw
            // 'dd/MM/yyyy' strings would sort by day-of-month before month
            // and year, which breaks across month and year boundaries.
            final sortedKeys = groups.keys.toList()
              ..sort((a, b) {
                final dateA = parseDayKey(a);
                final dateB = parseDayKey(b);
                if (dateA == null || dateB == null) {
                  if (dateA == null && dateB == null) return 0;
                  return dateA == null ? 1 : -1;
                }
                return dateB.compareTo(dateA);
              });

            return CustomScrollView(
              scrollBehavior: ScrollConfiguration.of(
                context,
              ).copyWith(overscroll: false),
              slivers: [
                for (final dateKey in sortedKeys) ...[
                  SliverStickyHeader(
                    header: Container(
                      width: double.maxFinite,
                      color: AppColor.background,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.padding16,
                        vertical: AppDimens.padding12,
                      ),
                      child: BlocBuilder<AppConfigCubit, AppConfigState>(
                        builder: (context, state) {
                          final String headerLabel;
                          final dt = parseDayKey(dateKey);
                          if (dt == null) {
                            headerLabel = dateKey;
                          } else {
                            final today = DateTime.now();
                            final dateOnlyNow = DateTime(
                              today.year,
                              today.month,
                              today.day,
                            );
                            final dateOnly = DateTime(
                              dt.year,
                              dt.month,
                              dt.day,
                            );
                            final diff = dateOnlyNow
                                .difference(dateOnly)
                                .inDays;
                            if (diff == 0) {
                              headerLabel = context.loc.today;
                            } else if (diff == 1) {
                              headerLabel = context.loc.yesterday;
                            } else {
                              headerLabel = DateFormat(
                                'EEEE, dd/MM/yyyy',
                              ).format(dt);
                            }
                          }
                          return Text(
                            headerLabel,
                            style: TextStyle(
                              fontSize: AppDimens.fontSizeDefault,
                              color: AppColor.foreground,
                            ),
                          );
                        },
                      ),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final purchaser = groups[dateKey]![index];
                        return Column(
                          children: [
                            CardWidget(
                              padding: EdgeInsets.zero,
                              margin: EdgeInsets.symmetric(
                                horizontal: AppDimens.padding16,
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppDimens.padding16,
                                  vertical: AppDimens.padding12,
                                ),
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                leading: CircleAvatar(
                                  backgroundColor: AppColor.lightPrimary,
                                  child: SvgPicture.asset(
                                    ImageConstant.user,
                                    colorFilter: const ColorFilter.mode(
                                      AppColor.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  purchaser.name ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppDimens.fontSize16,
                                    color: AppColor.black,
                                  ),
                                ),
                                subtitle: Text(
                                  purchaser.dateAdded ?? '',
                                  style: TextStyle(
                                    fontSize: AppDimens.fontSizeDefault,
                                    color: AppColor.black,
                                  ),
                                ),
                                trailing: Row(
                                  spacing: AppDimens.padding12,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${tarePolicy.netWeightOf(purchaser).toStringAsFixed(1)} kg',
                                      style: TextStyle(
                                        fontSize: AppDimens.fontSize16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.primary,
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      ImageConstant.rightArrow,
                                      colorFilter: const ColorFilter.mode(
                                        AppColor.grey,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ],
                                ),
                                // The filter is deliberately left alone on the
                                // way back: clearing only the query while the
                                // period chip stayed put reset half the filter
                                // with no sign of it having happened.
                                onTap: () => context.push(
                                  AppRouter.purchaserDetails,
                                  extra: purchaser,
                                ),
                              ),
                            ),
                            SizedBox(height: AppDimens.padding16),
                          ],
                        );
                      }, childCount: groups[dateKey]!.length),
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
