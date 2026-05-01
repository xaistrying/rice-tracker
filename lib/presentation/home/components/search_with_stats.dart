// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import '../../../app/constants/image_constant.dart';
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';

class SearchWithStats extends StatelessWidget {
  const SearchWithStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.padding16),
      decoration: BoxDecoration(color: AppColor.card),
      child: Column(
        spacing: AppDimens.padding16,
        children: [
          SearchBar(
            backgroundColor: const WidgetStatePropertyAll(AppColor.card),
            elevation: const WidgetStatePropertyAll(0),

            leading: SvgPicture.asset(
              ImageConstant.search,
              colorFilter: const ColorFilter.mode(
                AppColor.black,
                BlendMode.srcIn,
              ),
            ),

            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: AppDimens.padding16),
            ),

            overlayColor: const WidgetStatePropertyAll(Colors.transparent),

            textStyle: WidgetStatePropertyAll(
              TextStyle(
                fontSize: AppDimens.fontSizeDefault,
                color: AppColor.black,
              ),
            ),

            trailing: [
              IconButton(
                onPressed: () {},
                highlightColor: AppColor.primary,
                hoverColor: AppColor.selectionColor,
                icon: Icon(Icons.close_rounded),
              ),
            ],

            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.borderRadius8),
                side: const BorderSide(color: AppColor.border, width: 1.5),
              ),
            ),
          ),
          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '5',
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeDefault,
                        color: AppColor.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' people',
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeDefault,
                        color: AppColor.black,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Grand Total: ',
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeDefault,
                        color: AppColor.black,
                      ),
                    ),
                    TextSpan(
                      text: '97 kg',
                      style: TextStyle(
                        fontSize: AppDimens.fontSize16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
