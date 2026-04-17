import 'package:faims/l10n/app_localizations.dart';

/// Maps raw backend error strings to localized user-friendly messages.
class ErrorMapper {
  static String map(dynamic error, AppLocalizations l10n) {
    final raw = error.toString().replaceAll('Exception: ', '').toLowerCase();

    // Room cannot be deleted — has a first aid kit assigned
    if (raw.contains('room') && raw.contains('first aid kit')) {
      return l10n.errorRoomHasKit;
    }

    // Department with this name already exists
    if ((raw.contains('department') || raw.contains('відділ')) &&
        raw.contains('already exists')) {
      return l10n.errorDepartmentAlreadyExists;
    }

    // Room with this name already exists
    if ((raw.contains('room') || raw.contains('кімнат')) &&
        raw.contains('already exists')) {
      return l10n.errorRoomAlreadyExists;
    }

    // Kit unique number already exists
    if (raw.contains('unique number') && raw.contains('already exists')) {
      return l10n.errorKitNumberAlreadyExists;
    }

    // Kit with this unique number already exists (second pattern)
    if (raw.contains('unique number is already exist')) {
      return l10n.errorKitNumberAlreadyExists;
    }

    // User email already exists
    if (raw.contains('user with email') && raw.contains('already exists')) {
      return l10n.errorEmailAlreadyExists;
    }

    // Only administrator cannot be deleted
    if (raw.contains('only administrator')) {
      return l10n.errorUserIsLastAdmin;
    }

    // Cannot assign admin as responsible person
    if (raw.contains('administrator cannot be assigned')) {
      return l10n.cannotAssignAdminAsResponsible;
    }

    // Incorrect old/current password
    if (raw.contains('incorrect old password')) {
      return l10n.errorIncorrectOldPassword;
    }

    // Old password required
    if (raw.contains('old password is required')) {
      return l10n.errorOldPasswordRequired;
    }

    // Kit still has medications
    if (raw.contains('left some medications')) {
      return l10n.cannotDeleteDepartmentWithExistingRooms; // reuse pattern or add specific
    }

    // Department still has rooms
    if (raw.contains('delete all rooms')) {
      return l10n.cannotDeleteDepartmentWithExistingRooms;
    }

    // Fallback: return generic error
    return l10n.errorGeneral;
  }
}
