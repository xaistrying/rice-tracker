// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import 'package:rice_tracker/presentation/purchaser_details/components/app_bar_custom.dart';
import 'package:rice_tracker/presentation/purchaser_details/components/bag_list.dart';
import 'package:rice_tracker/presentation/purchaser_details/components/rice_input_with_stats.dart';
import 'package:rice_tracker/presentation/purchaser_details/cubit/selected_item_cubit.dart';
import '../../app/bloc/app_data/app_data_cubit.dart';
import '../../app/theme/app_dimens.dart';

class PurchaserDetailsScreen extends StatelessWidget {
  const PurchaserDetailsScreen({super.key, required this.purchaser});

  /// The purchaser as it was when this screen was pushed.
  ///
  /// Only its id is dependable: edits replace the model rather than mutating
  /// it, so this instance goes stale the moment a bag is added or the name is
  /// changed. [_livePurchaser] re-reads the current one from the cubit.
  final PurchaserModel purchaser;

  PurchaserModel _livePurchaser(AppDataState state) {
    final index = state.data.purchaserList.indexWhere(
      (e) => e.id == purchaser.id,
    );

    // Falls back to the pushed instance for the frame between deleting this
    // purchaser and the screen popping.
    return index == -1 ? purchaser : state.data.purchaserList[index];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectedItemCubit(),
      child: BlocBuilder<AppDataCubit, AppDataState>(
        builder: (context, state) {
          final live = _livePurchaser(state);

          return Scaffold(
            appBar: AppBarCustom(purchaser: live),
            body: Column(
              spacing: AppDimens.padding16,
              children: [
                BagList(purchaser: live),
                RiceInputWithStats(purchaser: live),
              ],
            ),
          );
        },
      ),
    );
  }
}
