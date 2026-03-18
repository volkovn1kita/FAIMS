// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get analytics => 'Analytics';

  @override
  String get logout => 'Logout';

  @override
  String get faimsMenu => 'FAIMS MENU';

  @override
  String welcomeUser(Object userName) {
    return 'Welcome, $userName';
  }

  @override
  String get overview => 'Overview';

  @override
  String get shortcuts => 'Shortcuts';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get myFirstAidKit => 'My First Aid Kit';

  @override
  String get retry => 'Retry';

  @override
  String get notAssignedToKit => 'You are not assigned to any first aid kit.';

  @override
  String get userRoleUser => 'User';

  @override
  String get medications => 'Medications';

  @override
  String get items => 'items';

  @override
  String get add => 'Add';

  @override
  String get searchMedicationHint => 'Search medication by name...';

  @override
  String get expired => 'Expired';

  @override
  String get critical => 'Critical';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get noMedicationsYet => 'No medications yet';

  @override
  String get tapToAddMedication => 'Tap \'Add\' to add your first medication';

  @override
  String get noMedicationsFound => 'No medications found';

  @override
  String get adjustSearchFilters => 'Try adjusting your search filters';

  @override
  String get department => 'Department';

  @override
  String get room => 'Room';

  @override
  String get quantity => 'Quantity';

  @override
  String get expires => 'Expires';

  @override
  String get writeOff => 'Write Off';

  @override
  String get use => 'Use';

  @override
  String get cancel => 'Cancel';

  @override
  String get reasonRequired => 'Reason (required)';

  @override
  String get manageKits => 'Manage Kits';

  @override
  String get attention => 'Attention';

  @override
  String get manageUsers => 'Manage Users';

  @override
  String get departments => 'Departments';

  @override
  String get totalKits => 'Total Kits';

  @override
  String get kitsNeedingAttention => 'Kits Needing Attention';

  @override
  String get users => 'Users';

  @override
  String get minRequired => 'Min Required';

  @override
  String get statusWarning => 'Warning';

  @override
  String get statusGood => 'Good';

  @override
  String get lowStockWarning => '(Low!)';

  @override
  String useMedicationTitle(Object medicationName) {
    return 'Use $medicationName';
  }

  @override
  String get available => 'Available';

  @override
  String get quantityToUse => 'Quantity to use';

  @override
  String get enterValidQuantity => 'Please enter a valid quantity';

  @override
  String get notEnoughAvailable => 'Not enough medication available';

  @override
  String get medicationUsedSuccess => 'Medication used successfully!';

  @override
  String writeOffMedicationTitle(Object medicationName) {
    return 'Write Off $medicationName';
  }

  @override
  String get quantityToWriteOff => 'Quantity to write off';

  @override
  String get reasonHint => 'e.g., Damaged, Expired, Lost';

  @override
  String get reasonIsRequired => 'Reason is required';

  @override
  String get medicationWrittenOffSuccess =>
      'Medication written off successfully!';

  @override
  String get addNewMedication => 'Add New Medication';

  @override
  String get medicationName => 'Medication Name';

  @override
  String get minimumQuantity => 'Min. Quantity';

  @override
  String get unit => 'Unit';

  @override
  String get expirationDate => 'Expiration Date';

  @override
  String get enterMedicationName => 'Please enter medication name';

  @override
  String get medicationAddedSuccess => 'Medication added successfully!';

  @override
  String get editDepartment => 'Edit Department';

  @override
  String get addDepartment => 'Add Department';

  @override
  String get departmentName => 'Department Name';

  @override
  String get enterDepartmentNameHint => 'Enter department name';

  @override
  String get departmentNameValidator => 'Please enter a department name';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get departmentUpdatedSuccess => 'Department updated successfully!';

  @override
  String get departmentAddedSuccess => 'Department added successfully!';

  @override
  String failedToSaveDepartment(Object error) {
    return 'Failed to save department: $error';
  }

  @override
  String get editKitTitle => 'Edit Kit';

  @override
  String get addKitTitle => 'Add New Kit';

  @override
  String get kitDetails => 'Kit details';

  @override
  String get kitName => 'Kit Name';

  @override
  String get kitNameHint => 'e.g., Kit No. 1 or Operating Room Kit';

  @override
  String get kitNameRequired => 'Kit Name is required';

  @override
  String get kitNameMinChars => 'Min 3 characters';

  @override
  String get kitNameHelper => 'Min 3 - Max 50 characters';

  @override
  String get uniqueNumber => 'Unique Number';

  @override
  String get uniqueNumberHelper => 'Must be unique. Format: KIT-#######';

  @override
  String get autoGenerated => 'Auto-generated';

  @override
  String get uniqueNumberRegenerated => 'Unique Number regenerated!';

  @override
  String get uniqueNumberRequired => 'Unique Number is required';

  @override
  String get ownershipAndLocation => 'Ownership & location';

  @override
  String get selectDepartmentHint => 'Select department';

  @override
  String get departmentRequired => 'Department is required';

  @override
  String get roomLocation => 'Room/Location';

  @override
  String get roomHintPreselect => 'Select after choosing department';

  @override
  String get roomHintSelect => 'Select room';

  @override
  String get roomRequired => 'Room/Location is required';

  @override
  String get roomHelperPreselect => 'Select a department first';

  @override
  String get roomHelperOptions =>
      'Options are loaded based on selected department';

  @override
  String get responsiblePerson => 'Responsible Person';

  @override
  String get responsiblePersonHint => 'Choose employee';

  @override
  String get responsiblePersonRequired => 'Responsible Person is required';

  @override
  String get responsiblePersonHelper => 'From getResponsibleUsers()';

  @override
  String get fieldRequired => 'Required';

  @override
  String get fillAllFieldsError => 'Please fill in all required fields.';

  @override
  String get kitAddedSuccess => 'First aid kit successfully added!';

  @override
  String get kitUpdatedSuccess => 'First aid kit successfully updated!';

  @override
  String kitSaveError(Object error) {
    return 'Error saving first aid kit: $error';
  }

  @override
  String get deleteKitTitle => 'Delete Kit';

  @override
  String deleteKitConfirmation(Object name, Object number) {
    return 'Are you sure you want to delete kit \"$name\" ($number)?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get kitDeleteSuccess => 'Kit deleted successfully!';

  @override
  String kitDeleteError(Object error) {
    return 'Error deleting kit: $error';
  }

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get editMedication => 'Edit Medication';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get medicationCreateHint => 'e.g., Aspirin';

  @override
  String get selectUnit => 'Please select a unit';

  @override
  String get selectQuantityHint => 'e.g., 50';

  @override
  String get enterQuantity => 'Please enter quantity';

  @override
  String get quantityMustBeANumber => 'Quantity must be a number';

  @override
  String get quantityCannotBeNegative => 'Quantity cannot be negative';

  @override
  String get selectMinQuantityHint => 'e.g., 10';

  @override
  String get pleaseEnterMinimumQuantity => 'Please enter minimum quantity';

  @override
  String get minimumQuantityMustBeANonNegativeNumber =>
      'Minimum Quantity must be a non-negative number';

  @override
  String get selectExpirationDate => 'Please select expiration date';

  @override
  String get expirationDateCannotBeInThePastForNewMedications =>
      'Expiration date cannot be in the past for new medications';

  @override
  String get selectDepartment => 'Please select a department';

  @override
  String get roomUpdatedSuccessfully => 'Room updated successfully!';

  @override
  String get roomAddedSuccessfully => 'Room added successfully!';

  @override
  String get editRoom => 'Edit Room';

  @override
  String get addRoom => 'Add Room';

  @override
  String get roomName => 'Room Name';

  @override
  String get roomNameHint => 'Enter room name';

  @override
  String get roomNameMissError => 'Please enter a room name';

  @override
  String get editUser => 'Edit User';

  @override
  String get addNewUser => 'Add New User';

  @override
  String get firstName => 'First Name';

  @override
  String get enterFirstName => 'Please enter first name';

  @override
  String get lastName => 'Last Name';

  @override
  String get enterLastName => 'Please enter last name';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Please enter email';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get changePassword => 'Change Password (optional)';

  @override
  String get password => 'Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get enterPassword => 'Please enter password';

  @override
  String get passwordLenghtHint => 'Password must be at least 6 characters';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get confirmPassword => 'Please confirm your password';

  @override
  String get passwordDoNotMatch => 'Passwords do not match';

  @override
  String get role => 'Role';

  @override
  String get selectRole => 'Please select a role';

  @override
  String get createUser => 'Create User';

  @override
  String get noDataAvailableYet => 'No data available yet';

  @override
  String get mostExpiredORwrittenOff => 'Most Expired / Written Off';

  @override
  String get mostUsedMedications => 'Most Used Medications';

  @override
  String get globalAnalytics => 'Global Analytics';

  @override
  String departmentRooms(Object departmentName) {
    return '$departmentName Rooms';
  }

  @override
  String get addNewRoom => 'Add New Room';

  @override
  String get noRoomsFound => 'No rooms found for this department. Add one now!';

  @override
  String get deleteRoom => 'Delete Room';

  @override
  String cannotDeleteKit(Object kitName) {
    return 'Cannot delete \"$kitName\" because it still contains medications. Please remove all medications first.';
  }

  @override
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String confirmDeleteFirstAidKit(Object kitName) {
    return 'Are you sure you want to delete this first aid kit: \"$kitName\"? This action cannot be undone.';
  }

  @override
  String get firstAidKitDeletedSuccessfully =>
      'First aid kit deleted successfully!';

  @override
  String firstAidKitDeleteAlert(Object medicationName) {
    return 'Are you sure you want to delete \"$medicationName\"? This action cannot be undone.';
  }

  @override
  String get medicationDeletedSuccessfully =>
      'Medication deleted successfully!';

  @override
  String get kitsContent => 'Kit Contents';

  @override
  String get kitDetailsNotFound => 'Kit details not found';

  @override
  String get medication => 'Medication';

  @override
  String get noMedicationsFoundInThisKit => 'No medications found in this kit.';

  @override
  String quantityIsGreaterThan0Erorr(Object medicationName) {
    return 'Cannot delete \"$medicationName\" because its quantity is greater than 0. Please set quantity to 0 first to delete.';
  }

  @override
  String get enterEmailAndPassword => 'Please enter email and password';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInLabel => 'Sign in to manage kits, medications and alerts';

  @override
  String get processing => 'Processing';

  @override
  String get login => 'Login';

  @override
  String get cannotDeleteDepartmentWithExistingRooms =>
      'Cannot delete department with existing rooms. Please delete rooms first.';

  @override
  String get deleteDepartmentAlert =>
      'Are you sure you want to delete this department? This action cannot be undone.';

  @override
  String get departmentDeletedSuccessfully =>
      'Department deleted successfully!';

  @override
  String get manageDepartments => 'Manage Departments';

  @override
  String get addNewDepartment => 'Add New Department';

  @override
  String get noDepartmentsFound => 'No departments found. Add one now!';

  @override
  String get deleteDepartment => 'Delete Department';

  @override
  String cannotDeleteKitBecauseIsNotEmpty(
    Object kitName,
    Object medicationsLength,
  ) {
    return 'Cannot delete \"$kitName\" because it still contains \"$medicationsLength\" medication(s). Please remove all medications first.';
  }

  @override
  String get deleteFirstAidKit => 'Delete First Aid Kit';

  @override
  String deleteKitAlert(Object kitName) {
    return 'Are you sure you want to delete the kit \"$kitName\"? This action cannot be undone.';
  }

  @override
  String kitDeleteSuccessfully(Object kitName) {
    return 'Kit \"$kitName\" deleted successfully!';
  }

  @override
  String get errorCheckingMedicationsForKit =>
      'Error checking medications for kit';

  @override
  String get deletionError => 'Deletion error';

  @override
  String get needsAttention => 'Needs Attention';

  @override
  String get searchKitsByNameOrID => 'Search kits by name or ID';

  @override
  String get status => 'Status';

  @override
  String get responsible => 'Responsible';

  @override
  String get noKitsFoundMatchingYourCriteria =>
      'No kits found matching your criteria.';

  @override
  String get uniqueID => 'Unique ID';

  @override
  String get deleteUserAlert =>
      'Are you sure you want to delete this user? This action cannot be undone.';

  @override
  String get searchByNameOrEmail => 'Search by name or email';

  @override
  String get filterByRole => 'Filter by Role';

  @override
  String get any => 'Any';

  @override
  String get addUser => 'Add User';

  @override
  String get sortByLastName => 'Sort by Last Name';

  @override
  String get noUsersFoundMatchingYourCriteria =>
      'No users found matching your criteria.';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get newPassAndConfirmPassDoNotMatch =>
      'New password and confirm password do not match.';

  @override
  String get failedToGetAvatar => 'Failed to get avatar URL after upload.';

  @override
  String get photoLibrary => 'Photo Library';

  @override
  String get removeAvatar => 'Remove Avatar';

  @override
  String get myProfile => 'My Profile';

  @override
  String get addAvatar => 'Add Avatar';

  @override
  String get changeAvatar => 'Change Avatar';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get firstNameCannotBeEmpty => 'First name cannot be empty';

  @override
  String get lastNameCannotBeEmpty => 'Last name cannot be empty';

  @override
  String get emailCannotBeEmpty => 'Email cannot be empty';

  @override
  String get camera => 'Camera';
}
