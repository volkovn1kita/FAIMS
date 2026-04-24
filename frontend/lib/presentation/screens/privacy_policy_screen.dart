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
          'Відхилити Політику?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: const Text(
          'Без прийняття Політики конфіденційності використання FAIMS неможливе. '
          'Ваші дані не будуть збережені.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Назад', style: TextStyle(color: AppTheme.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Вийти з додатку', style: TextStyle(color: Colors.red.shade600)),
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
              'Політика конфіденційності',
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
                          'Версія 1.0 · Дата набрання чинності: 24 квітня 2026 р.',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Будь ласка, ознайомтеся з цією Політикою конфіденційності перед використанням додатку. '
                          'Вона пояснює, які дані ми збираємо, як їх використовуємо та захищаємо.',
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
                    title: 'Які дані ми збираємо',
                    content: 'Ми збираємо та зберігаємо такі персональні дані:\n\n'
                        '• Прізвище, ім\'я та по батькові (ПІБ)\n'
                        '• Адреса електронної пошти (email)\n'
                        '• Хешований пароль (алгоритм BCrypt, cost factor 12)\n'
                        '• FCM-токен пристрою (для push-сповіщень про терміни придатності)\n'
                        '• Журнал операцій (дії в системі: додавання, використання, списання медикаментів)',
                  ),
                  const SizedBox(height: 12),

                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    number: '2',
                    title: 'Мета збору та обробки',
                    content: 'Зібрані дані використовуються виключно для:\n\n'
                        '• Ідентифікації та автентифікації користувача\n'
                        '• Надсилання push-сповіщень про термін придатності медикаментів\n'
                        '• Формування звітів і журналу операцій організації\n'
                        '• Розмежування доступу (ролі Адміністратор / Користувач)',
                  ),
                  const SizedBox(height: 12),

                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    number: '3',
                    title: 'Зберігання та захист даних',
                    content: '• Дані зберігаються на серверах DigitalOcean (Франкфурт, Німеччина, ЄС)\n'
                        '• Передача даних — виключно через HTTPS/TLS\n'
                        '• Токени авторизації — JWT з обмеженим терміном дії\n'
                        '• Термін зберігання персональних даних — 3 роки з моменту останньої активності\n'
                        '• Резервне копіювання здійснюється засобами DigitalOcean із шифруванням даних',
                  ),
                  const SizedBox(height: 12),

                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    number: '4',
                    title: 'Ваші права (GDPR / ЗУ «Про захист персональних даних»)',
                    content: 'Відповідно до чинного законодавства ви маєте право:\n\n'
                        '• Отримати копію своїх персональних даних\n'
                        '• Виправити неточні або застарілі дані\n'
                        '• Видалити свій акаунт та всі пов\'язані дані (право на забуття)\n'
                        '• Відкликати згоду на обробку в будь-який момент\n'
                        '• Подати скаргу до органу захисту персональних даних\n\n'
                        'Для видалення акаунту скористайтеся функцією «Видалити акаунт» '
                        'у розділі «Профіль → Небезпечна зона».',
                  ),
                  const SizedBox(height: 12),

                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    number: '5',
                    title: 'Передача даних третім особам',
                    content: 'Ваші дані не продаються і не передаються третім особам. '
                        'Виняток становлять технічні партнери, без яких робота сервісу неможлива:\n\n'
                        '• Firebase (Google LLC) — доставка push-сповіщень\n'
                        '• DigitalOcean LLC — хмарне зберігання та хостинг (дата-центр у Франкфурті, ЄС)\n\n'
                        'Обидва партнери є сертифікованими операторами даних відповідно до стандартів GDPR.',
                  ),
                  const SizedBox(height: 12),

                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    number: '6',
                    title: 'Зміни до Політики',
                    content: 'У разі суттєвих змін до цієї Політики конфіденційності '
                        'ми сповістимо вас через додаток і попросимо підтвердити згоду повторно. '
                        'Подальше використання додатку після повідомлення означає прийняття оновленої Політики.',
                  ),
                  const SizedBox(height: 12),

                  _buildSection(
                    theme: theme,
                    isDark: isDark,
                    number: '7',
                    title: 'Контактна інформація',
                    content: 'З питань щодо захисту персональних даних або для реалізації '
                        'ваших прав звертайтеся:\n\n'
                        'Email: volkovn936@gmail.com\n'
                        'Сайт: github.com/volkovn1kita/FAIMS',
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
                            'Я прочитав та погоджуюсь з Політикою конфіденційності FAIMS',
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
                            'Продовжити',
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
                    'Відхилити та вийти',
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
