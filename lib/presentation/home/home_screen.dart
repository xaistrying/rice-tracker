// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:rice_tracker/presentation/home/components/floating_action_button_custom.dart';
import 'package:rice_tracker/presentation/home/components/search_with_stats.dart';
import '../../app/bloc/app_data/app_data_cubit.dart';
import '../../domain/models/purchaser_filter.dart';
import 'components/app_bar_custom.dart';
import 'components/purchaser_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final nameController = TextEditingController();
  final searchController = TextEditingController();

  /// What the home list is narrowed by.
  ///
  /// Both the list and the stats above it read this one value, so they cannot
  /// disagree about what is being shown. The search text is mirrored into it
  /// from [searchController] so there is still a single source of truth.
  final filter = ValueNotifier(const PurchaserFilter());

  late final AppLifecycleListener _listener;

  void _updateIfNewDay() {
    if (!mounted) return;
    context.read<AppDataCubit>().updateIfNewDay();
  }

  void _syncQuery() {
    filter.value = filter.value.withQuery(searchController.text);
  }

  @override
  void initState() {
    super.initState();

    searchController.addListener(_syncQuery);

    // Only onResume: that is the point the user is looking at the list again.
    // The other callbacks fire on every step of the background/foreground
    // chain (inactive -> hidden -> paused, and back), so subscribing to all of
    // them ran this six times per app switch.
    _listener = AppLifecycleListener(onResume: _updateIfNewDay);
  }

  @override
  void dispose() {
    searchController.removeListener(_syncQuery);

    nameController.dispose();
    searchController.dispose();
    filter.dispose();

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
          SearchWithStats(searchController: searchController, filter: filter),
          Expanded(
            child: PurchaserList(
              searchController: searchController,
              filter: filter,
            ),
          ),
        ],
      ),
    );
  }
}
