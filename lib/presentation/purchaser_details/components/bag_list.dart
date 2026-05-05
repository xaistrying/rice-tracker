// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:rice_tracker/app/theme/app_dimens.dart';
import 'package:rice_tracker/presentation/purchaser_details/cubit/selected_item_cubit.dart';
import '../../../app/bloc/app_data/app_data_cubit.dart';
import '../../../app/constants/image_constant.dart';
import '../../../app/theme/app_color.dart';
import '../../../domain/models/bag_model.dart';
import '../../../domain/models/purchaser_model.dart';

class BagList extends StatelessWidget {
  const BagList({super.key, required this.purchaser});

  final PurchaserModel purchaser;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<AppDataCubit, AppDataState>(
        builder: (context, state) {
          final int numberOfBags =
              purchaser.quantity ?? purchaser.listOfRiceBagWeights?.length ?? 0;
          if (numberOfBags == 0) {
            return const SizedBox.shrink();
          }

          final int rows = (numberOfBags + 2) ~/ 3;
          return ListView.separated(
            itemCount: rows,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.padding16,
            ),
            itemBuilder: (context, rowIndex) {
              final int start = rowIndex * 3;
              return Row(
                spacing: AppDimens.padding8,
                children: List.generate(3, (colIndex) {
                  final int idx = start + colIndex;
                  if (idx >= numberOfBags) {
                    // empty slot to keep spacing
                    return const Expanded(child: SizedBox());
                  }

                  // safe access to BagModel weight
                  final List<BagModel> bags =
                      purchaser.listOfRiceBagWeights ?? [];
                  final double weight = idx < bags.length
                      ? (bags[idx].weight ?? 0.0)
                      : 0.0;

                  return Expanded(
                    child: BlocBuilder<SelectedItemCubit, SelectedItemState>(
                      builder: (context, state) {
                        return GestureDetector(
                          onTap: () {
                            context
                                .read<SelectedItemCubit>()
                                .updateSelectedItem(id: bags[idx].id);
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: AppColor.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimens.borderRadius8,
                                ),
                              ),
                              barrierColor: AppColor.barrierColor,
                              builder: (context) => Container(
                                width: double.maxFinite,
                                padding: const EdgeInsets.all(
                                  AppDimens.padding16,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: AppDimens.padding12,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Bag ${idx + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: AppDimens.fontSize16,
                                          color: AppColor.foreground,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppDimens.padding16,
                                        vertical: AppDimens.padding12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.border,
                                        border: Border.all(
                                          color: AppColor.grey,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppDimens.borderRadius8,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Weight:',
                                            style: const TextStyle(
                                              fontSize:
                                                  AppDimens.fontSizeDefault,
                                              color: AppColor.foreground,
                                            ),
                                          ),
                                          Spacer(),
                                          Text(
                                            '${weight.toStringAsFixed(1)} kg',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  AppDimens.fontSizeDefault,
                                              color: AppColor.foreground,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: IconButton(
                                        onPressed: () {
                                          context
                                              .read<AppDataCubit>()
                                              .removeBagFromPurchaser(
                                                purchaserId: purchaser.id,
                                                bagId: bags[idx].id,
                                              );
                                          context.pop();
                                        },
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppDimens.padding16,
                                            vertical: AppDimens.padding12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppDimens.borderRadius8,
                                            ),
                                          ),
                                          side: BorderSide(
                                            width: AppDimens.borderWidth1,
                                            color: AppColor.destructive,
                                          ),
                                          splashFactory: NoSplash.splashFactory,
                                          overlayColor: Colors.transparent,
                                        ),
                                        icon: SvgPicture.asset(
                                          ImageConstant.delete,
                                          colorFilter: const ColorFilter.mode(
                                            AppColor.destructive,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).then((_) {
                              if (context.mounted) {
                                context
                                    .read<SelectedItemCubit>()
                                    .updateSelectedItem(id: null);
                              }
                            });
                          },
                          child: BagItem(
                            weight: weight.toStringAsFixed(1),
                            isSelected:
                                state.data.selectedItemId == bags[idx].id,
                          ),
                        );
                      },
                    ),
                  );
                }),
              );
            },
            separatorBuilder: (context, index) =>
                SizedBox(height: AppDimens.padding8),
          );
        },
      ),
    );
  }
}

class BagItem extends StatelessWidget {
  const BagItem({super.key, required this.weight, this.isSelected = false});

  final String weight;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding16,
        vertical: AppDimens.padding12,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppColor.lightPrimary : AppColor.white,
        border: Border.all(
          color: isSelected ? AppColor.primary : AppColor.border,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              weight,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimens.fontSizeDefault,
                color: AppColor.foreground,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'kg',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppDimens.fontSizeDefault,
              color: AppColor.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
