// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:rice_tracker/app/extension/context_extension.dart';
import 'package:rice_tracker/app/theme/app_dimens.dart';
import 'package:rice_tracker/app/widgets/no_something_yet_tile.dart';
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
          final bags = purchaser.listOfRiceBagWeights ?? [];
          final int numberOfBags = bags.length;

          if (numberOfBags == 0) {
            return NoSomethingYetTile(
              title: context.loc.noRiceBagTitle,
              description: context.loc.noRiceBagDescription,
            );
          }

          final int rows = (numberOfBags + 2) ~/ 3;
          return ListView.separated(
            itemCount: rows,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.padding16,
            ),
            itemBuilder: (context, rowIndex) {
              final start = rowIndex * 3;
              return Row(
                spacing: AppDimens.padding8,
                children: List.generate(3, (colIndex) {
                  final idx = start + colIndex;
                  if (idx >= numberOfBags) {
                    return const Expanded(child: SizedBox());
                  }
                  return Expanded(
                    child: _buildBagCell(context, purchaser, bags, idx),
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

  Widget _buildBagCell(
    BuildContext context,
    PurchaserModel purchaser,
    List<BagModel> bags,
    int idx,
  ) {
    final bag = bags[idx];
    final weight = bag.weight ?? 0.0;

    return BlocBuilder<SelectedItemCubit, SelectedItemState>(
      builder: (context, selState) {
        final selectedId = selState.when(
          initialState: (d) => d.selectedItemId,
          updateSelectedItem: (d) => d.selectedItemId,
        );
        final isSelected = selectedId == bag.id;

        return GestureDetector(
          onTap: () {
            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
            context.read<SelectedItemCubit>().updateSelectedItem(id: bag.id);
            _showBagOptions(context, purchaser, bag, idx);
          },
          child: BagItem(
            weight: weight.toStringAsFixed(1),
            isSelected: isSelected,
            idx: idx,
          ),
        );
      },
    );
  }

  void _showBagOptions(
    BuildContext context,
    PurchaserModel purchaser,
    BagModel bag,
    int idx,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
      ),
      barrierColor: AppColor.barrierColor,
      builder: (context) => Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(AppDimens.padding16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppDimens.padding12,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                '${context.loc.bag} ${idx + 1}',
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
                border: Border.all(color: AppColor.grey),
                borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
              ),
              child: Row(
                children: [
                  Text(
                    '${context.loc.weight}:',
                    style: const TextStyle(
                      fontSize: AppDimens.fontSizeDefault,
                      color: AppColor.foreground,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${(bag.weight ?? 0.0).toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppDimens.fontSizeDefault,
                      color: AppColor.foreground,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.maxFinite,
              child: IconButton(
                onPressed: () {
                  context.read<AppDataCubit>().removeBagFromPurchaser(
                    purchaserId: purchaser.id,
                    bagId: bag.id,
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
        context.read<SelectedItemCubit>().updateSelectedItem(id: null);
      }
    });
  }
}

class BagItem extends StatelessWidget {
  const BagItem({
    super.key,
    required this.weight,
    this.isSelected = false,
    required this.idx,
  });

  final String weight;
  final bool isSelected;
  final int idx;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
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
        ),
        Positioned(
          top: 2,
          left: AppDimens.padding4,
          child: Text(
            '${idx + 1}',
            style: const TextStyle(
              fontSize: AppDimens.fontSizeSmall,
              color: AppColor.grey,
            ),
          ),
        ),
      ],
    );
  }
}
