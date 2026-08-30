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
  String get grandTotal => 'Grand total';

  @override
  String get people => 'people';

  @override
  String get name => 'Name';

  @override
  String get enterNameDialogTitle => 'Add new person';

  @override
  String get enterNameDialogDescription =>
      'Enter the name of the person to track their rice.';

  @override
  String get editName => 'Edit name';

  @override
  String get enterNewNameDialogDescription =>
      'Enter a new name to replace the current one.';

  @override
  String get enterName => 'Enter name...';

  @override
  String get deleteItemTitle => 'Delete this item?';

  @override
  String get deleteItemDescription => 'Once deleted, it can\'t be recovered.';

  @override
  String get enterAnAmount => 'Enter an amount...';

  @override
  String get bags => 'bags';

  @override
  String get bag => 'Bag';

  @override
  String get weight => 'Weight';

  @override
  String get noPeopleTitle => 'No one yet';

  @override
  String get noPeopleDescription =>
      'Tap + to add your first person and track how much rice they bought.';

  @override
  String get noRiceBagTitle => 'No rice bags yet';

  @override
  String get noRiceBagDescription =>
      'Start adding rice bags by entering the amount for each bag.';

  @override
  String get search => 'Search';

  @override
  String get warning => 'Warning';

  @override
  String get warningRiceAmountDescription =>
      'Please enter an amount between 0 and 1000.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get deleteAllPurchaser => 'Delete all purchasers';

  @override
  String get deleteAllPurchaserDialogDescription =>
      'This action will permanently delete all purchasers and cannot be undone.';

  @override
  String get deleteAllPurchaserConfirmHinText => 'Type DELETE to confirm';

  @override
  String get allTime => 'All';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get customRange => 'Custom';

  @override
  String get selectDateRange => 'Select a date range';

  @override
  String get noPurchaserInPeriodTitle => 'Nothing in this period';

  @override
  String get noPurchaserInPeriodDescription =>
      'No one was added in the selected period. Try a different range or clear the filter.';
}
