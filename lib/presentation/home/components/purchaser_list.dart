// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rice_tracker/app/bloc/app_config/app_config_cubit.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_data/app_data_cubit.dart';
import 'package:rice_tracker/app/extension/context_extension.dart';
import 'package:rice_tracker/app/theme/app_dimens.dart';
import 'package:rice_tracker/app/widgets/card_widget.dart';
import 'package:rice_tracker/app/widgets/no_something_yet_tile.dart';
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import '../../../app/constants/image_constant.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_color.dart';

class PurchaserList extends StatelessWidget {
  const PurchaserList({super.key, required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppDataCubit, AppDataState>(
      builder: (context, state) {
        if (state.data.purchaserList.isEmpty) {
          return NoSomethingYetTile(
            title: context.loc.noPeopleTitle,
            description: context.loc.noPeopleDescription,
          );
        }
        return ValueListenableBuilder(
          valueListenable: searchController,
          builder: (context, value, child) {
            List<PurchaserModel> purchaserList = state.data.purchaserList;
            if (value.text != '') {
              purchaserList = purchaserList
                  .where(
                    (e) => (e.name ?? '').toLowerCase().contains(
                      value.text.toLowerCase(),
                    ),
                  )
                  .toList();
            }
            // Group filtered purchasers by date
            final Map<String, List<PurchaserModel>> groups = {};
            for (final p in purchaserList) {
              final datePart = (p.dateAdded ?? '')
                  .split(' ')
                  .first; // dd/MM/yyyy
              groups.putIfAbsent(datePart, () => []).add(p);
            }

            final sortedKeys = groups.keys.toList()
              ..sort((a, b) => b.compareTo(a));

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
                          String headerLabel;
                          try {
                            final dt = DateFormat('dd/MM/yyyy').parse(dateKey);
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
                          } catch (_) {
                            headerLabel = dateKey;
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
                                      '${(purchaser.totalWeight ?? 0).toStringAsFixed(1)} kg',
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
                                onTap: () {
                                  context
                                      .push(
                                        AppRouter.purchaserDetails,
                                        extra: purchaser,
                                      )
                                      .then(
                                        (value) => searchController.clear(),
                                      );
                                },
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
