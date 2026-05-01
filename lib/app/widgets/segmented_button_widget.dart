// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';

class SegmentedButtonWidget extends StatelessWidget {
  const SegmentedButtonWidget({
    super.key,
    required this.values,
    this.onSelectionChanged,
    required this.selected,
  });

  final List<String> values;
  final Function(Set<String>)? onSelectionChanged;
  final Set<String> selected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: values.map((value) {
        String text = value;
        return ButtonSegment(
          value: value,
          label: Text(
            text,
            style: TextStyle(
              fontSize: AppDimens.fontSizeDefault,
              color: AppColor.black,
            ),
          ),
        );
      }).toList(),
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        padding: EdgeInsets.zero,
        selectedBackgroundColor: AppColor.primary,
        splashFactory: NoSplash.splashFactory,
        overlayColor: AppColor.selectionColor,
        visualDensity: const VisualDensity(
          horizontal: VisualDensity.minimumDensity,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadius4),
        ),
        side: BorderSide(color: AppColor.border, width: AppDimens.borderWidth1),
      ),
    );
  }
}
