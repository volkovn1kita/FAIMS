import 'package:shared_preferences/shared_preferences.dart';

/// Stores and checks whether the user has accepted the Privacy Policy.
/// Version-based: if the policy changes, bump [currentVersion] to force re-consent.
class PrivacyConsentService {
  static const String _versionKey = 'privacy_policy_version';
  static const String _acceptedAtKey = 'privacy_policy_accepted_at';

  /// Bump this when the privacy policy text changes significantly.
  static const String currentVersion = '1.0';

  /// Returns true only if the user accepted the current version of the policy.
  Future<bool> isAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_versionKey) == currentVersion;
  }

  /// Persists consent with the current policy version and a timestamp.
  Future<void> accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_versionKey, currentVersion);
    await prefs.setString(_acceptedAtKey, DateTime.now().toIso8601String());
  }

  /// Clears consent — use to force re-consent after a policy update.
  Future<void> revoke() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_versionKey);
    await prefs.remove(_acceptedAtKey);
  }
}
