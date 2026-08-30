import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart' deferred as app_localizations_en;
import 'app_localizations_vi.dart' deferred as app_localizations_vi;

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Rice Tracker'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand total'**
  String get grandTotal;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'people'**
  String get people;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterNameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add new person'**
  String get enterNameDialogTitle;

  /// No description provided for @enterNameDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the name of the person to track their rice.'**
  String get enterNameDialogDescription;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editName;

  /// No description provided for @enterNewNameDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter a new name to replace the current one.'**
  String get enterNewNameDialogDescription;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name...'**
  String get enterName;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemDescription.
  ///
  /// In en, this message translates to:
  /// **'Once deleted, it can\'t be recovered.'**
  String get deleteItemDescription;

  /// No description provided for @enterAnAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount...'**
  String get enterAnAmount;

  /// No description provided for @bags.
  ///
  /// In en, this message translates to:
  /// **'bags'**
  String get bags;

  /// No description provided for @bag.
  ///
  /// In en, this message translates to:
  /// **'Bag'**
  String get bag;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @noPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'No one yet'**
  String get noPeopleTitle;

  /// No description provided for @noPeopleDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first person and track how much rice they bought.'**
  String get noPeopleDescription;

  /// No description provided for @noRiceBagTitle.
  ///
  /// In en, this message translates to:
  /// **'No rice bags yet'**
  String get noRiceBagTitle;

  /// No description provided for @noRiceBagDescription.
  ///
  /// In en, this message translates to:
  /// **'Start adding rice bags by entering the amount for each bag.'**
  String get noRiceBagDescription;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @warningRiceAmountDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount between 0 and 1000.'**
  String get warningRiceAmountDescription;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @deleteAllPurchaser.
  ///
  /// In en, this message translates to:
  /// **'Delete all purchasers'**
  String get deleteAllPurchaser;

  /// No description provided for @deleteAllPurchaserDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'This action will permanently delete all purchasers and cannot be undone.'**
  String get deleteAllPurchaserDialogDescription;

  /// No description provided for @deleteAllPurchaserConfirmHinText.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get deleteAllPurchaserConfirmHinText;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTime;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customRange;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select a date range'**
  String get selectDateRange;

  /// No description provided for @noPurchaserInPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this period'**
  String get noPurchaserInPeriodTitle;

  /// No description provided for @noPurchaserInPeriodDescription.
  ///
  /// In en, this message translates to:
  /// **'No one was added in the selected period. Try a different range or clear the filter.'**
  String get noPurchaserInPeriodDescription;

  /// No description provided for @noSearchResultTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching name'**
  String get noSearchResultTitle;

  /// No description provided for @noSearchResultDescription.
  ///
  /// In en, this message translates to:
  /// **'No one matches what you typed. Check the spelling, or clear the search to see everyone.'**
  String get noSearchResultDescription;

  /// No description provided for @storeUnreadableTitle.
  ///
  /// In en, this message translates to:
  /// **'Your saved records could not be opened'**
  String get storeUnreadableTitle;

  /// No description provided for @storeUnreadableDescription.
  ///
  /// In en, this message translates to:
  /// **'They have not been deleted, and a copy has been kept. Please back up this device and get help before adding anything new.'**
  String get storeUnreadableDescription;

  /// No description provided for @storePartialTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 record could not be read} other{{count} records could not be read}}'**
  String storePartialTitle(int count);

  /// No description provided for @storePartialDescription.
  ///
  /// In en, this message translates to:
  /// **'Everything else is shown below, so totals here are lower than they should be. A copy of the original has been kept.'**
  String get storePartialDescription;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return lookupAppLocalizations(locale);
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

Future<AppLocalizations> lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return app_localizations_en.loadLibrary().then(
        (dynamic _) => app_localizations_en.AppLocalizationsEn(),
      );
    case 'vi':
      return app_localizations_vi.loadLibrary().then(
        (dynamic _) => app_localizations_vi.AppLocalizationsVi(),
      );
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
