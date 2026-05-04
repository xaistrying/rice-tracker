// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:rice_tracker/app/bloc/app_data/app_data_cubit.dart';
import 'package:rice_tracker/app/theme/app_dimens.dart';
import 'package:rice_tracker/app/widgets/card_widget.dart';
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
        return ValueListenableBuilder(
          valueListenable: searchController,
          builder: (context, value, child) {
            List<PurchaserModel> purchaserList = state.data.purchaserList;
            if (value.text != '') {
              purchaserList = purchaserList
                  .where((e) => (e.name ?? '').contains(value.text))
                  .toList();
            }
            return ListView.separated(
              itemCount: purchaserList.length,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.padding16,
              ),
              itemBuilder: (context, index) {
                final purchaser = purchaserList[index];
                return CardWidget(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppDimens.padding16,
                      vertical: AppDimens.padding12,
                    ),
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
                          '${purchaser.totalWeight ?? 0} kg',
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
                      context.push(
                        AppRouter.purchaserDetails,
                        extra: purchaser,
                      );
                      // searchController.clear();
                    },
                  ),
                );
              },
              separatorBuilder: (_, _) => SizedBox(height: AppDimens.padding16),
            );
          },
        );
      },
    );
  }
}
