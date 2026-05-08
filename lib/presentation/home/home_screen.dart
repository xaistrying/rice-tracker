// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:rice_tracker/presentation/home/components/floating_action_button_custom.dart';
import 'package:rice_tracker/presentation/home/components/search_with_stats.dart';
import '../../app/bloc/app_data/app_data_cubit.dart';
import 'components/app_bar_custom.dart';
import 'components/purchaser_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final nameController = TextEditingController();
  final searchController = TextEditingController();

  late final AppLifecycleListener _listener;

  Future<void> _updateIfNewDay() async {
    context.read<AppDataCubit>().updateIfNewDay();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _listener = AppLifecycleListener(
      onRestart: _updateIfNewDay,
      onDetach: _updateIfNewDay,
      onPause: _updateIfNewDay,
      onInactive: _updateIfNewDay,
      onHide: _updateIfNewDay,
      onShow: _updateIfNewDay,
      onResume: _updateIfNewDay,
    );

    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    searchController.dispose();

    WidgetsBinding.instance.removeObserver(this);
    _listener.dispose();

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
        children: [
          SearchWithStats(searchController: searchController),
          Expanded(child: PurchaserList(searchController: searchController)),
        ],
      ),
    );
  }
}
