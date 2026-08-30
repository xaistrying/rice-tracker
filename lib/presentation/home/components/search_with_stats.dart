// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_data/app_data_cubit.dart';
import '../../../app/constants/image_constant.dart';
import '../../../app/extension/context_extension.dart';
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../domain/models/purchaser_filter.dart';
import 'period_filter_chips.dart';

class SearchWithStats extends StatelessWidget {
  const SearchWithStats({
    super.key,
    required this.searchController,
    required this.filter,
  });

  final TextEditingController searchController;
  final ValueNotifier<PurchaserFilter> filter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(color: AppColor.card),
      child: Column(
        spacing: AppDimens.padding16,
        children: [
          // Search Bar
          SearchBar(
            controller: searchController,
            backgroundColor: const WidgetStatePropertyAll(AppColor.card),
            elevation: const WidgetStatePropertyAll(0),
            hintText: context.loc.search,
            hintStyle: WidgetStatePropertyAll(
              TextStyle(
                fontSize: AppDimens.fontSizeDefault,
                color: AppColor.grey,
              ),
            ),

            onTapOutside: (_) =>
                WidgetsBinding.instance.focusManager.primaryFocus?.unfocus(),

            leading: SvgPicture.asset(
              ImageConstant.search,
              colorFilter: const ColorFilter.mode(
                AppColor.black,
                BlendMode.srcIn,
              ),
            ),

            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: AppDimens.padding16),
            ),

            overlayColor: const WidgetStatePropertyAll(Colors.transparent),

            textStyle: WidgetStatePropertyAll(
              TextStyle(
                fontSize: AppDimens.fontSizeDefault,
                color: AppColor.black,
              ),
            ),

            trailing: [
              IconButton(
                onPressed: () => searchController.clear(),
                highlightColor: AppColor.primary,
                hoverColor: AppColor.selectionColor,
                icon: Icon(Icons.close_rounded),
              ),
            ],

            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
                side: const BorderSide(color: AppColor.border, width: 1.5),
              ),
            ),
          ),

          // Period filter
          PeriodFilterChips(filter: filter),

          // Stats
          BlocBuilder<AppDataCubit, AppDataState>(
            builder: (context, state) {
              final purchaserList = state.data.purchaserList;
              return ValueListenableBuilder(
                valueListenable: filter,
                builder: (context, activeFilter, child) {
                  final filterdPurchaserList = activeFilter.apply(
                    purchaserList,
                  );
                  // The total tracks what is on screen, so it stays consistent
                  // with the count beside it.
                  final totalWeights = filterdPurchaserList.fold(
                    0.0,
                    (previousValue, element) =>
                        previousValue + (element.totalWeight ?? 0.0),
                  );
                  return Row(
                    children: [
                      // Number of people
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: filterdPurchaserList.length.toString(),
                              style: TextStyle(
                                fontSize: AppDimens.fontSizeDefault,
                                color: AppColor.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' / ',
                              style: TextStyle(
                                fontSize: AppDimens.fontSizeDefault,
                                color: AppColor.black,
                              ),
                            ),
                            TextSpan(
                              text: purchaserList.length.toString(),
                              style: TextStyle(
                                fontSize: AppDimens.fontSizeDefault,
                                color: AppColor.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' ${context.loc.people}',
                              style: TextStyle(
                                fontSize: AppDimens.fontSizeDefault,
                                color: AppColor.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Spacer(),

                      // Grand Total
                      RichText(
                        maxLines: 1,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${context.loc.grandTotal}: ',
                              style: TextStyle(
                                fontSize: AppDimens.fontSizeDefault,
                                color: AppColor.black,
                              ),
                            ),
                            TextSpan(
                              text: '${totalWeights.toStringAsFixed(1)} kg',
                              style: TextStyle(
                                fontSize: AppDimens.fontSize16,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primary,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
