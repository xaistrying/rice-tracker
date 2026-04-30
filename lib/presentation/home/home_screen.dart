// Flutter imports:
import 'package:flutter/material.dart';
import 'package:rice_tracker/app/theme/app_dimens.dart';

// Project imports:
import 'package:rice_tracker/presentation/home/components/search_with_stats.dart';
import 'components/app_bar_custom.dart';
import 'components/purchaser_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(),
      body: Column(
        spacing: AppDimens.padding16,
        children: [
          SearchWithStats(),
          Expanded(child: PurchaserList()),
        ],
      ),
    );
  }
}
