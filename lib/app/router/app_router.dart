// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:rice_tracker/presentation/purchaser_details/purchaser_details_screen.dart';
import 'package:rice_tracker/presentation/settings/settings_screen.dart';
import '../../presentation/home/home_screen.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String settings = '/settings';
  static const String purchaserDetails = '/purchaserDetails';

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: home,
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: settings,
        builder: (context, state) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        path: purchaserDetails,
        builder: (context, state) {
          return const PurchaserDetailsScreen();
        },
      ),
    ],
  );

  static GoRouter get router => _router;
}
