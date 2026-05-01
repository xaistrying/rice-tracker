// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../app/theme/app_color.dart';
import '../../app/theme/app_dimens.dart';

class PurchaserDetailsScreen extends StatelessWidget {
  const PurchaserDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: AppDimens.padding16,
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.padding16,
          ),
          scrolledUnderElevation: 0.0,

          leading: Padding(
            padding: const EdgeInsets.only(
              left: AppDimens.padding16,
              top: AppDimens.padding8,
              bottom: AppDimens.padding8,
              right: 0.0,
            ),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
              highlightColor: AppColor.primary,
              hoverColor: AppColor.selectionColor,
              child: Container(
                padding: const EdgeInsets.all(AppDimens.padding8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
                ),
                child: Icon(Icons.arrow_back_rounded, color: AppColor.black),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
