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
import '../../app/theme/app_dimens.dart';

class PurchaserDetailsScreen extends StatelessWidget {
  const PurchaserDetailsScreen({super.key, required this.purchaser});

  final PurchaserModel purchaser;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectedItemCubit(),
      child: Scaffold(
        appBar: AppBarCustom(purchaser: purchaser),
        body: Column(
          spacing: AppDimens.padding16,
          children: [
            BagList(purchaser: purchaser),
            RiceInputWithStats(purchaser: purchaser),
          ],
        ),
      ),
    );
  }
}
