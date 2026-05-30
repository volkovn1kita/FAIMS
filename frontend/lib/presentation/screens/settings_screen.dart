import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:faims/l10n/app_localizations.dart';
import 'package:faims/presentation/providers/locale_provider.dart';
import 'package:faims/presentation/providers/theme_provider.dart';
import 'package:faims/core/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../data/services/auth_api_service.dart';
import '../../domain/repositories/auth_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _notifKey = 'notifications_enabled';

  bool _notificationsEnabled = true;
  bool _isTogglingNotifications = false;

  final _authRepository = AuthRepository();
  final _apiService = AuthApiService();

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool(_notifKey) ?? true;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (_isTogglingNotifications) return;
    setState(() => _isTogglingNotifications = true);

    try {
      final token = await _authRepository.getToken();
      if (token == null) return;

      if (value) {
        // Enable: get FCM token and register it on the server
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await _apiService.updateFcmToken(token, fcmToken);
        }
      } else {
        // Disable: send empty string → backend treats it as null → no notifications
        await _apiService.updateFcmToken(token, '');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notifKey, value);
      if (mounted) setState(() => _notificationsEnabled = value);
    } catch (e) {
      developer.log('Error toggling notifications: $e', name: 'SettingsScreen');
    } finally {
      if (mounted) setState(() => _isTogglingNotifications = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: theme.appBarTheme.backgroundColor,
            padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
            child: Text(
              l10n.settings,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Appearance ───────────────────────────────────
                  _sectionLabel(l10n.appearance, theme),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.primaryLight.withValues(alpha: 0.15)
                                  : Colors.grey.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              color: isDark ? AppTheme.primaryLight : Colors.amber.shade600,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              l10n.darkMode,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Switch.adaptive(
                            value: themeProvider.isDark,
                            activeThumbColor: AppTheme.primaryLight,
                            activeTrackColor: AppTheme.primaryLight.withValues(alpha: 0.4),
                            onChanged: (_) => themeProvider.toggleTheme(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Notifications ────────────────────────────────
                  _sectionLabel(l10n.notifications, theme),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _notificationsEnabled
                                  ? AppTheme.primary.withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _notificationsEnabled
                                  ? Icons.notifications_rounded
                                  : Icons.notifications_off_rounded,
                              color: _notificationsEnabled
                                  ? AppTheme.primary
                                  : Colors.grey.shade400,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              l10n.pushNotifications,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          _isTogglingNotifications
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppTheme.primary,
                                  ),
                                )
                              : Switch.adaptive(
                                  value: _notificationsEnabled,
                                  activeThumbColor: AppTheme.primaryLight,
                                  activeTrackColor: AppTheme.primaryLight.withValues(alpha: 0.4),
                                  onChanged: _toggleNotifications,
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Language ─────────────────────────────────────
                  _sectionLabel(l10n.languageLabel, theme),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildLanguageTile(
                          context: context,
                          title: 'Українська',
                          flag: '🇺🇦',
                          isSelected: localeProvider.locale?.languageCode == 'uk',
                          onTap: () => localeProvider.setLocale(const Locale('uk')),
                          isFirst: true,
                        ),
                        Divider(
                          height: 1, thickness: 1, indent: 20, endIndent: 20,
                          color: isDark ? Colors.grey.shade800 : const Color(0xFFEEEEEE),
                        ),
                        _buildLanguageTile(
                          context: context,
                          title: 'English',
                          flag: '🇬🇧',
                          isSelected: localeProvider.locale?.languageCode == 'en',
                          onTap: () => localeProvider.setLocale(const Locale('en')),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String title,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Text(flag, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.primary : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
