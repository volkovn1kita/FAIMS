import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:faims/core/app_theme.dart';
import 'package:faims/utils/privacy_consent_service.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _agreed = false;
  bool _isSaving = false;
  final _scrollController = ScrollController();
  final _consentService = PrivacyConsentService();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleAccept() async {
    if (!_agreed || _isSaving) return;
    setState(() => _isSaving = true);
    await _consentService.accept();
    if (mounted) context.go('/login');
  }

  Future<void> _handleDecline() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Decline Policy?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: const Text(
          'Without accepting the Privacy Policy, FAIMS cannot be used. '
          'Your data will not be saved.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Back', style: TextStyle(color: AppTheme.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Exit app', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield_outlined, color: AppTheme.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Scrollable policy content ────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FAIMS — First Aid Inventory Management System',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version 1.1 · Effective date: May 14, 2026',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Please read this Privacy Policy before using the app. '
                          'It explains what data we collect, how we use it, and how we protect it.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Policy sections
                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    number: '1',
                    title: 'What data we collect',
                    content: 'We collect and store the following personal data:\n\n'
                        '• Full name\n'
                        '• Email address\n'
                        '• Hashed password (BCrypt algorithm, cost factor 12)\n'
                        '• FCM device token (for push notifications about medication expiry)\n'
                        '• Operation log (actions in the system: adding, using, writing off medications)',
                  ),
                  const SizedBox(height: 12),

                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    number: '2',
                    title: 'Purpose of collection and processing',
                    content: 'Collected data is used exclusively for:\n\n'
                        '• User identification and authentication\n'
                        '• Sending push notifications about medication expiry dates\n'
                        '• Generating reports and the organization\'s operation log\n'
                        '• Role-based access control (Administrator / User)',
                  ),
                  const SizedBox(height: 12),

                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    number: '3',
                    title: 'Data storage and protection',
                    content: '• Data is stored on DigitalOcean servers (Frankfurt, Germany, EU)\n'
                        '• Data transmission is exclusively via HTTPS/TLS\n'
                        '• Authorization tokens are JWT with a limited lifetime\n'
                        '• Personal data retention period — 3 years from the last activity\n'
                        '• Backups are performed by DigitalOcean with data encryption',
                  ),
                  const SizedBox(height: 12),

                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    number: '4',
                    title: 'Your rights (GDPR)',
                    content: 'Under applicable law you have the right to:\n\n'
                        '• Obtain a copy of your personal data\n'
                        '• Correct inaccurate or outdated data\n'
                        '• Delete your account and all associated data (right to be forgotten)\n'
                        '• Withdraw consent for processing at any time\n'
                        '• Lodge a complaint with a data protection authority\n\n'
                        'To delete your account, use the "Delete account" option '
                        'in the "Profile → Danger Zone" section.',
                  ),
                  const SizedBox(height: 12),

                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    number: '5',
                    title: 'Sharing data with third parties',
                    content: 'Your data is not sold or transferred to third parties. '
                        'Exceptions are technical partners without whom the service cannot operate:\n\n'
                        '• Firebase (Google LLC) — push notification delivery\n'
                        '• DigitalOcean LLC — cloud storage and hosting (Frankfurt data centre, EU)\n\n'
                        'Both partners are certified data processors in accordance with GDPR standards.',
                  ),
                  const SizedBox(height: 12),

                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    number: '6',
                    title: 'Changes to this Policy',
                    content: 'In the event of material changes to this Privacy Policy, '
                        'we will notify you through the app and ask you to confirm your consent again. '
                        'Continued use of the app after the notification constitutes acceptance of the updated Policy.',
                  ),
                  const SizedBox(height: 12),

                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    number: '7',
                    title: 'Contact information',
                    content: 'For questions about personal data protection or to exercise '
                        'your rights, please contact us:\n\n'
                        'Email: volchonik634@gmail.com\n'
                        'Site: github.com/volkovn1kita/FAIMS',
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Sticky bottom: checkbox + buttons ───────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Checkbox row
                GestureDetector(
                  onTap: () => setState(() => _agreed = !_agreed),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _agreed
                          ? AppTheme.primary.withValues(alpha: 0.07)
                          : (isDark ? AppTheme.darkCard : Colors.grey.shade50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _agreed
                            ? AppTheme.primary.withValues(alpha: 0.4)
                            : theme.dividerColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreed,
                            onChanged: (v) => setState(() => _agreed = v ?? false),
                            activeColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'I have read and agree to the FAIMS Privacy Policy',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _agreed
                                  ? AppTheme.primary
                                  : theme.colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_agreed && !_isSaving) ? _handleAccept : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.3),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),

                // Decline link
                TextButton(
                  onPressed: _handleDecline,
                  child: Text(
                    'Decline and exit',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required bool isDark,
    required String number,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
