// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../domain/models/tare_rate.dart';
import '../extension/context_extension.dart';
import '../theme/app_color.dart';
import '../theme/app_dimens.dart';
import 'text_form_field_widget.dart';

/// Keeps the kilograms box to a number with at most one decimal place.
///
/// A plain character filter is not enough: allowing '.' through one keystroke
/// at a time let '1.6.6' be typed, which parses as nothing, so the box sat
/// showing a figure that was not the rate in force. A shape check that
/// demanded a complete number would be worse — it would reject the '1.' that
/// exists halfway through typing '1.5' — so '1.' is allowed and a second point
/// is not.
class _OneDecimalPlace extends TextInputFormatter {
  const _OneDecimalPlace();

  static final _allowed = RegExp(r'^\d*\.?\d?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => _allowed.hasMatch(newValue.text) ? newValue : oldValue;
}

/// The tare rate as it is spoken: '[3] bags = [1] kg'.
///
/// Reports a change only once what is typed makes a usable rate. Every total on
/// the screen divides by the bags box, so clearing it to retype a digit must
/// not be seen as a rate of zero — the last good one stays in force until a new
/// one is complete, and an unusable box is written back when focus leaves it.
class TareRateFields extends StatefulWidget {
  const TareRateFields({
    super.key,
    required this.rate,
    required this.onChanged,
    this.fieldWidth = 54,
    this.enabled = true,
  });

  final TareRate rate;

  /// Called with a valid rate only, never with a half-typed one.
  final ValueChanged<TareRate> onChanged;

  final double fieldWidth;

  /// When false the rate is shown greyed and cannot be edited.
  ///
  /// Shown rather than removed, so that switching the deduction off does not
  /// change the height of what it sits in and shuffle the page around it.
  final bool enabled;

  @override
  State<TareRateFields> createState() => _TareRateFieldsState();
}

class _TareRateFieldsState extends State<TareRateFields> {
  late final TextEditingController _bags = TextEditingController(
    text: '${widget.rate.bags}',
  );
  late final TextEditingController _kg = TextEditingController(
    text: widget.rate.kgLabel,
  );

  final _bagsFocus = FocusNode();
  final _kgFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _bagsFocus.addListener(_restoreUnusableOnBlur);
    _kgFocus.addListener(_restoreUnusableOnBlur);
  }

  @override
  void didUpdateWidget(covariant TareRateFields oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.rate == oldWidget.rate) return;

    // Only for a change that came from somewhere else — the default being
    // edited in Settings, say. Rewriting a field while it is being typed in
    // would jump the cursor to the end mid-word.
    if (!_bagsFocus.hasFocus) _bags.text = '${widget.rate.bags}';
    if (!_kgFocus.hasFocus) _kg.text = widget.rate.kgLabel;
  }

  @override
  void dispose() {
    _bags.dispose();
    _kg.dispose();
    _bagsFocus.dispose();
    _kgFocus.dispose();
    super.dispose();
  }

  /// Puts the rate in force back into any box that was left unusable, so a
  /// field cleared and abandoned does not sit empty while the totals below it
  /// still deduct.
  void _restoreUnusableOnBlur() {
    if (!_bagsFocus.hasFocus && _parseBags() == null) {
      _bags.text = '${widget.rate.bags}';
    }
    if (!_kgFocus.hasFocus && _parseKgTenths() == null) {
      _kg.text = widget.rate.kgLabel;
    }
  }

  int? _parseBags() {
    final value = int.tryParse(_bags.text.trim());

    if (value == null || value < 1 || value > TareRate.maxBags) return null;

    return value;
  }

  int? _parseKgTenths() {
    final value = double.tryParse(_kg.text.trim());

    if (value == null) return null;

    final tenths = (value * 10).round();

    if (tenths < 1 || tenths > TareRate.maxKgTenths) return null;

    return tenths;
  }

  void _commit() {
    final bags = _parseBags();
    final kgTenths = _parseKgTenths();

    // Half-typed: keep the rate that is already in force.
    if (bags == null || kgTenths == null) return;

    final next = TareRate(bags: bags, kgTenths: kgTenths);

    if (next != widget.rate) widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final label = TextStyle(
      fontSize: AppDimens.fontSizeDefault,
      color: widget.enabled ? AppColor.foreground : AppColor.grey,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _field(_bags, _bagsFocus, digitsOnly: true),
        Text(' ${context.loc.bags}  =  ', style: label),
        _field(_kg, _kgFocus, digitsOnly: false),
        Text(' kg', style: label),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    FocusNode focus, {
    required bool digitsOnly,
  }) {
    return SizedBox(
      width: widget.fieldWidth,
      child: TextFormFieldWidget(
        controller: controller,
        focusNode: focus,
        enabled: widget.enabled,
        onChanged: (_) => _commit(),
        textAlign: TextAlign.center,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding4,
          vertical: AppDimens.padding8,
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: !digitsOnly),
        textInputAction: TextInputAction.done,
        inputFormatters: [
          if (digitsOnly)
            FilteringTextInputFormatter.digitsOnly
          else
            const _OneDecimalPlace(),
          LengthLimitingTextInputFormatter(5),
        ],
      ),
    );
  }
}
