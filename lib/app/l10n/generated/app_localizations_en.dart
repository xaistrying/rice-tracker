// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rice Tracker';

  @override
  String get settings => 'Settings';

  @override
  String get languages => 'Languages';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get add => 'Add';

  @override
  String get grandTotal => 'Grand Total';

  @override
  String get people => 'people';

  @override
  String get name => 'Name';

  @override
  String get enterNameDialogTitle => 'Add New Person';

  @override
  String get enterNameDialogDescription =>
      'Enter the name of the person to track their rice.';

  @override
  String get enterName => 'Enter name...';

  @override
  String get deleteItemTitle => 'Delete this item?';

  @override
  String get deleteItemDescription => 'Once deleted, it can’t be recovered.';

  @override
  String get enterAnAmount => 'Enter an amount...';
}
