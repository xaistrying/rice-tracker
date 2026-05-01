// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../theme/app_color.dart';
import '../theme/app_dimens.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppDimens.padding16,
            vertical: AppDimens.padding12,
          ),
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
      ),
      child: child,
    );
  }
}
