import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('uk'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @faimsMenu.
  ///
  /// In en, this message translates to:
  /// **'FAIMS MENU'**
  String get faimsMenu;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {userName}'**
  String welcomeUser(Object userName);

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get shortcuts;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @myFirstAidKit.
  ///
  /// In en, this message translates to:
  /// **'My First Aid Kit'**
  String get myFirstAidKit;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @notAssignedToKit.
  ///
  /// In en, this message translates to:
  /// **'You are not assigned to any first aid kit.'**
  String get notAssignedToKit;

  /// No description provided for @userRoleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userRoleUser;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @searchMedicationHint.
  ///
  /// In en, this message translates to:
  /// **'Search medication by name...'**
  String get searchMedicationHint;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @noMedicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No medications yet'**
  String get noMedicationsYet;

  /// No description provided for @tapToAddMedication.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Add\' to add your first medication'**
  String get tapToAddMedication;

  /// No description provided for @noMedicationsFound.
  ///
  /// In en, this message translates to:
  /// **'No medications found'**
  String get noMedicationsFound;

  /// No description provided for @adjustSearchFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search filters'**
  String get adjustSearchFilters;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @writeOff.
  ///
  /// In en, this message translates to:
  /// **'Write Off'**
  String get writeOff;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Reason (required)'**
  String get reasonRequired;

  /// No description provided for @manageKits.
  ///
  /// In en, this message translates to:
  /// **'Manage Kits'**
  String get manageKits;

  /// No description provided for @attention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attention;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// No description provided for @departments.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get departments;

  /// No description provided for @totalKits.
  ///
  /// In en, this message translates to:
  /// **'Total Kits'**
  String get totalKits;

  /// No description provided for @kitsNeedingAttention.
  ///
  /// In en, this message translates to:
  /// **'Kits Needing Attention'**
  String get kitsNeedingAttention;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @minRequired.
  ///
  /// In en, this message translates to:
  /// **'Min Required'**
  String get minRequired;

  /// No description provided for @statusWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get statusWarning;

  /// No description provided for @statusGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get statusGood;

  /// No description provided for @lowStockWarning.
  ///
  /// In en, this message translates to:
  /// **'(Low!)'**
  String get lowStockWarning;

  /// No description provided for @useMedicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Use {medicationName}'**
  String useMedicationTitle(Object medicationName);

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @quantityToUse.
  ///
  /// In en, this message translates to:
  /// **'Quantity to use'**
  String get quantityToUse;

  /// No description provided for @enterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get enterValidQuantity;

  /// No description provided for @notEnoughAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not enough medication available'**
  String get notEnoughAvailable;

  /// No description provided for @medicationUsedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Medication used successfully!'**
  String get medicationUsedSuccess;

  /// No description provided for @writeOffMedicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Write Off {medicationName}'**
  String writeOffMedicationTitle(Object medicationName);

  /// No description provided for @quantityToWriteOff.
  ///
  /// In en, this message translates to:
  /// **'Quantity to write off'**
  String get quantityToWriteOff;

  /// No description provided for @reasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Damaged, Expired, Lost'**
  String get reasonHint;

  /// No description provided for @reasonIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Reason is required'**
  String get reasonIsRequired;

  /// No description provided for @medicationWrittenOffSuccess.
  ///
  /// In en, this message translates to:
  /// **'Medication written off successfully!'**
  String get medicationWrittenOffSuccess;

  /// No description provided for @addNewMedication.
  ///
  /// In en, this message translates to:
  /// **'Add New Medication'**
  String get addNewMedication;

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get medicationName;

  /// No description provided for @minimumQuantity.
  ///
  /// In en, this message translates to:
  /// **'Min. Quantity'**
  String get minimumQuantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @expirationDate.
  ///
  /// In en, this message translates to:
  /// **'Expiration Date'**
  String get expirationDate;

  /// No description provided for @enterMedicationName.
  ///
  /// In en, this message translates to:
  /// **'Please enter medication name'**
  String get enterMedicationName;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @fillAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get fillAllRequiredFields;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 6 characters.'**
  String get passwordMinLength;

  /// No description provided for @registrationError.
  ///
  /// In en, this message translates to:
  /// **'Registration error. Please check your connection.'**
  String get registrationError;

  /// No description provided for @registerClinicTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinic Registration'**
  String get registerClinicTitle;

  /// No description provided for @registerClinicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a workspace for your organization'**
  String get registerClinicSubtitle;

  /// No description provided for @organizationDataLabel.
  ///
  /// In en, this message translates to:
  /// **'ORGANIZATION DATA'**
  String get organizationDataLabel;

  /// No description provided for @clinicNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinic / Hospital Name *'**
  String get clinicNameLabel;

  /// No description provided for @clinicNameHint.
  ///
  /// In en, this message translates to:
  /// **'First City Hospital'**
  String get clinicNameHint;

  /// No description provided for @addressOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get addressOptionalLabel;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'1 Main St, Kyiv'**
  String get addressHint;

  /// No description provided for @adminDataLabel.
  ///
  /// In en, this message translates to:
  /// **'ADMINISTRATOR DATA'**
  String get adminDataLabel;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name *'**
  String get firstNameLabel;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'John'**
  String get firstNameHint;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name *'**
  String get lastNameLabel;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Doe'**
  String get lastNameHint;

  /// No description provided for @emailLoginLabel.
  ///
  /// In en, this message translates to:
  /// **'Email (Login) *'**
  String get emailLoginLabel;

  /// No description provided for @emailAdminHint.
  ///
  /// In en, this message translates to:
  /// **'admin@hospital.org'**
  String get emailAdminHint;

  /// No description provided for @passwordRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Password *'**
  String get passwordRequiredLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @createClinicButton.
  ///
  /// In en, this message translates to:
  /// **'Create Clinic'**
  String get createClinicButton;

  /// No description provided for @newClinicQuestion.
  ///
  /// In en, this message translates to:
  /// **'New clinic?'**
  String get newClinicQuestion;

  /// No description provided for @registerButtonText.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButtonText;

  /// No description provided for @medicationAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Medication added successfully!'**
  String get medicationAddedSuccess;

  /// No description provided for @editDepartment.
  ///
  /// In en, this message translates to:
  /// **'Edit Department'**
  String get editDepartment;

  /// No description provided for @addDepartment.
  ///
  /// In en, this message translates to:
  /// **'Add Department'**
  String get addDepartment;

  /// No description provided for @departmentName.
  ///
  /// In en, this message translates to:
  /// **'Department Name'**
  String get departmentName;

  /// No description provided for @newOrg.
  ///
  /// In en, this message translates to:
  /// **'New organization?'**
  String get newOrg;

  /// No description provided for @reportsAndLists.
  ///
  /// In en, this message translates to:
  /// **'Reports & Lists'**
  String get reportsAndLists;

  /// No description provided for @forPurchase.
  ///
  /// In en, this message translates to:
  /// **'For Purchase'**
  String get forPurchase;

  /// No description provided for @forDisposal.
  ///
  /// In en, this message translates to:
  /// **'For Disposal'**
  String get forDisposal;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @listIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'The list is empty'**
  String get listIsEmpty;

  /// No description provided for @pdfGenerationInProgress.
  ///
  /// In en, this message translates to:
  /// **'PDF Generation in progress...'**
  String get pdfGenerationInProgress;

  /// No description provided for @refill.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get refill;

  /// No description provided for @refillMedicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Refill: {name}'**
  String refillMedicationTitle(String name);

  /// No description provided for @newExpirationDate.
  ///
  /// In en, this message translates to:
  /// **'New expiration date'**
  String get newExpirationDate;

  /// No description provided for @medicationRefilledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Medication successfully refilled!'**
  String get medicationRefilledSuccess;

  /// No description provided for @forSelectedPeriod.
  ///
  /// In en, this message translates to:
  /// **'For selected period'**
  String get forSelectedPeriod;

  /// No description provided for @enterDepartmentNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter department name'**
  String get enterDepartmentNameHint;

  /// No description provided for @departmentNameValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter a department name'**
  String get departmentNameValidator;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @departmentUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Department updated successfully!'**
  String get departmentUpdatedSuccess;

  /// No description provided for @departmentAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Department added successfully!'**
  String get departmentAddedSuccess;

  /// No description provided for @failedToSaveDepartment.
  ///
  /// In en, this message translates to:
  /// **'Failed to save department: {error}'**
  String failedToSaveDepartment(Object error);

  /// No description provided for @editKitTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Kit'**
  String get editKitTitle;

  /// No description provided for @addKitTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Kit'**
  String get addKitTitle;

  /// No description provided for @kitDetails.
  ///
  /// In en, this message translates to:
  /// **'Kit details'**
  String get kitDetails;

  /// No description provided for @kitName.
  ///
  /// In en, this message translates to:
  /// **'Kit Name'**
  String get kitName;

  /// No description provided for @kitNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Kit No. 1 or Operating Room Kit'**
  String get kitNameHint;

  /// No description provided for @kitNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Kit Name is required'**
  String get kitNameRequired;

  /// No description provided for @kitNameMinChars.
  ///
  /// In en, this message translates to:
  /// **'Min 3 characters'**
  String get kitNameMinChars;

  /// No description provided for @kitNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Min 3 - Max 50 characters'**
  String get kitNameHelper;

  /// No description provided for @uniqueNumber.
  ///
  /// In en, this message translates to:
  /// **'Unique Number'**
  String get uniqueNumber;

  /// No description provided for @uniqueNumberHelper.
  ///
  /// In en, this message translates to:
  /// **'Must be unique. Format: KIT-#######'**
  String get uniqueNumberHelper;

  /// No description provided for @autoGenerated.
  ///
  /// In en, this message translates to:
  /// **'Auto-generated'**
  String get autoGenerated;

  /// No description provided for @uniqueNumberRegenerated.
  ///
  /// In en, this message translates to:
  /// **'Unique Number regenerated!'**
  String get uniqueNumberRegenerated;

  /// No description provided for @uniqueNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Unique Number is required'**
  String get uniqueNumberRequired;

  /// No description provided for @ownershipAndLocation.
  ///
  /// In en, this message translates to:
  /// **'Ownership & location'**
  String get ownershipAndLocation;

  /// No description provided for @selectDepartmentHint.
  ///
  /// In en, this message translates to:
  /// **'Select department'**
  String get selectDepartmentHint;

  /// No description provided for @departmentRequired.
  ///
  /// In en, this message translates to:
  /// **'Department is required'**
  String get departmentRequired;

  /// No description provided for @roomLocation.
  ///
  /// In en, this message translates to:
  /// **'Room/Location'**
  String get roomLocation;

  /// No description provided for @roomHintPreselect.
  ///
  /// In en, this message translates to:
  /// **'Select after choosing department'**
  String get roomHintPreselect;

  /// No description provided for @roomHintSelect.
  ///
  /// In en, this message translates to:
  /// **'Select room'**
  String get roomHintSelect;

  /// No description provided for @roomRequired.
  ///
  /// In en, this message translates to:
  /// **'Room/Location is required'**
  String get roomRequired;

  /// No description provided for @roomHelperPreselect.
  ///
  /// In en, this message translates to:
  /// **'Select a department first'**
  String get roomHelperPreselect;

  /// No description provided for @roomHelperOptions.
  ///
  /// In en, this message translates to:
  /// **'Options are loaded based on selected department'**
  String get roomHelperOptions;

  /// No description provided for @responsiblePerson.
  ///
  /// In en, this message translates to:
  /// **'Responsible Person'**
  String get responsiblePerson;

  /// No description provided for @responsiblePersonHint.
  ///
  /// In en, this message translates to:
  /// **'Choose employee'**
  String get responsiblePersonHint;

  /// No description provided for @responsiblePersonRequired.
  ///
  /// In en, this message translates to:
  /// **'Responsible Person is required'**
  String get responsiblePersonRequired;

  /// No description provided for @responsiblePersonHelper.
  ///
  /// In en, this message translates to:
  /// **'From getResponsibleUsers()'**
  String get responsiblePersonHelper;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @fillAllFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get fillAllFieldsError;

  /// No description provided for @kitAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'First aid kit successfully added!'**
  String get kitAddedSuccess;

  /// No description provided for @kitUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'First aid kit successfully updated!'**
  String get kitUpdatedSuccess;

  /// No description provided for @kitSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving first aid kit: {error}'**
  String kitSaveError(Object error);

  /// No description provided for @deleteKitTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Kit'**
  String get deleteKitTitle;

  /// No description provided for @deleteKitConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete kit \"{name}\" ({number})?'**
  String deleteKitConfirmation(Object name, Object number);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @kitDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Kit deleted successfully!'**
  String get kitDeleteSuccess;

  /// No description provided for @kitDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting kit: {error}'**
  String kitDeleteError(Object error);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @editMedication.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get editMedication;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @medicationCreateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Aspirin'**
  String get medicationCreateHint;

  /// No description provided for @selectUnit.
  ///
  /// In en, this message translates to:
  /// **'Please select a unit'**
  String get selectUnit;

  /// No description provided for @selectQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 50'**
  String get selectQuantityHint;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter quantity'**
  String get enterQuantity;

  /// No description provided for @quantityMustBeANumber.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be a number'**
  String get quantityMustBeANumber;

  /// No description provided for @quantityCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Quantity cannot be negative'**
  String get quantityCannotBeNegative;

  /// No description provided for @selectMinQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 10'**
  String get selectMinQuantityHint;

  /// No description provided for @pleaseEnterMinimumQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter minimum quantity'**
  String get pleaseEnterMinimumQuantity;

  /// No description provided for @minimumQuantityMustBeANonNegativeNumber.
  ///
  /// In en, this message translates to:
  /// **'Minimum Quantity must be a non-negative number'**
  String get minimumQuantityMustBeANonNegativeNumber;

  /// No description provided for @selectExpirationDate.
  ///
  /// In en, this message translates to:
  /// **'Please select expiration date'**
  String get selectExpirationDate;

  /// No description provided for @expirationDateCannotBeInThePastForNewMedications.
  ///
  /// In en, this message translates to:
  /// **'Expiration date cannot be in the past for new medications'**
  String get expirationDateCannotBeInThePastForNewMedications;

  /// No description provided for @selectDepartment.
  ///
  /// In en, this message translates to:
  /// **'Please select a department'**
  String get selectDepartment;

  /// No description provided for @roomUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Room updated successfully!'**
  String get roomUpdatedSuccessfully;

  /// No description provided for @roomAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Room added successfully!'**
  String get roomAddedSuccessfully;

  /// No description provided for @editRoom.
  ///
  /// In en, this message translates to:
  /// **'Edit Room'**
  String get editRoom;

  /// No description provided for @addRoom.
  ///
  /// In en, this message translates to:
  /// **'Add Room'**
  String get addRoom;

  /// No description provided for @roomName.
  ///
  /// In en, this message translates to:
  /// **'Room Name'**
  String get roomName;

  /// No description provided for @roomNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter room name'**
  String get roomNameHint;

  /// No description provided for @roomNameMissError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a room name'**
  String get roomNameMissError;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @addNewUser.
  ///
  /// In en, this message translates to:
  /// **'Add New User'**
  String get addNewUser;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter first name'**
  String get enterFirstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter last name'**
  String get enterLastName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password (optional)'**
  String get changePassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get enterPassword;

  /// No description provided for @passwordLenghtHint.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLenghtHint;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPassword;

  /// No description provided for @passwordDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordDoNotMatch;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Please select a role'**
  String get selectRole;

  /// No description provided for @createUser.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get createUser;

  /// No description provided for @noDataAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'No data available yet'**
  String get noDataAvailableYet;

  /// No description provided for @mostExpiredORwrittenOff.
  ///
  /// In en, this message translates to:
  /// **'Most Expired / Written Off'**
  String get mostExpiredORwrittenOff;

  /// No description provided for @mostUsedMedications.
  ///
  /// In en, this message translates to:
  /// **'Most Used Medications'**
  String get mostUsedMedications;

  /// No description provided for @globalAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Global Analytics'**
  String get globalAnalytics;

  /// No description provided for @departmentRooms.
  ///
  /// In en, this message translates to:
  /// **'{departmentName} Rooms'**
  String departmentRooms(Object departmentName);

  /// No description provided for @addNewRoom.
  ///
  /// In en, this message translates to:
  /// **'Add New Room'**
  String get addNewRoom;

  /// No description provided for @noRoomsFound.
  ///
  /// In en, this message translates to:
  /// **'No rooms found for this department. Add one now!'**
  String get noRoomsFound;

  /// No description provided for @deleteRoom.
  ///
  /// In en, this message translates to:
  /// **'Delete Room'**
  String get deleteRoom;

  /// No description provided for @cannotDeleteKit.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete \"{kitName}\" because it still contains medications. Please remove all medications first.'**
  String cannotDeleteKit(Object kitName);

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @confirmDeleteFirstAidKit.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this first aid kit: \"{kitName}\"? This action cannot be undone.'**
  String confirmDeleteFirstAidKit(Object kitName);

  /// No description provided for @firstAidKitDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'First aid kit deleted successfully!'**
  String get firstAidKitDeletedSuccessfully;

  /// No description provided for @firstAidKitDeleteAlert.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{medicationName}\"? This action cannot be undone.'**
  String firstAidKitDeleteAlert(Object medicationName);

  /// No description provided for @medicationDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Medication deleted successfully!'**
  String get medicationDeletedSuccessfully;

  /// No description provided for @kitsContent.
  ///
  /// In en, this message translates to:
  /// **'Kit Contents'**
  String get kitsContent;

  /// No description provided for @kitDetailsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Kit details not found'**
  String get kitDetailsNotFound;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @noMedicationsFoundInThisKit.
  ///
  /// In en, this message translates to:
  /// **'No medications found in this kit.'**
  String get noMedicationsFoundInThisKit;

  /// No description provided for @quantityIsGreaterThan0Erorr.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete \"{medicationName}\" because its quantity is greater than 0. Please set quantity to 0 first to delete.'**
  String quantityIsGreaterThan0Erorr(Object medicationName);

  /// No description provided for @enterEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get enterEmailAndPassword;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInLabel.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage kits, medications and alerts'**
  String get signInLabel;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @cannotDeleteDepartmentWithExistingRooms.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete department with existing rooms. Please delete rooms first.'**
  String get cannotDeleteDepartmentWithExistingRooms;

  /// No description provided for @deleteDepartmentAlert.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this department? This action cannot be undone.'**
  String get deleteDepartmentAlert;

  /// No description provided for @departmentDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Department deleted successfully!'**
  String get departmentDeletedSuccessfully;

  /// No description provided for @manageDepartments.
  ///
  /// In en, this message translates to:
  /// **'Manage Departments'**
  String get manageDepartments;

  /// No description provided for @addNewDepartment.
  ///
  /// In en, this message translates to:
  /// **'Add New Department'**
  String get addNewDepartment;

  /// No description provided for @noDepartmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No departments found. Add one now!'**
  String get noDepartmentsFound;

  /// No description provided for @deleteDepartment.
  ///
  /// In en, this message translates to:
  /// **'Delete Department'**
  String get deleteDepartment;

  /// No description provided for @cannotDeleteKitBecauseIsNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete \"{kitName}\" because it still contains \"{medicationsLength}\" medication(s). Please remove all medications first.'**
  String cannotDeleteKitBecauseIsNotEmpty(
    Object kitName,
    Object medicationsLength,
  );

  /// No description provided for @deleteFirstAidKit.
  ///
  /// In en, this message translates to:
  /// **'Delete First Aid Kit'**
  String get deleteFirstAidKit;

  /// No description provided for @deleteKitAlert.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the kit \"{kitName}\"? This action cannot be undone.'**
  String deleteKitAlert(Object kitName);

  /// No description provided for @kitDeleteSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Kit \"{kitName}\" deleted successfully!'**
  String kitDeleteSuccessfully(Object kitName);

  /// No description provided for @errorCheckingMedicationsForKit.
  ///
  /// In en, this message translates to:
  /// **'Error checking medications for kit'**
  String get errorCheckingMedicationsForKit;

  /// No description provided for @deletionError.
  ///
  /// In en, this message translates to:
  /// **'Deletion error'**
  String get deletionError;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get needsAttention;

  /// No description provided for @searchKitsByNameOrID.
  ///
  /// In en, this message translates to:
  /// **'Search kits by name or ID'**
  String get searchKitsByNameOrID;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @responsible.
  ///
  /// In en, this message translates to:
  /// **'Responsible'**
  String get responsible;

  /// No description provided for @noKitsFoundMatchingYourCriteria.
  ///
  /// In en, this message translates to:
  /// **'No kits found matching your criteria.'**
  String get noKitsFoundMatchingYourCriteria;

  /// No description provided for @uniqueID.
  ///
  /// In en, this message translates to:
  /// **'Unique ID'**
  String get uniqueID;

  /// No description provided for @deleteUserAlert.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this user? This action cannot be undone.'**
  String get deleteUserAlert;

  /// No description provided for @searchByNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email'**
  String get searchByNameOrEmail;

  /// No description provided for @filterByRole.
  ///
  /// In en, this message translates to:
  /// **'Filter by Role'**
  String get filterByRole;

  /// No description provided for @any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @sortByLastName.
  ///
  /// In en, this message translates to:
  /// **'Sort by Last Name'**
  String get sortByLastName;

  /// No description provided for @noUsersFoundMatchingYourCriteria.
  ///
  /// In en, this message translates to:
  /// **'No users found matching your criteria.'**
  String get noUsersFoundMatchingYourCriteria;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @newPassAndConfirmPassDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New password and confirm password do not match.'**
  String get newPassAndConfirmPassDoNotMatch;

  /// No description provided for @failedToGetAvatar.
  ///
  /// In en, this message translates to:
  /// **'Failed to get avatar URL after upload.'**
  String get failedToGetAvatar;

  /// No description provided for @photoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get photoLibrary;

  /// No description provided for @removeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Remove Avatar'**
  String get removeAvatar;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @addAvatar.
  ///
  /// In en, this message translates to:
  /// **'Add Avatar'**
  String get addAvatar;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get changeAvatar;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @firstNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'First name cannot be empty'**
  String get firstNameCannotBeEmpty;

  /// No description provided for @lastNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Last name cannot be empty'**
  String get lastNameCannotBeEmpty;

  /// No description provided for @emailCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get emailCannotBeEmpty;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
