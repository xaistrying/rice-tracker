// Flutter imports:
import 'package:flutter/material.dart';
import 'package:rice_tracker/app/theme/app_dimens.dart';
import 'package:rice_tracker/presentation/home/components/floating_action_button_custom.dart';

// Project imports:
import 'package:rice_tracker/presentation/home/components/search_with_stats.dart';
import 'components/app_bar_custom.dart';
import 'components/purchaser_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(),
      floatingActionButton: FloatingActionButtonCustom(
        controller: nameController,
      ),
      body: Column(
        spacing: AppDimens.padding16,
        children: [
          SearchWithStats(),
          Expanded(child: PurchaserList()),
          SizedBox(),
        ],
      ),
    );
  }
}
