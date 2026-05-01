import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/constants/image_constant.dart';
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/widgets/dialog_widget.dart';

class FloatingActionButtonCustom extends StatelessWidget {
  const FloatingActionButtonCustom({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) => DialogWidget(
            title: 'Add New Person',
            body: Column(
              children: [
                Text(
                  'Enter the name of the person to track their rice.',
                  style: TextStyle(
                    fontSize: AppDimens.fontSizeDefault,
                    color: AppColor.foreground,
                  ),
                ),
                SizedBox(height: AppDimens.padding12),
                Align(
                  alignment: AlignmentGeometry.centerLeft,
                  child: Text(
                    'Name',
                    style: TextStyle(
                      fontSize: AppDimens.fontSizeDefault,
                      fontWeight: FontWeight.bold,
                      color: AppColor.black,
                    ),
                  ),
                ),
                TextFormField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: AppDimens.fontSizeDefault,
                    color: AppColor.black,
                  ),
                  decoration: InputDecoration(
                    hint: Text(
                      'Enter name...',
                      style: TextStyle(
                        fontSize: AppDimens.fontSizeDefault,
                        color: AppColor.foreground,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.borderRadius8,
                      ),
                      borderSide: BorderSide(color: AppColor.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.borderRadius8,
                      ),
                      borderSide: BorderSide(color: AppColor.primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: AppColor.primary,
        shape: CircleBorder(),

        elevation: 1,
        highlightElevation: 0,
        hoverElevation: 0,
        disabledElevation: 1,

        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: SvgPicture.asset(
          ImageConstant.add,
          colorFilter: const ColorFilter.mode(
            AppColor.foreground,
            BlendMode.srcIn,
          ),
          height: AppDimens.iconSize20,
        ),
      ),
    );
  }
}
