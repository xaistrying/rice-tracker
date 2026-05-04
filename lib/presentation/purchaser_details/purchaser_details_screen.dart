// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import 'package:rice_tracker/presentation/purchaser_details/components/app_bar_custom.dart';
import 'package:rice_tracker/presentation/purchaser_details/components/rice_input_with_stats.dart';
import '../../app/theme/app_dimens.dart';

class PurchaserDetailsScreen extends StatelessWidget {
  const PurchaserDetailsScreen({super.key, required this.purchaser});

  final PurchaserModel purchaser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBarCustom(purchaser: purchaser),
        body: Column(
          spacing: AppDimens.padding16,
          children: [
            Expanded(child: ListView()),
            RiceInputWithStats(purchaser: purchaser),
          ],
        ),
      ),
    );
  }
}
