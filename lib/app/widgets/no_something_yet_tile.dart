// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/svg.dart';

// Project imports:
import '../constants/image_constant.dart';
import '../theme/app_color.dart';
import '../theme/app_dimens.dart';

class NoSomethingYetTile extends StatelessWidget {
  const NoSomethingYetTile({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppDimens.padding20),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColor.border,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              ImageConstant.wheat,
              colorFilter: const ColorFilter.mode(
                AppColor.foreground,
                BlendMode.srcIn,
              ),
              height: AppDimens.iconSize28,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.padding8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppDimens.fontSize16,
            fontWeight: FontWeight.bold,
            color: AppColor.black,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding24),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppDimens.fontSizeDefault,
              color: AppColor.black,
            ),
          ),
        ),
      ],
    );
  }
}
