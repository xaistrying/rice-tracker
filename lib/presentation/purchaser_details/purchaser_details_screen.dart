// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:

// Project imports:
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import 'package:rice_tracker/presentation/purchaser_details/components/app_bar_custom.dart';

class PurchaserDetailsScreen extends StatelessWidget {
  const PurchaserDetailsScreen({super.key, required this.purchaser});

  final PurchaserModel purchaser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(appBar: AppBarCustom(purchaser: purchaser)),
    );
  }
}
