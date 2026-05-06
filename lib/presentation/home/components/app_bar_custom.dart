// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:rice_tracker/app/router/app_router.dart';
import '../../../app/constants/image_constant.dart';
import '../../../app/extension/context_extension.dart';
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCustom({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0.0,

      titleSpacing: AppDimens.padding16,
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding16,
      ),

      leading: Container(
        margin: const EdgeInsets.only(
          left: AppDimens.padding16,
          top: AppDimens.padding8,
          bottom: AppDimens.padding8,
          right: 0.0,
        ),
        padding: const EdgeInsets.all(AppDimens.padding8),

        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
        ),

        child: SvgPicture.asset(
          ImageConstant.wheat,
          colorFilter: const ColorFilter.mode(
            AppColor.lightPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),

      title: Text(
        context.loc.appTitle,
        style: TextStyle(
          fontSize: AppDimens.fontSize20,
          fontWeight: FontWeight.bold,
        ),
      ),

      actions: [
        IconButton(
          onPressed: () => context.push(AppRouter.settings),
          highlightColor: AppColor.primary,
          hoverColor: AppColor.selectionColor,
          icon: SvgPicture.asset(
            ImageConstant.settings,
            colorFilter: const ColorFilter.mode(
              AppColor.black,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}
